// Copyright 2024 MongoDB, Inc.
// SPDX-License-Identifier: Apache-2.0

import 'dart:ffi';

import 'package:ffi/ffi.dart';
import 'package:realm_dart/src/native/error_handling.dart';

import '../configuration.dart'; // TODO: Remove this import
import '../migration.dart'; // TODO: Remove this import
import '../realm_class.dart'; // TODO: Remove this import
import '../scheduler.dart'; // TODO: Remove this import
import '../user.dart'; // TODO: Remove this import
import 'handle_base.dart';
import 'realm_bindings.dart';
import 'realm_core.dart';
import 'realm_handle.dart';
import 'realm_library.dart';
import 'schema_handle.dart'; // TODO: Remove this import

class ConfigHandle extends HandleBase<realm_config> {
  ConfigHandle(Pointer<realm_config> pointer) : super(pointer, 512);

  factory ConfigHandle.from(Configuration config) {
    return using((arena) {
      final configHandle = ConfigHandle(realmLib.realm_config_new());

      if (config.schemaObjects.isNotEmpty) {
        final schemaHandle = SchemaHandle.from(config.schemaObjects);
        realmLib.realm_config_set_schema(configHandle.pointer, schemaHandle.pointer);
      }

      realmLib.realm_config_set_path(configHandle.pointer, config.path.toCharPtr(arena));
      realmLib.realm_config_set_scheduler(configHandle.pointer, scheduler.handle.pointer);

      if (config.fifoFilesFallbackPath != null) {
        realmLib.realm_config_set_fifo_path(configHandle.pointer, config.fifoFilesFallbackPath!.toCharPtr(arena));
      }

      // Setting schema version only makes sense for local realms, but core insists it is always set,
      // hence we set it to 0 in those cases.

      final schemaVersion = switch (config) {
        (LocalConfiguration lc) => lc.schemaVersion,
        (FlexibleSyncConfiguration fsc) => fsc.schemaVersion,
        _ => 0,
      };
      realmLib.realm_config_set_schema_version(configHandle.pointer, schemaVersion);
      if (config.maxNumberOfActiveVersions != null) {
        realmLib.realm_config_set_max_number_of_active_versions(configHandle.pointer, config.maxNumberOfActiveVersions!);
      }
      if (config is LocalConfiguration) {
        //realmLib.realm_config_set_schema_mode(configHandle.pointer, realm_schema_mode.RLM_SCHEMA_MODE_ADDITIVE_DISCOVERED);
        if (config.initialDataCallback != null) {
          realmLib.realm_config_set_data_initialization_function(
            configHandle.pointer,
            Pointer.fromFunction(_initialDataCallback, false),
            config.toPersistentHandle(),
            realmLib.addresses.realm_dart_delete_persistent_handle,
          );
        }
        if (config.isReadOnly) {
          realmLib.realm_config_set_schema_mode(configHandle.pointer, realm_schema_mode.RLM_SCHEMA_MODE_IMMUTABLE);
        } else if (config.shouldDeleteIfMigrationNeeded) {
          realmLib.realm_config_set_schema_mode(configHandle.pointer, realm_schema_mode.RLM_SCHEMA_MODE_SOFT_RESET_FILE);
        }
        if (config.disableFormatUpgrade) {
          realmLib.realm_config_set_disable_format_upgrade(configHandle.pointer, config.disableFormatUpgrade);
        }
        if (config.shouldCompactCallback != null) {
          realmLib.realm_config_set_should_compact_on_launch_function(
            configHandle.pointer,
            Pointer.fromFunction(_shouldCompactCallback, false),
            config.toPersistentHandle(),
            realmLib.addresses.realm_dart_delete_persistent_handle,
          );
        }
        if (config.migrationCallback != null) {
          realmLib.realm_config_set_migration_function(
            configHandle.pointer,
            Pointer.fromFunction(_migrationCallback, false),
            config.toPersistentHandle(),
            realmLib.addresses.realm_dart_delete_persistent_handle,
          );
        }
      } else if (config is InMemoryConfiguration) {
        realmLib.realm_config_set_in_memory(configHandle.pointer, true);
      } else if (config is FlexibleSyncConfiguration) {
        realmLib.realm_config_set_schema_mode(configHandle.pointer, realm_schema_mode.RLM_SCHEMA_MODE_ADDITIVE_DISCOVERED);
        final syncConfigPtr = realmLib.realm_flx_sync_config_new(config.user.handle.pointer)..raiseLastErrorIfNull();
        try {
          realmLib.realm_sync_config_set_session_stop_policy(syncConfigPtr, config.sessionStopPolicy.index);
          realmLib.realm_sync_config_set_resync_mode(syncConfigPtr, config.clientResetHandler.clientResyncMode.index);
          final errorHandlerCallback =
              Pointer.fromFunction<Void Function(Handle, Pointer<realm_sync_session_t>, realm_sync_error_t)>(_syncErrorHandlerCallback);
          final errorHandlerUserdata = realmLib.realm_dart_userdata_async_new(config, errorHandlerCallback.cast(), scheduler.handle.pointer);
          realmLib.realm_sync_config_set_error_handler(syncConfigPtr, realmLib.addresses.realm_dart_sync_error_handler_callback, errorHandlerUserdata.cast(),
              realmLib.addresses.realm_dart_userdata_async_free);

          if (config.clientResetHandler.onBeforeReset != null) {
            final syncBeforeResetCallback = Pointer.fromFunction<Void Function(Handle, Pointer<shared_realm>, Pointer<Void>)>(_syncBeforeResetCallback);
            final beforeResetUserdata = realmLib.realm_dart_userdata_async_new(config, syncBeforeResetCallback.cast(), scheduler.handle.pointer);

            realmLib.realm_sync_config_set_before_client_reset_handler(syncConfigPtr, realmLib.addresses.realm_dart_sync_before_reset_handler_callback,
                beforeResetUserdata.cast(), realmLib.addresses.realm_dart_userdata_async_free);
          }

          if (config.clientResetHandler.onAfterRecovery != null || config.clientResetHandler.onAfterDiscard != null) {
            final syncAfterResetCallback =
                Pointer.fromFunction<Void Function(Handle, Pointer<shared_realm>, Pointer<realm_thread_safe_reference>, Bool, Pointer<Void>)>(
                    _syncAfterResetCallback);
            final afterResetUserdata = realmLib.realm_dart_userdata_async_new(config, syncAfterResetCallback.cast(), scheduler.handle.pointer);

            realmLib.realm_sync_config_set_after_client_reset_handler(syncConfigPtr, realmLib.addresses.realm_dart_sync_after_reset_handler_callback,
                afterResetUserdata.cast(), realmLib.addresses.realm_dart_userdata_async_free);
          }

          if (config.shouldCompactCallback != null) {
            realmLib.realm_config_set_should_compact_on_launch_function(
              configHandle.pointer,
              Pointer.fromFunction(_shouldCompactCallback, false),
              config.toPersistentHandle(),
              realmLib.addresses.realm_dart_delete_persistent_handle,
            );
          }

          realmLib.realm_config_set_sync_config(configHandle.pointer, syncConfigPtr);
        } finally {
          realmLib.realm_release(syncConfigPtr.cast());
        }
      } else if (config is DisconnectedSyncConfiguration) {
        realmLib.realm_config_set_schema_mode(configHandle.pointer, realm_schema_mode.RLM_SCHEMA_MODE_ADDITIVE_EXPLICIT);
        realmLib.realm_config_set_force_sync_history(configHandle.pointer, true);
      }

      if (config.encryptionKey != null) {
        realmLib.realm_config_set_encryption_key(configHandle.pointer, config.encryptionKey!.toUint8Ptr(arena), encryptionKeySize);
      }

      // For sync and for dynamic Realms, we need to have a complete view of the schema in Core.
      if (config.schemaObjects.isEmpty || config is FlexibleSyncConfiguration) {
        realmLib.realm_config_set_schema_subset_mode(configHandle.pointer, realm_schema_subset_mode.RLM_SCHEMA_SUBSET_MODE_COMPLETE);
      }

      return configHandle;
    });
  }
}

