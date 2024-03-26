// ignore_for_file: always_specify_types, unawaited_futures

import "package:flutter/material.dart";
import "package:flutter_test/flutter_test.dart";
import "package:refreshed/refreshed.dart";

import "utils/wrapper.dart";

void main() {
  testWidgets("Get.bottomSheet smoke test", (WidgetTester tester) async {
    await tester.pumpWidget(
      Wrapper(child: Container()),
    );

    await tester.pump();

    Get.bottomSheet(
      Wrap(
        children: <Widget>[
          ListTile(
            leading: const Icon(Icons.music_note),
            title: const Text("Music"),
            onTap: () {},
          ),
        ],
      ),
    );

    await tester.pumpAndSettle();

    expect(find.byIcon(Icons.music_note), findsOneWidget);
  });

  testWidgets("Get.bottomSheet close test", (WidgetTester tester) async {
    await tester.pumpWidget(
      Wrapper(child: Container()),
    );

    await tester.pump();

    Get.bottomSheet(
      Wrap(
        children: <Widget>[
          ListTile(
            leading: const Icon(Icons.music_note),
            title: const Text("Music"),
            onTap: () {},
          ),
        ],
      ),
    );

    await tester.pumpAndSettle();

    expect(Get.isBottomSheetOpen, true);

    Get.backLegacy();
    await tester.pumpAndSettle();

    expect(Get.isBottomSheetOpen, false);

    // expect(() => Get.bottomSheet(Container(), isScrollControlled: null),
    //     throwsAssertionError);

    // expect(() => Get.bottomSheet(Container(), isDismissible: null),
    //     throwsAssertionError);

    // expect(() => Get.bottomSheet(Container(), enableDrag: null),
    //     throwsAssertionError);

    await tester.pumpAndSettle();
  });

  // testWidgets(
  //   "GetMaterialApp with debugShowMaterialGrid null",
  //   (tester) async {
  //     expect(
  //       () => GetMaterialApp(
  //         debugShowMaterialGrid: null,
  //       ),
  //       throwsAssertionError,
  //     );
  //   },
  // );
}
