import "package:flutter_test/flutter_test.dart";
import "package:refreshed/refreshed.dart";

void main() {
  group("RxIntExt", () {
    test("Bit-wise AND operator", () {
      final Rx<int> rxInt = Rx<int>(10);
      expect(rxInt & 7, equals(10 & 7));
    });

    test("Bit-wise OR operator", () {
      final Rx<int> rxInt = Rx<int>(10);
      expect(rxInt | 7, equals(10 | 7));
    });

    test("Bit-wise XOR operator", () {
      final Rx<int> rxInt = Rx<int>(10);
      expect(rxInt ^ 7, equals(10 ^ 7));
    });

    test("Bit-wise negate operator", () {
      final Rx<int> rxInt = Rx<int>(10);
      expect(~rxInt, equals(~10));
    });

    test("Shift left operator", () {
      final Rx<int> rxInt = Rx<int>(10);
      expect(rxInt << 2, equals(10 << 2));
    });

    test("Shift right operator", () {
      final Rx<int> rxInt = Rx<int>(10);
      expect(rxInt >> 2, equals(10 >> 2));
    });

    test("Modular power method", () {
      final Rx<int> rxInt = Rx<int>(3);
      expect(rxInt.modPow(2, 5), equals(3.modPow(2, 5)));
    });

    test("Modular inverse method", () {
      final Rx<int> rxInt = Rx<int>(3);
      expect(rxInt.modInverse(5), equals(3.modInverse(5)));
    });

    test("Greatest common divisor method", () {
      final Rx<int> rxInt = Rx<int>(10);
      expect(rxInt.gcd(25), equals(10.gcd(25)));
    });

    test("isEven property", () {
      final Rx<int> rxInt = Rx<int>(10);
      expect(rxInt.isEven, equals(10.isEven));
    });

    test("isOdd property", () {
      final Rx<int> rxInt = Rx<int>(10);
      expect(rxInt.isOdd, equals(10.isOdd));
    });

    test("bitLength property", () {
      final Rx<int> rxInt = Rx<int>(10);
      expect(rxInt.bitLength, equals(10.bitLength));
    });

    test("toUnsigned method", () {
      final Rx<int> rxInt = Rx<int>(-1);
      expect(rxInt.toUnsigned(5), equals((-1).toUnsigned(5)));
    });

    test("toSigned method", () {
      final Rx<int> rxInt = Rx<int>(16);
      expect(rxInt.toSigned(5), equals(16.toSigned(5)));
    });

    test("Negation operator", () {
      final Rx<int> rxInt = Rx<int>(-5);
      expect(-rxInt, equals(-(-5)));
    });

    test("Absolute value method", () {
      final Rx<int> rxInt = Rx<int>(-5);
      expect(rxInt.abs(), equals((-5).abs()));
    });

    test("Sign property", () {
      final Rx<int> rxInt = Rx<int>(-5);
      expect(rxInt.sign, equals((-5).sign));
    });

    test("Round to double method", () {
      final Rx<int> rxInt = Rx<int>(10);
      expect(rxInt.roundToDouble(), equals(10.roundToDouble()));
    });

    test("Floor to double method", () {
      final Rx<int> rxInt = Rx<int>(10);
      expect(rxInt.floorToDouble(), equals(10.floorToDouble()));
    });

    test("Ceil to double method", () {
      final Rx<int> rxInt = Rx<int>(10);
      expect(rxInt.ceilToDouble(), equals(10.ceilToDouble()));
    });

    test("Truncate to double method", () {
      final Rx<int> rxInt = Rx<int>(10);
      expect(rxInt.truncateToDouble(), equals(10.truncateToDouble()));
    });
  });

  group("RxnIntExt", () {
    test("Bit-wise AND operator", () {
      final Rx<int?> rxInt = Rx<int?>(10);
      expect(rxInt & 7, equals(10 & 7));
    });

    test("Bit-wise OR operator", () {
      final Rx<int?> rxInt = Rx<int?>(10);
      expect(rxInt | 7, equals(10 | 7));
    });

    test("Bit-wise XOR operator", () {
      final Rx<int?> rxInt = Rx<int?>(10);
      expect(rxInt ^ 7, equals(10 ^ 7));
    });

    test("Bit-wise negate operator", () {
      final Rx<int?> rxInt = Rx<int?>(10);
      expect(~rxInt, equals(~10));
    });

    test("Shift left operator", () {
      final Rx<int?> rxInt = Rx<int?>(10);
      expect(rxInt << 2, equals(10 << 2));
    });

    test("Shift right operator", () {
      final Rx<int?> rxInt = Rx<int?>(10);
      expect(rxInt >> 2, equals(10 >> 2));
    });

    test("Modular power method", () {
      final Rx<int?> rxInt = Rx<int?>(3);
      expect(rxInt.modPow(2, 5), equals(3.modPow(2, 5)));
    });

    test("Modular inverse method", () {
      final Rx<int?> rxInt = Rx<int?>(3);
      expect(rxInt.modInverse(5), equals(3.modInverse(5)));
    });

    test("Greatest common divisor method", () {
      final Rx<int?> rxInt = Rx<int?>(10);
      expect(rxInt.gcd(25), equals(10.gcd(25)));
    });

    test("isEven property", () {
      final Rx<int?> rxInt = Rx<int?>(10);
      expect(rxInt.isEven, equals(10.isEven));
    });

    test("isOdd property", () {
      final Rx<int?> rxInt = Rx<int?>(10);
      expect(rxInt.isOdd, equals(10.isOdd));
    });

    test("bitLength property", () {
      final Rx<int?> rxInt = Rx<int?>(10);
      expect(rxInt.bitLength, equals(10.bitLength));
    });

    test("toUnsigned method", () {
      final Rx<int?> rxInt = Rx<int?>(-1);
      expect(rxInt.toUnsigned(5), equals((-1).toUnsigned(5)));
    });

    test("toSigned method", () {
      final Rx<int?> rxInt = Rx<int?>(16);
      expect(rxInt.toSigned(5), equals(16.toSigned(5)));
    });

    test("Negation operator", () {
      final Rx<int?> rxInt = Rx<int?>(-5);
      expect(-rxInt, equals(-(-5)));
    });

    test("Absolute value method", () {
      final Rx<int?> rxInt = Rx<int?>(-5);
      expect(rxInt.abs(), equals((-5).abs()));
    });

    test("Sign property", () {
      final Rx<int?> rxInt = Rx<int?>(-5);
      expect(rxInt.sign, equals((-5).sign));
    });

    test("Round to double method", () {
      final Rx<int?> rxInt = Rx<int?>(10);
      expect(rxInt.roundToDouble(), equals(10.roundToDouble()));
    });

    test("Floor to double method", () {
      final Rx<int?> rxInt = Rx<int?>(10);
      expect(rxInt.floorToDouble(), equals(10.floorToDouble()));
    });

    test("Ceil to double method", () {
      final Rx<int?> rxInt = Rx<int?>(10);
      expect(rxInt.ceilToDouble(), equals(10.ceilToDouble()));
    });

    test("Truncate to double method", () {
      final Rx<int?> rxInt = Rx<int?>(10);
      expect(rxInt.truncateToDouble(), equals(10.truncateToDouble()));
    });
  });
}
