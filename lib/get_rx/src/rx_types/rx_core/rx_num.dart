part of "../rx_types.dart";

/// Extension providing additional functionality for numeric values wrapped in an [Rx] object.
extension RxNumExt<T extends num> on Rx<T> {
  /// Multiplication operator.
  num operator *(num other) => value * other;

  /// Euclidean modulo operator.
  ///
  /// Returns the remainder of the Euclidean division. The Euclidean division of
  /// two integers `a` and `b` yields two integers `q` and `r` such that
  /// `a == b * q + r` and `0 <= r < b.abs()`.
  ///
  /// The Euclidean division is only defined for integers, but can be easily
  /// extended to work with doubles. In that case `r` may have a non-integer
  /// value, but it still verifies `0 <= r < |b|`.
  ///
  /// The sign of the returned value `r` is always positive.
  ///
  /// See [remainder] for the remainder of the truncating division.
  num operator %(num other) => value % other;

  /// Division operator.
  double operator /(num other) => value / other;

  /// Truncating division operator.
  ///
  /// If either operand is a [double] then the result of the truncating division
  /// `a ~/ b` is equivalent to `(a / b).truncate().toInt()`.
  ///
  /// If both operands are [int]s then `a ~/ b` performs the truncating
  /// integer division.
  int operator ~/(num other) => value ~/ other;

  /// Negate operator.
  num operator -() => -value;

  /// Relational less than operator.
  bool operator <(num other) => value < other;

  /// Relational less than or equal operator.
  bool operator <=(num other) => value <= other;

  /// Relational greater than operator.
  bool operator >(num other) => value > other;

  /// Relational greater than or equal operator.
  bool operator >=(num other) => value >= other;

  /// True if the number is the double Not-a-Number value; otherwise, false.
  bool get isNaN => value.isNaN;

  /// Truncates this [num] to an integer and returns the result as an [int]. */
  int toInt() => value.toInt();

  /// Return this [num] as a [double].
  ///
  /// If the number is not representable as a [double], an
  /// approximation is returned. For numerically large integers, the
  /// approximation may be infinite.
  double toDouble() => value.toDouble();
}

/// Extension providing additional functionality for nullable numeric values wrapped in an [Rx] object.
extension RxnNumExt<T extends num> on Rx<T?> {
  /// Multiplication operator.
  num? operator *(num other) {
    if (value != null) {
      return value! * other;
    }
    return null;
  }

  /// Euclidean modulo operator.
  ///
  /// Returns the remainder of the Euclidean division. The Euclidean division of
  /// two integers `a` and `b` yields two integers `q` and `r` such that
  /// `a == b * q + r` and `0 <= r < b.abs()`.
  ///
  /// The Euclidean division is only defined for integers, but can be easily
  /// extended to work with doubles. In that case `r` may have a non-integer
  /// value, but it still verifies `0 <= r < |b|`.
  ///
  /// The sign of the returned value `r` is always positive.
  ///
  /// See [remainder] for the remainder of the truncating division.
  num? operator %(num other) {
    if (value != null) {
      return value! % other;
    }
    return null;
  }

  /// Division operator.
  double? operator /(num other) {
    if (value != null) {
      return value! / other;
    }
    return null;
  }

  /// Truncating division operator.
  ///
  /// If either operand is a [double] then the result of the truncating division
  /// `a ~/ b` is equivalent to `(a / b).truncate().toInt()`.
  ///
  /// If both operands are [int]s then `a ~/ b` performs the truncating
  /// integer division.
  int? operator ~/(num other) {
    if (value != null) {
      return value! ~/ other;
    }
    return null;
  }

  /// Negate operator.
  num? operator -() {
    if (value != null) {
      return -value!;
    }
    return null;
  }

  /// Relational less than or equal operator.
  bool? operator <=(num other) {
    if (value != null) {
      return value! <= other;
    }
    return null;
  }

  /// Relational greater than operator.
  bool? operator >(num other) {
    if (value != null) {
      return value! > other;
    }
    return null;
  }

  /// Relational greater than or equal operator.
  bool? operator >=(num other) {
    if (value != null) {
      return value! >= other;
    }
    return null;
  }

  /// True if the number is the double Not-a-Number value; otherwise, false.
  bool? get isNaN => value?.isNaN;

  /// Truncates this [num] to an integer and returns the result as an [int]. */
  int? toInt() => value?.toInt();

  /// Return this [num] as a [double].
  ///
  /// If the number is not representable as a [double], an
  /// approximation is returned. For numerically large integers, the
  /// approximation may be infinite.
  double? toDouble() => value?.toDouble();
}

/// A reactive extension of [num] type, enabling reactive operations on numeric values.
class RxNum extends Rx<num> {
  /// Constructs a [RxNum] with the provided [initial] value.
  RxNum(super.initial);

