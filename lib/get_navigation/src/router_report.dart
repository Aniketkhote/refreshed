import "dart:collection";

import "package:refreshed/refreshed.dart";

/// Manages the routing and memory management for instances associated with routes in Refreshed.
///
/// This class handles the tracking and disposal of instances linked to specific routes
/// in a Refreshed application. It is particularly useful when managing the lifecycle
/// of instances created with `Get.create()` and associated with specific routes.
///
/// Instances of this class can be accessed via the static [instance] getter.
/// It provides methods to report route changes, link dependencies to routes,
/// and dispose of instances when routes are removed from memory.
class RouterReportManager<T> {
  RouterReportManager._();

  /// Holds a reference to the routes and their associated dependencies.
  final Map<T?, List<String>> _routesKey = <T?, List<String>>{};

  /// Stores references to onClose() functions of instances created with `Get.create()`.
  final Map<T?, HashSet<Function>> _routesByCreate = <T?, HashSet<Function>>{};

  static RouterReportManager? _instance;

  /// Retrieves the singleton instance of [RouterReportManager].
  static RouterReportManager get instance =>
      _instance ??= RouterReportManager._();

  /// Disposes of the singleton instance of [RouterReportManager].
  static void dispose() {
    _instance = null;
  }

  /// Prints the current instance stack for debugging purposes.
  void printInstanceStack() {
    Get.log(_routesKey.toString());
  }

  T? _current;

  void reportCurrentRoute(T newRoute) {
    _current = newRoute;
  }

  /// Links a dependency to the current route.
  ///
  /// Requires the usage of `GetMaterialApp`.
  void reportDependencyLinkedToRoute(String dependencyKey) {
    if (_current == null) {
      return;
    }
    if (_routesKey.containsKey(_current)) {
      _routesKey[_current!]!.add(dependencyKey);
    } else {
      _routesKey[_current] = <String>[dependencyKey];
    }
  }

  /// Clears all route keys and dependencies from memory.
  void clearRouteKeys() {
    _routesKey.clear();
    _routesByCreate.clear();
  }

  /// Appends a route by its created instance.
  ///
  /// This method is used internally for managing lifecycle of instances
  /// created with `Get.create()`.
  void appendRouteByCreate(GetLifeCycleMixin i) {
    _routesByCreate[_current] ??= HashSet<Function>();
    _routesByCreate[_current]!.add(i.onDelete);
  }

  /// Reports the disposal of a route.
  ///
  /// This method is called when a route is disposed, and it cleans up
  /// associated instances and dependencies.
  void reportRouteDispose(T disposed) {
    if (Get.smartManagement != SmartManagement.onlyBuilder) {
      _removeDependencyByRoute(disposed);
    }
  }

  /// Reports the impending disposal of a route.
  ///
  /// This method is called just before a route is disposed, and it ensures
  /// that instances and dependencies are properly handled before the route
  /// is removed from memory.
  void reportRouteWillDispose(T disposed) {
    final List<String> keysToRemove = <String>[];

    _routesKey[disposed]?.forEach(keysToRemove.add);

    if (_routesByCreate.containsKey(disposed)) {
      for (final Function onClose in _routesByCreate[disposed]!) {
        onClose();
      }
      _routesByCreate[disposed]!.clear();
      _routesByCreate.remove(disposed);
    }

    for (final String element in keysToRemove) {
      Get.markAsDirty(key: element);
    }

    keysToRemove.clear();
  }

  /// Removes dependencies associated with a route.
  ///
  /// This method is used internally to clear instances and dependencies
  /// associated with a route that is being removed from memory.
  void _removeDependencyByRoute(T routeName) {
    final List<String> keysToRemove = <String>[];

    _routesKey[routeName]?.forEach(keysToRemove.add);

    if (_routesByCreate.containsKey(routeName)) {
      for (final Function onClose in _routesByCreate[routeName]!) {
        onClose();
      }
      _routesByCreate[routeName]!.clear();
      _routesByCreate.remove(routeName);
    }

    for (final String element in keysToRemove) {
      final bool value = Get.delete(key: element);
      if (value) {
        _routesKey[routeName]?.remove(element);
      }
    }

    _routesKey.remove(routeName);

    keysToRemove.clear();
  }
}
