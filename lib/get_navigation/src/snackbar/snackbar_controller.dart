import "dart:async";
import "dart:math";
import "dart:ui";

import "package:flutter/material.dart";
import "package:refreshed/get_navigation/src/root/get_root.dart";
import "package:refreshed/refreshed.dart";

class SnackbarController {
  /// construct [SnackbarController]
  SnackbarController(this.snackbar);
  final GlobalKey<GetSnackBarState> key = GlobalKey<GetSnackBarState>();

  static bool get isSnackbarBeingShown =>
      GetRootState.controller.config.snackBarQueue.isJobInProgress;

  late Animation<double> _filterBlurAnimation;
  late Animation<Color?> _filterColorAnimation;

  final GetSnackBar snackbar;
  final Completer _transitionCompleter = Completer();

  late SnackbarStatusCallback? _snackbarStatus;
  late final Alignment? _initialAlignment;
  late final Alignment? _endAlignment;

  bool _wasDismissedBySwipe = false;

  bool _onTappedDismiss = false;

  Timer? _timer;

  /// The animation that drives the route's transition and the previous route's
  /// forward transition.
  late final Animation<Alignment> _animation;

  /// The animation controller that the route uses to drive the transitions.
  ///
  /// The animation itself is exposed by the [animation] property.
  late final AnimationController _controller;

  SnackbarStatus? _currentStatus;

  final List<OverlayEntry> _overlayEntries = <OverlayEntry>[];

  OverlayState? _overlayState;

  Future<void> get future => _transitionCompleter.future;

  /// Close the snackbar with or without animation.
  ///
  /// Uses Dart 3.8 pattern matching to handle different close behaviors
  /// based on whether animations are enabled.
  Future<void> close({bool withAnimations = true}) async =>
      switch (withAnimations) {
        // When animations are disabled, immediately remove the overlay
        false => _removeOverlay(),

        // When animations are enabled, trigger entry removal and wait for completion
        true => () async {
            _removeEntry();
            await future;
          }(),
      };

  /// Adds GetSnackbar to a view queue.
  /// Only one GetSnackbar will be displayed at a time, and this method returns
  /// a future to when the snackbar disappears.
  Future<void> show() async =>
      GetRootState.controller.config.snackBarQueue.addJob(this);

  void _cancelTimer() {
    if (_timer != null && _timer!.isActive) {
      _timer!.cancel();
    }
  }

  /// Configures the initial and end alignments based on snack position.
  ///
  /// Uses Dart 3.8 switch expression to set appropriate alignment values
  /// for different snack positions (top or bottom).
  void _configureAlignment(SnackPosition snackPosition) {
    // Use switch expression to set alignments based on position
    switch (snackbar.snackPosition) {
      case SnackPosition.top:
        _initialAlignment = const Alignment(-1, -2); // Initial: above screen
        _endAlignment = const Alignment(-1, -1); // End: at top

      case SnackPosition.bottom:
        _initialAlignment = const Alignment(-1, 2); // Initial: below screen
        _endAlignment = const Alignment(-1, 1); // End: at bottom
    }
  }

  bool _isTesting = false;

  void _configureOverlay() {
    final BuildContext? overlayContext = Get.overlayContext;
    _isTesting = overlayContext == null;
    _overlayState =
        _isTesting ? OverlayState() : Overlay.of(Get.overlayContext!);
    _overlayEntries
      ..clear()
      ..addAll(_createOverlayEntries(_getBodyWidget()));
    if (!_isTesting) {
      _overlayState!.insertAll(_overlayEntries);
    }

    _configureSnackBarDisplay();
  }

  void _configureSnackBarDisplay() {
    assert(
      !_transitionCompleter.isCompleted,
      "Snackbar configuration cannot be modified after it has been disposed. "
      "Ensure that you are not attempting to configure a snackbar after it has been closed or removed from the widget tree.",
    );

    _controller = _createAnimationController();
    _configureAlignment(snackbar.snackPosition);
    _snackbarStatus = snackbar.snackbarStatus;
    _filterBlurAnimation = _createBlurFilterAnimation();
    _filterColorAnimation = _createColorOverlayColor();
    _animation = _createAnimation();
    _animation.addStatusListener(_handleStatusChanged);
    _configureTimer();
    _controller.forward();
  }

  /// Configures the timer for auto-dismissing the snackbar.
  ///
  /// Uses Dart 3.8 pattern matching to handle the nullable duration
  /// and ensure any existing timer is properly canceled.
  void _configureTimer() {
    // Cancel any existing timer
    if (_timer != null && _timer!.isActive) {
      _timer!.cancel();
    }

    // Configure timer based on duration
    switch (snackbar.duration) {
      case null:
        // No duration specified, snackbar will remain until manually closed
        break;

      case var duration:
        // Create a timer to auto-dismiss after the specified duration
        _timer = Timer(duration, _removeEntry);
    }
  }

