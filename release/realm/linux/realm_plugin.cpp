#include "include/realm/realm_plugin.h"

#include <flutter_linux/flutter_linux.h>
#include <gtk/gtk.h>
#include <sys/utsname.h>

#include <cstring>

#include <string>

#ifndef APP_DIR_NAME
#define APP_DIR_NAME "realm_app"
#endif

#ifndef BUNDLE_ID
#define BUNDLE_ID "realm_bundle_id"
#endif

#define REALM_PLUGIN(obj) \
  (G_TYPE_CHECK_INSTANCE_CAST((obj), realm_plugin_get_type(), \
                              RealmPlugin))

struct _RealmPlugin {
  GObject parent_instance;
};

G_DEFINE_TYPE(RealmPlugin, realm_plugin, g_object_get_type())

// Called when a method call is received from Flutter.
static void realm_plugin_handle_method_call(
    RealmPlugin* self,
    FlMethodCall* method_call) {
  g_autoptr(FlMethodResponse) response = nullptr;

  response = FL_METHOD_RESPONSE(fl_method_not_implemented_response_new());

  fl_method_call_respond(method_call, response, nullptr);
}

static void realm_plugin_dispose(GObject* object) {
  G_OBJECT_CLASS(realm_plugin_parent_class)->dispose(object);
}

static void realm_plugin_class_init(RealmPluginClass* klass) {
  G_OBJECT_CLASS(klass)->dispose = realm_plugin_dispose;
}

static void realm_plugin_init(RealmPlugin* self) {}

static void method_call_cb(FlMethodChannel* channel, FlMethodCall* method_call,
                           gpointer user_data) {
  RealmPlugin* plugin = REALM_PLUGIN(user_data);
  realm_plugin_handle_method_call(plugin, method_call);
}

void realm_plugin_register_with_registrar(FlPluginRegistrar* registrar) {
  RealmPlugin* plugin = REALM_PLUGIN(
      g_object_new(realm_plugin_get_type(), nullptr));

  g_autoptr(FlStandardMethodCodec) codec = fl_standard_method_codec_new();
  g_autoptr(FlMethodChannel) channel =
      fl_method_channel_new(fl_plugin_registrar_get_messenger(registrar),
                            "realm",
                            FL_METHOD_CODEC(codec));
  fl_method_channel_set_method_call_handler(channel, method_call_cb,
                                            g_object_ref(plugin),
                                            g_object_unref);

  g_object_unref(plugin);
}

static std::string appDirName = APP_DIR_NAME;
static std::string bundleId = BUNDLE_ID;

const char* realm_dart_get_app_directory() {
    return appDirName.c_str();
}

const char* realm_dart_get_bundle_id() {
    return bundleId.c_str();
}
