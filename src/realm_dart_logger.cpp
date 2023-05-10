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

class LoggerData {
public:
    LoggerData(Dart_Handle logger_handle, realm_log_func_t callback, realm_scheduler_t* scheduler, uint64_t isolateId)
        :user_logger_handle(Dart_NewPersistentHandle_DL(logger_handle)), user_callback(callback), user_scheduler(*scheduler), user_isolate_id(isolateId)
    {}

    ~LoggerData() {
        Dart_DeletePersistentHandle_DL(user_logger_handle);
        user_callback = nullptr;
    }

    Dart_PersistentHandle user_logger_handle;
    realm_log_func_t user_callback = nullptr;
    std::shared_ptr<realm::util::Scheduler> user_scheduler;
    uint64_t user_isolate_id;
    bool is_predefined = false;

    void update_user_logger(Dart_Handle logger_handle)
    {
        Dart_DeletePersistentHandle_DL(user_logger_handle);
        user_logger_handle = (Dart_NewPersistentHandle_DL(logger_handle));
    }
};

auto& dart_logger_mutex = *new std::mutex;
bool is_core_logger_callback_set = false;
realm_log_level_e last_log_level = RLM_LOG_LEVEL_INFO;
std::map<std::uint64_t, LoggerData*> dart_loggers;
bool default_predefined = false;


LoggerData* try_get_logger(uint64_t key)
{
    LoggerData* loggerData = nullptr;
    if (dart_loggers.find(key) != dart_loggers.end())
    {
        loggerData = dart_loggers[key];
    }
    return loggerData;
}

RLM_API void realm_dart_release_logger(uint64_t isolateId) {
    std::lock_guard lock(dart_logger_mutex);
    LoggerData* loggerData = try_get_logger(isolateId);
    if (loggerData) {
        dart_loggers.erase(isolateId);
        loggerData->~LoggerData();
        loggerData = nullptr;
    }
}

void realm_dart_logger_callback(realm_userdata_t userData, realm_log_level_e level, const char* message) {
    std::lock_guard lock(dart_logger_mutex);
    std::string copy_message = message;
    if (last_log_level <= level)
    {
        for (auto itr = dart_loggers.begin(); itr != dart_loggers.end(); ++itr) {
            LoggerData* loggerData = dart_loggers[itr->first];
            if (!default_predefined || loggerData->is_predefined)
            {
                loggerData->user_scheduler->invoke([loggerData, level = level, message = std::move(message), copy_message]() mutable {
                    message = copy_message.c_str();
                (reinterpret_cast<realm_log_func_t>(loggerData->user_callback))(loggerData->user_logger_handle, level, message);
                });
            }
            if (!default_predefined) break;                
        }
    }
}

RLM_API void realm_dart_init_default_logger(realm_log_level_e level) {
    std::lock_guard lock(dart_logger_mutex);
    if (is_core_logger_callback_set) {
        return;
    }
    last_log_level = level;
    realm_set_log_callback(realm_dart_logger_callback, last_log_level, nullptr, nullptr);
    is_core_logger_callback_set = true;
}

RLM_API void realm_dart_set_logger(Dart_Handle logger, realm_log_func_t callback,
   realm_scheduler_t* scheduler, uint64_t isolateId, bool isPredefined) {
    std::lock_guard lock(dart_logger_mutex);
    LoggerData* loggerData = try_get_logger(isolateId);
    if (loggerData) {
        loggerData->update_user_logger(logger);
    }
    else
    {
        loggerData = new LoggerData(logger, callback, scheduler, isolateId);
        dart_loggers[isolateId] = loggerData;
    }
    loggerData->is_predefined = isPredefined;
    if (isPredefined)
    {
        default_predefined = true;
    }
}

RLM_API void realm_dart_set_log_level(realm_log_level_e level)
{
    std::lock_guard lock(dart_logger_mutex);
    if (last_log_level != level) {
        last_log_level = level;
        realm_set_log_level(last_log_level);
    }
}

RLM_API realm_log_level_e realm_dart_get_log_level()
{
    return last_log_level;
}
