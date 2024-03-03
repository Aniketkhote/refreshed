import 'package:flutter/widgets.dart';

import '../../../refreshed.dart';

/// A custom navigator widget that uses GetX for routing.
class GetNavigator extends Navigator {
  /// Constructs a [GetNavigator] using the provided route generation function.
  ///
  /// The [onGenerateRoute] callback is used to generate routes for the navigator.
  /// The [pages] parameter specifies the list of [GetPage] objects to be used for route resolution.
  ///
  /// The [key], [onPopPage], [observers], [transitionDelegate], [initialRoute], and [restorationScopeId]
  /// parameters are passed to the superclass constructor of [Navigator].
  GetNavigator.onGenerateRoute({
    GlobalKey<NavigatorState>? key,
    bool Function(Route<dynamic>, dynamic)? onPopPage,
    required List<GetPage> pages,
    List<NavigatorObserver>? observers,
    super.reportsRouteUpdateToEngine,
    TransitionDelegate? transitionDelegate,
    String? initialRoute,
    String? restorationScopeId,
  }) : super(
          key: key,
          onPopPage: onPopPage ??
              (route, result) {
                final didPop = route.didPop(result);
                if (!didPop) {
                  return false;
                }
                return true;
              },
          onGenerateRoute: (settings) {
            final selectedPageList =
                pages.where((element) => element.name == settings.name);
            if (selectedPageList.isNotEmpty) {
              final selectedPage = selectedPageList.first;
              return GetPageRoute(
                page: selectedPage.page,
                settings: settings,
              );
            }
            return null;
          },
          observers: [
            // GetObserver(),
            ...?observers,
          ],
          transitionDelegate:
              transitionDelegate ?? const DefaultTransitionDelegate<dynamic>(),
        );

  /// Constructs a [GetNavigator] using the provided parameters.
  ///
  /// This constructor directly sets the list of [pages] to be used for route resolution.
  ///
  /// The [key], [onPopPage], [observers], [transitionDelegate], [initialRoute], and [restorationScopeId]
  /// parameters are passed to the superclass constructor of [Navigator].
  GetNavigator({
    GlobalKey<NavigatorState>? key,
    bool Function(Route<dynamic>, dynamic)? onPopPage,
    required List<GetPage> pages,
    List<NavigatorObserver>? observers,
    super.reportsRouteUpdateToEngine,
    TransitionDelegate? transitionDelegate,
    String? initialRoute,
    String? restorationScopeId,
  }) : super(
          key: key,
          onPopPage: onPopPage ??
              (route, result) {
                final didPop = route.didPop(result);
                if (!didPop) {
                  return false;
                }
                return true;
              },
          observers: [
            // GetObserver(null, Get.routing),
            HeroController(),
            ...?observers,
          ],
          transitionDelegate:
              transitionDelegate ?? const DefaultTransitionDelegate<dynamic>(),
        );
}
