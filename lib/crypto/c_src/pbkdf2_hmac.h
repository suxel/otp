/*
 * %CopyrightBegin%
 *
 * SPDX-License-Identifier: Apache-2.0
 *
 * Copyright Ericsson AB 2010-2025. All Rights Reserved.
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *     http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 *
 * %CopyrightEnd%
 */

#ifndef E_PBKDF2_HMAC_H__
#define E_PBKDF2_HMAC_H__ 1

#include "common.h"

ERL_NIF_TERM pbkdf2_hmac_nif(ErlNifEnv* env, int argc,
                             const ERL_NIF_TERM argv[]);

#endif /* E_PBKDF2_HMAC_H__ */
