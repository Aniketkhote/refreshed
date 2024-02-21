import 'package:flutter/material.dart';

import 'animations.dart';

/// A widget that animates its builder's output value based on a provided tween and duration.
///
/// This widget allows you to create animations easily by specifying a `duration`,
/// a `tween`, and a `builder` function. The animation will be controlled by an
/// [AnimationController] internally and will apply the provided tween to the
/// controller's value over the specified duration. The output value of the tween
/// will be passed to the `builder` function, which is expected to return a widget.
///
/// By default, the animation starts immediately after the widget is built.
/// You can also specify a `delay` to postpone the animation start.
///
/// Additionally, you can provide optional callbacks for `onStart` and `onComplete`
/// to be notified when the animation starts and completes, respectively.
///
/// The animation's curve can be customized using the `curve` parameter.
/// If not provided, it defaults to [Curves.linear].
class GetAnimatedBuilder<T> extends StatefulWidget {
  const GetAnimatedBuilder({
    super.key,
    required this.duration,
    required this.tween,
    required this.idleValue,
    required this.builder,
    required this.child,
    required this.delay,
    this.curve = Curves.linear,
    this.onComplete,
    this.onStart,
  });

  /// The duration of the animation.
  final Duration duration;

  /// The delay before starting the animation.
  final Duration delay;

  /// The child widget that remains static during the animation.
  final Widget child;

  /// A callback function called when the animation completes.
  final ValueSetter<AnimationController>? onComplete;

  /// A callback function called when the animation starts.
  final ValueSetter<AnimationController>? onStart;

  /// The tween that defines the range of values for the animation.
  final Tween<T> tween;

  /// The initial value for the animation when it is not running.
  final T idleValue;

  /// The function that builds the animated widget.
  final ValueWidgetBuilder<T> builder;

  /// The curve used for the animation.
  final Curve curve;

  /// Returns the total duration including the delay before starting the animation.
  Duration get totalDuration => duration + delay;

  @override
  GetAnimatedBuilderState<T> createState() => GetAnimatedBuilderState<T>();
}

/// The state for [GetAnimatedBuilder].
class GetAnimatedBuilderState<T> extends State<GetAnimatedBuilder<T>>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<T> _animation;

  bool _wasStarted = false;
  late T _idleValue;
  bool _willResetOnDispose = false;

  /// Returns `true` if the animation will reset on dispose.
  bool get willResetOnDispose => _willResetOnDispose;

  void _listener(AnimationStatus status) {
    switch (status) {
      case AnimationStatus.completed:
        widget.onComplete?.call(_controller);
        if (_willResetOnDispose) {
          _controller.reset();
        }
        break;
      case AnimationStatus.forward:
        widget.onStart?.call(_controller);
        break;
      default:
        break;
    }
  }

  @override
  void initState() {
    super.initState();

    if (widget is OpacityAnimation) {
      final GetAnimatedBuilderState<T>? current =
          context.findRootAncestorStateOfType<GetAnimatedBuilderState<T>>();
      final bool isLast = current == null;

      if (widget is FadeInAnimation) {
        _idleValue = 1.0 as T;
      } else {
        if (isLast) {
          _willResetOnDispose = false;
        } else {
          _willResetOnDispose = true;
        }
        _idleValue = widget.idleValue;
      }
    } else {
      _idleValue = widget.idleValue;
    }

    _controller = AnimationController(
      vsync: this,
      duration: widget.duration,
    );

    _controller.addStatusListener(_listener);

    _animation = widget.tween.animate(
      CurvedAnimation(
        parent: _controller,
        curve: widget.curve,
      ),
    );

    Future<void>.delayed(widget.delay, () {
      if (mounted) {
        setState(() {
          _wasStarted = true;
          _controller.forward();
        });
      }
    });
  }

  @override
  void dispose() {
    _controller.removeStatusListener(_listener);
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (BuildContext context, Widget? child) {
        final T value = _wasStarted ? _animation.value : _idleValue;
        return widget.builder(context, value, child);
      },
      child: widget.child,
    );
  }
}
