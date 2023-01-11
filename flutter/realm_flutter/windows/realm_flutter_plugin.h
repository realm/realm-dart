#ifndef FLUTTER_PLUGIN_REALM_FLUTTER_PLUGIN_H_
#define FLUTTER_PLUGIN_REALM_FLUTTER_PLUGIN_H_

#include <flutter/method_channel.h>
#include <flutter/plugin_registrar_windows.h>

#include <memory>

namespace realm_flutter {

class RealmFlutterPlugin : public flutter::Plugin {
 public:
  static void RegisterWithRegistrar(flutter::PluginRegistrarWindows *registrar);

  RealmFlutterPlugin();

  virtual ~RealmFlutterPlugin();

  // Disallow copy and assign.
  RealmFlutterPlugin(const RealmFlutterPlugin&) = delete;
  RealmFlutterPlugin& operator=(const RealmFlutterPlugin&) = delete;

 private:
  // Called when a method is called on this plugin's channel from Dart.
  void HandleMethodCall(
      const flutter::MethodCall<flutter::EncodableValue> &method_call,
      std::unique_ptr<flutter::MethodResult<flutter::EncodableValue>> result);
};

}  // namespace realm_flutter

#endif  // FLUTTER_PLUGIN_REALM_FLUTTER_PLUGIN_H_
