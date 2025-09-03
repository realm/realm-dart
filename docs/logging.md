# Logging - Flutter SDK
> Version changed: v2.0.0

You can set or change your app's log level when developing or debugging
your application. You might want to change the log level to log different
amounts of data depending on your development needs. You can specify
different log levels or custom loggers on a per-isolate basis.

## Set or Change the Realm Log Level
In the Flutter SDK, you can set the level of detail in different parts of
your app. To configure the log level, pass a valid
[LogLevel](https://pub.dev/documentation/realm/latest/realm/LogLevel.html) value to
[setLogLevel](https://pub.dev/documentation/realm/latest/realm/RealmLogger/setLogLevel.html).

```dart
// If no category is set, default is LogCategory.realm
Realm.logger.setLogLevel(LogLevel.all, category: LogCategory.realm);
```

You can change the log level to increase or decrease verbosity at different
points in your code.

```dart
Realm.logger.setLogLevel(LogLevel.off);
await executeAppCode();

Realm.logger.setLogLevel(LogLevel.debug, category: LogCategory.realm);
await executeComplexCodeToDebug();
```

## Customize the Logger
The Flutter SDK logger conforms to the [Dart Logger class](https://pub.dev/documentation/logging/latest/logging/Logger-class.html).

To get started, set a log level:

```dart
Realm.logger.onRecord.listen((record) {
  // Do something with the log record
  print(record.message);
});
```

Define custom logging behavior by listening to [Realm.logger.onRecord](https://pub.dev/documentation/realm/latest/realm/RealmLogger/onRecord.html):

```dart
Realm.logger.onRecord.listen((event) {
  // Do something with the log event - for example, print to console
  print("Realm log message: '$event'");
});
```

## Turn Off Logging
You can turn off logging by passing `LogLevel.off` to `setLogLevel()`:

```dart
Realm.logger.setLogLevel(LogLevel.off);
```
