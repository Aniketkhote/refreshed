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

  /// Close the snackbar with animation
  Future<void> close({bool withAnimations = true}) async {
    if (!withAnimations) {
      _removeOverlay();
      return;
    }
    _removeEntry();
    await future;
  }

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

  void _configureAlignment(SnackPosition snackPosition) {
    switch (snackbar.snackPosition) {
      case SnackPosition.top:
        {
          _initialAlignment = const Alignment(-1, -2);
          _endAlignment = const Alignment(-1, -1);
          break;
        }
      case SnackPosition.bottom:
        {
          _initialAlignment = const Alignment(-1, 2);
          _endAlignment = const Alignment(-1, 1);
          break;
        }
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
      "Cannot configure a snackbar after disposing it.",
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

  void _configureTimer() {
    if (snackbar.duration != null) {
      if (_timer != null && _timer!.isActive) {
        _timer!.cancel();
      }
      _timer = Timer(snackbar.duration!, _removeEntry);
    } else {
      if (_timer != null) {
        _timer!.cancel();
      }
    }
  }

  /// Called to create the animation that exposes the current progress of
  /// the transition controlled by the animation controller created by
  /// `createAnimationController()`.
  Animation<Alignment> _createAnimation() {
    assert(
      !_transitionCompleter.isCompleted,
      "Cannot create a animation from a disposed snackbar",
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
      "Cannot create a animationController from a disposed snackbar",
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

  Widget _getDismissibleSnack(Widget child) => Dismissible(
        behavior: snackbar.hitTestBehavior ?? HitTestBehavior.opaque,
        direction: snackbar.dismissDirection ?? _getDefaultDismissDirection(),
        resizeDuration: null,
        confirmDismiss: (_) {
          if (_currentStatus == SnackbarStatus.opening ||
              _currentStatus == SnackbarStatus.closing) {
            return Future<bool?>.value(false);
          }
          return Future<bool?>.value(true);
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

  void _handleStatusChanged(AnimationStatus status) {
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

  void _removeEntry() {
    assert(
      !_transitionCompleter.isCompleted,
      "Cannot remove entry from a disposed snackbar",
    );

    _cancelTimer();

    if (_wasDismissedBySwipe) {
      Timer(const Duration(milliseconds: 200), _controller.reset);
      _wasDismissedBySwipe = false;
    } else {
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
      "Cannot remove overlay from a disposed snackbar",
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

  SnackbarController? get _currentSnackbar {
    if (_snackbarList.isEmpty) {
      return null;
    }
    return _snackbarList.first;
  }

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

  void disposeControllers() {
    if (_currentSnackbar != null) {
      _currentSnackbar?._removeOverlay();
      _currentSnackbar?._controller.dispose();
      _snackbarList.remove(_currentSnackbar);
    }

    _queue.cancelAllJobs();

    for (final SnackbarController element in _snackbarList) {
      element._controller.dispose();
    }
    _snackbarList.clear();
  }

  Future<void> closeCurrentJob() async {
    if (_currentSnackbar == null) {
      return;
    }
    await _currentSnackbar!.close();
  }
}
