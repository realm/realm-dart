# Delete a Realm File - Flutter SDK
In some cases, you may want to completely delete a realm file from disk.

Realm avoids copying data into memory except when absolutely required.
As a result, all objects managed by a realm have references to the file
on disk. Before you can safely delete the file, you must ensure the
deallocation of these objects:

- All objects read from or added to the realm
- All List and Results objects
- All `ThreadSafeReference` objects
- The realm itself

> **WARNING:**
> If you delete a realm file or any of its auxiliary files while one or
> more instances of the realm are open, you might corrupt the realm or
> disrupt sync.
>

## Delete a Realm File
You can delete the `.realm`, `.note` and `.management` files
for a given configuration with the static method
[Realm.deleteRealm()](https://pub.dev/documentation/realm/latest/realm/Realm/deleteRealm.html),
which accepts a path to a realm file as an argument.

```dart
//Get realm's file path
final path = realm.config.path;

// You must close a realm before deleting it
realm.close();

// Delete the realm
Realm.deleteRealm(path);
```