  /// Called to create the animation that exposes the current progress of
  /// the transition controlled by the animation controller created by
  /// `createAnimationController()`.
  Animation<Alignment> _createAnimation() {
    assert(
      !_transitionCompleter.isCompleted,
      "Cannot create or modify an animation for a snackbar that has already been disposed. "
      "Ensure the snackbar is still active before attempting to configure its animation.",
    );

    return AlignmentTween(begin: _initialAlignment, end: _endAlignment).animate(
      CurvedAnimation(
        parent: _controller,
        curve: snackbar.forwardAnimationCurve,
        reverseCurve: snackbar.reverseAnimationCurve,
      ),
    );
  }

  /// Called to create the animation controller that will drive the transitions
  /// to this route from the previous one, and back to the previous route
  /// from this one.
  AnimationController _createAnimationController() {
    assert(
      !_transitionCompleter.isCompleted,
      "Cannot create an animationController for a snackbar that has already been disposed. "
      "Ensure the snackbar is still active before attempting to create an animationController.",
    );

    assert(snackbar.animationDuration >= Duration.zero);
    return AnimationController(
      duration: snackbar.animationDuration,
      debugLabel: "$runtimeType",
      vsync: _overlayState!,
    );
  }

  Animation<double> _createBlurFilterAnimation() =>
      Tween<double>(begin: 0, end: snackbar.overlayBlur).animate(
        CurvedAnimation(
          parent: _controller,
          curve: const Interval(
            0,
            0.35,
            curve: Curves.easeInOutCirc,
          ),
        ),
      );

  Animation<Color?> _createColorOverlayColor() => ColorTween(
        begin: const Color(0x00000000),
        end: snackbar.overlayColor,
      ).animate(
        CurvedAnimation(
          parent: _controller,
          curve: const Interval(
            0,
            0.35,
            curve: Curves.easeInOutCirc,
          ),
        ),
      );

  Iterable<OverlayEntry> _createOverlayEntries(Widget child) => <OverlayEntry>[
        if (snackbar.overlayBlur > 0.0) ...<OverlayEntry>[
          OverlayEntry(
            builder: (BuildContext context) => GestureDetector(
              onTap: () {
                if (snackbar.isDismissible && !_onTappedDismiss) {
                  _onTappedDismiss = true;
                  close();
                }
              },
              child: AnimatedBuilder(
                animation: _filterBlurAnimation,
                builder: (BuildContext context, Widget? child) =>
                    BackdropFilter(
                  filter: ImageFilter.blur(
                    sigmaX: max(0.001, _filterBlurAnimation.value),
                    sigmaY: max(0.001, _filterBlurAnimation.value),
                  ),
                  child: Container(
                    constraints: const BoxConstraints.expand(),
                    color: _filterColorAnimation.value,
                  ),
                ),
              ),
            ),
          ),
        ],
        OverlayEntry(
          builder: (BuildContext context) => Semantics(
            focused: false,
            container: true,
            explicitChildNodes: true,
            child: AlignTransition(
              alignment: _animation,
              child: snackbar.isDismissible
                  ? _getDismissibleSnack(child)
                  : _getSnackbarContainer(child),
            ),
          ),
        ),
      ];

  Widget _getBodyWidget() => Builder(
        builder: (_) => MouseRegion(
          onEnter: (_) =>
              snackbar.onHover?.call(snackbar, SnackHoverState.entered),
          onExit: (_) =>
              snackbar.onHover?.call(snackbar, SnackHoverState.exited),
          child: GestureDetector(
            behavior: snackbar.hitTestBehavior ?? HitTestBehavior.deferToChild,
            onTap: snackbar.onTap != null
                ? () => snackbar.onTap?.call(snackbar)
                : null,
            child: snackbar,
          ),
        ),
      );

  DismissDirection _getDefaultDismissDirection() {
    if (snackbar.snackPosition == SnackPosition.top) {
      return DismissDirection.up;
    }
    return DismissDirection.down;
  }

  /// Creates a dismissible snackbar widget.
  ///
  /// Uses Dart 3.8 pattern matching to handle dismiss confirmation
  /// based on the current snackbar status.
  Widget _getDismissibleSnack(Widget child) => Dismissible(
        direction: _getDefaultDismissDirection(),
        resizeDuration: null,
        confirmDismiss: (_) => switch (_currentStatus) {
          // Prevent dismissal during opening or closing animations
          SnackbarStatus.opening ||
          SnackbarStatus.closing =>
            Future<bool?>.value(false),

          // Allow dismissal in all other states
          _ => Future<bool?>.value(true),
        },
        key: const Key("dismissible"),
        onDismissed: (_) {
          _wasDismissedBySwipe = true;
          _removeEntry();
        },
        child: _getSnackbarContainer(child),
      );

  Widget _getSnackbarContainer(Widget child) => Container(
        margin: snackbar.margin,
        child: child,
      );

