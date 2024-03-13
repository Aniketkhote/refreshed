import "package:flutter/material.dart";
import "package:flutter_test/flutter_test.dart";
import "package:refreshed/refreshed.dart";

void main() {
  testWidgets("test if Get.isSnackbarOpen works with Get.snackbar",
      (WidgetTester tester) async {
    await tester.pumpWidget(
      GetMaterialApp(
        popGesture: true,
        home: ElevatedButton(
          child: const Text("Open Snackbar"),
          onPressed: () {
            Get.snackbar(
              "title",
              "message",
              duration: const Duration(seconds: 1),
              mainButton:
                  TextButton(onPressed: () {}, child: const Text("button")),
              isDismissible: false,
            );
          },
        ),
      ),
    );

    await tester.pump();

    expect(Get.isSnackbarOpen, false);
    await tester.tap(find.text("Open Snackbar"));

    expect(Get.isSnackbarOpen, true);
    await tester.pump(const Duration(seconds: 1));
    expect(Get.isSnackbarOpen, false);
  });

  testWidgets("Get.rawSnackbar test", (WidgetTester tester) async {
    await tester.pumpWidget(
      GetMaterialApp(
        popGesture: true,
        home: ElevatedButton(
          child: const Text("Open Snackbar"),
          onPressed: () {
            Get.rawSnackbar(
              title: "title",
              message: "message",
              onTap: (_) {},
              icon: const Icon(Icons.alarm),
              showProgressIndicator: true,
              duration: const Duration(seconds: 1),
              leftBarIndicatorColor: Colors.amber,
              overlayBlur: 1,
            );
          },
        ),
      ),
    );

    await tester.pump();

    expect(Get.isSnackbarOpen, false);
    await tester.tap(
      find.text("Open Snackbar"),
    );

    expect(Get.isSnackbarOpen, true);
    await tester.pump(const Duration(seconds: 1));
    expect(Get.isSnackbarOpen, false);
  });

  testWidgets("test snackbar queue", (WidgetTester tester) async {
    const Text messageOne = Text("title");

    const Text messageTwo = Text("titleTwo");

    await tester.pumpWidget(
      GetMaterialApp(
        popGesture: true,
        home: ElevatedButton(
          child: const Text("Open Snackbar"),
          onPressed: () {
            Get
              ..rawSnackbar(
                messageText: messageOne,
                duration: const Duration(seconds: 1),
              )
              ..rawSnackbar(
                messageText: messageTwo,
                duration: const Duration(seconds: 1),
              );
          },
        ),
      ),
    );

    await tester.pump();

    expect(Get.isSnackbarOpen, false);
    await tester.tap(find.text("Open Snackbar"));
    expect(Get.isSnackbarOpen, true);

    await tester.pump(const Duration(milliseconds: 500));
    expect(find.text("title"), findsOneWidget);
    expect(find.text("titleTwo"), findsNothing);
    await tester.pump(const Duration(milliseconds: 500));
    expect(find.text("title"), findsNothing);
    expect(find.text("titleTwo"), findsOneWidget);
    await Get.closeAllSnackbars();
    await tester.pumpAndSettle();
  });

  testWidgets("test snackbar dismissible", (WidgetTester tester) async {
    const DismissDirection dismissDirection = DismissDirection.down;
    const Key snackBarTapTarget = Key("snackbar-tap-target");

    const GetSnackBar getBar = GetSnackBar(
      key: ValueKey<String>("dismissible"),
      message: "bar1",
      duration: Duration(seconds: 2),
      dismissDirection: dismissDirection,
    );

    await tester.pumpWidget(
      GetMaterialApp(
        home: Scaffold(
          body: Builder(
            builder: (BuildContext context) => Column(
              children: <Widget>[
                GestureDetector(
                  key: snackBarTapTarget,
                  onTap: () {
                    Get.showSnackbar(getBar);
                  },
                  behavior: HitTestBehavior.opaque,
                  child: const SizedBox(
                    height: 100,
                    width: 100,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );

    await tester.pump();

    expect(Get.isSnackbarOpen, false);
    expect(find.text("bar1"), findsNothing);

    await tester.tap(find.byKey(snackBarTapTarget));
    await tester.pumpAndSettle();

    expect(Get.isSnackbarOpen, true);
    await tester.pump(const Duration(milliseconds: 500));
    expect(find.byWidget(getBar), findsOneWidget);
    await tester.ensureVisible(find.byWidget(getBar));
    await tester.drag(find.byType(Dismissible), const Offset(0, 50));
    await tester.pumpAndSettle();
    await tester.pump(const Duration(milliseconds: 500));
    expect(Get.isSnackbarOpen, false);
  });

  testWidgets("test snackbar onTap", (WidgetTester tester) async {
    const DismissDirection dismissDirection = DismissDirection.vertical;
    const Key snackBarTapTarget = Key("snackbar-tap-target");
    int counter = 0;

    late final GetSnackBar getBar;

    late final SnackbarController getBarController;

    await tester.pumpWidget(
      GetMaterialApp(
        home: Scaffold(
          body: Builder(
            builder: (BuildContext context) => Column(
              children: <Widget>[
                GestureDetector(
                  key: snackBarTapTarget,
                  onTap: () {
                    getBar = GetSnackBar(
                      message: "bar1",
                      onTap: (_) {
                        counter++;
                      },
                      duration: const Duration(seconds: 2),
                      dismissDirection: dismissDirection,
                    );
                    getBarController = Get.showSnackbar(getBar);
                  },
                  behavior: HitTestBehavior.opaque,
                  child: const SizedBox(
                    height: 100,
                    width: 100,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );

    await tester.pumpAndSettle();

    expect(Get.isSnackbarOpen, false);
    expect(find.text("bar1"), findsNothing);

    await tester.tap(find.byKey(snackBarTapTarget));
    await tester.pumpAndSettle();

    expect(Get.isSnackbarOpen, true);
    await tester.pump(const Duration(milliseconds: 500));
    expect(find.byWidget(getBar), findsOneWidget);
    await tester.ensureVisible(find.byWidget(getBar));
    await tester.tap(find.byWidget(getBar));
    expect(counter, 1);
    await tester.pump(const Duration(milliseconds: 3000));
    await getBarController.close(withAnimations: false);
  });

  testWidgets("Get test actions and icon", (WidgetTester tester) async {
    const Icon icon = Icon(Icons.alarm);
    final TextButton action =
        TextButton(onPressed: () {}, child: const Text("button"));

    late final GetSnackBar getBar;

    await tester.pumpWidget(const GetMaterialApp(home: Scaffold()));

    await tester.pump();

    expect(Get.isSnackbarOpen, false);
    expect(find.text("bar1"), findsNothing);

    getBar = GetSnackBar(
      message: "bar1",
      icon: icon,
      mainButton: action,
      leftBarIndicatorColor: Colors.yellow,
      showProgressIndicator: true,
      // maxWidth: 100,
      borderColor: Colors.red,
      duration: const Duration(seconds: 1),
      isDismissible: false,
    );
    Get.showSnackbar(getBar);

    expect(Get.isSnackbarOpen, true);
    await tester.pump(const Duration(milliseconds: 500));
    expect(find.byWidget(getBar), findsOneWidget);
    expect(find.byWidget(icon), findsOneWidget);
    expect(find.byWidget(action), findsOneWidget);
    await tester.pump(const Duration(milliseconds: 500));

    expect(Get.isSnackbarOpen, false);
  });
}
