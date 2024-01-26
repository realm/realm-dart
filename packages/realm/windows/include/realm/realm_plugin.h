#ifndef FLUTTER_PLUGIN_REALM_PLUGIN_H_
#define FLUTTER_PLUGIN_REALM_PLUGIN_H_

#include <flutter_plugin_registrar.h>

#ifdef FLUTTER_PLUGIN_IMPL
#define FLUTTER_PLUGIN_EXPORT __declspec(dllexport)
#else
#define FLUTTER_PLUGIN_EXPORT __declspec(dllimport)
#endif

#if defined(__cplusplus)
extern "C" {
#endif

FLUTTER_PLUGIN_EXPORT void RealmPluginRegisterWithRegistrar(
    FlutterDesktopPluginRegistrarRef registrar);

FLUTTER_PLUGIN_EXPORT const wchar_t* realm_dart_get_app_directory();

FLUTTER_PLUGIN_EXPORT const char* realm_dart_get_bundle_id();

#if defined(__cplusplus)
}  // extern "C"
#endif

#endif  // FLUTTER_PLUGIN_REALM_PLUGIN_H_
