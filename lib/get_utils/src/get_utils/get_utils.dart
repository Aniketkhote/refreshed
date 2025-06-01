import "package:refreshed/utils.dart";

/// Returns whether a dynamic value PROBABLY
/// has the isEmpty getter/method by checking
/// standard dart types that contains it.
///
/// This is here for the 'DRY' principle
bool _isEmpty(dynamic value) {
  switch (value) {
    case null:
      return true;
    case String():
      return value.trim().isEmpty;
    case Iterable() || Map():
      return value.isEmpty;
    default:
      return false;
  }
}

/// Utility methods
class GetUtils {
  GetUtils._();

  /// Checks if data is null.
  static bool isNull(dynamic value) => value == null;

  /// Checks if data is null or blank (empty or only contains whitespace).
  static bool isNullOrBlank(dynamic value) => value == null || _isEmpty(value);

  /// Checks if data is null or blank (empty or only contains whitespace).
  static bool isBlank(dynamic value) => _isEmpty(value);

  /// Checks if string is int or double.
  static bool isNum(String? value) =>
      switch (value) { null => false, _ => num.tryParse(value) is num };

  /// Checks if a given [value] matches a [pattern] using a regular expression.
  ///
  /// Returns `true` if the [value] matches the [pattern], `false` otherwise.
  static bool hasMatch(String? value, String pattern) =>
      switch (value) { null => false, _ => RegExp(pattern).hasMatch(value) };

  /// Creates a path by concatenating the provided [path] and [segments].
  ///
  /// If [segments] is `null` or empty, the original [path] is returned.
  /// Otherwise, the [path] is concatenated with each segment from [segments]
  /// separated by a forward slash ('/').
  static String createPath(String path, [Iterable<String>? segments]) =>
      switch (segments) {
        null || Iterable(isEmpty: true) => path,
        _ => path + segments.map((e) => "/$e").join()
      };

  /// Utility function for printing logs with a specified prefix and additional information.
  ///
  /// This function logs the provided [value] along with the [prefix] and [info].
  /// If [isError] is set to true, the log is marked as an error.
  ///
  /// Example:
  /// ```dart
  /// printFunction('DEBUG:', 'Something happened', 'Additional information');
  /// ```
  ///
  /// This function delegates the logging to `Get.log` method from the Get package.
  /// Ensure that the Get package is imported and initialized properly for logging to work.
  ///
  /// See also:
  /// - [Get.log], the method used internally for logging.
  static void printFunction<T>(
    String prefix,
    T value,
    String info, {
    bool isError = false,
  }) {
    Get.log("$prefix $value $info".trim(), isError: isError);
  }
}

/// Callback type definition for a function that prints logs with optional error indication.
///
/// This typedef defines a function signature for logging purposes, where:
/// - [prefix] is a string indicating the prefix of the log message.
/// - [value] is the dynamic value to be logged.
/// - [info] provides additional information to be included in the log message.
/// - [isError] is an optional boolean parameter indicating if the log represents an error.
///
/// Example:
/// ```dart
/// PrintFunctionCallback myLogger = (prefix, value, info, {isError}) {
///   printFunction(prefix, value, info, isError: isError ?? false);
/// };
///
/// myLogger('ERROR:', 'An error occurred', 'Something went wrong', isError: true);
/// ```
///
/// This typedef can be used to define functions that conform to this signature,
/// providing flexibility in handling logging operations within Dart applications.
typedef PrintFunctionCallback<T> = void Function(
  String prefix,
  T value,
  String info, {
  bool? isError,
});
