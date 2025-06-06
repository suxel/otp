%%
%% %CopyrightBegin%
%%
%% SPDX-License-Identifier: Apache-2.0
%%
%% Copyright Ericsson AB 2004-2025. All Rights Reserved.
%%
%% Licensed under the Apache License, Version 2.0 (the "License");
%% you may not use this file except in compliance with the License.
%% You may obtain a copy of the License at
%%
%%     http://www.apache.org/licenses/LICENSE-2.0
%%
%% Unless required by applicable law or agreed to in writing, software
%% distributed under the License is distributed on an "AS IS" BASIS,
%% WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
%% See the License for the specific language governing permissions and
%% limitations under the License.
%%
%% %CopyrightEnd%
%%

-module(httpc_request).
-moduledoc false.

-include_lib("inets/src/http_lib/http_internal.hrl").
-include("httpc_internal.hrl").

%%% Internal API
-export([send/3, is_idempotent/1, is_client_closing/1]).


%%%=========================================================================
%%%  Internal application API
%%%=========================================================================
%%-------------------------------------------------------------------------
%% send(MaybeProxy, Request) ->
%%      MaybeProxy - {Host, Port}
%%      Host = string()
%%      Port = integer()
%%	Request - #request{}
%%	Socket - socket()
%%      CookieSupport - enabled | disabled | verify
%%                                   
%% Description: Composes and sends a HTTP-request. 
%%-------------------------------------------------------------------------
send(SendAddr, #session{socket = Socket, socket_type = SocketType}, 
     #request{socket_opts = SocketOpts} = Request) 
  when is_list(SocketOpts) -> 
    case http_transport:setopts(SocketType, Socket, SocketOpts) of
	ok ->
	    send(SendAddr, Socket, SocketType, 
		 Request#request{socket_opts = undefined});
	{error, Reason} ->
	    {error, {setopts_failed, Reason}}
    end;
send(SendAddr, #session{socket = Socket, socket_type = SocketType}, Request) ->
    send(SendAddr, Socket, SocketType, Request).
    
send(SendAddr, Socket, SocketType,
     #request{method          = Method,
              path            = Path,
              pquery          = Query,
              headers         = Headers,
              content         = Content,
              address         = Address,
              abs_uri         = AbsUri,
              headers_as_is   = HeadersAsIs,
              settings        = HttpOptions,
              userinfo        = UserInfo,
              request_options = Options}) ->

    ?hcrt("send",
          [{send_addr,       SendAddr},
           {socket,          Socket},
           {method,          Method},
           {path,            Path},
           {pquery,          Query},
           {headers,         Headers},
           {content,         Content},
           {address,         Address},
           {abs_uri,         AbsUri},
           {headers_as_is,   HeadersAsIs},
           {settings,        HttpOptions},
           {userinfo,        UserInfo},
           {request_options, Options}]),

    TmpHdrs = handle_user_info(UserInfo, Headers),

    {TmpHdrs2, Body} = post_data(Method, TmpHdrs, Content, HeadersAsIs),
    
    {NewHeaders, Uri} = 
	case Address of
	    SendAddr ->
		{TmpHdrs2, Path ++ Query};
	    _Proxy when SocketType == ip_comm ->
		TmpHdrs3 = handle_proxy(HttpOptions, TmpHdrs2), 
		{TmpHdrs3, AbsUri};
	    _  ->
		{TmpHdrs2, Path ++ Query}	
	end,
    
    FinalHeaders = try
                       case NewHeaders of
                           HeaderList when is_list(HeaderList) ->
                               http_headers(HeaderList, []);
                           _  ->
                               http_request:http_headers(NewHeaders)
                       end
                   catch throw:{invalid_header, _} = Bad ->
                           {error, Bad}
                   end,
    case FinalHeaders of
        {error,_} = InvalidHeaders ->
            InvalidHeaders;
        _ ->
            Version = HttpOptions#http_options.version,
            do_send_body(SocketType, Socket, Method, Uri, Version, FinalHeaders, Body)
    end.

do_send_body(SocketType, Socket, Method, Uri, Version, Headers, 
	     {ProcessBody, Acc}) when is_function(ProcessBody, 1) ->
    ?hcrt("send", [{acc, Acc}]),
    case do_send_body(SocketType, Socket, Method, Uri, Version, Headers, []) of
        ok ->
            do_send_body(SocketType, Socket, ProcessBody, Acc);
        Error ->
            Error
    end;

do_send_body(SocketType, Socket, Method, Uri, Version, Headers, Body) ->
    ?hcrt("create message", [{body, Body}]),
    Message = [method(Method), " ", Uri, " ",
	       Version, ?CRLF, Headers, ?CRLF, Body],
    ?hcrd("send", [{message, Message}]),
    http_transport:send(SocketType, Socket, Message).


do_send_body(SocketType, Socket, ProcessBody, Acc) ->
    case ProcessBody(Acc) of
        eof ->
            ok;
        {ok, Data, NewAcc} ->
            case http_transport:send(SocketType, Socket, Data) of
                ok ->
                    do_send_body(SocketType, Socket, ProcessBody, NewAcc);
                Error ->
                    Error
            end
    end.


%%-------------------------------------------------------------------------
%% is_idempotent(Method) ->
%% Method = atom()
%%                                   
%% Description: Checks if Method is considered idempotent.
%%-------------------------------------------------------------------------

%% In particular, the convention has been established that the GET and
%% HEAD methods SHOULD NOT have the significance of taking an action
%% other than retrieval. These methods ought to be considered "safe".
is_idempotent(head) -> 
    true;
is_idempotent(get) ->
    true;
%% Methods can also have the property of "idempotence" in that (aside
%% from error or expiration issues) the side-effects of N > 0
%% identical requests is the same as for a single request.
is_idempotent(put) -> 
    true;
is_idempotent(delete) ->
    true;
%% Also, the methods OPTIONS and TRACE SHOULD NOT have side effects,
%% and so are inherently idempotent.
is_idempotent(trace) ->
    true;
is_idempotent(options) ->
    true;
is_idempotent(_) ->
    false.

%%-------------------------------------------------------------------------
%% is_client_closing(Headers) ->
%% Headers = #http_request_h{}
%%                                   
%% Description: Checks if the client has supplied a "Connection:
%% close" header.
%%-------------------------------------------------------------------------
is_client_closing(Headers) ->
    case Headers#http_request_h.connection of
	"close" ->
	    true;
	 _ ->
	    false
    end.

%%%========================================================================
%%% Internal functions
%%%========================================================================
post_data(Method, Headers, {ContentType, Body}, HeadersAsIs)
    when (Method =:= post)
         orelse (Method =:= put)
         orelse (Method =:= patch)
         orelse (Method =:= delete) ->
    NewBody = update_body(Headers, Body),
    NewHeaders = update_headers(Headers, ContentType, Body, HeadersAsIs),
    {NewHeaders, NewBody};

post_data(_, Headers, _, []) ->
    {Headers, ""};
post_data(_, _, _, HeadersAsIs = [_|_]) ->
    {HeadersAsIs, ""}.

update_body(Headers, Body) ->
    case Headers#http_request_h.expect of
        "100-continue" ->
            "";
        _ ->
            Body
    end.

update_headers(Headers, ContentType, Body, []) ->
    case Body of
        [] ->
            Headers1 = Headers#http_request_h{'content-length' = "0"},
            handle_content_type(Headers1, ContentType);
        <<>> ->
            Headers1 = Headers#http_request_h{'content-length' = "0"},
            handle_content_type(Headers1, ContentType);
        {Fun, _Acc} when is_function(Fun, 1) ->
            %% A client MUST NOT generate a 100-continue expectation in a request
            %% that does not include a message body. This implies that either the
            %% Content-Length or the Transfer-Encoding header MUST be present.
            %% DO NOT send content-type when Body is empty.
            Headers1 = Headers#http_request_h{'content-type' = ContentType},
            handle_transfer_encoding(Headers1);
        _ ->
            Headers#http_request_h{
              'content-length' = body_length(Body),
              'content-type' = ContentType}
    end;
update_headers(_, _, _, HeadersAsIs) ->
    HeadersAsIs.

handle_transfer_encoding(Headers = #http_request_h{'transfer-encoding' = undefined}) ->
    Headers;
handle_transfer_encoding(Headers) ->
    %% RFC7230 3.3.2
    %% A sender MUST NOT send a 'Content-Length' header field in any message
    %% that contains a 'Transfer-Encoding' header field.
    Headers#http_request_h{'content-length' = undefined}.

body_length(Body) when is_binary(Body) ->
   integer_to_list(byte_size(Body));

body_length(Body) when is_list(Body) ->
  integer_to_list(iolist_size(Body)).

%% Set 'Content-Type' when it is explicitly set.
handle_content_type(Headers, "") ->
    Headers;
handle_content_type(Headers, ContentType) ->
    Headers#http_request_h{'content-type' = ContentType}.

method(Method) ->
    http_util:to_upper(atom_to_list(Method)).

http_headers([], Headers) ->
    lists:flatten(Headers);
http_headers([{Key,Value} | Rest], Headers) ->
    Header = Key ++ ": " ++ Value ++ ?CRLF,
    http_headers(Rest, [Header | Headers]).

handle_proxy(_, Headers) when is_list(Headers) ->
    Headers; %% Headers as is option was specified
handle_proxy(HttpOptions, Headers) ->
    case HttpOptions#http_options.proxy_auth of
	undefined ->
	    Headers;
	{User, Password} ->
	    UserPasswd = base64:encode_to_string(User ++ ":" ++ Password),
	    Headers#http_request_h{'proxy-authorization' = 
				   "Basic " ++ UserPasswd}
    end.

handle_user_info([], Headers) ->
    Headers;
handle_user_info(UserInfo, Headers) ->
    case string:tokens(UserInfo, ":") of
	[User, Passwd] ->
	    UserPasswd = base64:encode_to_string(
	        uri_string:percent_decode(User) ++ ":" ++ uri_string:percent_decode(Passwd)
	    ),
	    Headers#http_request_h{authorization = "Basic " ++ UserPasswd};
	[User] ->
	    UserPasswd = base64:encode_to_string(uri_string:percent_decode(User) ++ ":"),
	    Headers#http_request_h{authorization = "Basic " ++ UserPasswd}; 
	_ ->
	    Headers
    end.
