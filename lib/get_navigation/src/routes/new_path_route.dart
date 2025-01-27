import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:refreshed/get_navigation/get_navigation.dart';

/// Manages the route matching and navigation tree.
class RouteMatcher {
  final RouteNode _root = RouteNode("/", "/");

  /// Adds a route to the tree.
  RouteNode addRoute(String path) {
    final segments = _parsePath(path);
    var currentNode = _root;

    for (final segment in segments) {
      currentNode = currentNode.findOrAddChild(segment, path);
    }
    return currentNode;
  }

  /// Removes a route from the tree.
  void removeRoute(String path) {
    final segments = _parsePath(path);
    var currentNode = _root;

    // Traverse the tree to find the node to delete
    for (final segment in segments) {
      final child = currentNode.findChild(segment);
      if (child == null) return; // Node not found, nothing to delete
      currentNode = child;
    }

    // Remove the node if it exists
    currentNode.parent?.removeChild(currentNode);
  }

  /// Matches a route and returns the result.
  MatchResult? matchRoute(String path) {
    final uri = Uri.parse(path);
    final segments = _parsePath(uri.path);
    var currentNode = _root;
    final parameters = <String, String>{};

    for (final segment in segments) {
      final child = currentNode.findMatchingChild(segment);
      if (child == null) return null;

      if (child.isParameter) {
        parameters[child.path.substring(1)] = segment;
      }
      currentNode = child;
    }

    return MatchResult(
      currentNode,
      parameters,
      path,
      urlParameters: uri.queryParameters,
    );
  }

  /// Splits a path into its segments.
  List<String> _parsePath(String path) {
    return path.split("/").where((segment) => segment.isNotEmpty).toList();
  }
}

/// Represents the result of a route match.
class MatchResult {
  MatchResult(
    this.node,
    this.parameters,
    this.currentPath, {
    this.urlParameters = const {},
  });

  final RouteNode node;
  final String currentPath;
  final Map<String, String> parameters;
  final Map<String, String> urlParameters;

  @override
  String toString() =>
      "MatchResult(node: $node, currentPath: $currentPath, parameters: $parameters, urlParameters: $urlParameters)";
}

/// Represents a node in the routing tree.
class RouteNode {
  RouteNode(this.path, this.originalPath, {this.parent});

  final String path;
  final String originalPath;
  RouteNode? parent;
  final List<RouteNode> children = [];

  /// Checks if the node represents a parameter (e.g., ":id").
  bool get isParameter => path.startsWith(":");

  /// Gets the full path of the node.
  String get fullPath {
    if (parent == null) return "/";
    final parentPath = parent!.fullPath == "/" ? "" : parent!.fullPath;
    return "$parentPath/$path";
  }

  /// Finds a child node by name or creates a new one.
  RouteNode findOrAddChild(String name, String fullPath) {
    return findChild(name) ?? _addChild(RouteNode(name, fullPath));
  }

  /// Finds a child node by name.
  RouteNode? findChild(String name) {
    return children.firstWhereOrNull((node) => node.path == name);
  }

  /// Finds a matching child node.
  RouteNode? findMatchingChild(String name) {
    return children.firstWhereOrNull((node) => node.matches(name));
  }

  /// Adds a child node.
  RouteNode _addChild(RouteNode child) {
    children.add(child);
    child.parent = this;
    return child;
  }

  /// Removes a child node.
  void removeChild(RouteNode child) {
    children.remove(child);
  }

  /// Checks if the node matches a given name.
  bool matches(String name) {
    return name == path || path == "*" || isParameter;
  }

  @override
  String toString() =>
      "RouteNode(path: $path, children: $children, fullPath: $fullPath)";
}

/// Manages the routing tree and handles route operations.
class RouteTree {
  static final instance = RouteTree();

  final Map<String, GetPage> tree = {};
  final RouteMatcher matcher = RouteMatcher();

  /// Adds a single route to the tree.
  void addRoute(GetPage route) {
    matcher.addRoute(route.name);
    tree[route.name] = route;
    _handleChildren(route);
  }

  /// Adds multiple routes to the tree.
  void addRoutes(List<GetPage> routes) {
    for (final route in routes) {
      addRoute(route);
    }
  }

  /// Handles child routes recursively.
  void _handleChildren(GetPage route) {
    for (var child in route.children) {
      final mergedRoute = child.copyWith(
        name: route.inheritParentPath
            ? "${route.name}/${child.name}".replaceAll("//", "/")
            : child.name,
        middlewares: [...route.middlewares, ...child.middlewares],
        bindings: [...route.bindings, ...child.bindings],
      );
      addRoute(mergedRoute);
    }
  }

  /// Removes a single route from the tree.
  void removeRoute(GetPage route) {
    matcher.removeRoute(route.name);
    tree.remove(route.name);
  }

  /// Removes multiple routes from the tree.
  void removeRoutes(List<GetPage> routes) {
    for (final route in routes) {
      removeRoute(route);
    }
  }

  /// Matches a route by its path.
  RouteTreeResult? matchRoute(String path) {
    final matchResult = matcher.matchRoute(path);
    if (matchResult != null) {
      final route = tree[matchResult.node.originalPath];
      return RouteTreeResult(route: route, matchResult: matchResult);
    }
    return null;
  }
}

/// Represents the result of a route tree match.
class RouteTreeResult {
  RouteTreeResult({
    required this.route,
    required this.matchResult,
  });

  final GetPage? route;
  final MatchResult matchResult;

  /// Configures the route with additional arguments.
  RouteTreeResult configure(String page, Object? arguments) {
    return copyWith(
      route: route?.copyWith(
        key: ValueKey(page),
        settings: RouteSettings(name: page, arguments: arguments),
        completer: Completer(),
        arguments: arguments,
      ),
    );
  }

  /// Creates a copy of the result with updated properties.
  RouteTreeResult copyWith({
    GetPage? route,
    MatchResult? matchResult,
  }) {
    return RouteTreeResult(
      route: route ?? this.route,
      matchResult: matchResult ?? this.matchResult,
    );
  }

  @override
  String toString() {
    return "RouteTreeResult(route: $route, matchResult: $matchResult)";
  }
}