void _syncAfterResetCallback(Object userdata, Pointer<shared_realm> beforeHandle, Pointer<realm_thread_safe_reference> afterReference, bool didRecover,
    Pointer<Void> unlockCallbackFunc) {
  guardSynchronousCallback(() async {
    final syncConfig = userdata as FlexibleSyncConfiguration;
    final afterResetCallback = didRecover ? syncConfig.clientResetHandler.onAfterRecovery : syncConfig.clientResetHandler.onAfterDiscard;

    if (afterResetCallback == null) {
      return;
    }

    final beforeRealm = RealmInternal.getUnowned(syncConfig, RealmHandle.unowned(beforeHandle));
    final afterRealm = RealmInternal.getUnowned(
        syncConfig,
        RealmHandle.unowned(realmLib.realm_from_thread_safe_reference(
          afterReference,
          scheduler.handle.pointer,
        )));

    try {
      return await afterResetCallback(beforeRealm, afterRealm);
    } finally {
      beforeRealm.handle.release();
      afterRealm.handle.release();
    }
  }, unlockCallbackFunc);
}

bool _shouldCompactCallback(Pointer<Void> userdata, int totalSize, int usedSize) {
  final config = userdata.toObject();

  if (config is LocalConfiguration) {
    return config.shouldCompactCallback!(totalSize, usedSize);
  } else if (config is FlexibleSyncConfiguration) {
    return config.shouldCompactCallback!(totalSize, usedSize);
  }

  return false;
}

