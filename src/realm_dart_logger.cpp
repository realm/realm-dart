////////////////////////////////////////////////////////////////////////////////
//
// Copyright 2023 Realm Inc.
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

#include <sstream>
#include <set>
#include <mutex>
#include <thread>
#include <map>
#include <chrono>

#include "realm_dart_logger.h"
#include <realm/object-store/c_api/types.hpp>

auto& dart_logger_mutex = *new std::mutex;
bool is_core_logger_callback_set = false;
std::map<Dart_Port, realm_log_level_e> dart_send_ports;


bool isPortRegistered(Dart_Port key)
{
    return (dart_send_ports.find(key) != dart_send_ports.end());
}

RLM_API void realm_dart_release_logger(Dart_Port port) {
    std::lock_guard lock(dart_logger_mutex);
    if (isPortRegistered(port))
    {
        dart_send_ports.erase(port);
    }
}

bool send_message_to_scheduler(Dart_Port port, realm_log_level_e level, const char* message)
{
    Dart_CObject c_level;
    c_level.type = Dart_CObject_kInt32;
    c_level.value.as_int32 = level;

    Dart_CObject c_message;
    c_message.type = Dart_CObject_kString;
    c_message.value.as_string = (char*)message;

    Dart_CObject* c_request_arr[] = { &c_level , &c_message };
    Dart_CObject c_request;
    c_request.type = Dart_CObject_kArray;
    c_request.value.as_array.values = c_request_arr;
    c_request.value.as_array.length = sizeof(c_request_arr) / sizeof(c_request_arr[0]);

    bool result = Dart_PostCObject_DL(port, &c_request);
    return result;
}

void realm_dart_logger_callback(realm_userdata_t userData, realm_log_level_e level, const char* message) {
    std::lock_guard lock(dart_logger_mutex);

    for (auto itr = dart_send_ports.begin(); itr != dart_send_ports.end(); ++itr) {
        Dart_Port port = itr->first;
        bool result = send_message_to_scheduler(port, level, message);
    }
}

RLM_API bool realm_dart_init_default_logger() {
    std::lock_guard lock(dart_logger_mutex);
    if (is_core_logger_callback_set) {
        return false;
    }
    realm_set_log_callback(realm_dart_logger_callback, RLM_LOG_LEVEL_ALL, nullptr, nullptr);
    is_core_logger_callback_set = true;
    return true;
}

RLM_API void realm_dart_set_logger(realm_log_level_e level, Dart_Port port) {
    std::lock_guard lock(dart_logger_mutex);
    dart_send_ports[port] = level;
}

