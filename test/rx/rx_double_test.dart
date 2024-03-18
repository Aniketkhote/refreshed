import "package:flutter_test/flutter_test.dart";
import "package:refreshed/refreshed.dart";

void main() {
  group("RxDoubleExt Test", () {
    test("Basic arithmetic operations", () {
      final Rx<double> rxDouble = Rx<double>(5);

      expect(rxDouble.value + 2, equals(7.0));
      expect(rxDouble.value - 2, equals(3.0));
      expect(rxDouble.value * 2, equals(10.0));
      expect(rxDouble.value % 3, equals(2.0));
      expect(rxDouble.value / 2, equals(2.5));
      expect(rxDouble.value ~/ 2, equals(2));
      expect(-rxDouble.value, equals(-5.0));
    });

    test("Special properties", () {
      final Rx<double> rxDouble = Rx<double>(-5);

      expect(rxDouble.abs(), equals(5.0));
      expect(rxDouble.sign, equals(-1.0));
      expect(rxDouble.round(), equals(-5));
      expect(rxDouble.floor(), equals(-5));
      expect(rxDouble.ceil(), equals(-5));
      expect(rxDouble.truncate(), equals(-5));
      expect(rxDouble.roundToDouble(), equals(-5.0));
      expect(rxDouble.floorToDouble(), equals(-5.0));
      expect(rxDouble.ceilToDouble(), equals(-5.0));
      expect(rxDouble.truncateToDouble(), equals(-5.0));
    });
  });

  group("RxnDoubleExt Test", () {
    test("Basic arithmetic operations", () {
      final Rx<double?> rxDouble = Rx<double?>(5);

      expect(rxDouble.value! + 2, equals(7.0));
      expect(rxDouble.value! - 2, equals(3.0));
      expect(rxDouble.value! * 2, equals(10.0));
      expect(rxDouble.value! % 3, equals(2.0));
      expect(rxDouble.value! / 2, equals(2.5));
      expect(rxDouble.value! ~/ 2, equals(2));
      expect(-rxDouble.value!, equals(-5.0));
    });

    test("Special properties", () {
      final Rx<double?> rxDouble = Rx<double?>(-5);

      expect(rxDouble.abs(), equals(5.0));
      expect(rxDouble.sign, equals(-1.0));
      expect(rxDouble.round(), equals(-5));
      expect(rxDouble.floor(), equals(-5));
      expect(rxDouble.ceil(), equals(-5));
      expect(rxDouble.truncate(), equals(-5));
      expect(rxDouble.roundToDouble(), equals(-5.0));
      expect(rxDouble.floorToDouble(), equals(-5.0));
      expect(rxDouble.ceilToDouble(), equals(-5.0));
      expect(rxDouble.truncateToDouble(), equals(-5.0));
    });

    test("Nullable value handling", () {
      final Rx<double?> rxNull = Rx<double?>(null);

      expect(rxNull + 2, isNull);
      expect(rxNull - 2, isNull);
      expect(rxNull * 2, isNull);
      expect(rxNull % 3, isNull);
      expect(rxNull / 2, isNull);
      expect(rxNull ~/ 2, isNull);
      expect(-rxNull, isNull);
      expect(rxNull.abs(), isNull);
      expect(rxNull.sign, isNull);
      expect(rxNull.round(), isNull);
      expect(rxNull.floor(), isNull);
      expect(rxNull.ceil(), isNull);
      expect(rxNull.truncate(), isNull);
      expect(rxNull.roundToDouble(), isNull);
      expect(rxNull.floorToDouble(), isNull);
      expect(rxNull.ceilToDouble(), isNull);
      expect(rxNull.truncateToDouble(), isNull);
    });
  });
}
