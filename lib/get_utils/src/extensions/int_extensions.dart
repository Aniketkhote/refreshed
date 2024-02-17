extension DurationExt on int {
  /// Converts the integer to a [Duration] representing the given number of seconds.
  ///
  /// Example:
  /// ```dart
  /// final duration = 5.seconds;
  /// ```
  Duration get seconds => Duration(seconds: this);

  /// Converts the integer to a [Duration] representing the given number of days.
  ///
  /// Example:
  /// ```dart
  /// final duration = 3.days;
  /// ```
  Duration get days => Duration(days: this);

  /// Converts the integer to a [Duration] representing the given number of hours.
  ///
  /// Example:
  /// ```dart
  /// final duration = 12.hours;
  /// ```
  Duration get hours => Duration(hours: this);

  /// Converts the integer to a [Duration] representing the given number of minutes.
  ///
  /// Example:
  /// ```dart
  /// final duration = 30.minutes;
  /// ```
  Duration get minutes => Duration(minutes: this);

  /// Converts the integer to a [Duration] representing the given number of milliseconds.
  ///
  /// Example:
  /// ```dart
  /// final duration = 500.milliseconds;
  /// ```
  Duration get milliseconds => Duration(milliseconds: this);

  /// Converts the integer to a [Duration] representing the given number of microseconds.
  ///
  /// Example:
  /// ```dart
  /// final duration = 2500.microseconds;
  /// ```
  Duration get microseconds => Duration(microseconds: this);

  /// Alias for [milliseconds].
  ///
  /// Example:
  /// ```dart
  /// final duration = 500.ms;
  /// ```
  Duration get ms => milliseconds;
}
