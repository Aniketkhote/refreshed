import "package:flutter/widgets.dart";
import "package:refreshed/get_instance/src/bindings_interface.dart";
import "package:refreshed/get_navigation/src/routes/get_route.dart";
import "package:refreshed/get_navigation/src/routes/transitions_type.dart";

/// Enables the user to customize the intended pop behavior
///
/// Goes to either the previous _activePages entry or the previous page entry
///
/// e.g. if the user navigates to these pages
/// 1) /home
/// 2) /home/products/1234
///
/// when popping on [history] mode, it will emulate a browser back button.
///
/// so the new _activePages stack will be:
/// 1) /home
///
/// when popping on [page] mode, it will only remove the last part of the route
/// so the new _activePages stack will be:
/// 1) /home
/// 2) /home/products
///
/// another pop will change the _activePages stack to:
/// 1) /home
enum PopMode { history, page }

/// Enables the user to customize the behavior when pushing multiple routes that
/// shouldn't be duplicates
enum PreventDuplicateHandlingMode {
  /// Removes the _activePages entries until it reaches the old route
  popUntilOriginalRoute,

  /// Simply don't push the new route
  doNothing,

  /// Recommended - Moves the old route entry to the front
  ///
  /// With this mode, you guarantee there will be only one
  /// route entry for each location
  reorderRoutes,

  recreate,
}

mixin IGetNavigation<T> {
  Future<T?> to(
    Widget Function() page, {
    bool? opaque,
    Transition? transition,
    Curve? curve,
    Duration? duration,
    String? id,
    String? routeName,
    bool fullscreenDialog = false,
    Object? arguments,
    List<BindingsInterface> bindings = const <BindingsInterface>[],
    bool preventDuplicates = true,
    bool? popGesture,
    bool showCupertinoParallax = true,
    double Function(BuildContext context)? gestureWidth,
  });

  Future<void> popModeUntil(
    String fullRoute, {
    PopMode popMode = PopMode.history,
  });

  Future<T?> off(
    Widget Function() page, {
    bool? opaque,
    Transition? transition,
    Curve? curve,
    Duration? duration,
    String? id,
    String? routeName,
    bool fullscreenDialog = false,
    Object? arguments,
    List<BindingsInterface> bindings = const <BindingsInterface>[],
    bool preventDuplicates = true,
    bool? popGesture,
    bool showCupertinoParallax = true,
    double Function(BuildContext context)? gestureWidth,
  });

  Future<T?>? offAll(
    Widget Function() page, {
    bool Function(GetPage route)? predicate,
    bool opaque = true,
    bool? popGesture,
    String? id,
    String? routeName,
    Object? arguments,
    List<BindingsInterface> bindings = const <BindingsInterface>[],
    bool fullscreenDialog = false,
    Transition? transition,
    Curve? curve,
    Duration? duration,
    bool showCupertinoParallax = true,
    double Function(BuildContext context)? gestureWidth,
  });

  Future<T?> toNamed(
    String page, {
    Object? arguments,
    String? id,
    bool preventDuplicates = true,
    Map<String, String>? parameters,
  });

  Future<T?> offNamed(
    String page, {
    Object? arguments,
    String? id,
    Map<String, String>? parameters,
  });

  Future<T?>? offAllNamed(
    String newRouteName, {
    Object? arguments,
    String? id,
    Map<String, String>? parameters,
  });

  Future<T?>? offNamedUntil(
    String page, {
    bool Function(GetPage route)? predicate,
    Object? arguments,
    String? id,
    Map<String, String>? parameters,
  });

  Future<T?> toNamedAndOffUntil(
    String page,
    bool Function(GetPage) predicate, [
    Object? data,
  ]);

  Future<T?> offUntil(
    Widget Function() page,
    bool Function(GetPage) predicate, [
    Object? arguments,
  ]);

  void removeRoute(String name);

  void back([T? result]);

  Future<R?> backAndtoNamed<R>(String page, {T? result, Object? arguments});

  void backUntil(bool Function(GetPage) predicate);

  void goToUnknownPage([bool clearPages = true]);
}