  /// Handles animation status changes and updates snackbar status accordingly.
  ///
  /// Uses Dart 3.8 pattern matching to map animation status to snackbar status
  /// and perform appropriate actions for each state transition.
  void _handleStatusChanged(AnimationStatus status) {
    // Map animation status to snackbar status and perform appropriate actions
    switch (status) {
      case AnimationStatus.completed:
        _currentStatus = SnackbarStatus.open;
        _snackbarStatus?.call(_currentStatus);
        if (_overlayEntries.isNotEmpty) {
          _overlayEntries.first.opaque = false;
        }

      case AnimationStatus.forward:
        _currentStatus = SnackbarStatus.opening;
        _snackbarStatus?.call(_currentStatus);

      case AnimationStatus.reverse:
        _currentStatus = SnackbarStatus.closing;
        _snackbarStatus?.call(_currentStatus);
        if (_overlayEntries.isNotEmpty) {
          _overlayEntries.first.opaque = false;
        }

      case AnimationStatus.dismissed:
        assert(!_overlayEntries.first.opaque);
        _currentStatus = SnackbarStatus.closed;
        _snackbarStatus?.call(_currentStatus);
        _removeOverlay();
    }
  }

  /// Removes the snackbar entry with appropriate animation.
  ///
  /// Uses Dart 3.8 pattern matching to handle different removal behaviors
  /// based on whether the snackbar was dismissed by swipe.
  void _removeEntry() {
    assert(
      !_transitionCompleter.isCompleted,
      "Cannot remove an entry from a snackbar that has already been disposed. "
      "Ensure the snackbar is still active before attempting to remove it.",
    );

    _cancelTimer();

    // Handle different removal behaviors based on dismissal method
    switch (_wasDismissedBySwipe) {
      case true:
        // For swipe dismissal, reset controller after a short delay
        Timer(const Duration(milliseconds: 200), _controller.reset);
        _wasDismissedBySwipe = false;

      case false:
        // For regular dismissal, reverse the animation
        _controller.reverse();
    }
  }

  void _removeOverlay() {
    if (!_isTesting) {
      for (final OverlayEntry element in _overlayEntries) {
        element.remove();
      }
    }

    assert(
      !_transitionCompleter.isCompleted,
      "Cannot remove the overlay from a snackbar that has already been disposed. "
      "Ensure the snackbar is still active before attempting to remove the overlay.",
    );

    _controller.dispose();
    _overlayEntries.clear();
    _transitionCompleter.complete();
  }

  Future<void> _show() {
    _configureOverlay();
    return future;
  }

  static Future<void> cancelAllSnackbars() async {
    await GetRootState.controller.config.snackBarQueue.cancelAllJobs();
  }

  static Future<void> closeCurrentSnackbar() async {
    await GetRootState.controller.config.snackBarQueue.closeCurrentJob();
  }
}

class SnackBarQueue<T> {
  final GetQueue<T> _queue = GetQueue<T>();
  final List<SnackbarController> _snackbarList = <SnackbarController>[];

  /// Gets the current active snackbar, if any.
  ///
  /// Uses Dart 3.8 pattern matching to handle the empty list case.
  SnackbarController? get _currentSnackbar => switch (_snackbarList) {
        [] => null, // Empty list case - no active snackbar
        [var first, ..._] => first, // Non-empty list - return first item
      };

  bool get isJobInProgress => _snackbarList.isNotEmpty;

  Future<T> addJob(SnackbarController job) async {
    _snackbarList.add(job);
    final data = await _queue.add(job._show);
    _snackbarList.remove(job);
    return data;
  }

  Future<void> cancelAllJobs() async {
    await _currentSnackbar?.close();
    _queue.cancelAllJobs();
    _snackbarList.clear();
  }

  /// Disposes all snackbar controllers and cleans up resources.
  ///
  /// Uses Dart 3.8 pattern matching to handle the current snackbar disposal
  /// and cleans up remaining controllers.
  void disposeControllers() {
    // Handle current snackbar with pattern matching
    switch (_currentSnackbar) {
      case null:
        // No current snackbar, nothing to do here
        break;

      case var current:
        // Dispose current snackbar and remove from list
        current._removeOverlay();
        current._controller.dispose();
        _snackbarList.remove(current);
    }

    // Cancel all pending jobs
    _queue.cancelAllJobs();

    // Dispose remaining controllers and clear the list
    for (final controller in _snackbarList) {
      controller._controller.dispose();
    }
    _snackbarList.clear();
  }

  /// Closes the current active snackbar job, if one exists.
  ///
  /// Uses Dart 3.8 pattern matching to handle the nullable current snackbar.
  Future<void> closeCurrentJob() async => switch (_currentSnackbar) {
        null => {}, // No active snackbar - do nothing
        var snackbar => snackbar.close(), // Active snackbar - close it
      };
}
