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

#include <iostream>

#include <realm/sync/subscriptions.hpp>
#include <realm/object-store/c_api/util.hpp>
#include <realm/object-store/c_api/types.hpp>

#include "event_loop_dispatcher.hpp"

namespace realm::c_api {    

using namespace realm::sync;

RLM_API bool realm_dart_sync_on_subscription_set_state_change_async(
    const realm_flx_sync_subscription_set_t* subscription_set,
    realm_flx_sync_subscription_set_state_e notify_when,
    realm_dart_sync_on_subscription_state_changed callback,
    void* userdata,
    realm_free_userdata_func_t userdata_free,
    realm_scheduler_t* scheduler) noexcept
{
    return wrap_err([&]() {
        auto future_state = subscription_set->get_state_change_notification(SubscriptionSet::State{notify_when});
        std::move(future_state)
            .get_async([callback, scheduler, userdata = SharedUserdata(userdata, util::DispatchFreeUserdata(*scheduler, userdata_free))](const StatusWith<SubscriptionSet::State>& state) -> void {
                auto cb = util::EventLoopDispatcher{*scheduler, callback};     
                if (state.is_ok()) {
                    cb(userdata.get(), realm_flx_sync_subscription_set_state_e(static_cast<int>(state.get_value())));
                }
                else {
                    cb(userdata.get(), realm_flx_sync_subscription_set_state_e::RLM_SYNC_SUBSCRIPTION_ERROR);
                }
            });
        return true; 
    });
}

} // namespace realm::c_api
