import "package:flutter/material.dart";

import 'package:refreshed/get_navigation/src/router_report.dart';

/// A custom [PopupRoute] used by Refreshed for displaying modal bottom sheet routes.
///
/// This route displays a modal bottom sheet with customizable properties such as
/// the builder for the content, theme, background color, elevation, shape, animation
/// duration, and more.
class GetModalBottomSheetRoute<T> extends PopupRoute<T> {
  /// Constructs a [GetModalBottomSheetRoute].
  GetModalBottomSheetRoute({
    this.builder,
    this.theme,
    this.barrierLabel,
    this.backgroundColor,
    this.isPersistent,
    this.elevation,
    this.shape,
    this.clipBehavior,
    this.modalBarrierColor,
    this.isDismissible = true,
    this.enableDrag = true,
    required this.isScrollControlled,
    super.settings,
    this.enterBottomSheetDuration = const Duration(milliseconds: 250),
    this.exitBottomSheetDuration = const Duration(milliseconds: 200),
    this.curve,
    this.removeTop = true,
    this.constraints,
  }) {
    RouterReportManager.instance.reportCurrentRoute(this);
  }

  /// A builder function that returns the widget tree for the modal bottom sheet.
  final WidgetBuilder? builder;

  /// The theme to use for the modal bottom sheet.
  final ThemeData? theme;

  /// The color of the background behind the modal bottom sheet.
  final Color? backgroundColor;

  /// Whether this route is persistent (remains in memory after it's been dismissed).
  final bool? isPersistent;

  /// Whether the modal bottom sheet can scroll to accommodate the keyboard.
  final bool isScrollControlled;

  /// The z-coordinate at which to place the modal bottom sheet.
  final double? elevation;

  /// The shape of the modal bottom sheet.
  final ShapeBorder? shape;

  /// The clipping behavior of the modal bottom sheet.
  final Clip? clipBehavior;

  /// The color of the modal barrier that's shown behind the modal bottom sheet.
  final Color? modalBarrierColor;

  /// Whether the modal bottom sheet can be dismissed by tapping outside of its contents.
  final bool isDismissible;

  /// Whether the modal bottom sheet can be dragged vertically.
  final bool enableDrag;

  /// The duration for the modal bottom sheet to animate when entering the screen.
  final Duration enterBottomSheetDuration;

  /// The duration for the modal bottom sheet to animate when exiting the screen.
  final Duration exitBottomSheetDuration;

  /// The curve to use for the modal bottom sheet's entrance and exit animations.
  final Curve? curve;

  /// Whether to remove the safe area from the top of the modal bottom sheet.
  final bool removeTop;

  /// A label for the modal barrier that's shown behind the modal bottom sheet.
  @override
  final String? barrierLabel;

  @override
  Duration get transitionDuration => const Duration(milliseconds: 700);

  @override
  bool get barrierDismissible => isDismissible;

  @override
  Color get barrierColor => modalBarrierColor ?? Colors.black54;

  AnimationController? _animationController;

  final BoxConstraints? constraints;

  @override
  void dispose() {
    RouterReportManager.instance.reportRouteDispose(this);
    super.dispose();
  }

  @override
  Animation<double> createAnimation() {
    if (curve != null) {
      return CurvedAnimation(curve: curve!, parent: _animationController!.view);
    }
    return _animationController!.view;
  }

  @override
  AnimationController createAnimationController() {
    assert(_animationController == null);
    _animationController =
        BottomSheet.createAnimationController(navigator!.overlay!);
    _animationController!.duration = enterBottomSheetDuration;
    _animationController!.reverseDuration = exitBottomSheetDuration;
    return _animationController!;
  }

