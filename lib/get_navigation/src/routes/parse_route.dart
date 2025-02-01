import 'package:flutter/foundation.dart';

import '../../../refreshed.dart';

/// A class that decodes a route and provides information about the current
/// route tree branch and associated page settings.
@immutable
class RouteDecoder {
  const RouteDecoder(
    this.currentTreeBranch,
    this.pageSettings,
  );

  /// List of [GetPage] representing the current branch of the route tree.
  final List<GetPage> currentTreeBranch;

  /// The settings of the current page, including parameters and arguments.
  final PageSettings? pageSettings;

  /// Factory constructor to create a [RouteDecoder] from a given route [location].
  factory RouteDecoder.fromRoute(String location) {
    var uri = Uri.parse(location);
    final args = PageSettings(uri);
    final decoder =
        (Get.rootController.rootDelegate).matchRoute(location, arguments: args);

    decoder.route = decoder.route?.copyWith(
      completer: null,
      arguments: args,
      parameters: args.params,
    );
    return decoder;
  }

  /// Returns the last [GetPage] in the current tree branch, or `null` if empty.
  GetPage? get route =>
      currentTreeBranch.isNotEmpty ? currentTreeBranch.last : null;

  /// Returns the last [GetPage] or a default fallback [onUnknown].
  GetPage routeOrUnknown(GetPage onUnknown) => route ?? onUnknown;

  /// Retrieves the children of the current route, if any.
  List<GetPage>? get currentChildren => route?.children;

  /// Retrieves the parameters of the current page settings.
  Map<String, String> get parameters => pageSettings?.params ?? {};

  /// Sets the last [GetPage] in the current tree branch.
  set route(GetPage? getPage) {
    if (getPage == null) return;
    if (currentTreeBranch.isEmpty) {
      currentTreeBranch.add(getPage);
    } else {
      currentTreeBranch[currentTreeBranch.length - 1] = getPage;
    }
  }

  /// Retrieves the arguments passed to the current page.
  dynamic get args => pageSettings?.arguments;

  /// Retrieves arguments cast to a specific type [T], or `null` if type mismatch.
  T? arguments<T>() => args is T ? args as T : null;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is RouteDecoder &&
          listEquals(other.currentTreeBranch, currentTreeBranch) &&
          other.pageSettings == pageSettings);

  @override
  int get hashCode => Object.hash(currentTreeBranch, pageSettings);

  @override
  String toString() =>
      'RouteDecoder(branch: $currentTreeBranch, settings: $pageSettings)';
}

/// A class representing a parsed route tree that manages route matching
/// and manipulation for nested routing structures.
class ParseRouteTree {
  ParseRouteTree({required this.routes});

  /// List of all defined routes in the application.
  final List<GetPage> routes;

  /// Matches a given [name] to the appropriate route in the tree and returns a [RouteDecoder].
  RouteDecoder matchRoute(String name, {PageSettings? arguments}) {
    final uri = Uri.parse(name);
    final split = uri.path.split('/').where((element) => element.isNotEmpty);
    var curPath = '/';
    final cumulativePaths = <String>[];
    for (var item in split) {
      curPath = curPath.endsWith('/') ? curPath + item : '$curPath/$item';
      cumulativePaths.add(curPath);
    }

    if (cumulativePaths.isEmpty) {
      cumulativePaths.add('/');
    }

    final treeBranch = cumulativePaths
        .map((e) => MapEntry(e, _findRoute(e)))
        .where((element) => element.value != null)
        .map((e) => MapEntry(e.key, e.value!.copyWith(key: ValueKey(e.key))))
        .toList();

    final params = Map<String, String>.from(uri.queryParameters);
    if (treeBranch.isNotEmpty) {
      final lastRoute = treeBranch.last;
      final parsedParams = _parseParams(name, lastRoute.value.path);
      if (parsedParams.isNotEmpty) {
        params.addAll(parsedParams);
      }
      final mappedTreeBranch = treeBranch
          .map(
            (e) => e.value.copyWith(
              parameters: {
                if (e.value.parameters != null) ...e.value.parameters!,
                ...params,
              },
              name: e.key,
            ),
          )
          .toList();
      arguments?.params.clear();
      arguments?.params.addAll(params);
      return RouteDecoder(
        mappedTreeBranch,
        arguments,
      );
    }

    arguments?.params.clear();
    arguments?.params.addAll(params);

    return RouteDecoder(
      treeBranch.map((e) => e.value).toList(),
      arguments,
    );
  }

  /// Adds a list of routes to the route tree.
  void addRoutes<T>(List<GetPage<T>> getPages) {
    for (final route in getPages) {
      addRoute(route);
    }
  }

  /// Removes a list of routes from the route tree.
  void removeRoutes<T>(List<GetPage<T>> getPages) {
    for (final route in getPages) {
      removeRoute(route);
    }
  }

  /// Removes a specific route from the route tree.
  void removeRoute<T>(GetPage<T> route) {
    routes.remove(route);
    for (var page in _flattenPage(route)) {
      removeRoute(page);
    }
  }

  /// Adds a specific route to the route tree.
  void addRoute<T>(GetPage<T> route) {
    routes.add(route);
    for (var page in _flattenPage(route)) {
      addRoute(page);
    }
  }

  /// Flattens a route to include all its children recursively.
  List<GetPage> _flattenPage(GetPage route) {
    if (route.children.isEmpty) return [];
    final parentPath = route.name;

    return route.children.expand((page) {
      final updatedPage = _addChild(page, parentPath, route);
      return [updatedPage, ..._flattenPage(updatedPage)];
    }).toList();
  }

  /// Updates a [GetPage] with inherited properties.
  GetPage _addChild(GetPage origin, String parentPath, GetPage parent) {
    return origin.copyWith(
      middlewares: [...parent.middlewares, ...origin.middlewares],
      name: origin.inheritParentPath
          ? (parentPath + origin.name).replaceAll(r'//', '/')
          : origin.name,
      bindings: [...parent.bindings, ...origin.bindings],
      binds: [...parent.binds, ...origin.binds],
    );
  }

  /// Finds a route by its name in the route tree.
  GetPage? _findRoute(String name) =>
      routes.firstWhereOrNull((route) => route.path.regex.hasMatch(name));

  /// Parses parameters from the path based on the route's regex.
  Map<String, String> _parseParams(String path, PathDecoded routePath) {
    final params = <String, String>{};
    final uri = Uri.tryParse(path);
    if (uri == null) return params;

    final match = routePath.regex.firstMatch(uri.path);
    if (match != null) {
      for (var i = 0; i < routePath.keys.length; i++) {
        params[routePath.keys[i]!] = Uri.decodeQueryComponent(match[i + 1]!);
      }
    }
    return params;
  }
}

/// Extension on [List] to provide a `firstWhereOrNull` method.
extension FirstWhereOrNullExt<T> on List<T> {
  /// Returns the first element satisfying [test], or `null` if none are found.
  T? firstWhereOrNull(bool Function(T element) test) {
    for (var element in this) {
      if (test(element)) return element;
    }
    return null;
  }
}
