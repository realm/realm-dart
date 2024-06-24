////////////////////////////////////////////////////////////////////////////////
//
// Copyright 2024 Realm Inc.
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
// http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.
//
////////////////////////////////////////////////////////////////////////////////

#pragma once

#include <realm.h>
#include "realm_dart.h"

RLM_API realm_sync_socket_t* realm_dart_sync_socket_new(realm_userdata_t userdata,
                                                        realm_free_userdata_func_t userdata_free,
                                                        realm_scheduler_t* scheduler,
                                                        realm_sync_socket_post_func_t post_func,
                                                        realm_sync_socket_create_timer_func_t create_timer_func,
                                                        realm_sync_socket_timer_canceled_func_t cancel_timer_func,
                                                        realm_sync_socket_timer_free_func_t free_timer_func,
                                                        realm_sync_socket_connect_func_t websocket_connect_func,
                                                        realm_sync_socket_websocket_async_write_func_t websocket_write_func,
                                                        realm_sync_socket_websocket_free_func_t websocket_free_func);
