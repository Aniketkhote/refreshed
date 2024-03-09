import "package:flutter_test/flutter_test.dart";
import "package:refreshed/refreshed.dart";

void main() {
  group("RxBool tests", () {
    test("Initial value is false", () {
      final boolValue = RxBool(false);
      expect(boolValue.value, false);
    });

    test("Value changes correctly", () {
      final boolValue = RxBool(false);
      boolValue.value = true;
      expect(boolValue.value, true);
    });

    test("Value updates correctly", () {
      final boolValue = RxBool(false);
      boolValue.update((value) => !value!);
      expect(boolValue.value, true);
    });

    test("Toggle method toggles value", () {
      final boolValue = RxBool(false);
      boolValue.toggle();
      expect(boolValue.value, true);
      boolValue.toggle();
      expect(boolValue.value, false);
    });
  });

  group("RxInt tests", () {
    test("Initial value is 0", () {
      final intValue = RxInt(0);
      expect(intValue.value, 0);
    });

    test("Value changes correctly", () {
      final intValue = RxInt(0);
      intValue.value = 10;
      expect(intValue.value, 10);
    });

    test("Value updates correctly", () {
      final intValue = RxInt(0);
      intValue.update((value) => value! + 5);
      expect(intValue.value, 5);
    });
  });

  group("RxString tests", () {
    test("Initial value is empty", () {
      final stringValue = RxString("");
      expect(stringValue.value, "");
    });

    test("Value changes correctly", () {
      final stringValue = RxString("");
      stringValue.value = "Hello";
      expect(stringValue.value, "Hello");
    });

    test("Value updates correctly", () {
      final stringValue = RxString("");
      stringValue.update((value) => "$value World");
      expect(stringValue.value, " World");
    });

    test("Clear method clears value", () {
      final stringValue = RxString("Hello");
      stringValue.value = "";
      expect(stringValue.value, "");
    });
  });
}
