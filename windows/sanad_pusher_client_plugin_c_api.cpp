#include "include/sanad_pusher_client/sanad_pusher_client_plugin_c_api.h"

#include <flutter/plugin_registrar_windows.h>

#include "sanad_pusher_client_plugin.h"

void SanadPusherClientPluginCApiRegisterWithRegistrar(
    FlutterDesktopPluginRegistrarRef registrar) {
  sanad_pusher_client::SanadPusherClientPlugin::RegisterWithRegistrar(
      flutter::PluginRegistrarManager::GetInstance()
          ->GetRegistrar<flutter::PluginRegistrarWindows>(registrar));
}
