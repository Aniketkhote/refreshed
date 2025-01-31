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

    test("Negation operator", () {
      final Rx<int> rxInt = Rx<int>(-5);
      expect(-rxInt, equals(-(-5)));
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

    test("Negation operator", () {
      final Rx<int?> rxInt = Rx<int?>(-5);
      expect(-rxInt, equals(-(-5)));
    });
  });
}
