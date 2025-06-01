part of "../rx_types.dart";

/// Extension methods for [Rx<String>] to provide additional functionality.
extension RxStringExt on Rx<String> {
  /// Concatenates the current value of [Rx<String>] with [val].
  String operator +(String val) => value + val;

  /// Returns true if this string is empty.
  bool get isEmpty => value.isEmpty;

  /// Returns true if this string is not empty.
  bool get isNotEmpty => !isEmpty;

  /// Returns the string without any leading and trailing whitespace.
  String trim() => value.trim();
}

extension RxnStringExt on Rx<String?> {
  /// Concatenates the current value of [Rx<String?>] with [val].
  String operator +(String val) => (value ?? "") + val;

  /// Returns true if this string is empty.
  bool? get isEmpty => value?.isEmpty;

  /// Returns true if this string is not empty.
  bool? get isNotEmpty => value?.isNotEmpty;

  /// Returns the string without any leading and trailing whitespace.
  String? trim() => value?.trim();
  
  /// Returns true if the string is null or empty.
  bool get isNullOrEmpty => switch (value) {
    null => true,
    var str => str.isEmpty
  };
  
  /// Returns the string or a default value if the string is null.
  String orDefault(String defaultValue) => value ?? defaultValue;
  
  /// Returns the length of the string or 0 if the string is null.
  int get length => value?.length ?? 0;
}

/// Rx class for `String` Type.
class RxString extends Rx<String> {
  /// constructor [RxString]
  RxString(super.initial);
}

/// Rx class for `String` Type.
class RxnString extends Rx<String?> {
  /// constructor [RxnString]
  RxnString([super.initial]);
}
