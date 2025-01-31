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
  String operator +(String val) => (value ?? "") + val;

  /// Returns true if this string is empty.
  bool? get isEmpty => value?.isEmpty;

  /// Returns true if this string is not empty.
  bool? get isNotEmpty => value?.isNotEmpty;

  /// Returns the string without any leading and trailing whitespace.
  String? trim() => value?.trim();
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
