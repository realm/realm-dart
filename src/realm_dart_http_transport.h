////////////////////////////////////////////////////////////////////////////////
//
// Copyright 2022 Realm Inc.
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

#ifndef REALM_DART_HTTP_TRANSPORT_H
#define REALM_DART_HTTP_TRANSPORT_H

#include "realm.h"
#include "dart_api_dl.h"

/**
 * Callback function used by Core to make a HTTP request.
 *
 * Complete the request by calling realm_dart_http_transport_complete_request(),
 * passing in the request_context pointer here and the received response.
 * Network request are expected to be asynchronous and can be completed on any thread.
 *
 * @param userdata The userdata pointer passed to realm_dart_http_transport_new().
 * @param request The request to send.
 * @param request_context Internal state pointer of Core, needed by realm_http_transport_complete_request().
 */
typedef void (*realm_dart_http_request_func_t)(Dart_Handle userdata, const realm_http_request_t request, void* request_context);

/**
 * Create a new HTTP transport with these callbacks implementing its functionality.
 *
 * This is a dart specific wrapper for realm_http_transport_new.
 */
RLM_API realm_http_transport_t* realm_dart_http_transport_new(realm_dart_http_request_func_t request_callback,
                                                              Dart_Handle userdata);

#endif