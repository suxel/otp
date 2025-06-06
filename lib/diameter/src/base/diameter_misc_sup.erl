%%
%% %CopyrightBegin%
%%
%% SPDX-License-Identifier: Apache-2.0
%%
%% Copyright Ericsson AB 2010-2025. All Rights Reserved.
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

%%
%% The supervisor of the static server processes.
%%

-module(diameter_misc_sup).
-moduledoc false.

-behaviour(supervisor).

-export([start_link/0]).  %% supervisor start

%% supervisor callback
-export([init/1]).

-define(CHILDREN, [diameter_sync,      %% serialization
                   diameter_stats,     %% statistics counter management
                   diameter_reg,       %% service/property publishing
                   diameter_peer,      %% remote peer manager
                   diameter_dist,      %% request distribution
                   diameter_config]).  %% configuration/restart

%% start_link/0

start_link() ->
    SupName = {local, ?MODULE},
    supervisor:start_link(SupName, ?MODULE, []).

%% init/1

init([]) ->
    Flags = {one_for_one, 1, 5},
    Workers  = lists:map(fun spec/1, ?CHILDREN),
    {ok, {Flags, Workers}}.

spec(Mod) ->
    {Mod,
     {Mod, start_link, []},
     permanent,
     1000,
     worker,
     [Mod]}.
