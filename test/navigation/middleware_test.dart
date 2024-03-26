// ignore_for_file: always_specify_types, unawaited_futures

import "package:flutter/cupertino.dart";
import "package:flutter_test/flutter_test.dart";
import "package:refreshed/refreshed.dart";

import "get_main_test.dart";

class RedirectMiddleware<T> extends GetMiddleware<T> {
  @override
  Future<RouteDecoder<T>?> redirectDelegate(RouteDecoder<T> route) async =>
      RouteDecoder<T>.fromRoute("/second");
}

class RedirectMiddlewareNull<T> extends GetMiddleware<T> {
  @override
  Future<RouteDecoder<T>?> redirectDelegate(RouteDecoder<T> route) async =>
      null;
}

void main() {
  testWidgets("Middleware redirect smoke test", (WidgetTester tester) async {
    await tester.pumpWidget(
      GetMaterialApp(
        initialRoute: "/",
        getPages: <GetPage>[
          GetPage(name: "/", page: Container.new),
          GetPage(
            name: "/first",
            page: () => const FirstScreen(),
            middlewares: <GetMiddleware>[
              RedirectMiddleware(),
            ],
          ),
          GetPage(name: "/second", page: () => const SecondScreen()),
          GetPage(name: "/third", page: () => const ThirdScreen()),
        ],
      ),
    );

    Get.toNamed("/first");

    await tester.pumpAndSettle();
    expect(find.byType(SecondScreen), findsOneWidget);
  });

  testWidgets("Middleware redirect null test", (WidgetTester tester) async {
    await tester.pumpWidget(
      GetMaterialApp(
        initialRoute: "/",
        getPages: <GetPage>[
          GetPage(name: "/", page: Container.new),
          GetPage(
            name: "/first",
            page: () => const FirstScreen(),
            middlewares: <GetMiddleware>[
              RedirectMiddlewareNull(),
            ],
          ),
          GetPage(name: "/second", page: () => const SecondScreen()),
          GetPage(name: "/third", page: () => const ThirdScreen()),
        ],
      ),
    );

    // await tester.pump();

    Get.toNamed("/first");

    await tester.pumpAndSettle();
    expect(find.byType(FirstScreen), findsOneWidget);
  });
}
