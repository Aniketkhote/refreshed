// ignore_for_file: cascade_invocations, always_specify_types

import "dart:async";

import "package:flutter_test/flutter_test.dart";
import "package:refreshed/refreshed.dart";

void main() {
  test("once", () async {
    final RxInt count = 0.obs;
    int result = -1;
    once(count, (r) {
      result = r;
    });
    count.value++;
    await Future.delayed(Duration.zero);
    expect(1, result);
    count.value++;
    await Future.delayed(Duration.zero);
    expect(1, result);
    count.value++;
    await Future.delayed(Duration.zero);
    expect(1, result);
  });

  test("ever", () async {
    final RxInt count = 0.obs;
    int result = -1;
    ever<int>(count, (int value) {
      result = value;
    });
    count.value++;
    await Future.delayed(Duration.zero);
    expect(1, result);
    count.value++;
    await Future.delayed(Duration.zero);
    expect(2, result);
    count.value++;
    await Future.delayed(Duration.zero);
    expect(3, result);
  });

  test("debounce", () async {
    final RxInt count = 0.obs;
    int? result = -1;
    debounce(
      count,
      (r) {
        result = r as int?;
      },
      time: const Duration(milliseconds: 100),
    );

    count.value++;
    count.value++;
    count.value++;
    count.value++;
    await Future.delayed(Duration.zero);
    expect(-1, result);
    await Future.delayed(const Duration(milliseconds: 100));
    expect(4, result);
  });

  test("interval", () async {
    final RxInt count = 0.obs;
    int? result = -1;
    interval<int>(
      count,
      (int v) {
        result = v;
      },
      time: const Duration(milliseconds: 100),
    );

    count.value++;
    await Future.delayed(Duration.zero);
    await Future.delayed(const Duration(milliseconds: 100));
    expect(result, 1);
    count.value++;
    count.value++;
    count.value++;
    await Future.delayed(Duration.zero);
    await Future.delayed(const Duration(milliseconds: 100));
    expect(result, 2);
    count.value++;
    await Future.delayed(Duration.zero);
    await Future.delayed(const Duration(milliseconds: 100));
    expect(result, 5);
  });

  test("bindStream test", () async {
    int? count = 0;
    final StreamController<int> controller = StreamController<int>();
    final RxInt rx = 0.obs;

    rx.listen((int value) {
      count = value;
    });
    rx.bindStream(controller.stream);
    expect(count, 0);
    controller.add(555);

    await Future.delayed(Duration.zero);
    expect(count, 555);
    await controller.close();
  });

  test("Rx same value will not call the same listener when call", () async {
    final RxInt reactiveInteger = RxInt(2);
    int timesCalled = 0;
    reactiveInteger.listen((int newInt) {
      timesCalled++;
    });

    // we call 3
    reactiveInteger.call(3);
    // then repeat twice
    reactiveInteger.call(3);
    reactiveInteger.call(3);

    await Future.delayed(const Duration(milliseconds: 100));
    expect(1, timesCalled);
  });

  test("Rx different value will call the listener when trigger", () async {
    final RxInt reactiveInteger = RxInt(0);
    int timesCalled = 0;
    reactiveInteger.listen((int newInt) {
      timesCalled++;
    });

    // we call 3
    reactiveInteger.trigger(1);
    // then repeat twice
    reactiveInteger.trigger(2);
    reactiveInteger.trigger(3);

    await Future.delayed(const Duration(milliseconds: 100));

    expect(3, timesCalled);
  });

  test("Rx same value will call the listener when trigger", () async {
    final RxInt reactiveInteger = RxInt(2);
    int timesCalled = 0;
    reactiveInteger.listen((int newInt) {
      timesCalled++;
    });

    // we call 3
    reactiveInteger.trigger(3);
    // then repeat twice
    reactiveInteger.trigger(3);
    reactiveInteger.trigger(3);
    reactiveInteger.trigger(1);

    await Future.delayed(const Duration(milliseconds: 100));
    expect(4, timesCalled);
  });

  test("Rx String with non null values", () async {
    final Rx<String> reactiveString = Rx<String>("abc");
    String? currentString;
    reactiveString.listen((String newString) {
      currentString = newString;
    });

    expect(reactiveString.endsWith("c"), true);

    // we call 3
    reactiveString("b");

    await Future.delayed(Duration.zero);
    expect(currentString, "b");
  });

  test("Rx String with null values", () async {
    final Rx<String?> reactiveString = Rx<String?>(null);
    String? currentString;

    reactiveString.listen((String? newString) {
      currentString = newString;
    });

    // we call 3
    reactiveString("abc");

    await Future.delayed(Duration.zero);
    expect(reactiveString.endsWith("c"), true);
    expect(currentString, "abc");
  });

  test('Number of times "ever" is called in RxList', () async {
    final RxList<int> list = <int>[1, 2, 3].obs;
    int count = 0;
    ever<List<int>>(list, (List<int> value) {
      count++;
    });

    list.add(4);
    await Future.delayed(Duration.zero);
    expect(count, 1);

    count = 0;
    list.addAll(<int>[4, 5]);
    await Future.delayed(Duration.zero);
    expect(count, 1);

    count = 0;
    list.remove(2);
    await Future.delayed(Duration.zero);
    expect(count, 1);

    count = 0;
    list.removeWhere((int element) => element == 2);
    await Future.delayed(Duration.zero);
    expect(count, 1);

    count = 0;
    list.retainWhere((int element) => element == 1);
    await Future.delayed(Duration.zero);
    expect(count, 1);
  });
}
