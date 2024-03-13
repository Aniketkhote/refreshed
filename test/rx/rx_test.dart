// ignore_for_file: cascade_invocations

import "package:flutter_test/flutter_test.dart";
import "package:refreshed/refreshed.dart";

void main() {
  group("RxBool tests", () {
    test("Initial value is false", () {
      final RxBool boolValue = RxBool(false);
      expect(boolValue.value, false);
    });

    test("Value changes correctly", () {
      final RxBool boolValue = RxBool(false);
      boolValue.value = true;
      expect(boolValue.value, true);
    });

    test("Value updates correctly", () {
      final RxBool boolValue = RxBool(false);
      boolValue.update((bool? value) => !value!);
      expect(boolValue.value, true);
    });

    test("Toggle method toggles value", () {
      final RxBool boolValue = RxBool(false);
      boolValue.toggle();
      expect(boolValue.value, true);
      boolValue.toggle();
      expect(boolValue.value, false);
    });
  });

  group("RxInt tests", () {
    test("Initial value is 0", () {
      final RxInt intValue = RxInt(0);
      expect(intValue.value, 0);
    });

    test("Value changes correctly", () {
      final RxInt intValue = RxInt(0);
      intValue.value = 10;
      expect(intValue.value, 10);
    });

    test("Value updates correctly", () {
      final RxInt intValue = RxInt(0);
      intValue.update((int? value) => value! + 5);
      expect(intValue.value, 5);
    });
  });

  group("RxString tests", () {
    test("Initial value is empty", () {
      final RxString stringValue = RxString("");
      expect(stringValue.value, "");
    });

    test("Value changes correctly", () {
      final RxString stringValue = RxString("");
      stringValue.value = "Hello";
      expect(stringValue.value, "Hello");
    });

    test("Value updates correctly", () {
      final RxString stringValue = RxString("");
      stringValue.update((String? value) => "$value World");
      expect(stringValue.value, " World");
    });

    test("Clear method clears value", () {
      final RxString stringValue = RxString("Hello");
      stringValue.value = "";
      expect(stringValue.value, "");
    });
  });
}
