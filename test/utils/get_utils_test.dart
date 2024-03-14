import "package:flutter_test/flutter_test.dart";
import "package:refreshed/refreshed.dart";

class TestClass {}

class EmptyClass {}

void main() {
  // ignore: always_specify_types
  dynamic newId(e) => e;

  test("null isNullOrBlank should be true for null", () {
    expect(GetUtils.isNullOrBlank(null), true);
  });

  test("isNullOrBlank should be false for unsupported types", () {
    expect(GetUtils.isNullOrBlank(5), false);
    expect(GetUtils.isNullOrBlank(0), false);

    expect(GetUtils.isNullOrBlank(5.0), equals(false));
    expect(GetUtils.isNullOrBlank(0.0), equals(false));

    TestClass? testClass;
    expect(GetUtils.isNullOrBlank(testClass), equals(true));
    expect(GetUtils.isNullOrBlank(TestClass()), equals(false));
    expect(GetUtils.isNullOrBlank(EmptyClass()), equals(false));
  });

  test("isNullOrBlank should validate strings", () {
    expect(GetUtils.isNullOrBlank(""), true);
    expect(GetUtils.isNullOrBlank("  "), true);

    expect(GetUtils.isNullOrBlank("foo"), false);
    expect(GetUtils.isNullOrBlank(" foo "), false);

    expect(GetUtils.isNullOrBlank("null"), false);
  });

  test("isNullOrBlank should validate iterables", () {
    expect(GetUtils.isNullOrBlank(<int>[].map(newId)), true);
    expect(GetUtils.isNullOrBlank(<int>[1].map(newId)), false);
  });

  test("isNullOrBlank should validate lists", () {
    expect(GetUtils.isNullOrBlank(const <int>[]), true);
    expect(GetUtils.isNullOrBlank(<String>["oi", "foo"]), false);
    expect(
      GetUtils.isNullOrBlank(
        <Map<String, String>>[<String, String>{}, <String, String>{}],
      ),
      false,
    );
    expect(GetUtils.isNullOrBlank(<String>["foo"][0]), false);
  });

  test("isNullOrBlank should validate sets", () {
    expect(GetUtils.isNullOrBlank(<dynamic>{}), true);
    expect(GetUtils.isNullOrBlank(<int>{1}), false);
    expect(
      GetUtils.isNullOrBlank(<String>{"fluorine", "chlorine", "bromine"}),
      false,
    );
  });

  test("isNullOrBlank should validate maps", () {
    expect(GetUtils.isNullOrBlank(<String, String>{}), true);
    expect(GetUtils.isNullOrBlank(<int, int>{1: 1}), false);
    expect(GetUtils.isNullOrBlank(<String, String>{"other": "thing"}), false);

    final Map<String, String> map = <String, String>{"foo": "bar", "one": "um"};
    expect(GetUtils.isNullOrBlank(map["foo"]), false);
    expect(GetUtils.isNullOrBlank(map["other"]), true);
  });
}
