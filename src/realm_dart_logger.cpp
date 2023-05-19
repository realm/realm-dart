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
#include <algorithm>

#include "realm_dart_logger.h"

std::recursive_mutex dart_logger_mutex;
bool is_core_logger_callback_set = false;
std::map<Dart_Port, realm_log_level_e> dart_send_ports;
realm_log_level_e default_log_level;

realm_log_level_e calucale_minimum_log_level() {
    std::lock_guard<std::recursive_mutex> lock(dart_logger_mutex);
    auto min_element = std::min_element(dart_send_ports.begin(), dart_send_ports.end(),
        [](std::pair<Dart_Port, realm_log_level_e> const& prev, std::pair<Dart_Port, realm_log_level_e> const& next) {
        return prev.second < next.second;
    });
    return (min_element != dart_send_ports.end()) ? min_element->second : default_log_level;
}

RLM_API void realm_dart_release_logger(Dart_Port port) {
    std::lock_guard<std::recursive_mutex> lock(dart_logger_mutex); 
    if ((dart_send_ports.find(port) != dart_send_ports.end()))
    {
        dart_send_ports.erase(port);
        auto minimum_level = calucale_minimum_log_level();
        realm_set_log_level(minimum_level);
    }
}

bool send_message_to_scheduler(Dart_Port port, realm_log_level_e level, const char* message) {
    Dart_CObject c_level;
    c_level.type = Dart_CObject_kInt32;
    c_level.value.as_int32 = level;

    Dart_CObject c_message;
    c_message.type = Dart_CObject_kString;
    c_message.value.as_string = const_cast<char*>(message);

    Dart_CObject* c_request_arr[] = { &c_level , &c_message };
    Dart_CObject c_request;
    c_request.type = Dart_CObject_kArray;
    c_request.value.as_array.values = c_request_arr;
    c_request.value.as_array.length = sizeof(c_request_arr) / sizeof(c_request_arr[0]);

    return Dart_PostCObject_DL(port, &c_request);
}

void realm_dart_logger_callback(realm_userdata_t userData, realm_log_level_e level, const char* message) {
    std::lock_guard<std::recursive_mutex> lock(dart_logger_mutex);
    for (auto itr = dart_send_ports.begin(); itr != dart_send_ports.end(); ++itr) {
        Dart_Port port = itr->first;
        send_message_to_scheduler(port, level, message);
    }
}

RLM_API bool realm_dart_init_default_logger(realm_log_level_e level) {
    std::lock_guard<std::recursive_mutex> lock(dart_logger_mutex);
    if (is_core_logger_callback_set) {
        return false;
    }
    default_log_level = level;
    realm_set_log_callback(realm_dart_logger_callback, default_log_level, nullptr, nullptr);
    is_core_logger_callback_set = true;
    return true;
}

RLM_API void realm_dart_set_log_level(realm_log_level_e level, Dart_Port port) {
    std::lock_guard<std::recursive_mutex> lock(dart_logger_mutex);
    if (auto port_item = dart_send_ports.find(port); port_item == dart_send_ports.end() || port_item->second != level) {
        dart_send_ports[port] = level;
        auto minimum_level = calucale_minimum_log_level();
        realm_set_log_level(minimum_level);
    }
}

