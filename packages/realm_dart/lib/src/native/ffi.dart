// Import this file instead of package:ffi/ffi.dart
// Hides StringUtf8Pointer.toNativeUtf8 and StringUtf16Pointer since these allows
// silently allocating memory. Use toUtf8Ptr instead
export 'package:ffi/ffi.dart' hide StringUtf8Pointer, StringUtf16Pointer;