  /// Addition operator.
  ///
  /// Adds [other] to the current value, updates the value, and returns the new value.
  num operator +(num other) {
    value += other;
    return value;
  }

  /// Subtraction operator.
  ///
  /// Subtracts [other] from the current value, updates the value, and returns the new value.
  num operator -(num other) {
    value -= other;
    return value;
  }
}

/// A reactive extension of [num?] type, enabling reactive operations on nullable numeric values.
class RxnNum extends Rx<num?> {
  /// Constructs a [RxnNum] with an optional initial value.
  RxnNum([super.initial]);

  /// Addition operator.
  ///
  /// If the current value is not `null`, adds [other] to it, updates the value, and returns the new value.
  /// If the current value is `null`, returns `null`.
  num? operator +(num other) {
    if (value != null) {
      value = value! + other;
      return value;
    }
    return null;
  }

  /// Subtraction operator.
  ///
  /// If the current value is not `null`, subtracts [other] from it, updates the value, and returns the new value.
  /// If the current value is `null`, returns `null`.
  num? operator -(num other) {
    if (value != null) {
      value = value! - other;
      return value;
    }
    return null;
  }
}

/// Extension providing additional functionality for double values wrapped in an [Rx] object.
extension RxDoubleExt on Rx<double> {
  /// Addition operator.
  Rx<double> operator +(num other) {
    value = value + other;
    return this;
  }

  /// Subtraction operator.
  Rx<double> operator -(num other) {
    value = value - other;
    return this;
  }

  /// Multiplication operator.
  double operator *(num other) => value * other;

  /// modulo operator.
  double operator %(num other) => value % other;

  /// Division operator.
  double operator /(num other) => value / other;

  /// Truncating division operator.
  ///
  /// The result of the truncating division `a ~/ b` is equivalent to
  /// `(a / b).truncate()`.
  int operator ~/(num other) => value ~/ other;

  /// Negate operator. */
  double operator -() => -value;
}

/// Extension providing additional functionality for nullable double values wrapped in an [Rx] object.
extension RxnDoubleExt on Rx<double?> {
  /// Addition operator.
  Rx<double?>? operator +(num other) {
    if (value != null) {
      value = value! + other;
      return this;
    }
    return null;
  }

  /// Subtraction operator.
  Rx<double?>? operator -(num other) {
    if (value != null) {
      value = value! + other;
      return this;
    }
    return null;
  }

  /// Multiplication operator.
  double? operator *(num other) {
    if (value != null) {
      return value! * other;
    }
    return null;
  }

  /// modulo operator.
  double? operator %(num other) {
    if (value != null) {
      return value! % other;
    }
    return null;
  }

  /// Division operator.
  double? operator /(num other) {
    if (value != null) {
      return value! / other;
    }
    return null;
  }

  /// Truncating division operator.
  ///
  /// The result of the truncating division `a ~/ b` is equivalent to
  /// `(a / b).truncate()`.
  int? operator ~/(num other) {
    if (value != null) {
      return value! ~/ other;
    }
    return null;
  }

  /// Negate operator. */
  double? operator -() {
    if (value != null) {
      return -value!;
    }
    return null;
  }
}

/// A reactive extension of [double] type, enabling reactive operations on double values.
class RxDouble extends Rx<double> {
  /// Constructs a [RxDouble] with the provided [initial] value.
  RxDouble(super.initial);
}

/// A reactive extension of [double?] type, enabling reactive operations on nullable double values.
class RxnDouble extends Rx<double?> {
  /// Constructs a [RxnDouble] with an optional initial value.
  RxnDouble([super.initial]);
}

/// A reactive extension of [int] type, enabling reactive operations on integer values.
class RxInt extends Rx<int> {
  /// Constructs a [RxInt] with the provided [initial] value.
  RxInt(super.initial);

  /// Addition operator.
  RxInt operator +(int other) {
    value = value + other;
    return this;
  }

  /// Subtraction operator.
  RxInt operator -(int other) {
    value = value - other;
    return this;
  }
}

/// A reactive extension of [int?] type, enabling reactive operations on nullable integer values.
class RxnInt extends Rx<int?> {
  /// Constructs a [RxnInt] with an optional initial value.
  RxnInt([super.initial]);

  /// Addition operator.
  RxnInt operator +(int other) {
    if (value != null) {
      value = value! + other;
    }
    return this;
  }

  /// Subtraction operator.
  RxnInt operator -(int other) {
    if (value != null) {
      value = value! - other;
    }
    return this;
  }
}

/// Extension providing additional functionality for int values wrapped in an [Rx] object.
extension RxIntExt on Rx<int> {
  /// Bit-wise and operator.
  ///
  /// Treating both `this` and [other] as sufficiently large two's component
  /// integers, the result is a number with only the bits set that are set in
  /// both `this` and [other]
  ///
  /// If both operands are negative, the result is negative, otherwise
  /// the result is non-negative.
  int operator &(int other) => value & other;

