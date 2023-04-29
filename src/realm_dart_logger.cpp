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
    bool is_paused = false;
    bool is_predefined = false;

    void update_user_logger(Dart_Handle logger_handle)
    {
        Dart_DeletePersistentHandle_DL(user_logger_handle);
        user_logger_handle = (Dart_NewPersistentHandle_DL(logger_handle));
    }
};

auto& dart_logger_mutex = *new std::mutex;
std::condition_variable initialisation_condition;
std::mutex initialisation_mutex;
bool is_core_logger_callback_set = false;
realm_log_level_e last_log_level = RLM_LOG_LEVEL_INFO;
std::map<std::uint64_t, LoggerData*> dart_loggers;
LoggerData* default_logger;
Dart_Handle _defaultIsolateSendPort;


LoggerData* try_get_logger(uint64_t key)
{
    LoggerData* loggerData = nullptr;
    if (dart_loggers.find(key) != dart_loggers.end())
    {
        loggerData = dart_loggers[key];
    }
    return loggerData;
}

void pause_or_resume_default_logger()
{
    bool paused = false;
    for (auto itr = dart_loggers.begin(); itr != dart_loggers.end(); ++itr) {
        if (dart_loggers[itr->first]->is_predefined)
        {
            paused = true;
            break;
        }
    }
    default_logger->is_paused = paused;
}

RLM_API void realm_dart_release_logger(uint64_t isolateId) {
    std::lock_guard lock(dart_logger_mutex);
    LoggerData* loggerData = try_get_logger(isolateId);
    if (loggerData) {
        dart_loggers.erase(isolateId);
        loggerData->~LoggerData();
        loggerData = nullptr;
        pause_or_resume_default_logger();
    }
}

void realm_dart_logger_callback(realm_userdata_t userData, realm_log_level_e level, const char* message) {
    std::lock_guard lock(dart_logger_mutex);
    std::string copy_message = message;
    if (last_log_level <= level)
    {
        for (auto itr = dart_loggers.begin(); itr != dart_loggers.end(); ++itr) {
            LoggerData* loggerData = dart_loggers[itr->first];
            if (!loggerData->is_paused)
            {
                loggerData->user_scheduler->invoke([loggerData, level = level, message = std::move(message), copy_message]() mutable {
                    message = copy_message.c_str();
                (reinterpret_cast<realm_log_func_t>(loggerData->user_callback))(loggerData->user_logger_handle, level, message);
                });
            }
        }
    }
}

RLM_API void realm_dart_init_default_logger(realm_void_func_t runIsolateFunc) {
    std::lock_guard lock(dart_logger_mutex);
    if (is_core_logger_callback_set) {
        return;
    }
    runIsolateFunc(); // runIsolateFunc starts a new Isolate and then calls realm_dart_set_logger to unlocks the thread
    std::unique_lock initialisation_lock(initialisation_mutex);
    auto inOneMinute = std::chrono::system_clock::now() + std::chrono::minutes(1);
    initialisation_condition.wait_until(initialisation_lock, inOneMinute, [&] { return is_core_logger_callback_set; });
    realm_set_log_callback(realm_dart_logger_callback, last_log_level, nullptr, nullptr);
}

RLM_API void realm_dart_set_default_logger(Dart_Handle logger, realm_log_func_t callback,
    realm_scheduler_t* scheduler, uint64_t isolateId, Dart_Handle sendPort) {
    default_logger = new LoggerData(logger, callback, scheduler, isolateId);
    dart_loggers[isolateId] = default_logger;
    is_core_logger_callback_set = true;
    std::unique_lock initialisation_lock(initialisation_mutex);
    initialisation_lock.unlock();
    initialisation_condition.notify_one();
    _defaultIsolateSendPort = Dart_NewPersistentHandle_DL(sendPort);
}

RLM_API Dart_Handle realm_dart_set_logger(Dart_Handle logger, realm_log_func_t callback,
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
    pause_or_resume_default_logger();
    return _defaultIsolateSendPort;
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
