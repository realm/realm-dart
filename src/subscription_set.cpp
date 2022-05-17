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

#include "subscription_set.h"

#include <realm/object-store/c_api/types.hpp>
#include <realm/object-store/c_api/util.hpp>
#include <realm/sync/subscriptions.hpp>

#include "event_loop_dispatcher.hpp"

namespace realm::c_api {
namespace {

using namespace realm::sync;

using FreeT = std::function<void()>;
using CallbackT = std::function<void(realm_flx_sync_subscription_set_state)>; // Differs per callback
using UserdataT = std::tuple<CallbackT, FreeT>;

void _callback(void* userdata, realm_flx_sync_subscription_set_state state) {
    auto u = reinterpret_cast<UserdataT*>(userdata);
    std::get<0>(*u)(state);
}

void _userdata_free(void* userdata) {
    auto u = reinterpret_cast<UserdataT*>(userdata);
    std::get<1>(*u)();
    delete u;
}

RLM_API bool realm_dart_sync_on_subscription_set_state_change_async(
    const realm_flx_sync_subscription_set_t* subscription_set,
    realm_flx_sync_subscription_set_state_e notify_when,
    realm_sync_on_subscription_state_changed callback,
    void* userdata,
    realm_free_userdata_func_t userdata_free,
    realm_scheduler_t* scheduler) noexcept
{
    auto u = new UserdataT(std::bind(util::EventLoopDispatcher{ *scheduler, callback }, userdata, std::placeholders::_1),
                           std::bind(util::EventLoopDispatcher{ *scheduler, userdata_free }, userdata));
    return realm_sync_on_subscription_set_state_change_async(subscription_set, notify_when, _callback, u, _userdata_free);
}

} // anonymous namespace
} // namespace realm::c_api 
