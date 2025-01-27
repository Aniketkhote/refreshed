import "package:flutter/widgets.dart";
import "package:refreshed/refreshed.dart";

class GetNavigator extends Navigator {
  GetNavigator({
    required List<GetPage> super.pages,
    super.key,
    super.onPopPage,
    List<NavigatorObserver>? observers,
    super.reportsRouteUpdateToEngine,
    TransitionDelegate? transitionDelegate,
    super.initialRoute,
    super.restorationScopeId,
  }) : super(
          observers: <NavigatorObserver>[
            HeroController(),
            ...?observers,
          ],
          transitionDelegate:
              transitionDelegate ?? const DefaultTransitionDelegate<dynamic>(),
        );
  GetNavigator.onGenerateRoute({
    required List<GetPage> super.pages,
    GlobalKey<NavigatorState>? super.key,
    super.onPopPage,
    List<NavigatorObserver>? observers,
    super.reportsRouteUpdateToEngine,
    TransitionDelegate? transitionDelegate,
    super.initialRoute,
    super.restorationScopeId,
  }) : super(
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
