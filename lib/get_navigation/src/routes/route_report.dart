import 'package:flutter/material.dart';
import 'package:refreshed/get_navigation/src/router_report.dart';
import 'package:refreshed/get_navigation/src/routes/default_route.dart';

/// A widget that tracks and reports its route lifecycle events.
///
/// This widget is useful in navigation systems where tracking route
/// initialization and disposal events is required. It integrates with
/// [RouterReportManager] to report these events.
///
/// Example usage:
/// ```dart
/// RouteReport(
///   builder: (context) => SomeWidget(),
/// )
/// ```
class RouteReport extends StatefulWidget {
  /// Creates a [RouteReport] widget.
  ///
  /// The [builder] parameter is required and specifies the widget tree
  /// for this route.
  const RouteReport({
    super.key,
    required this.builder,
  });

  /// A function that returns the widget tree for this route.
  final WidgetBuilder builder;

  @override
  RouteReportState createState() => RouteReportState();
}

/// The state associated with [RouteReport].
///
/// This state reports route lifecycle events such as initialization and disposal
/// to the [RouterReportManager].
class RouteReportState extends State<RouteReport> with RouteReportMixin {
  @override
  void initState() {
    super.initState();
    RouterReportManager.instance.reportCurrentRoute(this);
  }

  @override
  void dispose() {
    RouterReportManager.instance.reportRouteDispose(this);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => widget.builder(context);
}
