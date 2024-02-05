#ifndef FLUTTER_PLUGIN_SANAD_PUSHER_CLIENT_PLUGIN_H_
#define FLUTTER_PLUGIN_SANAD_PUSHER_CLIENT_PLUGIN_H_

#include <flutter/method_channel.h>
#include <flutter/plugin_registrar_windows.h>

#include <memory>

namespace sanad_pusher_client {

class SanadPusherClientPlugin : public flutter::Plugin {
 public:
  static void RegisterWithRegistrar(flutter::PluginRegistrarWindows *registrar);

  SanadPusherClientPlugin();

  virtual ~SanadPusherClientPlugin();

  // Disallow copy and assign.
  SanadPusherClientPlugin(const SanadPusherClientPlugin&) = delete;
  SanadPusherClientPlugin& operator=(const SanadPusherClientPlugin&) = delete;

  // Called when a method is called on this plugin's channel from Dart.
  void HandleMethodCall(
      const flutter::MethodCall<flutter::EncodableValue> &method_call,
      std::unique_ptr<flutter::MethodResult<flutter::EncodableValue>> result);
};

}  // namespace sanad_pusher_client

#endif  // FLUTTER_PLUGIN_SANAD_PUSHER_CLIENT_PLUGIN_H_
