import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:refreshed/get_navigation/src/routes/not_found_page.dart';

import '../../../get_instance/src/bindings_interface.dart';
import '../../../get_utils/src/platform/platform.dart';
import '../../../route_manager.dart';

class GetDelegate extends RouterDelegate<RouteDecoder>
    with
        ChangeNotifier,
        PopNavigatorRouterDelegateMixin<RouteDecoder>,
        IGetNavigation {
  factory GetDelegate.createDelegate({
    GetPage<dynamic>? notFoundRoute,
    List<GetPage> pages = const [],
    List<NavigatorObserver>? navigatorObservers,
    TransitionDelegate<dynamic>? transitionDelegate,
    PopMode backButtonPopMode = PopMode.history,
    PreventDuplicateHandlingMode preventDuplicateHandlingMode =
        PreventDuplicateHandlingMode.reorderRoutes,
    GlobalKey<NavigatorState>? navigatorKey,
  }) {
    return GetDelegate(
      notFoundRoute: notFoundRoute,
      navigatorObservers: navigatorObservers,
      transitionDelegate: transitionDelegate,
      backButtonPopMode: backButtonPopMode,
      preventDuplicateHandlingMode: preventDuplicateHandlingMode,
      pages: pages,
      navigatorKey: navigatorKey,
    );
  }

  final List<RouteDecoder> _activePages = <RouteDecoder>[];
  final PopMode backButtonPopMode;
  final PreventDuplicateHandlingMode preventDuplicateHandlingMode;

  final GetPage notFoundRoute;

  final List<NavigatorObserver>? navigatorObservers;
  final TransitionDelegate<dynamic>? transitionDelegate;

  final Iterable<GetPage> Function(RouteDecoder currentNavStack)?
      pickPagesForRootNavigator;

  List<RouteDecoder> get activePages => _activePages;

  final _routeTree = ParseRouteTree(routes: []);

  List<GetPage> get registeredRoutes => _routeTree.routes;

  void addPages(List<GetPage> getPages) {
    _routeTree.addRoutes(getPages);
  }

  void clearRouteTree() {
    _routeTree.routes.clear();
  }

  void addPage(GetPage getPage) {
    _routeTree.addRoute(getPage);
  }

  void removePage(GetPage getPage) {
    _routeTree.removeRoute(getPage);
  }

  RouteDecoder matchRoute(String name, {PageSettings? arguments}) {
    return _routeTree.matchRoute(name, arguments: arguments);
  }

  @override
  GlobalKey<NavigatorState> navigatorKey;

  final String? restorationScopeId;

  GetDelegate({
    GetPage? notFoundRoute,
    this.navigatorObservers,
    this.transitionDelegate,
    this.backButtonPopMode = PopMode.history,
    this.preventDuplicateHandlingMode =
        PreventDuplicateHandlingMode.reorderRoutes,
    this.pickPagesForRootNavigator,
    this.restorationScopeId,
    bool showHashOnUrl = false,
    GlobalKey<NavigatorState>? navigatorKey,
    required List<GetPage> pages,
  })  : navigatorKey = navigatorKey ?? GlobalKey<NavigatorState>(),
        notFoundRoute = notFoundRoute ??=
            GetPage(name: '/404', page: () => NotFoundPage()) {
    if (!showHashOnUrl && GetPlatform.isWeb) setUrlStrategy();
    addPages(pages);
    addPage(notFoundRoute);
    Get.log('GetDelegate is created !');
  }

  Future<RouteDecoder?> runMiddleware(RouteDecoder config) async {
    final middlewares = config.currentTreeBranch.last.middlewares;
    if (middlewares.isEmpty) {
      return config;
    }
    var iterator = config;
    for (var item in middlewares) {
      var redirectRes = await item.redirectDelegate(iterator);

      if (redirectRes == null) {
        config.route?.completer?.complete();
        return null;
      }
      if (config != redirectRes) {
        config.route?.completer?.complete();
        Get.log('Redirect to ${redirectRes.pageSettings?.name}');
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
      return await runMiddleware(iterator);
    }
    return iterator;
  }

  Future<void> _unsafeHistoryAdd(RouteDecoder config) async {
    final res = await runMiddleware(config);
    if (res == null) return;
    _activePages.add(res);
  }

  Future<T?> _unsafeHistoryRemoveAt<T>(int index, T result) async {
    if (index == _activePages.length - 1 && _activePages.length > 1) {
      //removing WILL update the current route
      final toCheck = _activePages[_activePages.length - 2];
      final resMiddleware = await runMiddleware(toCheck);
      if (resMiddleware == null) return null;
      _activePages[_activePages.length - 2] = resMiddleware;
    }

    final completer = _activePages.removeAt(index).route?.completer;
    if (completer?.isCompleted == false) completer!.complete(result);

    return completer?.future as T?;
  }

  T arguments<T>() {
    return currentConfiguration?.pageSettings?.arguments as T;
  }

  Map<String, String> get parameters {
    return currentConfiguration?.pageSettings?.params ?? {};
  }

  PageSettings? get pageSettings {
    return currentConfiguration?.pageSettings;
  }

  Future<void> _pushHistory(RouteDecoder config) async {
    if (config.route!.preventDuplicates) {
      final originalEntryIndex = _activePages.indexWhere(
          (element) => element.pageSettings?.name == config.pageSettings?.name);
      if (originalEntryIndex >= 0) {
        switch (preventDuplicateHandlingMode) {
          case PreventDuplicateHandlingMode.popUntilOriginalRoute:
            popModeUntil(config.pageSettings!.name, popMode: PopMode.page);
            return;
          case PreventDuplicateHandlingMode.reorderRoutes:
            await _unsafeHistoryRemoveAt(originalEntryIndex, null);
            await _unsafeHistoryAdd(config);
            return;
          case PreventDuplicateHandlingMode.doNothing:
          default:
            return;
        }
      }
    }
    await _unsafeHistoryAdd(config);
  }

  Future<T?> _popHistory<T>(T result) async {
    if (!_canPopHistory()) return null;
    return await _doPopHistory(result);
  }

  Future<T?> _doPopHistory<T>(T result) async {
    return _unsafeHistoryRemoveAt<T>(_activePages.length - 1, result);
  }

  Future<T?> _popPage<T>(T result) async {
    if (!_canPopPage()) return null;
    return await _doPopPage(result);
  }

  // returns the popped page
  Future<T?> _doPopPage<T>(T result) async {
    final currentBranch = currentConfiguration?.currentTreeBranch;

    // If we don't have a current branch or it only has one item, just pop history
    if (currentBranch == null || currentBranch.length <= 1) {
      return await _popHistory(result);
    }

    // We have a branch with multiple items, so we need to handle partial popping
    final remaining = currentBranch.take(currentBranch.length - 1);
    final prevHistoryEntry = switch (_activePages.length) {
      > 1 => _activePages[_activePages.length - 2],
      _ => null,
    };

    // Check if current route is the same as the previous route
    if (prevHistoryEntry != null) {
      final newLocation = remaining.last.name;
      final prevLocation = prevHistoryEntry.pageSettings?.name;

      if (newLocation == prevLocation) {
        return await _popHistory(result);
      }
    }

    // Create a new route with the remaining tree branch
    final res = await _popHistory<T>(result);
    await _pushHistory(
      RouteDecoder(
        remaining.toList(),
        null,
      ),
    );
    return res;
  }

  Future<T?> _pop<T>(PopMode mode, T result) => switch (mode) {
        PopMode.history => _popHistory<T>(result),
        PopMode.page => _popPage<T>(result),
      };

  Future<T?> popHistory<T>(T result) async {
    return await _popHistory<T>(result);
  }

  bool _canPopHistory() {
    return _activePages.length > 1;
  }

  Future<bool> canPopHistory() {
    return SynchronousFuture(_canPopHistory());
  }

  bool _canPopPage() {
    final currentTreeBranch = currentConfiguration?.currentTreeBranch;
    if (currentTreeBranch == null) return false;
    return currentTreeBranch.length > 1 ? true : _canPopHistory();
  }

  Future<bool> canPopPage() {
    return SynchronousFuture(_canPopPage());
  }

  bool _canPop(PopMode mode) => switch (mode) {
        PopMode.history => _canPopHistory(),
        PopMode.page || _ => _canPopPage(),
      };

  /// gets the visual pages from the current _activePages entry
  ///
  /// visual pages must have [GetPage.participatesInRootNavigator] set to true
  Iterable<GetPage> getVisualPages(RouteDecoder? currentHistory) {
    final res = currentHistory!.currentTreeBranch
        .where((r) => r.participatesInRootNavigator != null);
    if (res.isEmpty) {
      //default behavior, all routes participate in root navigator
      return _activePages.map((e) => e.route!);
    } else {
      //user specified at least one participatesInRootNavigator
      return res
          .where((element) => element.participatesInRootNavigator == true);
    }
  }

  @override
  Widget build(BuildContext context) {
    final currentHistory = currentConfiguration;
    final pages = currentHistory == null
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
    if (clearPages) _activePages.clear();

    final pageSettings = _buildPageSettings(notFoundRoute.name);
    final routeDecoder = _getRouteDecoder(pageSettings);

    _push(routeDecoder!);
  }

  @protected
  void _popWithResult<T>([T? result]) {
    final completer = _activePages.removeLast().route?.completer;
    if (completer?.isCompleted == false) completer!.complete(result);
  }

  @override
  Future<T?> toNamed<T>(
    String page, {
    dynamic arguments,
    dynamic id,
    bool preventDuplicates = true,
    Map<String, String>? parameters,
  }) async {
    final args = _buildPageSettings(page, arguments);
    final route = _getRouteDecoder<T>(args);
    if (route != null) {
      return _push<T>(route);
    } else {
      goToUnknownPage();
    }
    return null;
  }

  @override
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
    bool rebuildStack = true,
    PreventDuplicateHandlingMode preventDuplicateHandlingMode =
        PreventDuplicateHandlingMode.reorderRoutes,
  }) async {
    routeName ??= _cleanRouteName("/${page.runtimeType}");

    final getPage = GetPage<T>(
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
    final args = _buildPageSettings(routeName, arguments);
    final route = _getRouteDecoder<T>(args);
    final result = await _push<T>(
      route!,
      rebuildStack: rebuildStack,
    );
    _routeTree.removeRoute(getPage);
    return result;
  }

  @override
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
  }) async {
    routeName ??= _cleanRouteName("/${page.runtimeType}");
    final route = GetPage<T>(
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

    final args = _buildPageSettings(routeName, arguments);
    return _replace(args, route);
  }

  @override
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
  }) async {
    routeName ??= _cleanRouteName("/${page.runtimeType}");
    final route = GetPage<T>(
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

    final args = _buildPageSettings(routeName, arguments);

    final newPredicate = predicate ?? (route) => false;

    while (_activePages.length > 1 && !newPredicate(_activePages.last.route!)) {
      _popWithResult();
    }

    return _replace(args, route);
  }

  @override
  Future<T?>? offAllNamed<T>(
    String newRouteName, {
    dynamic arguments,
    String? id,
    Map<String, String>? parameters,
  }) async {
    final args = _buildPageSettings(newRouteName, arguments);
    final route = _getRouteDecoder<T>(args);
    if (route == null) return null;

    while (_activePages.length > 1) {
      _activePages.removeLast();
    }

    return _replaceNamed(route);
  }

  @override
  Future<T?>? offNamedUntil<T>(
    String page, {
    bool Function(GetPage route)? predicate,
    dynamic arguments,
    String? id,
    Map<String, String>? parameters,
  }) async {
    final args = _buildPageSettings(page, arguments);
    final route = _getRouteDecoder<T>(args);
    if (route == null) return null;

    final newPredicate = predicate ?? (route) => false;

    while (_activePages.length > 1 && !newPredicate(_activePages.last.route!)) {
      _activePages.removeLast();
    }

    return _push(route);
  }

  @override
  Future<T?> offNamed<T>(
    String page, {
    dynamic arguments,
    String? id,
    Map<String, String>? parameters,
  }) async {
    final args = _buildPageSettings(page, arguments);
    final route = _getRouteDecoder<T>(args);
    if (route == null) return null;
    _popWithResult();
    return _push<T>(route);
  }

  @override
  Future<T?> toNamedAndOffUntil<T>(
    String page,
    bool Function(GetPage) predicate, [
    Object? data,
  ]) async {
    final arguments = _buildPageSettings(page, data);

    final route = _getRouteDecoder<T>(arguments);

    if (route == null) return null;

    while (_activePages.isNotEmpty && !predicate(_activePages.last.route!)) {
      _popWithResult();
    }

    return _push<T>(route);
  }

  @override
  Future<T?> offUntil<T>(
    Widget Function() page,
    bool Function(GetPage) predicate, [
    Object? arguments,
  ]) async {
    while (_activePages.isNotEmpty && !predicate(_activePages.last.route!)) {
      _popWithResult();
    }

    return to<T>(page, arguments: arguments);
  }

  @override
  void removeRoute<T>(String name) {
    _activePages.remove(RouteDecoder.fromRoute(name));
  }

  bool get canBack {
    return _activePages.length > 1;
  }

  void _checkIfCanBack() {
    assert(() {
      if (!canBack) {
        final last = _activePages.last;
        final name = last.route?.name;
        throw 'The page $name cannot be popped';
      }
      return true;
    }());
  }

  @override
  Future<R?> backAndtoNamed<T, R>(String page,
      {T? result, Object? arguments}) async {
    final args = _buildPageSettings(page, arguments);
    final route = _getRouteDecoder<R>(args);
    if (route == null) return null;
    _popWithResult<T>(result);
    return _push<R>(route);
  }

  /// Removes routes according to [PopMode]
  /// until it reaches the specific [fullRoute],
  /// DOES NOT remove the [fullRoute]
  @override
  Future<void> popModeUntil(
    String fullRoute, {
    PopMode popMode = PopMode.history,
  }) async {
    // Remove history or page entries until we reach the target route
    var iterator = currentConfiguration;

    // Keep popping until we can't pop anymore or we find the target route
    while (iterator != null && _canPop(popMode)) {
      // Check if we've reached the target route
      // Note: This check is outside the while condition to avoid WASM compile errors
      // See: https://github.com/flutter/flutter/issues/140110
      if (iterator.pageSettings?.name == fullRoute) {
        break;
      }

      // Pop one level and update our iterator to the new configuration
      await _pop(popMode, null);
      iterator = currentConfiguration;
    }

    // Notify listeners about the navigation changes
    notifyListeners();
  }

  @override
  void backUntil(bool Function(GetPage) predicate) {
    while (_activePages.length > 1 && !predicate(_activePages.last.route!)) {
      _popWithResult();
    }

    notifyListeners();
  }

  Future<T?> _replace<T>(PageSettings arguments, GetPage<T> page) async {
    final index = _activePages.length > 1 ? _activePages.length - 1 : 0;
    _routeTree.addRoute(page);

    final activePage = _getRouteDecoder(arguments);

    _activePages[index] = activePage!;

    notifyListeners();
    final result = await activePage.route?.completer?.future as Future<T?>?;
    _routeTree.removeRoute(page);

    return result;
  }

  Future<T?> _replaceNamed<T>(RouteDecoder activePage) async {
    final index = _activePages.length > 1 ? _activePages.length - 1 : 0;
    // final activePage = _configureRouterDecoder<T>(page, arguments);
    _activePages[index] = activePage;

    notifyListeners();
    final result = await activePage.route?.completer?.future as Future<T?>?;
    return result;
  }

  /// Takes a route [name] String generated by [to], [off], [offAll]
  /// (and similar context navigation methods), cleans the extra chars and
  /// accommodates the format.
  /// `() => MyHomeScreenView` becomes `/my-home-screen-view`.
  String _cleanRouteName(String name) {
    name = name.replaceAll('() => ', '');

    /// uncomment for URL styling.
    // name = name.paramCase!;
    if (!name.startsWith('/')) {
      name = '/$name';
    }
    return Uri.tryParse(name)?.toString() ?? name;
  }

  PageSettings _buildPageSettings(String page, [Object? data]) {
    var uri = Uri.parse(page);
    return PageSettings(uri, data);
  }

  @protected
  RouteDecoder? _getRouteDecoder<T>(PageSettings arguments) {
    var page = arguments.uri.path;
    final parameters = arguments.params;
    if (parameters.isNotEmpty) {
      final uri = Uri(path: page, queryParameters: parameters);
      page = uri.toString();
    }

    final decoder = _routeTree.matchRoute(page, arguments: arguments);
    final route = decoder.route;
    if (route == null) return null;

    return _configureRouterDecoder<T>(decoder, arguments);
  }

  /// Configures a RouteDecoder with the appropriate parameters and arguments
  ///
  /// This method prepares a route decoder for navigation by:
  /// 1. Setting up parameters from query or params
  /// 2. Adding query parameters to params
  /// 3. Updating the route with arguments, parameters and a key
  /// 4. Creating a completer if needed for async navigation
  @protected
  RouteDecoder _configureRouterDecoder<T>(
      RouteDecoder decoder, PageSettings arguments) {
    // Determine which parameters to use (query or params)
    final parameters = switch (arguments.params) {
      var p when p.isEmpty => arguments.query,
      var p => p,
    };

    // Add query parameters to params for complete parameter set
    arguments.params.addAll(arguments.query);

    // Add parameters to decoder if it doesn't have any
    if (decoder.parameters.isEmpty) {
      decoder.parameters.addAll(parameters);
    }

    // Update the route with the necessary configuration
    decoder.route = decoder.route?.copyWith(
      // Only create a completer if we're not on the first page
      completer: switch (_activePages) {
        var pages when pages.isEmpty => null,
        _ => Completer<T?>(),
      },
      arguments: arguments,
      parameters: parameters,
      key: ValueKey(arguments.name),
    );

    return decoder;
  }

  /// Pushes a new route to the navigation stack after running middleware
  ///
  /// This method handles:
  /// 1. Running middleware to potentially transform the route
  /// 2. Checking for and handling duplicate routes based on handling mode
  /// 3. Updating the active pages list
  /// 4. Notifying listeners of changes
  Future<T?> _push<T>(RouteDecoder decoder, {bool rebuildStack = true}) async {
    // Run middleware which may transform or cancel the navigation
    var res = await runMiddleware(decoder);
    if (res == null) return null;

    // Get the duplicate handling mode from the route or use default
    final preventDuplicateHandlingMode =
        res.route?.preventDuplicateHandlingMode ??
            PreventDuplicateHandlingMode.reorderRoutes;

    // Check if this route already exists in the stack
    final onStackPage = _activePages
        .firstWhereOrNull((element) => element.route?.key == res.route?.key);

    // Handle route based on whether it's a duplicate and the handling mode
    switch ((onStackPage, preventDuplicateHandlingMode)) {
      // No duplicate found - simply add the new page
      case (null, _):
        _activePages.add(res);

      // Duplicate found with doNothing mode - do nothing as the name suggests
      case (_, PreventDuplicateHandlingMode.doNothing):
        break;

      // Duplicate found with reorderRoutes or recreate mode
      // Both modes remove the existing page and add the new one
      case (var existingPage, PreventDuplicateHandlingMode.reorderRoutes) ||
            (var existingPage, PreventDuplicateHandlingMode.recreate):
        _activePages.remove(existingPage);
        _activePages.add(res);

      // Duplicate found with popUntilOriginalRoute mode
      case (
          var existingPage,
          PreventDuplicateHandlingMode.popUntilOriginalRoute
        ):
        // Pop until we reach the original route
        while (_activePages.last == existingPage) {
          _popWithResult();
        }
    }

    // Notify listeners if needed
    if (rebuildStack) {
      notifyListeners();
    }

    return decoder.route?.completer?.future as Future<T?>?;
  }

  @override
  Future<void> setNewRoutePath(RouteDecoder configuration) async {
    final page = configuration.route;
    if (page == null) {
      goToUnknownPage();
      return;
    } else {
      _push(configuration);
    }
  }

  @override
  RouteDecoder? get currentConfiguration {
    if (_activePages.isEmpty) return null;
    final route = _activePages.last;
    return route;
  }

  /// Handles popup routes like dialogs and bottom sheets
  ///
  /// Returns true if a popup was handled, false otherwise
  Future<bool> handlePopupRoutes({
    Object? result,
  }) async {
    // Get the current route at the top of the navigator
    Route? currentRoute;
    navigatorKey.currentState!.popUntil((route) {
      currentRoute = route;
      return true;
    });

    // Handle the route based on its type
    return switch (currentRoute) {
      // If it's a popup route (dialog, bottom sheet, etc.), try to pop it
      PopupRoute() => await navigatorKey.currentState!.maybePop(result),
      // For any other route type, return false
      _ => false,
    };
  }

  /// Handles back button/pop requests in the application
  ///
  /// This method follows this sequence:
  /// 1. First tries to handle any popup routes (dialogs, bottom sheets)
  /// 2. Then attempts to pop based on the specified mode
  /// 3. If neither succeeds, delegates to the system's default behavior
  @override
  Future<bool> popRoute({
    Object? result,
    PopMode? popMode,
  }) async {
    // First handle any popup routes (dialogs, bottom sheets, etc.)
    final wasPopup = await handlePopupRoutes(result: result);

    // Return early if a popup was handled
    if (wasPopup) return true;

    // Use the provided popMode or fall back to the default backButtonPopMode
    final mode = popMode ?? backButtonPopMode;

    // Handle pop based on whether we can pop with the current mode
    if (_canPop(mode)) {
      // We can pop something, so do it and notify listeners
      await _pop(mode, result);
      notifyListeners();
      return true;
    } else {
      // We can't pop anything, let the system handle it (may exit the app)
      return await super.popRoute();
    }
  }

  @override
  void back<T>([T? result]) {
    _checkIfCanBack();
    _popWithResult<T>(result);
    notifyListeners();
  }

  /// Handles visual route popping and returns whether the pop was successful
  ///
  /// This method:
  /// 1. Attempts to pop the route
  /// 2. If successful, updates the navigation state
  /// 3. Notifies listeners of the change
  bool _onPopVisualRoute(Route<dynamic> route, dynamic result) {
    // Try to pop the route and check if it was successful
    if (!route.didPop(result)) {
      return false;
    }

    // Route was successfully popped, update navigation state
    _popWithResult(result);

    // Notify listeners of the change
    notifyListeners();

    // Return success
    return true;
  }
}