bool _migrationCallback(Pointer<Void> userdata, Pointer<shared_realm> oldRealmHandle, Pointer<shared_realm> newRealmHandle, Pointer<realm_schema> schema) {
  final oldHandle = RealmHandle.unowned(oldRealmHandle);
  final newHandle = RealmHandle.unowned(newRealmHandle);
  try {
    final LocalConfiguration config = userdata.toObject();

    final oldSchemaVersion = realmLib.realm_get_schema_version(oldRealmHandle);
    final oldConfig = Configuration.local([], path: config.path, isReadOnly: true, schemaVersion: oldSchemaVersion);
    final oldRealm = RealmInternal.getUnowned(oldConfig, oldHandle, isInMigration: true);

    final newRealm = RealmInternal.getUnowned(config, newHandle, isInMigration: true);

    final migration = MigrationInternal.create(RealmInternal.getMigrationRealm(oldRealm), newRealm, SchemaHandle.unowned(schema));
    config.migrationCallback!(migration, oldSchemaVersion);
    return true;
  } catch (ex) {
    realmLib.realm_register_user_code_callback_error(ex.toPersistentHandle());
  } finally {
    oldHandle.release();
    newHandle.release();
  }

  return false;
}

void _syncErrorHandlerCallback(Object userdata, Pointer<realm_sync_session> session, realm_sync_error error) {
  final syncConfig = userdata as FlexibleSyncConfiguration;
  // TODO: Take the app from the session instead of from syncConfig after fixing issue https://github.com/realm/realm-dart/issues/633
  final syncError = SyncErrorInternal.createSyncError(error.toDart(), app: syncConfig.user.app);

  if (syncError is ClientResetError) {
    syncConfig.clientResetHandler.onManualReset?.call(syncError);
    return;
  }

  syncConfig.syncErrorHandler(syncError);
}

void _syncBeforeResetCallback(Object userdata, Pointer<shared_realm> realmPtr, Pointer<Void> unlockCallbackFunc) {
  guardSynchronousCallback(() async {
    final syncConfig = userdata as FlexibleSyncConfiguration;
    var beforeResetCallback = syncConfig.clientResetHandler.onBeforeReset!;

    final realm = RealmInternal.getUnowned(syncConfig, RealmHandle.unowned(realmPtr));
    try {
      await beforeResetCallback(realm);
    } finally {
      realm.handle.release();
    }
  }, unlockCallbackFunc);
}

bool _initialDataCallback(Pointer<Void> userdata, Pointer<shared_realm> realmPtr) {
  final realmHandle = RealmHandle.unowned(realmPtr);
  try {
    final LocalConfiguration config = userdata.toObject();
    final realm = RealmInternal.getUnowned(config, realmHandle);
    config.initialDataCallback!(realm);
    return true;
  } catch (ex) {
    realmLib.realm_register_user_code_callback_error(ex.toPersistentHandle());
  } finally {
    realmHandle.release();
  }

  return false;
}
