import "dart:developer" as developer;

import "package:refreshed/get_core/src/get_main.dart";

/// A typedef representing a callback function for writing logs, typically used in the context of Refreshed.
typedef LogWriterCallback = void Function(String text, {bool isError});

/// The default logger function used by Refreshed for writing logs.
///
/// It takes a [value] parameter representing the log text and an optional [isError]
/// parameter indicating whether the log is an error message. By default, if [isError]
/// is not provided, it is assumed to be false. If [isError] is true or if logging
/// is enabled (as determined by [Get.isLogEnable]), the log message is written
/// using the developer log provided by the framework.
void defaultLogWriterCallback(String value, {bool isError = false}) {
  if (isError || Get.isLogEnable) {
    developer.log(value, name: "Refreshed");
  }
}
