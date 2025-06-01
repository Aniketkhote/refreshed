import 'dart:async';

import 'package:flutter/cupertino.dart';

import '../../../refreshed.dart';

/// Middleware to handle page lifecycle events in a prioritized manner.
///
/// Functions are called in this order:
/// `redirect -> onPageCalled -> onBindingsStart -> onPageBuildStart -> onPageBuilt -> onPageDispose`
abstract class GetMiddleware {
  /// Creates a middleware with a given priority.
  const GetMiddleware({this.priority = 0});

  /// Defines the execution order of middlewares. Lower values run first.
  final int priority;

  /// Called when searching for a route. Can return a new [RouteSettings] to redirect.
  RouteSettings? redirect(String? route) => null;

  /// Called when the router delegate changes the current route.
  FutureOr<RouteDecoder?> redirectDelegate(RouteDecoder route) => route;

  /// Called when a page is accessed. Can modify the [GetPage].
  GetPage? onPageCalled(GetPage? page) => page;

  /// Called before [BindingsInterface] initialization. Can modify bindings.
  List<R>? onBindingsStart<R>(List<R>? bindings) => bindings;

  /// Called before the page builder executes.
  GetPageBuilder? onPageBuildStart(GetPageBuilder? page) => page;

  /// Called after the page builder executes.
  Widget onPageBuilt(Widget page) => page;

  /// Called when the page is disposed.
  void onPageDispose() {}
}

/// Manages and executes [GetMiddleware] in a prioritized order.
class MiddlewareRunner {
  /// Creates a [MiddlewareRunner] and sorts middlewares by priority.
  MiddlewareRunner(List<GetMiddleware>? middlewares)
      : _middlewares = middlewares != null
            ? (List.of(middlewares)
              ..sort((a, b) => a.priority.compareTo(b.priority)))
            : const [];

  final List<GetMiddleware> _middlewares;

  /// Runs the `onPageCalled` hook in sequence.
  GetPage? runOnPageCalled(GetPage? page) {
    for (final middleware in _middlewares) {
      page = middleware.onPageCalled(page);
    }
    return page;
  }

  /// Runs the `redirect` hook in sequence.
  ///
  /// Returns the first non-null redirect result from any middleware,
  /// or null if no middleware redirects.
  RouteSettings? runRedirect(String? route) {
    // Use firstWhereOrNull with pattern matching to find the first middleware that redirects
    final redirectingMiddleware = _middlewares.firstWhereOrNull(
      (middleware) => middleware.redirect(route) != null
    );
    
    // Return the redirect result from the middleware or null if none found
    return redirectingMiddleware?.redirect(route);
  }

  /// Runs the `onBindingsStart` hook in sequence.
  List<R>? runOnBindingsStart<R>(List<R>? bindings) {
    for (final middleware in _middlewares) {
      bindings = middleware.onBindingsStart(bindings);
    }
    return bindings;
  }

  /// Runs the `onPageBuildStart` hook in sequence.
  GetPageBuilder? runOnPageBuildStart(GetPageBuilder? page) {
    for (final middleware in _middlewares) {
      page = middleware.onPageBuildStart(page);
    }
    return page;
  }

  /// Runs the `onPageBuilt` hook in sequence.
  Widget runOnPageBuilt(Widget page) {
    for (final middleware in _middlewares) {
      page = middleware.onPageBuilt(page);
    }
    return page;
  }

  /// Runs the `onPageDispose` hook in sequence.
  void runOnPageDispose() {
    for (final middleware in _middlewares) {
      middleware.onPageDispose();
    }
  }
}

/// Handles page redirection in a GetX navigation context.
class PageRedirect {
  GetPage? route;
  GetPage? unknownRoute;
  RouteSettings? settings;
  bool isUnknown;

  /// Creates an instance of [PageRedirect].
  PageRedirect(
      {this.route, this.unknownRoute, this.isUnknown = false, this.settings});

  /// Returns a [GetPageRoute] for the given route.
  GetPageRoute<T> getPageToRoute<T>(
      GetPage rou, GetPage? unk, BuildContext context) {
    // Check for redirections until we reach a stable state
    while (needRecheck(context)) {
      // Break if we lose essential state
      if (settings == null || route == null) break;
    }
    
    // Determine the final route to use (unknown or regular)
    final r = (isUnknown ? unk : rou)!;
    
    // Create and return the page route with all properties from the route
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
      // Use default transition duration if not specified
      transitionDuration: r.transitionDuration ?? Get.defaultTransitionDuration,
      reverseTransitionDuration:
          r.reverseTransitionDuration ?? Get.defaultTransitionDuration,
      transition: r.transition,
      popGesture: r.popGesture,
      fullscreenDialog: r.fullscreenDialog,
      middlewares: r.middlewares,
    );
  }

  /// Determines if redirection is needed based on route middlewares.
  ///
  /// This method:
  /// 1. Ensures settings are initialized
  /// 2. Matches the current route
  /// 3. Processes middlewares if present
  /// 4. Returns whether redirection is needed
  bool needRecheck(BuildContext context) {
    // Ensure settings is initialized
    settings ??= route;
    
    // Get the matched route for the current settings
    final match = context.delegate.matchRoute(settings!.name!);
    
    // Handle case when no route is found
    if (match.route == null) {
      isUnknown = true;
      return false;
    }
    
    // If no middlewares, no need to recheck
    if (match.route!.middlewares.isEmpty) {
      return false;
    }
    
    // Process middlewares
    final matchedRoute = match.route!;
    final runner = MiddlewareRunner(matchedRoute.middlewares);
    route = runner.runOnPageCalled(matchedRoute);
    addPageParameter(route!);
    settings = runner.runRedirect(settings!.name) ?? settings;
    
    // Return true if settings changed (redirection happened)
    return settings != matchedRoute;
  }

  /// Adds parameters from [route] to [Get.parameters].
  ///
  /// Uses pattern matching to handle the nullable parameters map.
  void addPageParameter(GetPage route) => switch (route.parameters) {
    // When parameters exist, add them to the global parameters
    Map<String, String> params => Get.parameters.addAll(params),
    // When parameters are null, do nothing
    null => {},
  };
}
