import "package:flutter_test/flutter_test.dart";
import "package:refreshed/refreshed.dart";

void main() {
  group("RxNumExt Test", () {
    test("Basic arithmetic operations", () {
      final Rx<int> rxInt = Rx<int>(5);
      final Rx<double> rxDouble = Rx<double>(3.5);

      expect(rxInt * 2, equals(10));
      expect(rxDouble * 2, equals(7.0));

      expect(rxInt % 3, equals(2));
      expect(rxDouble % 2, equals(1.5));

      expect(rxInt / 2, equals(2.5));
      expect(rxDouble / 2, equals(1.75));

      expect(rxInt ~/ 2, equals(2));
      expect(rxDouble ~/ 2, equals(1));
    });

    test("Relational operators", () {
      final Rx<int> rxInt = Rx<int>(5);
      final Rx<double> rxDouble = Rx<double>(3.5);

      expect(rxInt < 10, isTrue);
      expect(rxDouble < 4.0, isTrue);

      expect(rxInt <= 5, isTrue);
      expect(rxDouble <= 3.5, isTrue);

      expect(rxInt > 2, isTrue);
      expect(rxDouble > 3.0, isTrue);

      expect(rxInt >= 5, isTrue);
      expect(rxDouble >= 3.5, isTrue);
    });

    test("Special properties", () {
      final Rx<double> rxNaN = Rx<double>(double.nan);
      final Rx<double> rxPositiveInfinity = Rx<double>(double.infinity);
      final Rx<double> rxNegativeInfinity = Rx<double>(-double.infinity);

      expect(rxNaN.isNaN, isTrue);
      expect(rxPositiveInfinity.isInfinite, isTrue);
      expect(rxNegativeInfinity.isInfinite, isTrue);
      expect(rxNegativeInfinity.isNegative, isTrue);
      expect(rxPositiveInfinity.isFinite, isFalse);
    });

    test("Rounding operations", () {
      final Rx<double> rxDouble = Rx<double>(3.5);

      expect(rxDouble.round(), equals(4));
      expect(rxDouble.floor(), equals(3));
      expect(rxDouble.ceil(), equals(4));
      expect(rxDouble.truncate(), equals(3));
      expect(rxDouble.roundToDouble(), equals(4.0));
      expect(rxDouble.floorToDouble(), equals(3.0));
      expect(rxDouble.ceilToDouble(), equals(4.0));
      expect(rxDouble.truncateToDouble(), equals(3.0));
    });

    test("Conversion operations", () {
      final Rx<int> rxInt = Rx<int>(5);
      final Rx<double> rxDouble = Rx<double>(3.5);

      expect(rxInt.toInt(), equals(5));
      expect(rxDouble.toDouble(), equals(3.5));

      expect(rxInt.toStringAsFixed(2), equals("5.00"));
      expect(rxDouble.toStringAsExponential(), equals("3.5e+0"));
      expect(rxDouble.toStringAsPrecision(2), equals("3.5"));
    });
  });
  group("RxnNumExt Test", () {
    test("Basic arithmetic operations", () {
      final Rx<int?> rxInt = Rx<int?>(5);
      final Rx<double?> rxDouble = Rx<double?>(3.5);

      expect(rxInt * 2, equals(10));
      expect(rxDouble * 2, equals(7.0));

      expect(rxInt % 3, equals(2));
      expect(rxDouble % 2, equals(1.5));

      expect(rxInt / 2, equals(2.5));
      expect(rxDouble / 2, equals(1.75));

      expect(rxInt ~/ 2, equals(2));
      expect(rxDouble ~/ 2, equals(1));
    });

    test("Relational operators", () {
      final Rx<int?> rxInt = Rx<int?>(5);
      final Rx<double?> rxDouble = Rx<double?>(3.5);

      expect(rxInt < 10, isTrue);
      expect(rxDouble < 4.0, isTrue);

      expect(rxInt <= 5, isTrue);
      expect(rxDouble <= 3.5, isTrue);

      expect(rxInt > 2, isTrue);
      expect(rxDouble > 3.0, isTrue);

      expect(rxInt >= 5, isTrue);
      expect(rxDouble >= 3.5, isTrue);
    });

    test("Special properties", () {
      final Rx<double?> rxNaN = Rx<double?>(double.nan);
      final Rx<double?> rxPositiveInfinity = Rx<double?>(double.infinity);
      final Rx<double?> rxNegativeInfinity = Rx<double?>(-double.infinity);
      final Rx<double?> rxNull = Rx<double?>(null);

      expect(rxNaN.isNaN, isTrue);
      expect(rxPositiveInfinity.isInfinite, isTrue);
      expect(rxNegativeInfinity.isInfinite, isTrue);
      expect(rxNegativeInfinity.isNegative, isTrue);
      expect(rxPositiveInfinity.isFinite, isFalse);
      expect(rxNull.isNaN, null);
      expect(rxNull.isInfinite, null);
      expect(rxNull.isNegative, null);
      expect(rxNull.isFinite, null);
    });

    test("Rounding operations", () {
      final Rx<double?> rxDouble = Rx<double?>(3.5);

      expect(rxDouble.round(), equals(4));
      expect(rxDouble.floor(), equals(3));
      expect(rxDouble.ceil(), equals(4));
      expect(rxDouble.truncate(), equals(3));
      expect(rxDouble.roundToDouble(), equals(4.0));
      expect(rxDouble.floorToDouble(), equals(3.0));
      expect(rxDouble.ceilToDouble(), equals(4.0));
      expect(rxDouble.truncateToDouble(), equals(3.0));
    });

    test("Conversion operations", () {
      final Rx<int?> rxInt = Rx<int?>(5);
      final Rx<double?> rxDouble = Rx<double?>(3.5);

      expect(rxInt.toInt(), equals(5));
      expect(rxDouble.toDouble(), equals(3.5));

      expect(rxInt.toStringAsFixed(2), equals("5.00"));
      expect(rxDouble.toStringAsExponential(), equals("3.5e+0"));
      expect(rxDouble.toStringAsPrecision(2), equals("3.5"));
    });
  });
}
