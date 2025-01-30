import "package:flutter/material.dart";
import "package:flutter_test/flutter_test.dart";
import "package:refreshed/refreshed.dart";

void main() {
  Get.lazyPut<Controller2>(Controller2.new);
  testWidgets("GetxController smoke test", (WidgetTester test) async {
    await test.pumpWidget(
      MaterialApp(
        home: GetBuilder<Controller>(
          init: Controller(),
          builder: (Controller controller) => Column(
            children: <Widget>[
              Text(
                "${controller.counter}",
              ),
              TextButton(
                child: const Text("increment"),
                onPressed: () => controller.increment(),
              ),
              TextButton(
                child: const Text("incrementWithId"),
                onPressed: () => controller.incrementWithId(),
              ),
              GetBuilder<Controller>(
                id: "1",
                didChangeDependencies: (_) {
                  // print("didChangeDependencies called");
                },
                builder: (Controller controller) =>
                    Text("id ${controller.counter}"),
              ),
              GetBuilder<Controller2>(
                builder: (Controller2 controller) =>
                    Text("lazy ${controller.test}"),
              ),
              GetBuilder<ControllerNonGlobal>(
                init: ControllerNonGlobal(),
                global: false,
                builder: (ControllerNonGlobal controller) =>
                    Text("single ${controller.nonGlobal}"),
              ),
            ],
          ),
        ),
      ),
    );

    expect(find.text("0"), findsOneWidget);

    Controller.to.increment();

    await test.pump();

    expect(find.text("1"), findsOneWidget);

    await test.tap(find.text("increment"));

    await test.pump();

    expect(find.text("2"), findsOneWidget);

    await test.tap(find.text("incrementWithId"));

    await test.pump();

    expect(find.text("id 3"), findsOneWidget);
    expect(find.text("lazy 0"), findsOneWidget);
    expect(find.text("single 0"), findsOneWidget);
  });
}

class Controller extends GetxController {
  static Controller get to => Get.find();

  int counter = 0;

  void increment() {
    counter++;
    update();
  }

  void incrementWithId() {
    counter++;
    update(<Object>["1"]);
  }
}

class Controller2 extends GetxController {
  int test = 0;
}

class ControllerNonGlobal extends GetxController {
  int nonGlobal = 0;
}
