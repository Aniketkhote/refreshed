import 'package:flutter/widgets.dart';

import '../../../get_instance/src/bindings_interface.dart';
import '../routes/get_route.dart';
import '../routes/transitions_type.dart';

/// Enables the user to customize the intended pop behavior
///
/// Goes to either the previous _activePages entry or the previous page entry
///
/// e.g. if the user navigates to these pages
/// 1) /home
/// 2) /home/products/1234
///
/// when popping on [History] mode, it will emulate a browser back button.
///
/// so the new _activePages stack will be:
/// 1) /home
///
/// when popping on [Page] mode, it will only remove the last part of the route
/// so the new _activePages stack will be:
/// 1) /home
/// 2) /home/products
///
/// another pop will change the _activePages stack to:
/// 1) /home
enum PopMode {
  history,
  page,
}

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

/// A mixin that provides navigation methods for managing routes in a Flutter application.
mixin IGetNavigation {
  /// Navigates to the specified [page] with optional configurations.
  ///
  /// Parameters:
  /// - [opaque]: Whether the page is opaque.
  /// - [transition]: The transition type to use.
  /// - [curve]: The curve for the transition.
  /// - [duration]: The duration of the transition.
  /// - [id]: A unique identifier for the navigation.
  /// - [routeName]: The name of the route.
  /// - [fullscreenDialog]: Whether the page is displayed as a fullscreen dialog.
  /// - [arguments]: Additional arguments to pass to the page.
  /// - [bindings]: List of bindings to initialize with the page.
  /// - [preventDuplicates]: Prevents duplicate navigation to the same page.
  /// - [popGesture]: Enables or disables the back gesture.
  /// - [showCupertinoParallax]: Whether to show a parallax effect on iOS.
  /// - [gestureWidth]: Customizes the width of the back gesture area.
  Future<T?> to<T>(
    Widget Function() page, {
    bool? opaque,
    Transition? transition,
    Curve? curve,
    Duration? duration,
    String? id,
    String? routeName,
    bool fullscreenDialog = false,
    dynamic arguments,
    List<BindingsInterface> bindings = const [],
    bool preventDuplicates = true,
    bool? popGesture,
    bool showCupertinoParallax = true,
    double Function(BuildContext context)? gestureWidth,
  });

  /// Pops routes until the specified [fullRoute] is reached using the specified [popMode].
  Future<void> popModeUntil(
    String fullRoute, {
    PopMode popMode = PopMode.history,
  });

  /// Replaces the current route with the specified [page].
  Future<T?> off<T>(
    Widget Function() page, {
    bool? opaque,
    Transition? transition,
    Curve? curve,
    Duration? duration,
    String? id,
    String? routeName,
    bool fullscreenDialog = false,
    dynamic arguments,
    List<BindingsInterface> bindings = const [],
    bool preventDuplicates = true,
    bool? popGesture,
    bool showCupertinoParallax = true,
    double Function(BuildContext context)? gestureWidth,
  });

  /// Clears the navigation stack and navigates to the specified [page].
  Future<T?>? offAll<T>(
    Widget Function() page, {
    bool Function(GetPage route)? predicate,
    bool opaque = true,
    bool? popGesture,
    String? id,
    String? routeName,
    dynamic arguments,
    List<BindingsInterface> bindings = const [],
    bool fullscreenDialog = false,
    Transition? transition,
    Curve? curve,
    Duration? duration,
    bool showCupertinoParallax = true,
    double Function(BuildContext context)? gestureWidth,
  });

  /// Navigates to the named route [page] with optional arguments and configurations.
  Future<T?> toNamed<T>(
    String page, {
    dynamic arguments,
    String? id,
    bool preventDuplicates = true,
    Map<String, String>? parameters,
  });

  /// Replaces the current route with the named route [page].
  Future<T?> offNamed<T>(
    String page, {
    dynamic arguments,
    String? id,
    Map<String, String>? parameters,
  });

  /// Clears the navigation stack and navigates to the named route [newRouteName].
  Future<T?>? offAllNamed<T>(
    String newRouteName, {
    dynamic arguments,
    String? id,
    Map<String, String>? parameters,
  });

  /// Replaces routes until the specified named route [page] is reached.
  Future<T?>? offNamedUntil<T>(
    String page, {
    bool Function(GetPage route)? predicate,
    dynamic arguments,
    String? id,
    Map<String, String>? parameters,
  });

  /// Navigates to the named route [page] and clears routes until the predicate is met.
  Future<T?> toNamedAndOffUntil<T>(
    String page,
    bool Function(GetPage) predicate, [
    Object? data,
  ]);

  /// Replaces routes with [page] until the predicate is met.
  Future<T?> offUntil<T>(
    Widget Function() page,
    bool Function(GetPage) predicate, [
    Object? arguments,
  ]);

  /// Removes the route with the specified [name] from the navigation stack.
  void removeRoute<T>(String name);

  /// Pops the current route and optionally returns [result].
  void back<T>([T? result]);

  /// Pops the current route and navigates to the named route [page].
  Future<R?> backAndtoNamed<T, R>(String page, {T? result, Object? arguments});

  /// Pops routes until the predicate is met.
  void backUntil(bool Function(GetPage) predicate);

  /// Navigates to an unknown page. Optionally clears all pages.
  void goToUnknownPage([bool clearPages = true]);
}
