#include "include/realm_flutter/realm_flutter_plugin_c_api.h"

#include <flutter/plugin_registrar_windows.h>

#include "realm_flutter_plugin.h"

void RealmFlutterPluginCApiRegisterWithRegistrar(
    FlutterDesktopPluginRegistrarRef registrar) {
  realm_flutter::RealmFlutterPlugin::RegisterWithRegistrar(
      flutter::PluginRegistrarManager::GetInstance()
          ->GetRegistrar<flutter::PluginRegistrarWindows>(registrar));
}
