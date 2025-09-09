# Configure & Open a Realm - Flutter SDK
## Open a Realm
Use the [Configuration](https://pub.dev/documentation/realm/latest/realm/Configuration-class.html) class
to control the specifics of the realm you
would like to open, including the schema.

### Open a Local Realm
To create a realm that persists data locally,
create a configuration with [Configuration.local()](https://pub.dev/documentation/realm/latest/realm/Realm-class.html).
You must provide a list of schemas as an argument.

Pass the `Configuration` to the [Realm](https://pub.dev/documentation/realm/latest/realm/Realm-class.html) constructor.

```dart
final config = Configuration.local([Car.schema]);
final realm = Realm(config);
```

You can now use that realm instance to work with objects in the database.

### Open an In-Memory Realm
To create a realm that runs in memory without being persisted,
create your `Configuration` with [Configuration.inMemory()](https://pub.dev/documentation/realm/latest/realm/Configuration/inMemory.html).
You must provide a list of schemas as an argument.
In-memory realms **cannot** also be read-only.

Pass the `Configuration` to the [Realm](https://pub.dev/documentation/realm/latest/realm/Realm-class.html) constructor.

```dart
final config = Configuration.inMemory([Car.schema]);
final realm = Realm(config);
```

## Configure a Realm
You can add optional properties to the realm's `Configuration`.

### Open a Read-Only Realm
You can open an existing realm in read-only mode. To open a read-only realm,
add `readOnly: true` to your `Configuration` object.

You can only open *existing* realms in read-only mode.
If you try to write to a read-only realm, it throws an error.

```dart
final config = Configuration.local([Car.schema], isReadOnly: true);
final realm = Realm(config);
```

### Set Custom FIFO Special Files
Set a value for Realm's [FIFO special files](https://www.ibm.com/docs/en/zos/2.3.0?topic=csf-fifo-special-files) location.
Opening a realm creates a number of lightweight FIFO special files
that coordinate access to the realm across threads and processes.
If the realm file is in a location that doesn't allow for the creation of
FIFO special files (such as FAT32 filesystems), then the realm cannot be opened.
In this case, Realm needs a different location to store these files.
Add `fifoFilesFallbackPath: <Your Custom FIFO File Path>` to your `Configuration` object.

This property is ignored if the directory for the realm file allows
FIFO special files.

```dart
final config = Configuration.local([Car.schema],
    fifoFilesFallbackPath: "./fifo_folder");
final realm = Realm(config);
```

### Add Initial Data to Realm
Use [initialDataCallback()](https://pub.dev/documentation/realm/latest/realm/InitialDataCallback.html) to invoke
a callback function the first time that you open a realm.
The function only executes the first time you open that realm on the device.
The realm instance passed to the callback function already has a write transaction open,
so you do not need to wrap write operations in a `Realm.write()` transaction block.
`initialDataCallback` can be useful for adding initial data to your application
the first time that it is opened on a device.

```dart
void dataCb(Realm realm) {
  realm.add(Car(ObjectId(), 'Honda'));
}

final config =
    Configuration.local([Car.schema], initialDataCallback: dataCb);
final realm = Realm(config);
Car honda = realm.all<Car>()[0];
```

### Customize Default Configuration
You can customize the default path where Realm stores database files
and the default name given to database files.

Use the static [Configuration.defaultRealmName](https://pub.dev/documentation/realm/latest/realm/Configuration/defaultRealmName.html)
and [Configuration.defaultRealmPath](https://pub.dev/documentation/realm/latest/realm/Configuration/defaultRealmPath.html)
to set default configuration for all realms opened within an application.

```dart
Configuration.defaultRealmName = "myRealmName.realm";

final customDefaultRealmPath = path.join(
    (await Directory.systemTemp.createTemp()).path,
    Configuration.defaultRealmName);
Configuration.defaultRealmPath = customDefaultRealmPath;

// Configurations used in the application will use these values
final config = Configuration.local([Car.schema]);
// The path is your system's temp directory
// with the file named 'myRealmName.realm'
print(config.path);
```

You can also check where realm stores the files by default using the static getter
[Configuration.defaultStoragePath](https://pub.dev/documentation/realm/latest/realm/Configuration/defaultStoragePath.html).
The value for this property varies depending on the platform you are using the SDK
on and whether you are using the Dart or Flutter versions of Realm.
Check the value of `Configuration.defaultStoragePath` in your application
to see where realm files are stored in your environment.

```dart
final storagePath = Configuration.defaultStoragePath;
// See value in your application
print(storagePath);
```

### Manage Schema Changes
For more information about managing schema changes when configuring a realm,
refer to the Update a Realm Object Schema documentation.

### Encrypt a Realm
You can encrypt your local realm to ensure data security. For more information,
see Encrypt a Realm.

### Compact a Realm
You can reduce the local realm file size to improve performance and manage file
size in a resource-constrained environment. For more information, refer to
Compact a Realm.

## Close a Realm
### Flutter
Once you've finished working with a realm, close it to prevent memory leaks.

```dart
realm.close();
```

### Dart
Once you've finished working with a realm, close it to prevent memory leaks.

```dart
realm.close();
```

If you're running a Dart CLI application, to prevent the process from hanging
call [Realm.shutdown()](https://pub.dev/documentation/realm/latest/realm/Realm/shutdown.html).

```dart
Realm.shutdown();
```

## Copy Data into a New Realm
To copy data from an existing realm to a new realm with different
configuration options, pass the new configuration to
[Realm.writeCopy()](https://pub.dev/documentation/realm/latest/realm/Realm/writeCopy.html).

In the new realm's configuration, you *must* specify the `path`.
You **cannot** write to a path that already contains a file.

Using `Realm.writeCopy()`, you can convert between the following
[Configuration](https://pub.dev/documentation/realm/latest/realm/Configuration-class.html)
types:

- `LocalConfiguration` to `LocalConfiguration`
- `InMemoryConfiguration` to `InMemoryConfiguration`
- `LocalConfiguration` to read-only `LocalConfiguration` and vice versa
- `InMemoryConfiguration` to `LocalConfiguration` and vice versa

Some additional considerations to keep in mind while using `Realm.writeCopy()`:

- The destination file cannot already exist.
- Copying a realm is not allowed within a write transaction or during migration.

before the copy is written. This ensures that the file can be used
as a starting point for a newly-installed application.
The `Realm.writeCopy()` throws if there are pending uploads.

The following example copies the data from a realm with a `InMemoryConfiguration`
to a new realm with a `LocalConfiguration`.

```dart
// Create in-memory realm and add data to it.
// Note that even though the realm is in-memory, it still has a file path.
// This is because in-memory realms still use memory-mapped files
// for their operations; they just don't persist data across launches.
final inMemoryRealm =
    Realm(Configuration.inMemory([Person.schema], path: 'inMemory.realm'));
inMemoryRealm.write(() {
  inMemoryRealm.addAll([Person("Tanya"), Person("Greg"), Person("Portia")]);
});

// Copy contents of `inMemoryRealm` to a new realm with `localConfig`.
// `localConfig` uses the default file path for local realms.
final localConfig = Configuration.local([Person.schema]);
inMemoryRealm.writeCopy(localConfig);
// Close the realm you just copied when you're done working with it.
inMemoryRealm.close();

// Open the local realm that the data from `inMemoryRealm`
// was just copied to with `localConfig`.
final localRealm = Realm(localConfig);

// Person object for "Tanya" is in `localRealm` because
// the data was copied over with `inMemoryRealm.writeCopy()`.
final tanya = localRealm.find<Person>("Tanya");
```

You can also include a new encryption key
in the copied realm's configuration or remove the encryption key from the new configuration.

The following example copies data from an **unencrypted** realm with a `LocalConfiguration`
to an **encrypted** realm with a `LocalConfiguration`.

```dart
// Create unencrypted realm and add data to it.
final unencryptedRealm = Realm(Configuration.local([Person.schema]));
unencryptedRealm.write(() => unencryptedRealm.addAll([
      Person("Daphne"),
      Person("Harper"),
      Person("Ethan"),
      Person("Cameron")
    ]));

// Create encryption key and encrypted realm.
final key = List<int>.generate(64, (i) => Random().nextInt(256));
final encryptedConfig = Configuration.local([Person.schema],
    path: 'encrypted.realm', encryptionKey: key);
// Copy the data from `unencryptedRealm` to a new realm with
// the `encryptedConfig`. The data is encrypted as part of the copying.
unencryptedRealm.writeCopy(encryptedConfig);
// Close the realm you just copied when you're done working with it.
unencryptedRealm.close();

// Open the new encrypted realm with `encryptedConfig`.
final encryptedRealm = Realm(encryptedConfig);

// Person object for "Harper" is in `localRealm` because
// the data was copied over with `unencryptedRealm.writeCopy()`.
final harper = encryptedRealm.find<Person>('Harper');
```
