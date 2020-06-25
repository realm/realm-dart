cmake_minimum_required(VERSION 3.13)

project(object-store)

set(SOURCES
     ../object-store/src/binding_callback_thread_observer.cpp,
     ../object-store/src/collection_notifications.cpp,
     ../object-store/src/index_set.cpp,
     ../object-store/src/list.cpp,
     ../object-store/src/object.cpp,
     ../object-store/src/object_changeset.cpp,
     ../object-store/src/object_schema.cpp,
     ../object-store/src/object_store.cpp,
     ../object-store/src/placeholder.cpp,
     ../object-store/src/results.cpp,
     ../object-store/src/schema.cpp,
     ../object-store/src/shared_realm.cpp,
     ../object-store/src/thread_safe_reference.cpp,
     ../object-store/src/impl/collection_change_builder.cpp,
     ../object-store/src/impl/collection_notifier.cpp,
     ../object-store/src/impl/list_notifier.cpp,
     ../object-store/src/impl/object_notifier.cpp,
     ../object-store/src/impl/realm_coordinator.cpp,
     ../object-store/src/impl/results_notifier.cpp,
     ../object-store/src/impl/transact_log_handler.cpp,
     ../object-store/src/impl/weak_realm_notifier.cpp,
     ../object-store/src/util/uuid.cpp,
     ../object-store/external/json/json.hpp,
     ../object-store/src/audit.hpp,
     ../object-store/src/binding_callback_thread_observer.hpp,
     ../object-store/src/binding_context.hpp,
     ../object-store/src/collection_notifications.hpp,
     ../object-store/src/execution_context_id.hpp,
     ../object-store/src/feature_checks.hpp,
     ../object-store/src/index_set.hpp,
     ../object-store/src/list.hpp,
     ../object-store/src/object.hpp,
     ../object-store/src/object_accessor.hpp,
     ../object-store/src/object_changeset.hpp,
     ../object-store/src/object_schema.hpp,
     ../object-store/src/object_store.hpp,
     ../object-store/src/property.hpp,
     ../object-store/src/results.hpp,
     ../object-store/src/schema.hpp,
     ../object-store/src/shared_realm.hpp,
     ../object-store/src/thread_safe_reference.hpp,
     ../object-store/src/impl/collection_change_builder.hpp,
     ../object-store/src/impl/collection_notifier.hpp,
     ../object-store/src/impl/list_notifier.hpp,
     ../object-store/src/impl/notification_wrapper.hpp,
     ../object-store/src/impl/object_accessor_impl.hpp,
     ../object-store/src/impl/object_notifier.hpp,
     ../object-store/src/impl/realm_coordinator.hpp,
     ../object-store/src/impl/results_notifier.hpp,
     ../object-store/src/impl/transact_log_handler.hpp,
     ../object-store/src/impl/weak_realm_notifier.hpp,
     ../object-store/src/impl/apple/external_commit_helper.hpp,
     ../object-store/src/impl/apple/keychain_helper.hpp,
     ../object-store/src/impl/epoll/external_commit_helper.hpp,
     ../object-store/src/impl/external_commit_helper.hpp,
     ../object-store/src/impl/generic/external_commit_helper.hpp,
     ../object-store/src/impl/windows/external_commit_helper.hpp,
     ../object-store/src/sync/async_open_task.hpp,
     ../object-store/src/sync/partial_sync.hpp,
     ../object-store/src/sync/subscription_state.hpp,
     ../object-store/src/sync/sync_config.hpp,
     ../object-store/src/sync/sync_manager.hpp,
     ../object-store/src/sync/sync_permission.hpp,
     ../object-store/src/sync/sync_session.hpp,
     ../object-store/src/sync/sync_user.hpp,
     ../object-store/src/sync/impl/apple/network_reachability_observer.hpp,
     ../object-store/src/sync/impl/apple/system_configuration.hpp,
     ../object-store/src/sync/impl/network_reachability.hpp,
     ../object-store/src/sync/impl/sync_client.hpp,
     ../object-store/src/sync/impl/sync_file.hpp,
     ../object-store/src/sync/impl/sync_metadata.hpp,
     ../object-store/src/sync/impl/work_queue.hpp,
     ../object-store/src/server/adapter.hpp,
     ../object-store/src/server/admin_realm.hpp,
     ../object-store/src/server/global_notifier.hpp,
     ../object-store/src/util/aligned_union.hpp,
     ../object-store/src/util/atomic_shared_ptr.hpp,
     ../object-store/src/util/event_loop_dispatcher.hpp,
     ../object-store/src/util/event_loop_signal.hpp,
     ../object-store/src/util/tagged_bool.hpp,
     ../object-store/src/util/uuid.hpp,
     ../object-store/src/util/android/event_loop_signal.hpp,
     ../object-store/src/util/apple/event_loop_signal.hpp,
     ../object-store/src/util/generic/event_loop_signal.hpp,
     ../object-store/src/util/uv/event_loop_signal.hpp,
    )

set(HEADERS
    )

set(INCLUDE_DIRS
    ../object-store/src,
    ../object-store/external/json
)

if(CMAKE_SYSTEM_NAME MATCHES "^Windows")
    list(APPEND SOURCES ../object-store/src/impl/windows/external_commit_helper.cpp)
endif()

add_definitions(-DREALM_PLATFORM_NODE=1)


add_library(object-store STATIC ${SOURCES} ${HEADERS})

set_target_properties(object-store PROPERTIES POSITION_INDEPENDENT_CODE 1)

target_include_directories(object-store PUBLIC ${DART_INCLUDE_DIR} ${INCLUDE_DIRS})

