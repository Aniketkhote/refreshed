// ignore_for_file: unawaited_futures

import "package:flutter/cupertino.dart";
import "package:flutter_test/flutter_test.dart";
import "package:refreshed/refreshed.dart";

void main() {
  test("Parse Page with children", () {
    final Map<String, String> testParams = <String, String>{"hi": "value"};
    final GetPage<dynamic> pageTree = GetPage<dynamic>(
      name: "/city",
      page: Container.new,
      children: <GetPage<dynamic>>[
        GetPage<dynamic>(
          name: "/home",
          page: Container.new,
          transition: Transition.rightToLeftWithFade,
          children: <GetPage<dynamic>>[
            GetPage<dynamic>(
              name: "/bed-room",
              transition: Transition.size,
              page: Container.new,
            ),
            GetPage<dynamic>(
              name: "/living-room",
              transition: Transition.topLevel,
              page: Container.new,
            ),
          ],
        ),
        GetPage<dynamic>(
          name: "/work",
          transition: Transition.upToDown,
          page: Container.new,
          children: <GetPage<dynamic>>[
            GetPage<dynamic>(
              name: "/office",
              transition: Transition.zoom,
              page: Container.new,
              children: <GetPage<dynamic>>[
                GetPage<dynamic>(
                  name: "/pen",
                  transition: Transition.cupertino,
                  page: Container.new,
                  parameters: testParams,
                ),
                GetPage<dynamic>(
                  name: "/paper",
                  page: Container.new,
                  transition: Transition.downToUp,
                ),
              ],
            ),
            GetPage<dynamic>(
              name: "/meeting-room",
              transition: Transition.fade,
              page: Container.new,
            ),
          ],
        ),
      ],
    );

    final ParseRouteTree<dynamic> tree =
        ParseRouteTree<dynamic>(routes: <GetPage<dynamic>>[]);

    tree.addRoute(pageTree);

    const String searchRoute = "/city/work/office/pen";
    final RouteDecoder<dynamic> match = tree.matchRoute(searchRoute);
    expect(match, isNotNull);
    expect(match.route!.name, searchRoute);
    final Map<String, String> testRouteParam = match.route!.parameters!;
    for (final MapEntry<String, String> tParam in testParams.entries) {
      expect(testRouteParam[tParam.key], tParam.value);
    }
  });

  test("Parse Page without children", () {
    final List<GetPage<dynamic>> pageTree = <GetPage<dynamic>>[
      GetPage<dynamic>(
        name: "/city",
        page: Container.new,
        transition: Transition.cupertino,
      ),
      GetPage<dynamic>(
        name: "/city/home",
        page: Container.new,
        transition: Transition.downToUp,
      ),
      GetPage<dynamic>(
        name: "/city/home/bed-room",
        page: Container.new,
        transition: Transition.fade,
      ),
      GetPage<dynamic>(
        name: "/city/home/living-room",
        page: Container.new,
        transition: Transition.fadeIn,
      ),
      GetPage<dynamic>(
        name: "/city/work",
        page: Container.new,
        transition: Transition.leftToRight,
      ),
      GetPage<dynamic>(
        name: "/city/work/office",
        page: Container.new,
        transition: Transition.leftToRightWithFade,
      ),
      GetPage<dynamic>(
        name: "/city/work/office/pen",
        page: Container.new,
        transition: Transition.native,
      ),
      GetPage<dynamic>(
        name: "/city/work/office/paper",
        page: Container.new,
        transition: Transition.noTransition,
      ),
      GetPage<dynamic>(
        name: "/city/work/meeting-room",
        page: Container.new,
        transition: Transition.rightToLeft,
      ),
    ];

    final ParseRouteTree<dynamic> tree =
        ParseRouteTree<dynamic>(routes: pageTree);

    // for (var p in pageTree) {
    //   tree.addRoute(p);
    // }

    const String searchRoute = "/city/work/office/pen";
    final RouteDecoder<dynamic> match = tree.matchRoute(searchRoute);
    expect(match, isNotNull);
    expect(match.route!.name, searchRoute);
  });

  testWidgets(
    "test params from dynamic route",
    (WidgetTester tester) async {
      await tester.pumpWidget(
        GetMaterialApp<dynamic>(
          initialRoute: "/first/juan",
          getPages: <GetPage<dynamic>>[
            GetPage<dynamic>(page: Container.new, name: "/first/:name"),
            GetPage<dynamic>(page: Container.new, name: "/second/:id"),
            GetPage<dynamic>(page: Container.new, name: "/third"),
            GetPage<dynamic>(
              page: Container.new,
              name: "/last/:id/:name/profile",
            ),
          ],
        ),
      );

      expect(Get.parameters["name"], "juan");

      Get.toNamed("/second/1234");

      await tester.pumpAndSettle();

      expect(Get.parameters["id"], "1234");

      Get.toNamed("/third?name=jonny&job=dev");

      await tester.pumpAndSettle();

      expect(Get.parameters["name"], "jonny");
      expect(Get.parameters["job"], "dev");

      Get.toNamed("/last/1234/ana/profile");

      await tester.pumpAndSettle();

      expect(Get.parameters["id"], "1234");
      expect(Get.parameters["name"], "ana");

      Get.toNamed("/last/1234/ana/profile?job=dev");

      await tester.pumpAndSettle();

      expect(Get.parameters["id"], "1234");
      expect(Get.parameters["name"], "ana");
      expect(Get.parameters["job"], "dev");
    },
  );

  testWidgets(
    "params in url by parameters",
    (WidgetTester tester) async {
      await tester.pumpWidget(
        GetMaterialApp<dynamic>(
          initialRoute: "/first/juan",
          getPages: <GetPage<dynamic>>[
            GetPage<dynamic>(page: Container.new, name: "/first/:name"),
            GetPage<dynamic>(page: Container.new, name: "/italy"),
          ],
        ),
      );

      // Get.parameters = ({"varginias": "varginia", "vinis": "viniiss"});
      final Map<String, String> parameters = <String, String>{
        "varginias": "varginia",
        "vinis": "viniiss",
      };
      // print("Get.parameters: ${Get.parameters}");
      parameters.addAll(<String, String>{"a": "b", "c": "d"});
      Get.toNamed("/italy", parameters: parameters);

      await tester.pumpAndSettle();
      expect(Get.parameters["varginias"], "varginia");
      expect(Get.parameters["vinis"], "viniiss");
      expect(Get.parameters["a"], "b");
      expect(Get.parameters["c"], "d");
    },
  );
}
