//
//  Generated file. Do not edit.
//

// clang-format off

#include "generated_plugin_registrant.h"

#include <sanad_pusher_client/sanad_pusher_client_plugin.h>

void fl_register_plugins(FlPluginRegistry* registry) {
  g_autoptr(FlPluginRegistrar) sanad_pusher_client_registrar =
      fl_plugin_registry_get_registrar_for_plugin(registry, "SanadPusherClientPlugin");
  sanad_pusher_client_plugin_register_with_registrar(sanad_pusher_client_registrar);
}
