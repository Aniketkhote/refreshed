import 'package:flutter/foundation.dart';

import 'log.dart';
import 'smart_management.dart';

/// A contract defining the interface for interacting with the "Get" class,
/// enabling auxiliary packages to extend its functionality through extensions.
abstract class GetInterface {
  /// Defines the default strategy for managing the state of the application.
  SmartManagement smartManagement = SmartManagement.full;

  /// Indicates whether logging is enabled. By default, it follows the
  /// debug mode setting of the application.
  bool isLogEnable = kDebugMode;

  /// A callback function responsible for writing logs. By default, it
  /// uses the default log writer callback provided by the framework.
  LogWriterCallback log = defaultLogWriterCallback;
}