  @override
  Widget buildPage(BuildContext context, Animation<double> animation,
      Animation<double> secondaryAnimation,) {
    final sheetTheme =
        theme?.bottomSheetTheme ?? Theme.of(context).bottomSheetTheme;
    // By definition, the bottom sheet is aligned to the bottom of the page
    // and isn't exposed to the top padding of the MediaQuery.
    Widget bottomSheet = MediaQuery.removePadding(
      context: context,
      removeTop: removeTop,
      child: Padding(
        padding:
            EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
        child: _GetModalBottomSheet<T>(
          route: this,
          backgroundColor: backgroundColor ??
              sheetTheme.modalBackgroundColor ??
              sheetTheme.backgroundColor,
          elevation:
              elevation ?? sheetTheme.modalElevation ?? sheetTheme.elevation,
          shape: shape,
          clipBehavior: clipBehavior,
          isScrollControlled: isScrollControlled,
          enableDrag: enableDrag,
          constraints: constraints,
        ),
      ),
    );
    if (theme != null) bottomSheet = Theme(data: theme!, child: bottomSheet);
    return bottomSheet;
  }
}

class _GetModalBottomSheet<T> extends StatefulWidget {
  const _GetModalBottomSheet({
    super.key,
    this.route,
    this.backgroundColor,
    this.elevation,
    this.shape,
    this.clipBehavior,
    this.isScrollControlled = false,
    this.enableDrag = true,
    this.isPersistent = false,
    this.constraints,
  });
  final bool isPersistent;
  final GetModalBottomSheetRoute<T>? route;
  final bool isScrollControlled;
  final Color? backgroundColor;
  final double? elevation;
  final ShapeBorder? shape;
  final Clip? clipBehavior;
  final bool enableDrag;
  final BoxConstraints? constraints;

  @override
  _GetModalBottomSheetState<T> createState() => _GetModalBottomSheetState<T>();
}

class _GetModalBottomSheetState<T> extends State<_GetModalBottomSheet<T>> {
  String _getRouteLabel(MaterialLocalizations localizations) {
    if ((Theme.of(context).platform == TargetPlatform.android) ||
        (Theme.of(context).platform == TargetPlatform.fuchsia)) {
      return localizations.dialogLabel;
    } else {
      return "";
    }
  }

  @override
  Widget build(BuildContext context) {
    assert(debugCheckHasMediaQuery(context));
    assert(debugCheckHasMaterialLocalizations(context));
    final mediaQuery = MediaQuery.of(context);
    final localizations = MaterialLocalizations.of(context);
    final routeLabel = _getRouteLabel(localizations);

    return AnimatedBuilder(
      animation: widget.route!.animation!,
      builder: (context, child) {
        // Disable the initial animation when accessible navigation is on so
        // that the semantics are added to the tree at the correct time.
        final animationValue = mediaQuery.accessibleNavigation
            ? 1.0
            : widget.route!.animation!.value;
        return Semantics(
          scopesRoute: true,
          namesRoute: true,
          label: routeLabel,
          explicitChildNodes: true,
          child: ClipRect(
            child: CustomSingleChildLayout(
              delegate: _GetModalBottomSheetLayout(
                  animationValue, widget.isScrollControlled,),
              child: widget.isPersistent == false
                  ? BottomSheet(
                      animationController: widget.route!._animationController,
                      onClosing: () {
                        if (widget.route!.isCurrent) {
                          Navigator.pop(context);
                        }
                      },
                      builder: widget.route!.builder!,
                      backgroundColor: widget.backgroundColor,
                      elevation: widget.elevation,
                      shape: widget.shape,
                      clipBehavior: widget.clipBehavior,
                      enableDrag: widget.enableDrag,
                      constraints: widget.constraints,
                    )
                  : Scaffold(
                      bottomSheet: BottomSheet(
                        animationController: widget.route!._animationController,
                        onClosing: () {
                          // if (widget.route.isCurrent) {
                          //   Navigator.pop(context);
                          // }
                        },
                        builder: widget.route!.builder!,
                        backgroundColor: widget.backgroundColor,
                        elevation: widget.elevation,
                        shape: widget.shape,
                        clipBehavior: widget.clipBehavior,
                        enableDrag: widget.enableDrag,
                        constraints: widget.constraints,
                      ),
                    ),
            ),
          ),
        );
      },
    );
  }
}

