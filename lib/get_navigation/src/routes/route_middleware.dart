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
  RouteSettings? runRedirect(String? route) {
    for (final middleware in _middlewares) {
      final redirectTo = middleware.redirect(route);
      if (redirectTo != null) return redirectTo;
    }
    return null;
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
    while (needRecheck(context)) {
      if (settings == null || route == null) break;
    }
    final r = (isUnknown ? unk : rou)!;
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

  /// Determines if redirection is needed.
  bool needRecheck(BuildContext context) {
    settings ??= route;
    final match = context.delegate.matchRoute(settings!.name!);
    if (match.route == null) {
      isUnknown = true;
      return false;
    }
    if (match.route!.middlewares.isEmpty) return false;
    final runner = MiddlewareRunner(match.route!.middlewares);
    route = runner.runOnPageCalled(match.route);
    addPageParameter(route!);
    settings = runner.runRedirect(settings!.name) ?? settings;
    return settings != match.route;
  }

  /// Adds parameters from [route] to [Get.parameters].
  void addPageParameter(GetPage route) {
    if (route.parameters == null) return;
    Get.parameters.addAll(route.parameters!);
  }
}
