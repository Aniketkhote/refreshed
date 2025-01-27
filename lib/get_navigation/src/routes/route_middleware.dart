import 'dart:async';

import 'package:flutter/cupertino.dart';

import '../../../refreshed.dart';

/// The Page Middlewares.
/// The Functions will be called in this order
/// (( [redirect] -> [onPageCalled] -> [onBindingsStart] ->
/// [onPageBuildStart] -> [onPageBuilt] -> [onPageDispose] ))
abstract class GetMiddleware {
  GetMiddleware({this.priority = 0});

  /// The Order of the Middlewares to run.
  ///
  /// {@tool snippet}
  /// This Middewares will be called in this order.
  /// ```dart
  /// final middlewares = [
  ///   GetMiddleware(priority: 2),
  ///   GetMiddleware(priority: 5),
  ///   GetMiddleware(priority: 4),
  ///   GetMiddleware(priority: -8),
  /// ];
  /// ```
  ///  -8 => 2 => 4 => 5
  /// {@end-tool}
  final int priority;

  /// This function will be called when the page of
  /// the called route is being searched for.
  /// It take RouteSettings as a result an redirect to the new settings or
  /// give it null and there will be no redirecting.
  /// {@tool snippet}
  /// ```dart
  /// GetPage redirect(String route) {
  ///   final authService = Get.find<AuthService>();
  ///   return authService.authed.value ? null : RouteSettings(name: '/login');
  /// }
  /// ```
  /// {@end-tool}
  RouteSettings? redirect(String? route) => null;

  /// Similar to [redirect],
  /// This function will be called when the router delegate changes the
  /// current route.
  ///
  /// The default implmentation is to navigate to
  /// the input route, with no redirection.
  ///
  /// if this returns null, the navigation is stopped,
  /// and no new routes are pushed.
  /// {@tool snippet}
  /// ```dart
  /// GetNavConfig? redirect(GetNavConfig route) {
  ///   final authService = Get.find<AuthService>();
  ///   return authService.authed.value ? null : RouteSettings(name: '/login');
  /// }
  /// ```
  /// {@end-tool}
  FutureOr<RouteDecoder?> redirectDelegate(RouteDecoder route) => (route);

  /// This function will be called when this Page is called
  /// you can use it to change something about the page or give it new page
  /// {@tool snippet}
  /// ```dart
  /// GetPage onPageCalled(GetPage page) {
  ///   final authService = Get.find<AuthService>();
  ///   return page.copyWith(title: 'Welcome ${authService.UserName}');
  /// }
  /// ```
  /// {@end-tool}
  GetPage? onPageCalled(GetPage? page) => page;

  /// This function will be called right before the [BindingsInterface] are initialize.
  /// Here you can change [BindingsInterface] for this page
  /// {@tool snippet}
  /// ```dart
  /// List<Bindings> onBindingsStart(List<Bindings> bindings) {
  ///   final authService = Get.find<AuthService>();
  ///   if (authService.isAdmin) {
  ///     bindings.add(AdminBinding());
  ///   }
  ///   return bindings;
  /// }
  /// ```
  /// {@end-tool}
  List<R>? onBindingsStart<R>(List<R>? bindings) => bindings;

  /// This function will be called right after the [BindingsInterface] are initialize.
  GetPageBuilder? onPageBuildStart(GetPageBuilder? page) => page;

  /// This function will be called right after the
  /// GetPage.page function is called and will give you the result
  /// of the function. and take the widget that will be showed.
  Widget onPageBuilt(Widget page) => page;

  void onPageDispose() {}
}

/// A class to manage and execute a list of [GetMiddleware] in a prioritized manner.
///
/// This class ensures that middlewares are sorted by priority and provides
/// methods to run middleware hooks for various stages of a page's lifecycle.
class MiddlewareRunner {
  /// Creates an instance of [MiddlewareRunner].
  ///
  /// If [middlewares] is provided, it will be sorted by priority.
  MiddlewareRunner(List<GetMiddleware>? middlewares)
      : _middlewares = middlewares != null
            ? (List.of(middlewares)..sort(_compareMiddleware))
            : const [];

  /// The list of middlewares managed by this runner, sorted by priority.
  final List<GetMiddleware> _middlewares;

  /// Compares two [GetMiddleware] objects by their priority.
  ///
  /// A lower priority value indicates higher priority.
  static int _compareMiddleware(GetMiddleware a, GetMiddleware b) =>
      a.priority.compareTo(b.priority);

  /// Runs the `onPageCalled` hook for each middleware in sequence.
  ///
  /// This method allows middlewares to modify or replace the provided [page].
  ///
  /// Returns the modified or replaced [GetPage], or `null` if all middlewares return `null`.
  GetPage? runOnPageCalled(GetPage? page) {
    for (final middleware in _middlewares) {
      page = middleware.onPageCalled(page);
    }
    return page;
  }

  /// Runs the `redirect` hook for each middleware in sequence.
  ///
  /// This method allows middlewares to intercept and redirect a [route].
  ///
  /// Returns a [RouteSettings] object for redirection, or `null` if no redirection is needed.
  RouteSettings? runRedirect(String? route) {
    for (final middleware in _middlewares) {
      final redirectTo = middleware.redirect(route);
      if (redirectTo != null) {
        return redirectTo;
      }
    }
    return null;
  }