class _GetPerModalBottomSheet<T> extends StatefulWidget {
  const _GetPerModalBottomSheet({
    super.key,
    this.route,
    this.isPersistent,
    this.backgroundColor,
    this.elevation,
    this.shape,
    this.clipBehavior,
    this.isScrollControlled = false,
    this.enableDrag = true,
    this.constraints,
  });
  final bool? isPersistent;
  final GetModalBottomSheetRoute<T>? route;
  final bool isScrollControlled;
  final Color? backgroundColor;
  final double? elevation;
  final ShapeBorder? shape;
  final Clip? clipBehavior;
  final bool enableDrag;
  final BoxConstraints? constraints;

  @override
  _GetPerModalBottomSheetState<T> createState() =>
      _GetPerModalBottomSheetState<T>();
}

class _GetPerModalBottomSheetState<T>
    extends State<_GetPerModalBottomSheet<T>> {
  String _getRouteLabel(MaterialLocalizations localizations) {
    if ((Theme.of(context).platform == TargetPlatform.android) ||
        (Theme.of(context).platform == TargetPlatform.fuchsia)) {
      return localizations.dialogLabel;
    } else {
      return "";
    }
  }

  @override
  Widget build(BuildContext context) {
    assert(debugCheckHasMediaQuery(context));
    assert(debugCheckHasMaterialLocalizations(context));
    final mediaQuery = MediaQuery.of(context);
    final localizations = MaterialLocalizations.of(context);
    final routeLabel = _getRouteLabel(localizations);

    return AnimatedBuilder(
      animation: widget.route!.animation!,
      builder: (context, child) {
        // Disable the initial animation when accessible navigation is on so
        // that the semantics are added to the tree at the correct time.
        final animationValue = mediaQuery.accessibleNavigation
            ? 1.0
            : widget.route!.animation!.value;
        return Semantics(
          scopesRoute: true,
          namesRoute: true,
          label: routeLabel,
          explicitChildNodes: true,
          child: ClipRect(
            child: CustomSingleChildLayout(
              delegate: _GetModalBottomSheetLayout(
                  animationValue, widget.isScrollControlled,),
              child: widget.isPersistent == false
                  ? BottomSheet(
                      animationController: widget.route!._animationController,
                      onClosing: () {
                        if (widget.route!.isCurrent) {
                          Navigator.pop(context);
                        }
                      },
                      builder: widget.route!.builder!,
                      backgroundColor: widget.backgroundColor,
                      elevation: widget.elevation,
                      shape: widget.shape,
                      clipBehavior: widget.clipBehavior,
                      enableDrag: widget.enableDrag,
                      constraints: widget.constraints,
                    )
                  : Scaffold(
                      bottomSheet: BottomSheet(
                        animationController: widget.route!._animationController,
                        onClosing: () {
                          // if (widget.route.isCurrent) {
                          //   Navigator.pop(context);
                          // }
                        },
                        builder: widget.route!.builder!,
                        backgroundColor: widget.backgroundColor,
                        elevation: widget.elevation,
                        shape: widget.shape,
                        clipBehavior: widget.clipBehavior,
                        enableDrag: widget.enableDrag,
                        constraints: widget.constraints,
                      ),
                    ),
            ),
          ),
        );
      },
    );
  }
}

class _GetModalBottomSheetLayout extends SingleChildLayoutDelegate {
  _GetModalBottomSheetLayout(this.progress, this.isScrollControlled);

  final double progress;
  final bool isScrollControlled;

  @override
  BoxConstraints getConstraintsForChild(BoxConstraints constraints) {
    return BoxConstraints(
      minWidth: constraints.maxWidth,
      maxWidth: constraints.maxWidth,
      minHeight: 0.0,
      maxHeight: isScrollControlled
          ? constraints.maxHeight
          : constraints.maxHeight * 9.0 / 16.0,
    );
  }

  @override
  Offset getPositionForChild(Size size, Size childSize) {
    return Offset(0.0, size.height - childSize.height * progress);
  }

  @override
  bool shouldRelayout(_GetModalBottomSheetLayout oldDelegate) {
    return progress != oldDelegate.progress;
  }
}
