// ignore_for_file: always_specify_types, unawaited_futures

import "package:flutter/material.dart";
import "package:flutter_test/flutter_test.dart";
import "package:refreshed/refreshed.dart";

import "../navigation/utils/wrapper.dart";

void main() {
  testWidgets("Get.defaultDialog smoke test", (WidgetTester tester) async {
    await tester.pumpWidget(
      Wrapper(child: Container()),
    );

    await tester.pumpAndSettle();

    expect("covid".tr, "Corona Virus");
    expect("total_confirmed".tr, "Total Confirmed");
    expect("total_deaths".tr, "Total Deaths");

    Get.updateLocale(const Locale("pt", "BR"));

    await tester.pumpAndSettle();

    expect("covid".tr, "Corona Vírus");
    expect("total_confirmed".tr, "Total confirmado");
    expect("total_deaths".tr, "Total de mortes");

    Get.updateLocale(const Locale("en", "EN"));

    await tester.pumpAndSettle();

    expect("covid".tr, "Corona Virus");
    expect("total_confirmed".tr, "Total Confirmed");
    expect("total_deaths".tr, "Total Deaths");
  });
}
