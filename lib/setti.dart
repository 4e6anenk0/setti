/// Support for doing something awesome.
///
/// More dartdocs go here.
library;

//export 'src/setti.dart';
export 'src/setti_configurations.dart';
export 'src/setti_layer.dart';
export 'src/setting_types/base/setting.dart';
export 'src/setting_types/enum/enum_setting.dart';
export 'src/setting_types/storage_rules.dart';
export 'src/storage/interfaces/settings_storage_interface.dart';
export 'src/exceptions/exceptions.dart';
export 'src/setti.dart';
export 'src/setti_manager.dart';

/* export 'src/storage/local/storages/vm_storages.dart'
    if (dart.library.js) 'src/storage/local/storages/web_storages.dart'
    if (dart.library.html) 'src/storage/local/storages/web_storages.dart'; */

export 'src/platform/setti.dart'
    if (dart.library.io) 'src/platform/os/setti.dart'
    if (dart.library.js_interop) 'src/platform/web/setti.dart'
    if (dart.library.js) 'src/platform/web/setti.dart'
    if (dart.library.html) 'src/platform/web/setti.dart';
//export 'src/storage/local/storages/ini_storage.dart' show Ini;

// TODO: Export any libraries intended for clients of this package.
