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

    test("Nullable value handling", () {
      final Rx<double?> rxNull = Rx<double?>(null);

      expect(rxNull + 2, isNull);
      expect(rxNull - 2, isNull);
      expect(rxNull * 2, isNull);
      expect(rxNull % 3, isNull);
      expect(rxNull / 2, isNull);
      expect(rxNull ~/ 2, isNull);
      expect(-rxNull, isNull);
    });
  });
}
