#include "include/realm/realm_plugin.h"

// This must be included before many other Windows headers.
#include <windows.h>

#include <shlobj_core.h>
#include <Knownfolders.h>
#include <combaseapi.h>
#include <sstream>

#include <flutter/method_channel.h>
#include <flutter/plugin_registrar_windows.h>
#include <flutter/standard_method_codec.h>

#include <map>
#include <memory>
#include <sstream>

#ifndef APP_DIR_NAME
#define APP_DIR_NAME "realm_app"
#endif

// #pragma message("APP_DIR_NAME is " _CRT_STRINGIZE(APP_DIR_NAME))

namespace
{
class RealmPlugin : public flutter::Plugin
{
public:
    static void RegisterWithRegistrar(flutter::PluginRegistrarWindows* registrar);

    RealmPlugin();

    virtual ~RealmPlugin();

private:
    // Called when a method is called on this plugin's channel from Dart.
    void HandleMethodCall(
        const flutter::MethodCall<flutter::EncodableValue>& method_call,
        std::unique_ptr<flutter::MethodResult<flutter::EncodableValue>> result);
};

// static
void RealmPlugin::RegisterWithRegistrar(flutter::PluginRegistrarWindows* registrar)
{
    //TODO: these channels seem unneccessary. Remove if not needed
    auto channel = std::make_unique<flutter::MethodChannel<flutter::EncodableValue>>(registrar->messenger(), "realm", &flutter::StandardMethodCodec::GetInstance());

    auto plugin = std::make_unique<RealmPlugin>();

    channel->SetMethodCallHandler(
        [plugin_pointer = plugin.get()](const auto& call, auto result)
    {
        plugin_pointer->HandleMethodCall(call, std::move(result));
    });

    registrar->AddPlugin(std::move(plugin));
}

RealmPlugin::RealmPlugin() {}

RealmPlugin::~RealmPlugin() {}

void RealmPlugin::HandleMethodCall(
    const flutter::MethodCall<flutter::EncodableValue>& method_call,
    std::unique_ptr<flutter::MethodResult<flutter::EncodableValue>> result)
{
    result->NotImplemented();
}

} // namespace

void RealmPluginRegisterWithRegistrar(
    FlutterDesktopPluginRegistrarRef registrar)
{
    RealmPlugin::RegisterWithRegistrar(flutter::PluginRegistrarManager::GetInstance()->GetRegistrar<flutter::PluginRegistrarWindows>(registrar));
}

static std::wstring appDirName;

// Returns the app directory on the current machine or null if getting the default directory fails
// On Windows this is the C:\Users\username\AppData\Roaming\app_name directory
const wchar_t* realm_dart_get_app_directory() {
    if (!appDirName.empty()) {
        return appDirName.c_str();
    }

    PWSTR ppszPath;
    int hResult = SHGetKnownFolderPath(FOLDERID_RoamingAppData, KF_FLAG_DEFAULT, NULL, &ppszPath);
    if (!SUCCEEDED(hResult)) {
        CoTaskMemFree(ppszPath);
        return nullptr;
    }

    std::wstringstream ss;
    ss << ppszPath << "\\" << APP_DIR_NAME;
    appDirName = ss.str();

    CoTaskMemFree(ppszPath);

    return  appDirName.c_str();
}