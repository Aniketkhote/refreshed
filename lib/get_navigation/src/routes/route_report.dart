import "package:flutter/material.dart";

import 'package:refreshed/get_navigation/src/router_report.dart';
import 'package:refreshed/get_navigation/src/routes/default_route.dart';

/// A StatefulWidget that reports its route lifecycle events to a [RouterReportManager].
///
/// This widget is designed to be used within a routing system where you need
/// to track the lifecycle events of a route, such as when it is initialized
/// and disposed.
///
/// Example:
///
/// ```dart
/// RouteReport(
///   builder: (context) {
///     return SomeWidget();
///   },
/// )
/// ```
class RouteReport extends StatefulWidget {
  /// Constructs a RouteReport widget.
  ///
  /// The [builder] parameter is required and must not be null. It defines
  /// the widget tree for this route.
  const RouteReport({super.key, required this.builder});

  /// A callback that builds the widget tree for this route.
  final WidgetBuilder builder;

  @override
  RouteReportState createState() => RouteReportState();
}

/// The state for [RouteReport].
///
/// This state mixin adds lifecycle event reporting to the route.
/// It reports route initialization and disposal to a [RouterReportManager].
class RouteReportState extends State<RouteReport> with RouteReportMixin {
  @override
  void initState() {
    RouterReportManager.instance.reportCurrentRoute(this);
    super.initState();
  }

  @override
  void dispose() {
    RouterReportManager.instance.reportRouteDispose(this);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return widget.builder(context);
  }
}
