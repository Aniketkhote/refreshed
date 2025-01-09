// ignore_for_file: no_runtimetype_tostring, avoid_dynamic_calls

import "package:refreshed/get_utils/src/get_utils/get_utils.dart";

/// Extension on dynamic to provide utility methods for dynamic objects.
extension DynamicExtension on dynamic {
  /// Checks if the dynamic object is null, empty, or consists only of whitespace.
  /// Returns `true` if the object is blank; otherwise, returns `false`.
  bool get isBlank => GetUtils.isBlank(this);

  /// Prints an error message with optional additional [info].
  /// Allows specifying a custom [logFunction] to handle the printing.
  void printError({
    String info = "",
    Function logFunction = GetUtils.printFunction,
  }) =>
      logFunction("Error: $runtimeType", this, info, isError: true);

  /// Prints an information message with optional additional [info].
  /// Allows specifying a custom [printFunction] to handle the printing.
  void printInfo({
    String info = "",
    Function printFunction = GetUtils.printFunction,
  }) =>
      printFunction("Info: $runtimeType", this, info);
}
