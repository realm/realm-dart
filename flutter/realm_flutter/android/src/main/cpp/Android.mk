LOCAL_PATH:= $(call my-dir)

# include $(CLEAR_VARS)
LOCAL_MODULE := crypto
LOCAL_SRC_FILES := lib/$(TARGET_ARCH_ABI)/libcrypto.a
include $(PREBUILT_STATIC_LIBRARY)

include $(CLEAR_VARS)
LOCAL_MODULE := realm-android
LOCAL_SRC_FILES := lib/$(TARGET_ARCH_ABI)/librealm-android-$(TARGET_ARCH_ABI).a
include $(PREBUILT_STATIC_LIBRARY)

include $(CLEAR_VARS)
LOCAL_MODULE := realm-parser-android
LOCAL_SRC_FILES := lib/$(TARGET_ARCH_ABI)/librealm-parser-android-$(TARGET_ARCH_ABI).a
include $(PREBUILT_STATIC_LIBRARY)

include $(CLEAR_VARS)
LOCAL_MODULE := libflutter
LOCAL_SRC_FILES := lib/$(TARGET_ARCH_ABI)/libflutter.so
include $(PREBUILT_SHARED_LIBRARY)

include $(CLEAR_VARS)
LOCAL_MODULE := librealm_flutter

REALM_DART_EXTENSION_SRC_PATH := ../../../../../../src
REALM_DART_EXTENSION_PATH := $(REALM_DART_EXTENSION_SRC_PATH)/realm-dart-extension
OBJECT_STORE_PATH := $(REALM_DART_EXTENSION_SRC_PATH)/object-store

LOCAL_SRC_FILES := realm_flutter.cpp
LOCAL_SRC_FILES += dart_api_dl.cc
LOCAL_SRC_FILES += $(REALM_DART_EXTENSION_PATH)/dart/dart_init.cpp
LOCAL_SRC_FILES += $(REALM_DART_EXTENSION_PATH)/dart/dart_types.cpp
LOCAL_SRC_FILES += $(REALM_DART_EXTENSION_PATH)/realm-js-common/js_realm.cpp
LOCAL_SRC_FILES += $(REALM_DART_EXTENSION_PATH)/dart/platform.cpp
LOCAL_SRC_FILES += $(REALM_DART_EXTENSION_PATH)/realm_dart_extension.cpp


LOCAL_SRC_FILES += $(OBJECT_STORE_PATH)/src/impl/collection_change_builder.cpp
LOCAL_SRC_FILES += $(OBJECT_STORE_PATH)/src/impl/collection_notifier.cpp
LOCAL_SRC_FILES += $(OBJECT_STORE_PATH)/src/impl/list_notifier.cpp
LOCAL_SRC_FILES += $(OBJECT_STORE_PATH)/src/impl/object_notifier.cpp
LOCAL_SRC_FILES += $(OBJECT_STORE_PATH)/src/impl/realm_coordinator.cpp
LOCAL_SRC_FILES += $(OBJECT_STORE_PATH)/src/impl/results_notifier.cpp
LOCAL_SRC_FILES += $(OBJECT_STORE_PATH)/src/impl/transact_log_handler.cpp
LOCAL_SRC_FILES += $(OBJECT_STORE_PATH)/src/impl/weak_realm_notifier.cpp
LOCAL_SRC_FILES += $(OBJECT_STORE_PATH)/src/impl/epoll/external_commit_helper.cpp
LOCAL_SRC_FILES += $(OBJECT_STORE_PATH)/src/util/uuid.cpp
LOCAL_SRC_FILES += $(OBJECT_STORE_PATH)/src/binding_callback_thread_observer.cpp
LOCAL_SRC_FILES += $(OBJECT_STORE_PATH)/src/collection_notifications.cpp
LOCAL_SRC_FILES += $(OBJECT_STORE_PATH)/src/index_set.cpp
LOCAL_SRC_FILES += $(OBJECT_STORE_PATH)/src/list.cpp
LOCAL_SRC_FILES += $(OBJECT_STORE_PATH)/src/object_schema.cpp
LOCAL_SRC_FILES += $(OBJECT_STORE_PATH)/src/object_store.cpp
LOCAL_SRC_FILES += $(OBJECT_STORE_PATH)/src/object.cpp
LOCAL_SRC_FILES += $(OBJECT_STORE_PATH)/src/object_changeset.cpp
LOCAL_SRC_FILES += $(OBJECT_STORE_PATH)/src/results.cpp
LOCAL_SRC_FILES += $(OBJECT_STORE_PATH)/src/schema.cpp
LOCAL_SRC_FILES += $(OBJECT_STORE_PATH)/src/shared_realm.cpp
LOCAL_SRC_FILES += $(OBJECT_STORE_PATH)/src/thread_safe_reference.cpp
LOCAL_SRC_FILES += $(OBJECT_STORE_PATH)/src/util/scheduler.cpp

REALM_DART_EXTENSION_FULL_PATH := $(LOCAL_PATH)/$(REALM_DART_EXTENSION_SRC_PATH)/realm-dart-extension
OBJECT_STORE_PATH_FULL_PATH := $(LOCAL_PATH)/$(REALM_DART_EXTENSION_SRC_PATH)/object-store
DART_INCLUDE := $(LOCAL_PATH)/$(REALM_DART_EXTENSION_SRC_PATH)/dart-include

$(info REALM_DART_EXTENSION_FULL_PATH is $(REALM_DART_EXTENSION_FULL_PATH))
$(info OBJECT_STORE_PATH_FULL_PATH is $(OBJECT_STORE_PATH_FULL_PATH))


LOCAL_C_INCLUDES := $(REALM_DART_EXTENSION_FULL_PATH)/realm-js-common
LOCAL_C_INCLUDES += $(OBJECT_STORE_PATH_FULL_PATH)/src
LOCAL_C_INCLUDES += $(OBJECT_STORE_PATH_FULL_PATH)/external/json
LOCAL_C_INCLUDES += $(LOCAL_PATH)/lib/include
LOCAL_C_INCLUDES += $(LOCAL_PATH)/lib/include/openssl
LOCAL_C_INCLUDES += dart_io_extensions.h
LOCAL_C_INCLUDES += dart_api_dl.h
LOCAL_C_INCLUDES += dart_version.h
LOCAL_C_INCLUDES += dart_api_dl_impl.h
LOCAL_C_INCLUDES += $(REALM_DART_EXTENSION_FULL_PATH)/dart
LOCAL_C_INCLUDES += $(DART_INCLUDE)

LOCAL_CPPFLAGS += -DFLUTTER

#LOCAL_ALLOW_UNDEFINED_SYMBOLS := true

LOCAL_STATIC_LIBRARIES := realm-parser-android
LOCAL_STATIC_LIBRARIES += realm-android
# LOCAL_STATIC_LIBRARIES += librealm-object-store
LOCAL_STATIC_LIBRARIES += crypto

LOCAL_SHARED_LIBRARIES := libflutter

# LOCAL_LDLIBS    := -llog -landroid -lstlport -llibc++_static

# LOCAL_SHARED_LIBRARIES := libjsc
include $(BUILD_SHARED_LIBRARY)
