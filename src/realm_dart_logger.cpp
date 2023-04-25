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

#include "realm_dart_logger.h"
#include <realm/object-store/c_api/types.hpp>
struct LoggerData {

    LoggerData(Dart_Handle logger_handle, realm_log_level_e level, realm_log_func_t callback, realm_scheduler_t* scheduler, uint64_t isolateId)
        :user_logger_handle(Dart_NewPersistentHandle_DL(logger_handle)), user_log_level(level), user_callback(callback), user_scheduler(*scheduler), user_isolate_id(isolateId)
    {}

    ~LoggerData() {
        Dart_DeletePersistentHandle_DL(user_logger_handle);
    }

    Dart_PersistentHandle user_logger_handle;
    realm_log_level_e user_log_level;
    realm_log_func_t user_callback = nullptr;
    std::shared_ptr<realm::util::Scheduler> user_scheduler;
    uint64_t user_isolate_id;

    void update_user_logger(Dart_Handle logger_handle, realm_log_level_e log_level)
    {
        Dart_DeletePersistentHandle_DL(user_logger_handle);
        user_logger_handle = (Dart_NewPersistentHandle_DL(logger_handle));
        user_log_level = log_level;
    }
};

auto& dart_logger_mutex = *new std::mutex;
uint64_t default_logger_isolate_id;
bool is_core_logger_callback_set = false;
realm_log_level_e last_log_level = RLM_LOG_LEVEL_OFF;
std::map<std::uint64_t, LoggerData*> dart_loggers;
Dart_Port default_logger_receive_port;

LoggerData* tryGetLogger(uint64_t key)
{
    LoggerData* loggerData = nullptr;
    auto& found = dart_loggers.find(key);
    if (found != std::end(dart_loggers))
    {
        loggerData = found->second;
    }
    return loggerData;
}

void realm_dart_loggers_free(realm_userdata_t userdata)
{
    std::lock_guard lock(dart_logger_mutex);
    realm_set_log_callback(nullptr, RLM_LOG_LEVEL_OFF, nullptr, nullptr);
    for (auto itr = dart_loggers.begin(); itr != dart_loggers.end(); ++itr) {
        dart_loggers[itr->first] = nullptr;
    }
    dart_loggers.clear();
    Dart_PostInteger_DL(default_logger_receive_port, 0);
}

RLM_API void realm_dart_release_logger(uint64_t isolateId) {
    std::lock_guard lock(dart_logger_mutex);
    LoggerData* loggerData = tryGetLogger(isolateId);
    if (loggerData) {
        dart_loggers.erase(isolateId);
        loggerData->~LoggerData();
        loggerData = nullptr;
    }
}

void realm_dart_logger_callback(realm_userdata_t userData, realm_log_level_e level, const char* message) {
    if (level >= last_log_level)
    {
        std::lock_guard lock(dart_logger_mutex);
        std::string copy_message = message;
        for (auto itr = dart_loggers.begin(); itr != dart_loggers.end(); ++itr) {
            LoggerData* loggerData = dart_loggers[itr->first];
            loggerData->user_scheduler->invoke([loggerData, level = level, message = std::move(message), copy_message]() mutable {
                message = copy_message.c_str();
            (reinterpret_cast<realm_log_func_t>(loggerData->user_callback))(loggerData->user_logger_handle, level, message);
            });
        }
    }
}

void set_last_log_level(realm_log_level_e level) {
    if (last_log_level != level) {

        realm_log_level maximum_log_level = RLM_LOG_LEVEL_OFF;
        for (auto itr = dart_loggers.begin(); itr != dart_loggers.end(); ++itr) {
            realm_log_level user_level = dart_loggers[itr->first]->user_log_level;
               maximum_log_level = (user_level < maximum_log_level)?user_level: maximum_log_level;
        }
        last_log_level = maximum_log_level;
        realm_set_log_level(last_log_level);
    }
}

RLM_API void realm_dart_init_default_logger(realm_init_log_func_t callback, realm_log_level_e level) {
    std::lock_guard lock(dart_logger_mutex);
    if (!is_core_logger_callback_set) {
        realm_set_log_callback(realm_dart_logger_callback, level, nullptr, realm_dart_loggers_free);
        last_log_level = level;
        is_core_logger_callback_set = true;
        callback(level);
    }
}

RLM_API void realm_dart_add_default_logger(Dart_Handle logger, realm_log_func_t callback, realm_log_level_e level, realm_scheduler_t* scheduler, uint64_t isolateId, Dart_Port receive_port) {
    std::lock_guard lock(dart_logger_mutex);
    LoggerData* loggerData = new LoggerData(logger, level, callback, scheduler, isolateId);
    dart_loggers[isolateId] = loggerData;
    default_logger_isolate_id = isolateId;
    default_logger_receive_port = receive_port;
    set_last_log_level(level);
}

RLM_API void realm_dart_add_new_logger(Dart_Handle logger, realm_log_func_t callback, realm_log_level_e level, realm_scheduler_t* scheduler, uint64_t isolateId) {
    std::lock_guard lock(dart_logger_mutex);
    LoggerData* loggerData = tryGetLogger(isolateId);
    if (loggerData) {
        loggerData->update_user_logger(logger, level);
    }
    else
    {
        LoggerData* loggerData = new LoggerData(logger, level, callback, scheduler, isolateId);
        dart_loggers[isolateId] = loggerData;
    }
    set_last_log_level(level);
}

RLM_API void realm_dart_set_log_level(realm_log_level_e level, uint64_t isolateId)
{
    std::lock_guard lock(dart_logger_mutex);
    uint64_t isolateIdToFind = isolateId == 0 ? default_logger_isolate_id : isolateId;
    LoggerData* loggerData = tryGetLogger(isolateIdToFind);
    if (loggerData) {
        loggerData->user_log_level = level;
        set_last_log_level(level);
    }
}