x.x.x Release notes (yyyy-MM-dd)
==============================================================

**This project is in the Alpha stage. All API's might change without warning and no guarantees are given about stability. Do not use it in production.**

### Enhancements
* Support change notifications on query results. ([#208](https://github.com/realm/realm-dart/pull/208))
* Support change notifications on list collections. ([#261](https://github.com/realm/realm-dart/pull/261))
* Support change notifications on realm objects. ([#262](https://github.com/realm/realm-dart/pull/262))
* Added support for checking if realm lists and realm objects are valid. ([#183](https://github.com/realm/realm-dart/pull/183))
* Support query on lists of realm objects. ([#239](https://github.com/realm/realm-dart/pull/239))
* Added support for opening realm in read-only mode. ([#260](https://github.com/realm/realm-dart/pull/260))
* Added support for opening in-memory realms. ([#280](https://github.com/realm/realm-dart/pull/280))
* Primary key fields no longer required to be `final` in data model classes ([#240](https://github.com/realm/realm-dart/pull/240))
* List fields no longer required to be `final` in data model classes. ([#253](https://github.com/realm/realm-dart/pull/253))
* Support custom FIFO special files. ([#284](https://github.com/realm/realm-dart/pull/284))
* Support flutter for Linux desktop. ([#279](https://github.com/realm/realm-dart/pull/279/))

### Compatibility
* Dart ^2.15 on Windows, MacOS and Linux
* Flutter ^2.10 on Android, iOS, Linux, MacOS and Windows

### Fixed
* Snapshot the results collection when iterating if the items are realm objects. ([#258](https://github.com/realm/realm-dart/pull/258))


0.2.0+alpha Release notes (2022-01-31)
==============================================================

**This project is in the Alpha stage. All API's might change without warning and no guarantees are given about stability. Do not use it in production.**

### Enhancements 
* Completely rewritten from the ground up with sound null safety and using Dart FFI

### Compatibility
* Dart ^2.15 on Windows, MacOS and Linux

0.2.0-alpha.2 Release notes (2022-01-29)
==============================================================

Notes: This release is a prerelease version. All API's might change without warning and no guarantees are given about stability. 

### Enhancements 
* Completеly rewritten from the ground up with sound null safety and using Dart FFI

### Fixed
* Fix running package commands.

### Compatibility
* Dart ^2.15 on Windows, MacOS and Linux

0.2.0-alpha.1 Release notes (2022-01-29)
==============================================================

Notes: This release is a prerelease version. All API's might change without warning and no guarantees are given about stability. 

### Enhancements 
* Completеly rewritten from the ground up with sound null safety and using Dart FFI

### Fixed
* Realm close stops internal scheduler.

### Internal
* Fix linter issues

### Compatibility
* Dart ^2.15 on Windows, MacOS and Linux

0.2.0-alpha Release notes (2022-01-27)
==============================================================

Notes: This release is a prerelease version. All API's might change without warning and no guarantees are given about stability. 

### Enhancements 
* Completеly rewritten from the ground up with sound null safety and using Dart FFI

### Compatibility
* Dart ^2.15 on Windows, MacOS and Linux

### Internal
* Uses Realm Core v11.9.0

0.1.1+preview Release notes (2021-04-01)
=============================================================
### Fixed
* `realm_dart install` command is correctly installing the realm native binary

### Compatibility
* Windows and Mac
* Dart SDK 2.12 stable from https://dart.dev/

0.1.0+preview Release notes (2021-04-01)
=============================================================
### Enhancements
* The initial preview version of the Realm SDK for Dart.

### Compatibility
* Windows and Mac
* Dart SDK 2.12 stable from https://dart.dev/