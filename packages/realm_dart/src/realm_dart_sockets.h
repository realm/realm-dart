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

#include "realm/sync/socket_provider.hpp"
#include "realm_dart.h"
#include <realm.h>

typedef Dart_Handle (*realm_dart_sync_socket_connect_func_t)(realm_websocket_endpoint_t endpoint, realm::sync::WebSocketObserver* websocket_observer);

RLM_API realm_sync_socket_t * realm_dart_sync_socket_new(Dart_Handle managed_provider,
                           realm_scheduler_t *scheduler,
                           realm_dart_sync_socket_connect_func_t connect);