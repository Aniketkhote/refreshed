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

      expect(rxNaN.isNaN, isTrue);
    });

    test("Conversion operations", () {
      final Rx<int> rxInt = Rx<int>(5);
      final Rx<double> rxDouble = Rx<double>(3.5);

      expect(rxInt.toInt(), equals(5));
      expect(rxDouble.toDouble(), equals(3.5));
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

      expect(rxInt <= 5, isTrue);
      expect(rxDouble <= 3.5, isTrue);

      expect(rxInt > 2, isTrue);
      expect(rxDouble > 3.0, isTrue);

      expect(rxInt >= 5, isTrue);
      expect(rxDouble >= 3.5, isTrue);
    });
  });
}
