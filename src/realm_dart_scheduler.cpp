#include <thread>
#include <functional>

#include <realm.h>
#include "dart_api_dl.h"
#include "realm_dart_scheduler.h"

struct SchedulerData {
    std::thread::id threadId;
    Dart_Port port;

    realm_scheduler_notify_func_t callback;
    void* callback_userData;
    realm_free_userdata_func_t free_userData_func;
};

static const int SCHEDULER_FINALIZE = NULL;

void realm_dart_scheduler_free_userData(void* userData) {
    SchedulerData* scheduler = static_cast<SchedulerData*>(userData);
    Dart_PostInteger_DL(scheduler->port, SCHEDULER_FINALIZE);
    
    //delete the scheduler
    delete scheduler;
}

//This can be invoked on any thread.
void realm_dart_scheduler_notify(void* userData) {

    // TODO: Consider removing this commented code when the reinterpret_cast<std::uintptr_t> below is tested on all platforms
    // //This posts the userdata to the main thread as Pointer<Void>. 
    // //The RealmScheduler should invoke the realm_dart_scheduler_invoke 
    // //from the main thread passing back the same pointer to userData
    // //see here https://github.com/dart-lang/sdk/issues/47270
    // Dart_CObject message;
    // message.type = Dart_CObject_kExternalTypedData;
    // message.value.as_external_typed_data.type = Dart_TypedData_kUint8;
    // message.value.as_external_typed_data.length = 0;
    // message.value.as_external_typed_data.data = nullptr;
    // message.value.as_external_typed_data.peer = userData;
    // //This callback is supposed to release the peer data. We don't use it since our peer is userData which is deleted by the realm_dart_scheduler_free_userData
    // message.value.as_external_typed_data.callback = [](void* isolate_callback_data, void* peer) {};
    // auto& scheduler = *static_cast<SchedulerData*>(userData);
    // Dart_PostCObject(scheduler.port, &message);
    
    auto& scheduler = *static_cast<SchedulerData*>(userData);
    std::uintptr_t pointer = reinterpret_cast<std::uintptr_t>(userData);
    Dart_PostInteger_DL(scheduler.port, pointer);
}

bool realm_dart_scheduler_is_on_thread(void* userData) {
    auto& scheduler = *static_cast<SchedulerData*>(userData);
    return scheduler.threadId == std::this_thread::get_id();
}

bool realm_dart_scheduler_is_same_as(const void* userData1, const void* userData2) {
    auto &scheduler1 = *static_cast<const SchedulerData*>(userData1);
    auto &scheduler2 = *static_cast<const SchedulerData*>(userData2);
    return scheduler1.threadId == scheduler2.threadId;
}

bool realm_dart_scheduler_can_deliver_notifications(void* userData) {
    return true;
}

void realm_dart_scheduler_set_notify_callback(void* userData, void* callback_userData, realm_free_userdata_func_t free_userData_func, realm_scheduler_notify_func_t notify_func) {
    auto& scheduler = *static_cast<SchedulerData*>(userData);
    scheduler.callback = notify_func;
    scheduler.free_userData_func = free_userData_func;
    scheduler.callback_userData = callback_userData;
}

RLM_API realm_scheduler_t* realm_dart_create_scheduler(Dart_Port port) {
    SchedulerData* scheduler = new SchedulerData();
    scheduler->threadId = std::this_thread::get_id();
    scheduler->port = port;

    return realm_scheduler_new(scheduler, 
        realm_dart_scheduler_free_userData, 
        realm_dart_scheduler_notify, 
        realm_dart_scheduler_is_on_thread, 
        realm_dart_scheduler_is_same_as,
        realm_dart_scheduler_can_deliver_notifications,
        realm_dart_scheduler_set_notify_callback);
}

//This is called from Dart on the main thread
RLM_API void realm_dart_scheduler_invoke(void* userData) {
    auto& scheduler = *static_cast<SchedulerData*>(userData);

    //invoke the notify callback
    scheduler.callback(scheduler.callback_userData);
    
    //call the function that will free the callback user data
    scheduler.free_userData_func(scheduler.callback_userData);
}