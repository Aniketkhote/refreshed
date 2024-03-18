import "package:flutter_test/flutter_test.dart";
import "package:refreshed/refreshed.dart";

void main() {
  group("RxBoolExt", () {
    test("isTrue property", () {
      final Rx<bool> rxBoolTrue = Rx<bool>(true);
      expect(rxBoolTrue.isTrue, equals(true));

      final Rx<bool> rxBoolFalse = Rx<bool>(false);
      expect(rxBoolFalse.isTrue, equals(false));
    });

    test("isFalse property", () {
      final Rx<bool> rxBoolTrue = Rx<bool>(true);
      expect(rxBoolTrue.isFalse, equals(false));

      final Rx<bool> rxBoolFalse = Rx<bool>(false);
      expect(rxBoolFalse.isFalse, equals(true));
    });

    test("Logical AND operator", () {
      final Rx<bool> rxBoolTrue = Rx<bool>(true);
      final Rx<bool> rxBoolFalse = Rx<bool>(false);

      expect(rxBoolTrue & true, equals(true));
      expect(rxBoolTrue & false, equals(false));
      expect(rxBoolFalse & true, equals(false));
      expect(rxBoolFalse & false, equals(false));
    });

    test("Logical OR operator", () {
      final Rx<bool> rxBoolTrue = Rx<bool>(true);
      final Rx<bool> rxBoolFalse = Rx<bool>(false);

      expect(rxBoolTrue | true, equals(true));
      expect(rxBoolTrue | false, equals(true));
      expect(rxBoolFalse | true, equals(true));
      expect(rxBoolFalse | false, equals(false));
    });

    test("Logical XOR operator", () {
      final Rx<bool> rxBoolTrue = Rx<bool>(true);
      final Rx<bool> rxBoolFalse = Rx<bool>(false);

      expect(rxBoolTrue ^ true, equals(false));
      expect(rxBoolTrue ^ false, equals(true));
      expect(rxBoolFalse ^ true, equals(true));
      expect(rxBoolFalse ^ false, equals(false));
    });

    test("Toggle method", () {
      final Rx<bool> rxBool = Rx<bool>(true);
      rxBool.toggle();
      expect(rxBool.value, equals(false));
    });
  });

  group("RxnBoolExt", () {
    test("isTrue property", () {
      final Rx<bool?> rxBoolTrue = Rx<bool?>(true);
      expect(rxBoolTrue.isTrue, equals(true));

      final Rx<bool?> rxBoolNull = Rx<bool?>(null);
      expect(rxBoolNull.isTrue, equals(null));
    });

    test("isFalse property", () {
      final Rx<bool?> rxBoolTrue = Rx<bool?>(true);
      expect(rxBoolTrue.isFalse, equals(false));

      final Rx<bool?> rxBoolNull = Rx<bool?>(null);
      expect(rxBoolNull.isFalse, equals(null));
    });

    test("Logical AND operator", () {
      final Rx<bool?> rxBoolTrue = Rx<bool?>(true);
      final Rx<bool?> rxBoolFalse = Rx<bool?>(false);
      final Rx<bool?> rxBoolNull = Rx<bool?>(null);

      expect(rxBoolTrue & true, equals(true));
      expect(rxBoolTrue & false, equals(false));

      expect(rxBoolFalse & true, equals(false));
      expect(rxBoolFalse & false, equals(false));

      expect(rxBoolNull & true, equals(null));
      expect(rxBoolNull & false, equals(null));
    });

    test("Logical OR operator", () {
      final Rx<bool?> rxBoolTrue = Rx<bool?>(true);
      final Rx<bool?> rxBoolFalse = Rx<bool?>(false);
      final Rx<bool?> rxBoolNull = Rx<bool?>(null);

      expect(rxBoolTrue | true, equals(true));
      expect(rxBoolTrue | false, equals(true));

      expect(rxBoolFalse | true, equals(true));
      expect(rxBoolFalse | false, equals(false));

      expect(rxBoolNull | true, equals(null));
      expect(rxBoolNull | false, equals(null));
    });

    test("Logical XOR operator", () {
      final Rx<bool?> rxBoolTrue = Rx<bool?>(true);
      final Rx<bool?> rxBoolFalse = Rx<bool?>(false);
      final Rx<bool?> rxBoolNull = Rx<bool?>(null);

      expect(rxBoolTrue ^ true, equals(false));
      expect(rxBoolTrue ^ false, equals(true));

      expect(rxBoolFalse ^ true, equals(true));
      expect(rxBoolFalse ^ false, equals(false));

      expect(rxBoolNull ^ true, equals(false));
      expect(rxBoolNull ^ false, equals(false));
    });

    test("Toggle method", () {
      final Rx<bool?> rxBoolTrue = Rx<bool?>(true);
      final Rx<bool?> rxBoolFalse = Rx<bool?>(false);
      final Rx<bool?> rxBoolNull = Rx<bool?>(null);

      rxBoolTrue.toggle();
      expect(rxBoolTrue.value, equals(false));

      rxBoolFalse.toggle();
      expect(rxBoolFalse.value, equals(true));

      rxBoolNull.toggle();
      expect(rxBoolNull.value, equals(null));
    });
  });
}
