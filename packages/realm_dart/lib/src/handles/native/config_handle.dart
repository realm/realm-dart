// Copyright 2024 MongoDB, Inc.
// SPDX-License-Identifier: Apache-2.0

import 'dart:ffi';

import '../../migration.dart';
import '../../realm_class.dart';
import 'convert_native.dart';
import 'ffi.dart';
import 'handle_base.dart';
import 'realm_bindings.dart';
import 'realm_handle.dart';
import 'realm_library.dart';
import 'scheduler_handle.dart';
import 'schema_handle.dart';

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
      realmLib.realm_config_set_scheduler(configHandle.pointer, schedulerHandle.pointer);

      if (config.fifoFilesFallbackPath != null) {
        realmLib.realm_config_set_fifo_path(configHandle.pointer, config.fifoFilesFallbackPath!.toCharPtr(arena));
      }

      // Setting schema version only makes sense for local realms, but core insists it is always set,
      // hence we set it to 0 in those cases.

      final schemaVersion = switch (config) {
        (LocalConfiguration lc) => lc.schemaVersion,
        _ => 0,
      };
      realmLib.realm_config_set_schema_version(configHandle.pointer, schemaVersion);
      if (config.maxNumberOfActiveVersions != null) {
        realmLib.realm_config_set_max_number_of_active_versions(configHandle.pointer, config.maxNumberOfActiveVersions!);
      }
      if (config is LocalConfiguration) {
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
      }

      final key = config.encryptionKey;
      if (key != null) {
        realmLib.realm_config_set_encryption_key(configHandle.pointer, key.toUint8Ptr(arena), key.length);
      }

      // For dynamic Realms, we need to have a complete view of the schema in Core.
      if (config.schemaObjects.isEmpty) {
        realmLib.realm_config_set_schema_subset_mode(configHandle.pointer, realm_schema_subset_mode.RLM_SCHEMA_SUBSET_MODE_COMPLETE);
      }

      return configHandle;
    });
  }
}

bool _shouldCompactCallback(Pointer<Void> userdata, int totalSize, int usedSize) {
  final config = userdata.toObject();

  if (config is LocalConfiguration) {
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
