import "package:refreshed/utils.dart";

/// Returns whether a dynamic value PROBABLY
/// has the isEmpty getter/method by checking
/// standard dart types that contains it.
///
/// This is here to for the 'DRY'
bool? _isEmpty(value) {
  if (value is String) {
    return value.trim().isEmpty;
  }
  if (value is Iterable || value is Map) {
    return value.isEmpty as bool?;
  }
  return false;
}

/// Utility methods
class GetUtils {
  GetUtils._();

  /// Checks if data is null.
  static bool isNull(value) => value == null;

  /// In dart2js (in flutter v1.17) a var by default is undefined.
  /// *Use this only if you are in version <- 1.17*.
  /// So we assure the null type in json conversions to avoid the
  /// "value":value==null?null:value; someVar.nil will force the null type
  /// if the var is null or undefined.
  /// `nil` taken from ObjC just to have a shorter syntax.
  static dynamic nil(s) => s;

  /// Checks if data is null or blank (empty or only contains whitespace).
  static bool? isNullOrBlank(value) {
    if (isNull(value)) {
      return true;
    }

    // Pretty sure that isNullOrBlank should't be validating
    // iterables... but I'm going to keep this for compatibility.
    return _isEmpty(value);
  }

  /// Checks if data is null or blank (empty or only contains whitespace).
  static bool? isBlank(value) => _isEmpty(value);

  /// Checks if string is int or double.
  static bool isNum(String value) {
    if (isNull(value)) {
      return false;
    }

    return num.tryParse(value) is num;
  }

  /// Checks if a given [value] matches a [pattern] using a regular expression.
  ///
  /// Returns `true` if the [value] matches the [pattern], `false` otherwise.
  static bool hasMatch(String? value, String pattern) =>
      (value == null) ? false : RegExp(pattern).hasMatch(value);

  /// Creates a path by concatenating the provided [path] and [segments].
  ///
  /// If [segments] is `null` or empty, the original [path] is returned.
  /// Otherwise, the [path] is concatenated with each segment from [segments]
  /// separated by a forward slash ('/').
  static String createPath(String path, [Iterable<String>? segments]) {
    if (segments == null || segments.isEmpty) {
      return path;
    }
    final Iterable<String> list = segments.map((String e) => "/$e");
    return path + list.join();
  }

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
