import '../get_utils/get_utils.dart';

extension GetDynamicUtils on dynamic {
  /// Checks if the dynamic object is null or empty.
  ///
  /// Returns `true` if the object is null, an empty string, list, map, or set; otherwise, returns `false`.
  bool? get isBlank => GetUtils.isBlank(this);

  /// Prints an error message along with additional information.
  ///
  /// The [info] parameter can be used to provide additional context or details about the error.
  /// The [logFunction] parameter allows specifying a custom function for logging errors.
  void printError({
    String info = '',
    Function logFunction = GetUtils.printFunction,
  }) =>
      // ignore: unnecessary_this
      logFunction('Error: ${this.runtimeType}', this, info, isError: true);

  /// Prints an informational message along with additional information.
  ///
  /// The [info] parameter can be used to provide additional context or details about the information being printed.
  /// The [printFunction] parameter allows specifying a custom function for printing information.
  void printInfo({
    String info = '',
    Function printFunction = GetUtils.printFunction,
  }) =>
      // ignore: unnecessary_this
      printFunction('Info: ${this.runtimeType}', this, info);
}
