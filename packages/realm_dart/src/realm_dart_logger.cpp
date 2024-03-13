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
#include <realm/object-store/c_api/util.hpp>

#include "realm_dart_logger.h"

using namespace realm::util;

std::mutex dart_logger_mutex;
bool is_core_logger_callback_set = false;
std::set<Dart_Port> dart_send_ports;

RLM_API void realm_dart_detach_logger(Dart_Port port) {
    std::lock_guard<std::mutex> lock(dart_logger_mutex);
    dart_send_ports.erase(port);
}

RLM_API void realm_dart_attach_logger(Dart_Port port) {
    std::lock_guard<std::mutex> lock(dart_logger_mutex);
    dart_send_ports.insert(port);
}

bool send_message_to_scheduler(Dart_Port port, const char* category, realm_log_level_e level, const char* message) {
    Dart_CObject c_category;
    c_category.type = Dart_CObject_kString;
    c_category.value.as_string = const_cast<char*>(category);

    Dart_CObject c_level;
    c_level.type = Dart_CObject_kInt32;
    c_level.value.as_int32 = level;

    Dart_CObject c_message;
    c_message.type = Dart_CObject_kString;
    c_message.value.as_string = const_cast<char*>(message);

    Dart_CObject* c_request_arr[] = { &c_category, &c_level, &c_message };
    Dart_CObject c_request;
    c_request.type = Dart_CObject_kArray;
    c_request.value.as_array.values = c_request_arr;
    c_request.value.as_array.length = sizeof(c_request_arr) / sizeof(c_request_arr[0]);

    return Dart_PostCObject_DL(port, &c_request);
}

void realm_dart_logger_callback(realm_userdata_t userData, const char* category, realm_log_level_e level, const char* message) {
    std::lock_guard<std::mutex> lock(dart_logger_mutex);
    for (auto itr = dart_send_ports.begin(); itr != dart_send_ports.end(); ++itr) {
        Dart_Port port = *itr;
        send_message_to_scheduler(port, category, level, message);
    }
}

RLM_API bool realm_dart_init_core_logger(realm_log_level_e level) {
    std::lock_guard<std::mutex> lock(dart_logger_mutex);
    if (is_core_logger_callback_set) {
        return false;
    }

    realm_set_log_callback(realm_dart_logger_callback, level, nullptr, nullptr);
    is_core_logger_callback_set = true;

    return is_core_logger_callback_set;
}

RLM_API void realm_dart_log(realm_log_level_e level, const char* category, const char* message) {
    Logger::get_default_logger()->log(LogCategory::get_category(category), Logger::Level(level), message);
}