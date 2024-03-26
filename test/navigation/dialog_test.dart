// ignore_for_file: always_specify_types, unawaited_futures

import "package:flutter/material.dart";
import "package:flutter_test/flutter_test.dart";
import "package:refreshed/refreshed.dart";

import "utils/wrapper.dart";

void main() {
  testWidgets("Get.defaultDialog smoke test", (WidgetTester tester) async {
    await tester.pumpWidget(
      Wrapper(child: Container()),
    );

    await tester.pump();

    Get.defaultDialog(
      onConfirm: () {},
      middleText: "Dialog made in 3 lines of code",
    );

    await tester.pumpAndSettle();

    expect(find.text("Ok"), findsOneWidget);
  });

  testWidgets("Get.dialog smoke test", (WidgetTester tester) async {
    await tester.pumpWidget(
      Wrapper(child: Container()),
    );

    await tester.pump();

    Get.dialog(const YourDialogWidget());

    await tester.pumpAndSettle();

    expect(find.byType(YourDialogWidget), findsOneWidget);
  });

  testWidgets("Get.dialog close test", (WidgetTester tester) async {
    await tester.pumpWidget(
      Wrapper(child: Container()),
    );

    await tester.pump();

    Get.dialog(const YourDialogWidget());
    await tester.pumpAndSettle();

    expect(find.byType(YourDialogWidget), findsOneWidget);
    // expect(Get.isDialogOpen, true);

    Get.backLegacy();
    await tester.pumpAndSettle();

    expect(find.byType(YourDialogWidget), findsNothing);
    // expect(Get.isDialogOpen, false);
    // await tester.pumpAndSettle();
  });
}

class YourDialogWidget extends StatelessWidget {
  const YourDialogWidget({super.key});

  @override
  Widget build(BuildContext context) => Container();
}
