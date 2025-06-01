import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:refreshed/get_core/get_core.dart';
import 'package:refreshed/get_navigation/get_navigation.dart';
import 'package:refreshed/get_navigation/src/dialog/dialog_route.dart';
import 'package:refreshed/get_navigation/src/router_report.dart';
import 'package:refreshed/instance_manager.dart';

/// Extracts the name of a route based on its instance type or returns null if not possible.
String? _extractRouteName(Route? route) => switch (route) {
  null => null,
  _ when route.settings.name != null => route.settings.name,
  GetPageRoute() => route.routeName,
  GetDialogRoute() => "DIALOG ${route.hashCode}",
  GetModalBottomSheetRoute() => "BOTTOMSHEET ${route.hashCode}",
  _ => null,
};

/// A custom NavigatorObserver for tracking route changes and managing routing data.
class GetObserver extends NavigatorObserver {
  GetObserver([this.routing, this._routeSend]);

  final Function(Routing?)? routing;
  final Routing? _routeSend;

  @override
  void didPop(Route route, Route? previousRoute) {
    super.didPop(route, previousRoute);
    final currentRoute = _RouteData.ofRoute(route);
    final newRoute = _RouteData.ofRoute(previousRoute);

    // Log appropriate message based on route type
    switch (currentRoute) {
      case var r when r.isBottomSheet || r.isDialog:
        Get.log("CLOSE ${r.name}");
      case var r when r.isGetPageRoute:
        Get.log("CLOSE TO ROUTE ${r.name}");
      default:
        // No logging needed
        break;
    }

    // Report the current route if available
    if (previousRoute != null) {
      RouterReportManager.instance.reportCurrentRoute(previousRoute);
    }

    // Update routing information
    _routeSend?.update((value) {
      // Update current and previous route information
      switch (previousRoute) {
        case PageRoute():
          value.current = _extractRouteName(previousRoute) ?? "";
          value.previous = newRoute.name ?? "";
        case _ when value.previous.isNotEmpty:
          value.current = value.previous;
        default:
          // Keep current value
          break;
      }

      // Update other routing properties
      value.args = previousRoute?.settings.arguments;
      value.route = previousRoute;
      value.isBack = true;
      value.removed = "";
      value.isBottomSheet = newRoute.isBottomSheet;
      value.isDialog = newRoute.isDialog;
    });

    routing?.call(_routeSend);
  }

  @override
  void didPush(Route route, Route? previousRoute) {
    super.didPush(route, previousRoute);
    final newRoute = _RouteData.ofRoute(route);

    // Log appropriate message based on route type
    switch (newRoute) {
      case var r when r.isBottomSheet || r.isDialog:
        Get.log("OPEN ${r.name}");
      case var r when r.isGetPageRoute:
        Get.log("GOING TO ROUTE ${r.name}");
      default:
        // No logging needed
        break;
    }

    // Report the current route
    RouterReportManager.instance.reportCurrentRoute(route);

    // Update routing information
    _routeSend?.update((value) {
      // Update current route if it's a page route
      if (route is PageRoute) {
        value.current = newRoute.name ?? "";
      }

      // Set previous route name if available
      final previousRouteName = _extractRouteName(previousRoute);
      if (previousRouteName != null) {
        value.previous = previousRouteName;
      }

      // Update other routing properties
      value.args = route.settings.arguments;
      value.route = route;
      value.isBack = false;
      value.removed = "";
      value.isBottomSheet = newRoute.isBottomSheet;
      value.isDialog = newRoute.isDialog;
    });

    routing?.call(_routeSend);
  }

  @override
  void didRemove(Route route, Route? previousRoute) {
    super.didRemove(route, previousRoute);
    final routeName = _extractRouteName(route);
    final currentRoute = _RouteData.ofRoute(route);
    final previousRouteName = _extractRouteName(previousRoute);

    // Log route removal information
    Get.log("REMOVING ROUTE $routeName");
    Get.log("PREVIOUS ROUTE $previousRouteName");

    // Update routing information
    _routeSend?.update((value) {
      value.route = previousRoute;
      value.isBack = false;
      value.removed = routeName ?? "";
      value.previous = previousRouteName ?? '';
      
      // Reset bottom sheet and dialog flags if needed
      value.isBottomSheet = currentRoute.isBottomSheet ? false : value.isBottomSheet;
      value.isDialog = currentRoute.isDialog ? false : value.isDialog;
    });

    // Report route disposal for specific route types
    switch (route) {
      case GetPageRoute() || MaterialPageRoute() || CupertinoPageRoute():
        RouterReportManager.instance.reportRouteWillDispose(route);
      default:
        // No reporting needed
        break;
    }

    routing?.call(_routeSend);
  }

  @override
  void didReplace({Route? newRoute, Route? oldRoute}) {
    super.didReplace(newRoute: newRoute, oldRoute: oldRoute);
    final newName = _extractRouteName(newRoute);
    final oldName = _extractRouteName(oldRoute);
    final currentRoute = _RouteData.ofRoute(oldRoute);

    // Log route replacement information
    Get.log("REPLACE ROUTE $oldName");
    Get.log("NEW ROUTE $newName");

    // Report the new current route if available
    if (newRoute != null) {
      RouterReportManager.instance.reportCurrentRoute(newRoute);
    }

    // Update routing information
    _routeSend?.update((value) {
      // Update current route if it's a page route
      switch (newRoute) {
        case PageRoute():
          value.current = newName ?? "";
        default:
          // Keep current value
          break;
      }

      // Update other routing properties
      value.args = newRoute?.settings.arguments;
      value.route = newRoute;
      value.isBack = false;
      value.removed = "";
      value.previous = oldName ?? '';
      
      // Reset bottom sheet and dialog flags if needed
      value.isBottomSheet = currentRoute.isBottomSheet ? false : value.isBottomSheet;
      value.isDialog = currentRoute.isDialog ? false : value.isDialog;
    });

    // Report route disposal for specific route types
    if (oldRoute is GetPageRoute) {
      RouterReportManager.instance.reportRouteWillDispose(oldRoute);
    }

    routing?.call(_routeSend);
  }
}

/// Represents the current state of routing, including the current route,
/// previous route, arguments, and other relevant information.
class Routing {
  Routing({
    this.current = "",
    this.previous = "",
    this.args,
    this.removed = "",
    this.route,
    this.isBack,
    this.isBottomSheet,
    this.isDialog,
  });

  String current;
  String previous;
  dynamic args;
  String removed;
  Route<dynamic>? route;
  bool? isBack;
  bool? isBottomSheet;
  bool? isDialog;

  void update(void Function(Routing value) fn) {
    fn(this);
  }
}

/// Utility class for determining the type of a route.
class _RouteData {
  _RouteData({
    required this.name,
    required this.isGetPageRoute,
    required this.isBottomSheet,
    required this.isDialog,
  });

  factory _RouteData.ofRoute(Route? route) => switch (route) {
    null => _RouteData(
      name: null,
      isGetPageRoute: false,
      isDialog: false,
      isBottomSheet: false,
    ),
    _ => _RouteData(
      name: _extractRouteName(route),
      isGetPageRoute: route is GetPageRoute,
      isDialog: route is GetDialogRoute,
      isBottomSheet: route is GetModalBottomSheetRoute,
    ),
  };

  final bool isGetPageRoute;
  final bool isBottomSheet;
  final bool isDialog;
  final String? name;
}
