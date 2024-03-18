part of "../rx_types.dart";

/// Extension methods for [Rx<String>] to provide additional functionality.
extension RxStringExt on Rx<String> {
  /// Concatenates the current value of [Rx<String>] with [val].
  String operator +(String val) => value + val;

  /// Compares the current value of [Rx<String>] with [other].
  ///
  /// Returns a negative integer if the current value is less than [other],
  /// zero if they are equal, and a positive integer if the current value is greater than [other].
  int compareTo(String other) => value.compareTo(other);

  /// Returns true if this string ends with [other]. For example:
  ///
  ///     'Dart'.endsWith('t'); // true
  bool endsWith(String other) => value.endsWith(other);

  /// Returns true if this string starts with a match of [pattern].
  bool startsWith(Pattern pattern, [int index = 0]) =>
      value.startsWith(pattern, index);

  /// Returns the position of the first match of [pattern] in this string
  int indexOf(Pattern pattern, [int start = 0]) =>
      value.indexOf(pattern, start);

  /// Returns the starting position of the last match [pattern] in this string,
  /// searching backward starting at [start], inclusive:
  int lastIndexOf(Pattern pattern, [int? start]) =>
      value.lastIndexOf(pattern, start);

  /// Returns true if this string is empty.
  bool get isEmpty => value.isEmpty;

  /// Returns true if this string is not empty.
  bool get isNotEmpty => !isEmpty;

  /// Returns the substring of this string that extends from [startIndex],
  /// inclusive, to [endIndex], exclusive
  String substring(int startIndex, [int? endIndex]) =>
      value.substring(startIndex, endIndex);

  /// Returns the string without any leading and trailing whitespace.
  String trim() => value.trim();

  /// Returns the string without any leading whitespace.
  ///
  /// As [trim], but only removes leading whitespace.
  String trimLeft() => value.trimLeft();

  /// Returns the string without any trailing whitespace.
  ///
  /// As [trim], but only removes trailing whitespace.
  String trimRight() => value.trimRight();

  /// Pads this string on the left if it is shorter than [width].
  ///
  /// Return a new string that prepends [padding] onto this string
  /// one time for each position the length is less than [width].
  String padLeft(int width, [String padding = " "]) =>
      value.padLeft(width, padding);

  /// Pads this string on the right if it is shorter than [width].

  /// Return a new string that appends [padding] after this string
  /// one time for each position the length is less than [width].
  String padRight(int width, [String padding = " "]) =>
      value.padRight(width, padding);

  /// Returns true if this string contains a match of [other]:
  bool contains(Pattern other, [int startIndex = 0]) =>
      value.contains(other, startIndex);

  /// Replaces all substrings that match [from] with [replace].
  String replaceAll(Pattern from, String replace) =>
      value.replaceAll(from, replace);

  /// Splits the string at matches of [pattern] and returns a list
  /// of substrings.
  List<String> split(Pattern pattern) => value.split(pattern);

  /// Converts all characters in this string to lower case.
  /// If the string is already in all lower case, this method returns `this`.
  String toLowerCase() => value.toLowerCase();

  /// Converts all characters in this string to upper case.
  /// If the string is already in all upper case, this method returns `this`.
  String toUpperCase() => value.toUpperCase();

  Iterable<Match> allMatches(String string, [int start = 0]) =>
      value.allMatches(string, start);

  Match? matchAsPrefix(String string, [int start = 0]) =>
      value.matchAsPrefix(string, start);
}

extension RxnStringExt on Rx<String?> {
  String operator +(String val) => (value ?? "") + val;

  int? compareTo(String other) => value?.compareTo(other);

  /// Returns true if this string ends with [other]. For example:
  ///
  ///     'Dart'.endsWith('t'); // true
  bool? endsWith(String other) => value?.endsWith(other);

  /// Returns true if this string starts with a match of [pattern].
  bool? startsWith(Pattern pattern, [int index = 0]) =>
      value?.startsWith(pattern, index);

  /// Returns the position of the first match of [pattern] in this string
  int? indexOf(Pattern pattern, [int start = 0]) =>
      value?.indexOf(pattern, start);

  /// Returns the starting position of the last match [pattern] in this string,
  /// searching backward starting at [start], inclusive:
  int? lastIndexOf(Pattern pattern, [int? start]) =>
      value?.lastIndexOf(pattern, start);

  /// Returns true if this string is empty.
  bool? get isEmpty => value?.isEmpty;

  /// Returns true if this string is not empty.
  bool? get isNotEmpty => value?.isNotEmpty;

  /// Returns the substring of this string that extends from [startIndex],
  /// inclusive, to [endIndex], exclusive
  String? substring(int startIndex, [int? endIndex]) =>
      value?.substring(startIndex, endIndex);

  /// Returns the string without any leading and trailing whitespace.
  String? trim() => value?.trim();

  /// Returns the string without any leading whitespace.
  ///
  /// As [trim], but only removes leading whitespace.
  String? trimLeft() => value?.trimLeft();

  /// Returns the string without any trailing whitespace.
  ///
  /// As [trim], but only removes trailing whitespace.
  String? trimRight() => value?.trimRight();

  /// Pads this string on the left if it is shorter than [width].
  ///
  /// Return a new string that prepends [padding] onto this string
  /// one time for each position the length is less than [width].
  String? padLeft(int width, [String padding = " "]) =>
      value?.padLeft(width, padding);

  /// Pads this string on the right if it is shorter than [width].

  /// Return a new string that appends [padding] after this string
  /// one time for each position the length is less than [width].
  String? padRight(int width, [String padding = " "]) =>
      value?.padRight(width, padding);

  /// Returns true if this string contains a match of [other]:
  bool? contains(Pattern other, [int startIndex = 0]) =>
      value?.contains(other, startIndex);

  /// Replaces all substrings that match [from] with [replace].
  String? replaceAll(Pattern from, String replace) =>
      value?.replaceAll(from, replace);

  /// Splits the string at matches of [pattern] and returns a list
  /// of substrings.
  List<String>? split(Pattern pattern) => value?.split(pattern);

  /// Converts all characters in this string to lower case.
  /// If the string is already in all lower case, this method returns `this`.
  String? toLowerCase() => value?.toLowerCase();

  /// Converts all characters in this string to upper case.
  /// If the string is already in all upper case, this method returns `this`.
  String? toUpperCase() => value?.toUpperCase();

  Iterable<Match>? allMatches(String string, [int start = 0]) =>
      value?.allMatches(string, start);

  Match? matchAsPrefix(String string, [int start = 0]) =>
      value?.matchAsPrefix(string, start);
}

/// Rx class for `String` Type.
class RxString extends Rx<String> implements Comparable<String>, Pattern {
  /// constructor [RxString]
  RxString(super.initial);

  @override
  Iterable<Match> allMatches(String string, [int start = 0]) =>
      value.allMatches(string, start);

  @override
  Match? matchAsPrefix(String string, [int start = 0]) =>
      value.matchAsPrefix(string, start);

  @override
  int compareTo(String other) => value.compareTo(other);
}

/// Rx class for `String` Type.
class RxnString extends Rx<String?> implements Comparable<String>, Pattern {
  /// constructor [RxnString]
  RxnString([super.initial]);

  @override
  Iterable<Match> allMatches(String string, [int start = 0]) =>
      value!.allMatches(string, start);

  @override
  Match? matchAsPrefix(String string, [int start = 0]) =>
      value!.matchAsPrefix(string, start);

  @override
  int compareTo(String other) => value!.compareTo(other);
}
