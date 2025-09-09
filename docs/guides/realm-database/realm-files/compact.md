# Reduce Realm File Size - Flutter SDK
The size of a realm is always larger than the total size of
the objects stored within it. This architecture enables some of realm's
performance, concurrency, and safety benefits.

Realm writes new data within unused space tracked inside a
file. In some situations, unused space may comprise a significant
portion of a realm file. Realm's default behavior is to automatically
compact a realm to prevent it from growing too large.
You can use manual compaction strategies when
automatic compaction is not sufficient for your use case.

## Automatic Compaction
> Version added: 0.9.0

The SDK automatically compacts Realm files in the background by continuously reallocating data
within the file and removing unused file space. Automatic compaction is sufficient for minimizing the Realm file size
for most applications.

## Manual Compaction Strategies
If automatic compaction is deemed insufficient, manual compaction
can be used for applications that require stricter management
of file size to improve performance. A production application should
implement manual compaction to periodically reduce the realm file size
if it does not use automatic compaction.

Compacting a realm can be an expensive operation that can block the UI thread.
Optimize compacting to balance frequency with performance gains. If your
application runs in a resource-constrained environment, you may want to
compact when you reach a certain file size or when the file size negatively
impacts performance.

Use either of the following two strategies to compact a realm file manually:

- Realm.compact() static method: Use this
method to compact a realm.
- Conditionally compact on open:
use the `shouldCompactCallback()` when you want to define one or more
conditions to determine whether to compact the realm. You might check
for a certain realm file size, a percentage of unused space, or other
conditions that are relevant to your performance needs or runtime
environment.

### Realm.compact() Static Method
You can compact a realm file by calling [Realm.compact()](https://pub.dev/documentation/realm/latest/realm/Realm/compact.html). This method takes a [Configuration](https://pub.dev/documentation/realm/latest/realm/Configuration-class.html) as an argument. When you use this method,
the device must have enough free space to make a copy of the realm.

`Realm.compact()` obtains an instance of the realm, and opens it to
trigger any schema version upgrades, file format upgrades, migration and
initial data callbacks. Upon successfully opening the realm and performing
these operations, this method then compacts the realm.

If successful, a call to `Realm.compact()` returns `true`.

Do not call this method from inside a transaction. You also cannot compact an
open realm.

```dart
final config = Configuration.local([Car.schema]);

final compacted = Realm.compact(config);
print(
    "Successfully compacted the realm: $compacted"); // On success, this prints "true"

final realm = Realm(config);

```

### Conditionally Compact on Open
You can define a [shouldCompactCallback()](https://pub.dev/documentation/realm/latest/realm/LocalConfiguration/shouldCompactCallback.html) as a property of a
realm's configuration. You can use this with the [Configuration.local()](https://pub.dev/documentation/realm/latest/realm/Configuration/local.html).

This callback takes two `int` values representing the total number of
bytes and the used bytes of the realm file on disk. The callback returns
a `bool`. Compaction only occurs if the `bool` returns `true` and
another process is not currently accessing the realm file.

The most basic usage is to define a file size at which compaction should occur.

```dart
final config = Configuration.local([Car.schema],
    shouldCompactCallback: ((totalSize, usedSize) {
  // shouldCompactCallback sizes are in bytes.
  // For convenience, this example defines a const
  // representing a byte to MB conversion for compaction
  // at an arbitrary 10MB file size.
  const tenMB = 10 * 1048576;
  return totalSize > tenMB;
}));
final realm = Realm(config);
```

You can define more complex logic if you need to optimize performance for
different use cases. For example, you could set a threshold for compaction
when a certain percentage of the file size is used.

```dart
final config = Configuration.local([Car.schema],
    shouldCompactCallback: ((totalSize, usedSize) {
  // Compact if the file is over 10MB in size and less than 50% 'used'
  const tenMB = 10 * 1048576;
  return (totalSize > tenMB) &&
      (usedSize.toDouble() / totalSize.toDouble()) < 0.5;
}));
final realm = Realm(config);
```
