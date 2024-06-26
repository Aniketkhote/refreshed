import "package:flutter/cupertino.dart";
import "package:flutter/material.dart";
import "package:refreshed/get_core/get_core.dart";
import "package:refreshed/get_navigation/get_navigation.dart";
import "package:refreshed/get_navigation/src/dialog/dialog_route.dart";
import "package:refreshed/get_navigation/src/router_report.dart";
import "package:refreshed/instance_manager.dart";

/// Extracts the name of a route based on it's instance type
/// or null if not possible.
String? _extractRouteName(Route? route) {
  if (route?.settings.name != null) {
    return route!.settings.name;
  }

  if (route is GetPageRoute) {
    return route.routeName;
  }

  if (route is GetDialogRoute) {
    return "DIALOG ${route.hashCode}";
  }

  if (route is GetModalBottomSheetRoute) {
    return "BOTTOMSHEET ${route.hashCode}";
  }

  return null;
}

class GetObserver extends NavigatorObserver {
  GetObserver([this.routing, this._routeSend]);
  final Function(Routing?)? routing;

  final Routing? _routeSend;

  @override
  void didPop(Route route, Route? previousRoute) {
    super.didPop(route, previousRoute);
    final _RouteData currentRoute = _RouteData.ofRoute(route);
    final _RouteData newRoute = _RouteData.ofRoute(previousRoute);

    if (currentRoute.isBottomSheet || currentRoute.isDialog) {
      Get.log("CLOSE ${currentRoute.name}");
    } else if (currentRoute.isGetPageRoute) {
      Get.log("CLOSE TO ROUTE ${currentRoute.name}");
    }
    if (previousRoute != null) {
      RouterReportManager.instance.reportCurrentRoute(previousRoute);
    }

    // Here we use a 'inverse didPush set', meaning that we use
    // previous route instead of 'route' because this is
    // a 'inverse push'
    _routeSend?.update((Routing value) {
      // Only PageRoute is allowed to change current value
      if (previousRoute is PageRoute) {
        value.current = _extractRouteName(previousRoute) ?? "";
        value.previous = newRoute.name ?? "";
      } else if (value.previous.isNotEmpty) {
        value.current = value.previous;
      }

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
    final _RouteData newRoute = _RouteData.ofRoute(route);

    if (newRoute.isBottomSheet || newRoute.isDialog) {
      Get.log("OPEN ${newRoute.name}");
    } else if (newRoute.isGetPageRoute) {
      Get.log("GOING TO ROUTE ${newRoute.name}");
    }

    RouterReportManager.instance.reportCurrentRoute(route);
    _routeSend!.update((Routing value) {
      // Only PageRoute is allowed to change current value
      if (route is PageRoute) {
        value.current = newRoute.name ?? "";
      }
      final String? previousRouteName = _extractRouteName(previousRoute);
      if (previousRouteName != null) {
        value.previous = previousRouteName;
      }

      value.args = route.settings.arguments;
      value.route = route;
      value.isBack = false;
      value.removed = "";
      value.isBottomSheet =
          newRoute.isBottomSheet ? true : value.isBottomSheet ?? false;
      value.isDialog = newRoute.isDialog ? true : value.isDialog ?? false;
    });

    if (routing != null) {
      routing!(_routeSend);
    }
  }

  @override
  void didRemove(Route route, Route? previousRoute) {
    super.didRemove(route, previousRoute);
    final String? routeName = _extractRouteName(route);
    final _RouteData currentRoute = _RouteData.ofRoute(route);

    Get.log("REMOVING ROUTE $routeName");

    _routeSend?.update((Routing value) {
      value.route = previousRoute;
      value.isBack = false;
      value.removed = routeName ?? "";
      value.previous = routeName ?? "";
      value.isBottomSheet =
          currentRoute.isBottomSheet ? false : value.isBottomSheet;
      value.isDialog = currentRoute.isDialog ? false : value.isDialog;
    });

    if (route is GetPageRoute ||
        route is MaterialPageRoute ||
        route is CupertinoPageRoute) {
      RouterReportManager.instance.reportRouteWillDispose(route);
    }
    routing?.call(_routeSend);
  }

  @override
  void didReplace({Route? newRoute, Route? oldRoute}) {
    super.didReplace(newRoute: newRoute, oldRoute: oldRoute);
    final String? newName = _extractRouteName(newRoute);
    final String? oldName = _extractRouteName(oldRoute);
    final _RouteData currentRoute = _RouteData.ofRoute(oldRoute);

    Get.log("REPLACE ROUTE $oldName");
    Get.log("NEW ROUTE $newName");

    if (newRoute != null) {
      RouterReportManager.instance.reportCurrentRoute(newRoute);
    }

    _routeSend?.update((Routing value) {
      // Only PageRoute is allowed to change current value
      if (newRoute is PageRoute) {
        value.current = newName ?? "";
      }

      value.args = newRoute?.settings.arguments;
      value.route = newRoute;
      value.isBack = false;
      value.removed = "";
      value.previous = "$oldName";
      value.isBottomSheet =
          currentRoute.isBottomSheet ? false : value.isBottomSheet;
      value.isDialog = currentRoute.isDialog ? false : value.isDialog;
    });
    if (oldRoute is GetPageRoute) {
      RouterReportManager.instance.reportRouteWillDispose(oldRoute);
    }

    routing?.call(_routeSend);
  }
}

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

/// This is basically a util for rules about 'what a route is'
class _RouteData {
  _RouteData({
    required this.name,
    required this.isGetPageRoute,
    required this.isBottomSheet,
    required this.isDialog,
  });

  factory _RouteData.ofRoute(Route? route) => _RouteData(
        name: _extractRouteName(route),
        isGetPageRoute: route is GetPageRoute,
        isDialog: route is GetDialogRoute,
        isBottomSheet: route is GetModalBottomSheetRoute,
      );
  final bool isGetPageRoute;
  final bool isBottomSheet;
  final bool isDialog;
  final String? name;
}