  /// Bit-wise or operator.
  ///
  /// Treating both `this` and [other] as sufficiently large two's component
  /// integers, the result is a number with the bits set that are set in either
  /// of `this` and [other]
  ///
  /// If both operands are non-negative, the result is non-negative,
  /// otherwise the result is negative.
  int operator |(int other) => value | other;

  /// Bit-wise exclusive-or operator.
  ///
  /// Treating both `this` and [other] as sufficiently large two's component
  /// integers, the result is a number with the bits set that are set in one,
  /// but not both, of `this` and [other]
  ///
  /// If the operands have the same sign, the result is non-negative,
  /// otherwise the result is negative.
  int operator ^(int other) => value ^ other;

  /// The bit-wise negate operator.
  ///
  /// Treating `this` as a sufficiently large two's component integer,
  /// the result is a number with the opposite bits set.
  ///
  /// This maps any integer `x` to `-x - 1`.
  int operator ~() => ~value;
}

/// Extension providing additional functionality for nullable int values wrapped in an [Rx] object.
extension RxnIntExt on Rx<int?> {
  /// Bit-wise and operator.
  ///
  /// Treating both `this` and [other] as sufficiently large two's component
  /// integers, the result is a number with only the bits set that are set in
  /// both `this` and [other]
  ///
  /// If both operands are negative, the result is negative, otherwise
  /// the result is non-negative.
  int? operator &(int other) {
    if (value != null) {
      return value! & other;
    }
    return null;
  }

  /// Bit-wise or operator.
  ///
  /// Treating both `this` and [other] as sufficiently large two's component
  /// integers, the result is a number with the bits set that are set in either
  /// of `this` and [other]
  ///
  /// If both operands are non-negative, the result is non-negative,
  /// otherwise the result is negative.
  int? operator |(int other) {
    if (value != null) {
      return value! | other;
    }
    return null;
  }

  /// Bit-wise exclusive-or operator.
  ///
  /// Treating both `this` and [other] as sufficiently large two's component
  /// integers, the result is a number with the bits set that are set in one,
  /// but not both, of `this` and [other]
  ///
  /// If the operands have the same sign, the result is non-negative,
  /// otherwise the result is negative.
  int? operator ^(int other) {
    if (value != null) {
      return value! ^ other;
    }
    return null;
  }

  /// The bit-wise negate operator.
  ///
  /// Treating `this` as a sufficiently large two's component integer,
  /// the result is a number with the opposite bits set.
  ///
  /// This maps any integer `x` to `-x - 1`.
  int? operator ~() {
    if (value != null) {
      return ~value!;
    }
    return null;
  }
}

/// An Rx object for managing boolean values.
class RxBool extends Rx<bool> {
  /// Constructs a [RxBool] with the provided [initial] value.
  RxBool(super.initial);

  @override
  String toString() => value ? "true" : "false";
}

/// An Rx object for managing nullable boolean values.
class RxnBool extends Rx<bool?> {
  /// Constructs a [RxnBool] with the provided [initial] value.
  RxnBool([super.initial]);

  @override
  String toString() => "$value";
}

/// Extension on [Rx<bool>] providing methods for boolean operations.
extension RxBoolExt on Rx<bool> {
  /// Returns `true` if the value is `true`.
  bool get isTrue => value;

  /// Returns `true` if the value is `false`.
  bool get isFalse => !isTrue;

  /// Performs a logical AND operation between the Rx value and [other].
  bool operator &(bool other) => other && value;

  /// Performs a logical OR operation between the Rx value and [other].
  bool operator |(bool other) => other || value;

  /// Performs a logical XOR operation between the Rx value and [other].
  bool operator ^(bool other) => !other == value;

  /// Toggles the boolean value of the Rx object between `true` and `false`.
  void toggle() {
    call(!value);
    // return this;
  }
}

/// Extension on [Rx<bool?>] providing methods for nullable boolean operations.
extension RxnBoolExt on Rx<bool?> {
  /// Returns `true` if the value is `true`.
  bool? get isTrue => value;

  /// Returns `true` if the value is `false`.
  bool? get isFalse {
    if (value != null) {
      return !isTrue!;
    }
    return null;
  }

  /// Performs a logical AND operation between the Rx value and [other].
  bool? operator &(bool other) {
    if (value != null) {
      return other && value!;
    }
    return null;
  }

  /// Performs a logical OR operation between the Rx value and [other].
  bool? operator |(bool other) {
    if (value != null) {
      return other || value!;
    }
    return null;
  }

  /// Performs a logical XOR operation between the Rx value and [other].
  bool? operator ^(bool other) => !other == value;

  /// Toggles the boolean value of the Rx object between `true` and `false`.
  void toggle() {
    if (value != null) {
      call(!value!);
      // return this;
    }
  }
}