  /// Runs the `onBindingsStart` hook for each middleware in sequence.
  ///
  /// This method allows middlewares to modify or replace the list of [bindings].
  ///
  /// Returns the modified list of bindings, or `null` if all middlewares return `null`.
  List<R>? runOnBindingsStart<R>(List<R>? bindings) {
    for (final middleware in _middlewares) {
      bindings = middleware.onBindingsStart(bindings);
    }
    return bindings;
  }

  /// Runs the `onPageBuildStart` hook for each middleware in sequence.
  ///
  /// This method allows middlewares to modify or replace the [page] builder.
  ///
  /// Returns the modified [GetPageBuilder], or `null` if all middlewares return `null`.
  GetPageBuilder? runOnPageBuildStart(GetPageBuilder? page) {
    for (final middleware in _middlewares) {
      page = middleware.onPageBuildStart(page);
    }
    return page;
  }

  /// Runs the `onPageBuilt` hook for each middleware in sequence.
  ///
  /// This method allows middlewares to modify or replace the built [page] widget.
  ///
  /// Returns the modified [Widget].
  Widget runOnPageBuilt(Widget page) {
    for (final middleware in _middlewares) {
      page = middleware.onPageBuilt(page);
    }
    return page;
  }

  /// Runs the `onPageDispose` hook for each middleware in sequence.
  ///
  /// This method is called when a page is disposed, allowing middlewares to perform cleanup.
  void runOnPageDispose() {
    for (final middleware in _middlewares) {
      middleware.onPageDispose();
    }
  }
}

/// A class to handle page redirection in a GetX navigation context.
///
/// This class manages redirections based on middlewares, unknown routes,
/// and other routing configurations.
class PageRedirect {
  /// The current route being processed.
  GetPage? route;

  /// The route to display when the current route is unknown.
  GetPage? unknownRoute;

  /// The settings for the current route.
  RouteSettings? settings;

  /// Indicates whether the current route is unknown.
  bool isUnknown;

  /// Creates an instance of [PageRedirect].
  ///
  /// - [route]: The initial route.
  /// - [unknownRoute]: The fallback route for unknown pages.
  /// - [isUnknown]: Whether the route is unknown (default is `false`).
  /// - [settings]: The route settings for the current route.
  PageRedirect({
    this.route,
    this.unknownRoute,
    this.isUnknown = false,
    this.settings,
  });

  /// Returns a [GetPageRoute] for the provided route.
  ///
  /// This method processes the [rou] and [unk] routes, running any required
  /// middleware checks and returning the appropriate page route.
  GetPageRoute<T> getPageToRoute<T>(
      GetPage rou, GetPage? unk, BuildContext context) {
    // Process middleware and recheck if needed.
    while (needRecheck(context)) {
      // Prevent infinite loops by ensuring settings or route changes are valid.
      if (settings == null || route == null) break;
    }

    // Use the unknown route if the current route is marked as unknown.
    final r = (isUnknown ? unk : rou)!;

    // Create and return the GetPageRoute.
    return GetPageRoute<T>(
      page: r.page,
      parameter: r.parameters,
      alignment: r.alignment,
      title: r.title,
      maintainState: r.maintainState,
      routeName: r.name,
      settings: r,
      curve: r.curve,
      showCupertinoParallax: r.showCupertinoParallax,
      gestureWidth: r.gestureWidth,
      opaque: r.opaque,
      customTransition: r.customTransition,
      bindings: r.bindings,
      binding: r.binding,
      binds: r.binds,
      transitionDuration: r.transitionDuration ?? Get.defaultTransitionDuration,
      reverseTransitionDuration:
          r.reverseTransitionDuration ?? Get.defaultTransitionDuration,
      transition: r.transition,
      popGesture: r.popGesture,
      fullscreenDialog: r.fullscreenDialog,
      middlewares: r.middlewares,
    );
  }

  /// Checks if a redirect is needed based on the current context and settings.
  ///
  /// Returns `true` if the route needs to be rechecked; otherwise, `false`.
  bool needRecheck(BuildContext context) {
    // Set default settings if null.
    settings ??= route;

    // Match the route using the context's delegate.
    final match = context.delegate.matchRoute(settings!.name!);

    // If no matching route is found, mark it as unknown.
    if (match.route == null) {
      isUnknown = true;
      return false;
    }

    // If the route has no middlewares, no recheck is needed.
    if (match.route!.middlewares.isEmpty) return false;

    // Run middlewares for the matched route.
    final runner = MiddlewareRunner(match.route!.middlewares);
    route = runner.runOnPageCalled(match.route);
    addPageParameter(route!);

    // Run redirect logic for the current route.
    settings = runner.runRedirect(settings!.name) ?? settings;

    // Recheck if the settings or route has changed.
    return settings != match.route;
  }

  /// Adds parameters from the provided [route] to the global [Get.parameters].
  void addPageParameter(GetPage route) {
    if (route.parameters == null) return;

    // Merge the route's parameters with the existing global parameters.
    final parameters = Map<String, String?>.from(Get.parameters);
    parameters.addEntries(route.parameters!.entries);
  }
}
