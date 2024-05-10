// ignore_for_file: avoid_annotating_with_dynamic

import "package:flutter/widgets.dart";
import "package:refreshed/refreshed.dart";

class GetNavigator extends Navigator {
  GetNavigator({
    required List<GetPage> super.pages,
    super.key,
    bool Function(Route<dynamic>, dynamic)? onPopPage,
    List<NavigatorObserver>? observers,
    super.reportsRouteUpdateToEngine,
    TransitionDelegate? transitionDelegate,
    super.initialRoute,
    super.restorationScopeId,
  }) : super(
          //keys should be optional
          onPopPage: onPopPage ??
              (Route route, result) {
                final bool didPop = route.didPop(result);
                if (!didPop) {
                  return false;
                }
                return true;
              },
          observers: <NavigatorObserver>[
            // GetObserver(null, Get.routing),
            HeroController(),
            ...?observers,
          ],
          transitionDelegate:
              transitionDelegate ?? const DefaultTransitionDelegate<dynamic>(),
        );
  GetNavigator.onGenerateRoute({
    required List<GetPage> super.pages,
    GlobalKey<NavigatorState>? super.key,
    bool Function(Route<dynamic>, dynamic)? onPopPage,
    List<NavigatorObserver>? observers,
    super.reportsRouteUpdateToEngine,
    TransitionDelegate? transitionDelegate,
    super.initialRoute,
    super.restorationScopeId,
  }) : super(
          //keys should be optional
          onPopPage: onPopPage ??
              (Route route, result) {
                final bool didPop = route.didPop(result);
                if (!didPop) {
                  return false;
                }
                return true;
              },
          onGenerateRoute: (RouteSettings settings) {
            final Iterable<GetPage> selectedPageList =
                pages.where((GetPage element) => element.name == settings.name);
            if (selectedPageList.isNotEmpty) {
              final GetPage selectedPage = selectedPageList.first;
              return GetPageRoute(
                page: selectedPage.page,
                settings: settings,
              );
            }
            return null;
          },
          observers: <NavigatorObserver>[
            ...?observers,
          ],
          transitionDelegate:
              transitionDelegate ?? const DefaultTransitionDelegate<dynamic>(),
        );
}
