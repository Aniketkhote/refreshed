import 'dart:math';

/// Extension providing additional functionality for doubles.
extension DoubleExt on double {
  /// Returns this double value rounded to the specified number of decimal places.
  ///
  /// [fractionDigits] is the number of digits after the decimal point.
  double toPrecision(int fractionDigits) {
    var mod = pow(10, fractionDigits.toDouble()).toDouble();
    return ((this * mod).round().toDouble() / mod);
  }

  /// Returns a [Duration] representing this double value in milliseconds.
  Duration get milliseconds => Duration(microseconds: (this * 1000).round());

  /// Alias for [milliseconds].
  Duration get ms => milliseconds;

  /// Returns a [Duration] representing this double value in seconds.
  Duration get seconds => Duration(milliseconds: (this * 1000).round());

  /// Returns a [Duration] representing this double value in minutes.
  Duration get minutes =>
      Duration(seconds: (this * Duration.secondsPerMinute).round());

  /// Returns a [Duration] representing this double value in hours.
  Duration get hours =>
      Duration(minutes: (this * Duration.minutesPerHour).round());

  /// Returns a [Duration] representing this double value in days.
  Duration get days => Duration(hours: (this * Duration.hoursPerDay).round());
}
