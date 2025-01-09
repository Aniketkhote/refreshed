import "package:flutter_test/flutter_test.dart";
import "package:refreshed/utils.dart";

void main() {
  test("String test", () {
    const String value = "string";
    String expected = "";
    void logFunction(
      String prefix,
      dynamic value,
      String info, {
      bool isError = false,
    }) {
      expected = "$prefix $value $info".trim();
    }

    value.printError(logFunction: logFunction);
    expect(expected, "Error: String string");
  });
  test("Int test", () {
    const int value = 1;
    String expected = "";
    void logFunction(
      String prefix,
      dynamic value,
      String info, {
      bool isError = false,
    }) {
      expected = "$prefix $value $info".trim();
    }

    value.printError(logFunction: logFunction);
    expect(expected, "Error: int 1");
  });
  test("Double test", () {
    const double value = 1;
    String expected = "";
    void logFunction(
      String prefix,
      dynamic value,
      String info, {
      bool isError = false,
    }) {
      expected = "$prefix $value $info".trim();
    }

    value.printError(logFunction: logFunction);
    expect(expected, "Error: double 1.0");
  });
}
