//
//  Generated file. Do not edit.
//

// clang-format off

#include "generated_plugin_registrant.h"

#include <print_usb/print_usb_plugin_c_api.h>
#include <windows_printer/windows_printer_plugin_c_api.h>

void RegisterPlugins(flutter::PluginRegistry* registry) {
  PrintUsbPluginCApiRegisterWithRegistrar(
      registry->GetRegistrarForPlugin("PrintUsbPluginCApi"));
  WindowsPrinterPluginCApiRegisterWithRegistrar(
      registry->GetRegistrarForPlugin("WindowsPrinterPluginCApi"));
}
