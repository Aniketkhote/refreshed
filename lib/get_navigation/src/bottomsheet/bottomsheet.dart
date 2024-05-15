import "package:flutter/material.dart";
import "package:refreshed/get_navigation/src/router_report.dart";

/// A custom [PopupRoute] used by Refreshed for displaying modal bottom sheet routes.
///
/// This route displays a modal bottom sheet with customizable properties such as
/// the builder for the content, theme, background color, elevation, shape, animation
/// duration, and more.
class GetModalBottomSheetRoute<T> extends PopupRoute<T> {
  /// Constructs a [GetModalBottomSheetRoute].
  GetModalBottomSheetRoute({
    required this.isScrollControlled,
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
    super.settings,
    this.enterBottomSheetDuration = const Duration(milliseconds: 250),
    this.exitBottomSheetDuration = const Duration(milliseconds: 200),
    this.curve,
    this.removeTop = true,
    this.constraints,
    this.showDragHandle = true,
    this.shadowColor,
    this.dragHandleColor,
    this.dragHandleSize,
    this.onDragStart,
    this.onDragEnd,
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

  /// Constraints for a box.
  final BoxConstraints? constraints;

  /// Determines whether to show a drag handle for the bottom sheet.
  final bool? showDragHandle;

  /// The color of the drag handle for the bottom sheet.
  final Color? dragHandleColor;

  /// The size of the drag handle for the bottom sheet.
  final Size? dragHandleSize;

  /// Callback function invoked when the user finishes dragging the bottom sheet.
  final BottomSheetDragEndHandler? onDragEnd;

  /// Callback function invoked when the user starts dragging the bottom sheet.
  final BottomSheetDragStartHandler? onDragStart;

  /// The color of the shadow displayed beneath the bottom sheet.
  final Color? shadowColor;

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
  Widget buildPage(
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
  ) {
    final BottomSheetThemeData sheetTheme =
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
          showDragHandle: showDragHandle,
          shadowColor: shadowColor,
          dragHandleColor: dragHandleColor ?? sheetTheme.dragHandleColor,
          dragHandleSize: dragHandleSize,
          onDragEnd: onDragEnd,
          onDragStart: onDragStart,
          isPersistent: isPersistent ?? false,
        ),
      ),
    );
    if (theme != null) {
      bottomSheet = Theme(data: theme!, child: bottomSheet);
    }
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
    this.showDragHandle = true,
    this.shadowColor,
    this.dragHandleColor,
    this.dragHandleSize,
    this.onDragStart,
    this.onDragEnd,
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
  final bool? showDragHandle;
  final Color? dragHandleColor;
  final Size? dragHandleSize;
  final BottomSheetDragEndHandler? onDragEnd;
  final BottomSheetDragStartHandler? onDragStart;
  final Color? shadowColor;

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
    final MediaQueryData mediaQuery = MediaQuery.of(context);
    final MaterialLocalizations localizations =
        MaterialLocalizations.of(context);
    final String routeLabel = _getRouteLabel(localizations);

    return AnimatedBuilder(
      animation: widget.route!.animation!,
      builder: (BuildContext context, Widget? child) {
        // Disable the initial animation when accessible navigation is on so
        // that the semantics are added to the tree at the correct time.
        final double animationValue = mediaQuery.accessibleNavigation
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
                animationValue,
                isScrollControlled: widget.isScrollControlled,
              ),
              child: BottomSheet(
                animationController: widget.route!._animationController,
                onClosing: () {
                  if (!widget.isPersistent) {
                    if (widget.route!.isCurrent) {
                      Navigator.pop(context);
                    }
                  }
                },
                builder: widget.route!.builder!,
                backgroundColor: widget.backgroundColor,
                elevation: widget.elevation,
                shape: widget.shape,
                clipBehavior: widget.clipBehavior,
                enableDrag: widget.enableDrag,
                constraints: widget.constraints,
                showDragHandle: widget.showDragHandle,
                dragHandleColor: widget.dragHandleColor,
                dragHandleSize: widget.dragHandleSize,
                onDragEnd: widget.onDragEnd,
                onDragStart: widget.onDragStart,
                shadowColor: widget.shadowColor,
                key: widget.key,
              ),
            ),
          ),
        );
      },
    );
  }
}

class _GetModalBottomSheetLayout extends SingleChildLayoutDelegate {
  _GetModalBottomSheetLayout(this.progress, {required this.isScrollControlled});

  final double progress;
  final bool isScrollControlled;

  @override
  BoxConstraints getConstraintsForChild(BoxConstraints constraints) =>
      BoxConstraints(
        minWidth: constraints.maxWidth,
        maxWidth: constraints.maxWidth,
        maxHeight: isScrollControlled
            ? constraints.maxHeight
            : constraints.maxHeight * 9.0 / 16.0,
      );

  @override
  Offset getPositionForChild(Size size, Size childSize) =>
      Offset(0, size.height - childSize.height * progress);

  @override
  bool shouldRelayout(_GetModalBottomSheetLayout oldDelegate) =>
      progress != oldDelegate.progress;
}
