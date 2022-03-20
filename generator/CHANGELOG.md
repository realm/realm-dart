0.2.1+alpha Release notes (2022-03-20)
=============================================================

**This project is in the Alpha stage. All API's might change without warning and no guarantees are given about stability. Do not use it in production.**

### Enhancements 
* Support for object notifications. Generated code for `RealmObject.changes` method. [#262](https://github.com/realm/realm-dart/pull/262)
* Generated code now returns `RealmList` for `List<T>` model property types. [#270](https://github.com/realm/realm-dart/pull/270)
* Removes `final` requirement for primary keys. [#253](https://github.com/realm/realm-dart/pull/253)
* Removed `final` requirement for list properties. [#253](https://github.com/realm/realm-dart/pull/253)
* Generated code throws exception if primary key is being set. [#253](https://github.com/realm/realm-dart/pull/253)

### Internal
* `RealmObject`s are now also `RealmEntity`. A class for sharing common logic. This class should not be used directly.

### Compatibility
* Flutter ^2.8 and Dart ^2.15

0.2.0+alpha Release notes (2022-01-31)
=============================================================

**This project is in the Alpha stage. All API's might change without warning and no guarantees are given about stability. Do not use it in production.**

### Enhancements 
* Completely rewritten from the ground up with sound null safety and using Dart FFI and new way of defining realm models

### Compatibility
* Flutter ^2.8 and Dart ^2.15

0.2.0-alpha.1 Release notes (2022-01-29)
=============================================================

Notes: This release is a prerelease version. All API's might change without warning and no guarantees are given about stability. 

### Enhancements 
* Completеly rewritten from the ground up with sound null safety and using Dart FFI bindings and new way of defining realm models

### Internal
* Fixed linter issues

### Compatibility
* Dart ^2.15

0.2.0-alpha Release notes (2022-01-27)
=============================================================

Notes: This release is a prerelease version. All API's might change without warning and no guarantees are given about stability. 

### Enhancements 
* Completеly rewritten from the ground up with sound null safety and using Dart FFI bindings and new way of defining realm models

### Compatibility
* Dart ^2.15


0.1.0+preview Release notes (2021-04-01)
=============================================================
### Enhancements
* The initial preview version of the Realm Generator for Realm Flutter and Realm Dart SDKs