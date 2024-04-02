import "dart:async";

import "package:flutter/foundation.dart";
import "package:flutter/material.dart";
import "package:refreshed/get_instance/src/bindings_interface.dart";
import "package:refreshed/get_navigation/src/routes/new_path_route.dart";
import "package:refreshed/route_manager.dart";
import "package:refreshed/utils.dart";

class GetDelegate<T> extends RouterDelegate<RouteDecoder<T>>
    with
        ChangeNotifier,
        PopNavigatorRouterDelegateMixin<RouteDecoder<T>>,
        IGetNavigation<T> {
  GetDelegate({
    required List<GetPage<T>> pages,
    GetPage<T>? notFoundRoute,
    this.navigatorObservers,
    this.transitionDelegate,
    this.backButtonPopMode = PopMode.history,
    this.preventDuplicateHandlingMode =
        PreventDuplicateHandlingMode.reorderRoutes,
    this.pickPagesForRootNavigator,
    this.restorationScopeId,
    bool showHashOnUrl = false,
    GlobalKey<NavigatorState>? navigatorKey,
  })  : navigatorKey = navigatorKey ?? GlobalKey<NavigatorState>(),
        notFoundRoute = notFoundRoute ??= GetPage(
          name: "/404",
          page: () => const Scaffold(
            body: Center(child: Text("Route not found")),
          ),
        ) {
    if (!showHashOnUrl && GetPlatform.isWeb) {
      setUrlStrategy();
    }
    addPages(pages);
    addPage(notFoundRoute);
    Get.log("GetDelegate is created !");
  }
  factory GetDelegate.createDelegate({
    GetPage<T>? notFoundRoute,
    List<GetPage<dynamic>> pages = const <GetPage<dynamic>>[],
    List<NavigatorObserver>? navigatorObservers,
    TransitionDelegate<dynamic>? transitionDelegate,
    PopMode backButtonPopMode = PopMode.history,
    PreventDuplicateHandlingMode preventDuplicateHandlingMode =
        PreventDuplicateHandlingMode.reorderRoutes,
    GlobalKey<NavigatorState>? navigatorKey,
  }) =>
      GetDelegate(
        notFoundRoute: notFoundRoute,
        navigatorObservers: navigatorObservers,
        transitionDelegate: transitionDelegate,
        backButtonPopMode: backButtonPopMode,
        preventDuplicateHandlingMode: preventDuplicateHandlingMode,
        pages: pages as List<GetPage<T>>,
        navigatorKey: navigatorKey,
      );

  final List<RouteDecoder> _activePages = <RouteDecoder>[];
  final PopMode backButtonPopMode;
  final PreventDuplicateHandlingMode preventDuplicateHandlingMode;

  final GetPage notFoundRoute;

  final List<NavigatorObserver>? navigatorObservers;
  final TransitionDelegate<dynamic>? transitionDelegate;

  final Iterable<GetPage> Function(RouteDecoder currentNavStack)?
      pickPagesForRootNavigator;

  List<RouteDecoder> get activePages => _activePages;

  final ParseRouteTree<T> _routeTree =
      ParseRouteTree<T>(routes: <GetPage<T>>[]);

  List<GetPage> get registeredRoutes => _routeTree.routes;

  void addPages(List<GetPage<T>> getPages) {
    _routeTree.addRoutes(getPages);
  }

  void clearRouteTree() {
    _routeTree.routes.clear();
  }

  void addPage(GetPage<T> getPage) {
    _routeTree.addRoute(getPage);
  }

  void removePage(GetPage<T> getPage) {
    _routeTree.removeRoute(getPage);
  }

  RouteDecoder<T> matchRoute(String name, {PageSettings? arguments}) =>
      _routeTree.matchRoute(name, arguments: arguments);

  @override
  GlobalKey<NavigatorState> navigatorKey;

  final String? restorationScopeId;

  Future<RouteDecoder?> runMiddleware(RouteDecoder config) async {
    final List<GetMiddleware> middlewares =
        config.currentTreeBranch.last.middlewares;
    if (middlewares.isEmpty) {
      return config;
    }
    RouteDecoder iterator = config;
    for (final GetMiddleware item in middlewares) {
      final RouteDecoder? redirectRes = await item.redirectDelegate(iterator);
      if (redirectRes == null) {
        return null;
      }
      iterator = redirectRes;
      // Stop the iteration over the middleware if we changed page
      // and that redirectRes is not the same as the current config.
      if (config != redirectRes) {
        break;
      }
    }
    // If the target is not the same as the source, we need
    // to run the middlewares for the new route.
    if (iterator != config) {
      return runMiddleware(iterator);
    }
    return iterator;
  }

  Future<void> _unsafeHistoryAdd(RouteDecoder config) async {
    final RouteDecoder? res = await runMiddleware(config);
    if (res == null) {
      return;
    }
    _activePages.add(res);
  }

  Future<T?> _unsafeHistoryRemoveAt(int index, T? result) async {
    if (index == _activePages.length - 1 && _activePages.length > 1) {
      //removing WILL update the current route
      final RouteDecoder toCheck = _activePages[_activePages.length - 2];
      final RouteDecoder? resMiddleware = await runMiddleware(toCheck);
      if (resMiddleware == null) {
        return null;
      }
      _activePages[_activePages.length - 2] = resMiddleware;
    }

    final Completer? completer = _activePages.removeAt(index).route?.completer;
    if (completer?.isCompleted == false) {
      completer!.complete(result);
    }

    return completer?.future as T?;
  }

  T arguments() => currentConfiguration?.pageSettings?.arguments as T;

  Map<String, String> get parameters =>
      currentConfiguration?.pageSettings?.params ?? <String, String>{};

  PageSettings? get pageSettings => currentConfiguration?.pageSettings;

  Future<void> _pushHistory(RouteDecoder config) async {
    if (config.route!.preventDuplicates) {
      final int originalEntryIndex = _activePages.indexWhere(
        (RouteDecoder element) =>
            element.pageSettings?.name == config.pageSettings?.name,
      );
      if (originalEntryIndex >= 0) {
        switch (preventDuplicateHandlingMode) {
          case PreventDuplicateHandlingMode.popUntilOriginalRoute:
            popModeUntil(config.pageSettings!.name, popMode: PopMode.page);
          case PreventDuplicateHandlingMode.reorderRoutes:
            await _unsafeHistoryRemoveAt(originalEntryIndex, null);
            await _unsafeHistoryAdd(config);
          case PreventDuplicateHandlingMode.doNothing:
          default:
            break;
        }
        return;
      }
    }
    await _unsafeHistoryAdd(config);
  }

  Future<T?> _popHistory(T? result) async {
    if (!_canPopHistory()) {
      return null;
    }
    return _doPopHistory(result);
  }

  Future<T?> _doPopHistory(T? result) async =>
      _unsafeHistoryRemoveAt(_activePages.length - 1, result);

  Future<T?> _popPage(T? result) async {
    if (!_canPopPage()) {
      return null;
    }
    return _doPopPage(result);
  }

  // returns the popped page
  Future<T?> _doPopPage(T? result) async {
    final List<GetPage>? currentBranch =
        currentConfiguration?.currentTreeBranch;
    if (currentBranch != null && currentBranch.length > 1) {
      //remove last part only
      final Iterable<GetPage> remaining =
          currentBranch.take(currentBranch.length - 1);
      final RouteDecoder? prevHistoryEntry = _activePages.length > 1
          ? _activePages[_activePages.length - 2]
          : null;

      //check if current route is the same as the previous route
      if (prevHistoryEntry != null) {
        //if so, pop the entire _activePages entry
        final String newLocation = remaining.last.name;
        final String? prevLocation = prevHistoryEntry.pageSettings?.name;
        if (newLocation == prevLocation) {
          //pop the entire _activePages entry
          return _popHistory(result);
        }
      }

      //create a new route with the remaining tree branch
      final T? res = await _popHistory(result);
      await _pushHistory(
        RouteDecoder(
          remaining.toList(),
          null,
          //TOOD: persist state??
        ),
      );
      return res;
    } else {
      //remove entire entry
      return _popHistory(result);
    }
  }

  Future<T?> _pop(PopMode mode, T? result) async {
    switch (mode) {
      case PopMode.history:
        return _popHistory(result);
      case PopMode.page:
        return _popPage(result);
      default:
        return null;
    }
  }

  Future<T?> popHistory(T? result) async => _popHistory(result);

  bool _canPopHistory() => _activePages.length > 1;

  Future<bool> canPopHistory() => SynchronousFuture<bool>(_canPopHistory());

  bool _canPopPage() {
    final List<GetPage>? currentTreeBranch =
        currentConfiguration?.currentTreeBranch;
    if (currentTreeBranch == null) {
      return false;
    }
    return currentTreeBranch.length > 1 || _canPopHistory();
  }

  Future<bool> canPopPage() => SynchronousFuture<bool>(_canPopPage());

  bool _canPop(PopMode mode) {
    switch (mode) {
      case PopMode.history:
        return _canPopHistory();
      case PopMode.page:
        return _canPopPage();
    }
  }

  /// gets the visual pages from the current _activePages entry
  ///
  /// visual pages must have [GetPage.participatesInRootNavigator] set to true
  Iterable<GetPage> getVisualPages(RouteDecoder? currentHistory) {
    final Iterable<GetPage> res = currentHistory!.currentTreeBranch
        .where((GetPage r) => r.participatesInRootNavigator != null);
    if (res.isEmpty) {
      //default behavior, all routes participate in root navigator
      return _activePages.map((RouteDecoder e) => e.route!);
    } else {
      //user specified at least one participatesInRootNavigator
      return res.where(
        (GetPage element) => element.participatesInRootNavigator == true,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final RouteDecoder? currentHistory = currentConfiguration;
    final List<GetPage> pages = currentHistory == null
        ? <GetPage>[]
        : pickPagesForRootNavigator?.call(currentHistory).toList() ??
            getVisualPages(currentHistory).toList();
    if (pages.isEmpty) {
      return ColoredBox(
        color: Theme.of(context).scaffoldBackgroundColor,
      );
    }
    return GetNavigator(
      key: navigatorKey,
      onPopPage: _onPopVisualRoute,
      pages: pages,
      observers: navigatorObservers,
      transitionDelegate:
          transitionDelegate ?? const DefaultTransitionDelegate<dynamic>(),
    );
  }

  @override
  Future<void> goToUnknownPage([bool clearPages = false]) async {
    if (clearPages) {
      _activePages.clear();
    }

    final PageSettings pageSettings = _buildPageSettings(notFoundRoute.name);
    final RouteDecoder? routeDecoder = _getRouteDecoder(pageSettings);

    await _push(routeDecoder!);
  }

  @protected
  void _popWithResult([T? result]) {
    final Completer? completer = _activePages.removeLast().route?.completer;
    if (completer?.isCompleted == false) {
      completer!.complete(result);
    }
  }

  @override
  Future<T?> toNamed(
    String page, {
    Object? arguments,
    String? id,
    bool preventDuplicates = true,
    Map<String, String>? parameters,
  }) async {
    final PageSettings args = _buildPageSettings(page, arguments);
    final RouteDecoder<T>? route = _getRouteDecoder(args);
    if (route != null) {
      return _push(route);
    } else {
      await goToUnknownPage();
    }
    return null;
  }

  @override
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
    bool rebuildStack = true,
    PreventDuplicateHandlingMode preventDuplicateHandlingMode =
        PreventDuplicateHandlingMode.reorderRoutes,
  }) async {
    routeName = cleanRouteName("/${page.runtimeType}");
    // if (preventDuplicateHandlingMode ==
    //PreventDuplicateHandlingMode.Recreate) {
    //   routeName = routeName + page.hashCode.toString();
    // }

    final GetPage<T> getPage = GetPage<T>(
      name: routeName,
      opaque: opaque ?? true,
      page: page,
      gestureWidth: gestureWidth,
      showCupertinoParallax: showCupertinoParallax,
      popGesture: popGesture ?? Get.defaultPopGesture,
      transition: transition ?? Get.defaultTransition,
      curve: curve ?? Get.defaultTransitionCurve,
      fullscreenDialog: fullscreenDialog,
      bindings: bindings,
      transitionDuration: duration ?? Get.defaultTransitionDuration,
      preventDuplicateHandlingMode: preventDuplicateHandlingMode,
    );

    _routeTree.addRoute(getPage);
    final PageSettings args = _buildPageSettings(routeName, arguments);
    final RouteDecoder? route = _getRouteDecoder(args);
    final T? result = await _push(
      route!,
      rebuildStack: rebuildStack,
    );
    _routeTree.removeRoute(getPage);
    return result;
  }

  @override
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
  }) async {
    routeName = cleanRouteName("/${page.runtimeType}");
    final GetPage<T> route = GetPage<T>(
      name: routeName,
      opaque: opaque ?? true,
      page: page,
      gestureWidth: gestureWidth,
      showCupertinoParallax: showCupertinoParallax,
      popGesture: popGesture ?? Get.defaultPopGesture,
      transition: transition ?? Get.defaultTransition,
      curve: curve ?? Get.defaultTransitionCurve,
      fullscreenDialog: fullscreenDialog,
      bindings: bindings,
      transitionDuration: duration ?? Get.defaultTransitionDuration,
    );

    final PageSettings args = _buildPageSettings(routeName, arguments);
    return _replace(args, route);
  }

  @override
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
  }) async {
    routeName = cleanRouteName("/${page.runtimeType}");
    final GetPage<T> route = GetPage<T>(
      name: routeName,
      opaque: opaque,
      page: page,
      gestureWidth: gestureWidth,
      showCupertinoParallax: showCupertinoParallax,
      popGesture: popGesture ?? Get.defaultPopGesture,
      transition: transition ?? Get.defaultTransition,
      curve: curve ?? Get.defaultTransitionCurve,
      fullscreenDialog: fullscreenDialog,
      bindings: bindings,
      transitionDuration: duration ?? Get.defaultTransitionDuration,
    );

    final PageSettings args = _buildPageSettings(routeName, arguments);

    final bool Function(GetPage route) newPredicate =
        predicate ?? (GetPage route) => false;

    while (_activePages.length > 1 && !newPredicate(_activePages.last.route!)) {
      _popWithResult();
    }

    return _replace(args, route);
  }

  @override
  Future<T?>? offAllNamed(
    String newRouteName, {
    // bool Function(GetPage route)? predicate,
    Object? arguments,
    String? id,
    Map<String, String>? parameters,
  }) async {
    final PageSettings args = _buildPageSettings(newRouteName, arguments);
    final RouteDecoder<T>? route = _getRouteDecoder(args);
    if (route == null) {
      return null;
    }

    while (_activePages.length > 1) {
      _activePages.removeLast();
    }

    return _replaceNamed(route);
  }

  @override
  Future<T?>? offNamedUntil(
    String page, {
    bool Function(GetPage route)? predicate,
    Object? arguments,
    String? id,
    Map<String, String>? parameters,
  }) async {
    final PageSettings args = _buildPageSettings(page, arguments);
    final RouteDecoder<T>? route = _getRouteDecoder(args);
    if (route == null) {
      return null;
    }

    final bool Function(GetPage<T> route) newPredicate =
        predicate ?? (GetPage<T> route) => false;

    while (_activePages.length > 1 &&
        newPredicate(_activePages.last.route! as GetPage<T>)) {
      _activePages.removeLast();
    }

    return _replaceNamed(route);
  }

  @override
  Future<T?> offNamed(
    String page, {
    Object? arguments,
    String? id,
    Map<String, String>? parameters,
  }) async {
    final PageSettings args = _buildPageSettings(page, arguments);
    final RouteDecoder? route = _getRouteDecoder(args);
    if (route == null) {
      return null;
    }
    _popWithResult();
    return _push(route);
  }

  @override
  Future<T?> toNamedAndOffUntil(
    String page,
    bool Function(GetPage) predicate, [
    Object? data,
  ]) async {
    final PageSettings arguments = _buildPageSettings(page, data);

    final RouteDecoder<T>? route = _getRouteDecoder(arguments);

    if (route == null) {
      return null;
    }

    while (_activePages.isNotEmpty && !predicate(_activePages.last.route!)) {
      _popWithResult();
    }

    return _push(route);
  }

  @override
  Future<T?> offUntil(
    Widget Function() page,
    bool Function(GetPage) predicate, [
    Object? arguments,
  ]) async {
    while (_activePages.isNotEmpty && !predicate(_activePages.last.route!)) {
      _popWithResult();
    }

    return to(page, arguments: arguments);
  }

  @override
  void removeRoute(String name) {
    _activePages.remove(RouteDecoder<T>.fromRoute(name));
  }

  bool get canBack => _activePages.length > 1;

  void _checkIfCanBack() {
    assert(() {
      if (!canBack) {
        final RouteDecoder last = _activePages.last;
        final String? name = last.route?.name;
        throw "The page $name cannot be popped";
      }
      return true;
    }());
  }

  @override
  Future<T?> backAndtoNamed(
    String page, {
    Object? result,
    Object? arguments,
  }) async {
    final PageSettings args = _buildPageSettings(page, arguments);
    final RouteDecoder? route = _getRouteDecoder(args);
    if (route == null) {
      return null;
    }
    _popWithResult(result as T?);
    return _push(route);
  }

  /// Removes routes according to [PopMode]
  /// until it reaches the specific [fullRoute],
  /// DOES NOT remove the [fullRoute]
  @override
  Future<void> popModeUntil(
    String fullRoute, {
    PopMode popMode = PopMode.history,
  }) async {
    // remove history or page entries until you meet route
    RouteDecoder? iterator = currentConfiguration;
    while (_canPop(popMode) && iterator != null) {
      //the next line causes wasm compile error if included in the while loop
      //https://github.com/flutter/flutter/issues/140110
      if (iterator.pageSettings?.name == fullRoute) {
        break;
      }
      await _pop(popMode, null);
      // replace iterator
      iterator = currentConfiguration;
    }
    notifyListeners();
  }

  @override
  void backUntil(bool Function(GetPage) predicate) {
    while (_activePages.length <= 1 && !predicate(_activePages.last.route!)) {
      _popWithResult();
    }

    notifyListeners();
  }

  Future<T?> _replace(PageSettings arguments, GetPage<T> page) async {
    final int index = _activePages.length > 1 ? _activePages.length - 1 : 0;
    _routeTree.addRoute(page);

    final RouteDecoder? activePage = _getRouteDecoder(arguments);

    _activePages[index] = activePage!;

    notifyListeners();
    final Future<T?>? result =
        await activePage.route?.completer?.future as Future<T?>?;
    _routeTree.removeRoute(page);

    return result;
  }

  Future<T?> _replaceNamed(RouteDecoder activePage) async {
    final int index = _activePages.length > 1 ? _activePages.length - 1 : 0;
    _activePages[index] = activePage;

    notifyListeners();
    final Future<T?>? result =
        await activePage.route?.completer?.future as Future<T?>?;
    return result;
  }

  PageSettings _buildPageSettings(String page, [Object? data]) {
    final Uri uri = Uri.parse(page);
    return PageSettings(uri, data);
  }

  @protected
  RouteDecoder<T>? _getRouteDecoder(PageSettings arguments) {
    String page = arguments.uri.path;
    final Map<String, String> parameters = arguments.params;
    if (parameters.isNotEmpty) {
      final Uri uri = Uri(path: page, queryParameters: parameters);
      page = uri.toString();
    }

    final RouteDecoder<T> decoder =
        _routeTree.matchRoute(page, arguments: arguments);
    final GetPage<T>? route = decoder.route;
    if (route == null) {
      return null;
    }

    return _configureRouterDecoder(decoder, arguments);
  }

  @protected
  RouteDecoder<T> _configureRouterDecoder(
    RouteDecoder<T> decoder,
    PageSettings arguments,
  ) {
    final Map<String, String> parameters =
        arguments.params.isEmpty ? arguments.query : arguments.params;
    arguments.params.addAll(arguments.query);
    if (decoder.parameters.isEmpty) {
      decoder.parameters.addAll(parameters);
    }

    decoder.route = decoder.route?.copyWith(
      completer: _activePages.isEmpty ? null : Completer<T?>(),
      arguments: arguments,
      parameters: parameters,
      key: ValueKey<String>(arguments.name),
    );

    return decoder;
  }

  Future<T?> _push(RouteDecoder decoder, {bool rebuildStack = true}) async {
    final RouteDecoder? mid = await runMiddleware(decoder);
    final RouteDecoder res = mid ?? decoder;
    // if (res == null) res = decoder;

    final PreventDuplicateHandlingMode preventDuplicateHandlingMode =
        res.route?.preventDuplicateHandlingMode ??
            PreventDuplicateHandlingMode.reorderRoutes;

    final RouteDecoder? onStackPage = _activePages.firstWhereOrNull(
      (RouteDecoder element) => element.route?.key == res.route?.key,
    );

    /// There are no duplicate routes in the stack
    if (onStackPage == null) {
      _activePages.add(res);
    } else {
      /// There are duplicate routes, reorder
      switch (preventDuplicateHandlingMode) {
        case PreventDuplicateHandlingMode.doNothing:
          break;
        case PreventDuplicateHandlingMode.reorderRoutes:
          _activePages.remove(onStackPage);
          _activePages.add(res);
        case PreventDuplicateHandlingMode.popUntilOriginalRoute:
          while (_activePages.last == onStackPage) {
            _popWithResult();
          }
        case PreventDuplicateHandlingMode.recreate:
          _activePages.remove(onStackPage);
          _activePages.add(res);
      }
    }
    if (rebuildStack) {
      notifyListeners();
    }

    return decoder.route?.completer?.future as Future<T?>?;
  }

  @override
  Future<void> setNewRoutePath(RouteDecoder configuration) async {
    final GetPage? page = configuration.route;
    if (page == null) {
      await goToUnknownPage();
      return;
    } else {
      _push(configuration);
    }
  }

  @override
  RouteDecoder<T>? get currentConfiguration {
    if (_activePages.isEmpty) {
      return null;
    }
    final RouteDecoder route = _activePages.last;
    return route as RouteDecoder<T>;
  }

  Future<bool> handlePopupRoutes({
    Object? result,
  }) async {
    Route? currentRoute;
    navigatorKey.currentState!.popUntil((Route route) {
      currentRoute = route;
      return true;
    });
    if (currentRoute is PopupRoute) {
      return navigatorKey.currentState!.maybePop(result);
    }
    return false;
  }

  @override
  Future<bool> popRoute({
    Object? result,
    PopMode? popMode,
  }) async {
    //Returning false will cause the entire app to be popped.
    final bool wasPopup = await handlePopupRoutes(result: result);
    if (wasPopup) {
      return true;
    }

    if (_canPop(popMode ?? backButtonPopMode)) {
      await _pop(popMode ?? backButtonPopMode, result as T?);
      notifyListeners();
      return true;
    }

    return super.popRoute();
  }

  @override
  void back([T? result]) {
    _checkIfCanBack();
    _popWithResult(result);
    notifyListeners();
  }

  // ignore: avoid_annotating_with_dynamic
  bool _onPopVisualRoute(Route<dynamic> route, dynamic result) {
    final bool didPop = route.didPop(result);
    if (!didPop) {
      return false;
    }
    _popWithResult(result);
    // final settings = route.settings;
    // if (settings is GetPage) {
    //   final config = _activePages.cast<RouteDecoder?>().firstWhere(
    //         (element) => element?.route == settings,
    //         orElse: () => null,
    //       );
    //   if (config != null) {
    //     _removeHistoryEntry(config, result);
    //   }
    // }
    notifyListeners();
    //return !route.navigator!.userGestureInProgress;
    return true;
  }
}

/// Takes a route [name] String generated by [to], [off], [offAll]
/// (and similar context navigation methods), cleans the extra chars and
/// accommodates the format.
///
/// This function cleans and formats the route name string to adhere to a
/// more appealing URL naming convention, such as kebab case.
///
/// Example:
/// ```dart
/// void main() {
///   String routeName = "() => MyHomeScreenView";
///   String cleanedRoute = cleanRouteName(routeName);
///   print(cleanedRoute); // Output: '/my-home-screen-view'
/// }
/// ```
///
/// In the above example, the `cleanRouteName` function takes a route name
/// string generated by context navigation methods, removes any extra characters,
/// converts it to kebab case, and prepends a forward slash if necessary.
/// The cleaned route name is then returned.
String cleanRouteName(String name) {
  name = name.replaceAll("() => ", "");

  // Convert the route name to kebab case
  // name = name.paramCase!;

  if (!name.startsWith("/")) {
    name = "/$name";
  }

  // Optionally, parse the route name as a URI and convert it to a string
  return Uri.tryParse(name)?.toString() ?? name;
}
