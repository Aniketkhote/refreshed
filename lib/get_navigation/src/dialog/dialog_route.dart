import "package:flutter/widgets.dart";
import "package:refreshed/get_navigation/src/router_report.dart";

/// A custom [PopupRoute] used by GetX for displaying dialog routes.
///
/// This route provides a customizable dialog transition and allows the
/// specification of various properties such as barrier color, duration,
/// and dismissibility.
class GetDialogRoute<T> extends PopupRoute<T> {
  /// Constructs a [GetDialogRoute].
  GetDialogRoute({
    required RoutePageBuilder pageBuilder,
    bool barrierDismissible = true,
    String? barrierLabel,
    Color barrierColor = const Color(0x80000000),
    Duration transitionDuration = const Duration(milliseconds: 200),
    RouteTransitionsBuilder? transitionBuilder,
    super.settings,
  })  : widget = pageBuilder,
        _barrierDismissible = barrierDismissible,
        _barrierLabel = barrierLabel,
        _barrierColor = barrierColor,
        _transitionDuration = transitionDuration,
        _transitionBuilder = transitionBuilder {
    RouterReportManager.instance.reportCurrentRoute(this);
  }

  /// The widget builder for the dialog content.
  final RoutePageBuilder widget;

  @override
  bool get barrierDismissible => _barrierDismissible;
  final bool _barrierDismissible;

  @override
  void dispose() {
    RouterReportManager.instance.reportRouteDispose(this);
    super.dispose();
  }

  @override
  String? get barrierLabel => _barrierLabel;
  final String? _barrierLabel;

  @override
  Color get barrierColor => _barrierColor;
  final Color _barrierColor;

  @override
  Duration get transitionDuration => _transitionDuration;
  final Duration _transitionDuration;

  /// The custom transition builder for the dialog.
  final RouteTransitionsBuilder? _transitionBuilder;

  @override
  Widget buildPage(
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
  ) =>
      Semantics(
        scopesRoute: true,
        explicitChildNodes: true,
        child: widget(context, animation, secondaryAnimation),
      );

  @override
  Widget buildTransitions(
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) {
    if (_transitionBuilder == null) {
      return FadeTransition(
        opacity: CurvedAnimation(
          parent: animation,
          curve: Curves.linear,
        ),
        child: child,
      );
    }
    return _transitionBuilder(context, animation, secondaryAnimation, child);
  }
}
