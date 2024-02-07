#ifndef FLUTTER_PLUGIN_REALM_PLUGIN_H_
#define FLUTTER_PLUGIN_REALM_PLUGIN_H_

#include <flutter_linux/flutter_linux.h>

G_BEGIN_DECLS

#ifdef FLUTTER_PLUGIN_IMPL
#define FLUTTER_PLUGIN_EXPORT __attribute__((visibility("default")))
#else
#define FLUTTER_PLUGIN_EXPORT
#endif

typedef struct _RealmPlugin RealmPlugin;
typedef struct {
  GObjectClass parent_class;
} RealmPluginClass;

FLUTTER_PLUGIN_EXPORT GType realm_plugin_get_type();

FLUTTER_PLUGIN_EXPORT void realm_plugin_register_with_registrar(
    FlPluginRegistrar* registrar);

FLUTTER_PLUGIN_EXPORT const char* realm_dart_get_app_directory();

FLUTTER_PLUGIN_EXPORT const char* realm_dart_get_bundle_id();

G_END_DECLS

#endif  // FLUTTER_PLUGIN_REALM_PLUGIN_H_
