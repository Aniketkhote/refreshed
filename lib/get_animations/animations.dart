import 'dart:math';
import 'dart:ui';

import 'package:flutter/widgets.dart';

import 'get_animated_builder.dart';

typedef OffsetBuilder = Offset Function(BuildContext, double);

/// An animation that adjusts the opacity of its child.
class FadeInAnimation extends OpacityAnimation {
  FadeInAnimation({
    super.key,
    required super.duration,
    required super.delay,
    required super.child,
    super.onComplete,
    super.begin = 0,
    super.end = 1,
    super.idleValue = 0,
  });
}

/// An animation that adjusts the opacity of its child in reverse.
class FadeOutAnimation extends OpacityAnimation {
  FadeOutAnimation({
    super.key,
    required super.duration,
    required super.delay,
    required super.child,
    super.onComplete,
    super.begin = 1,
    super.end = 0,
    super.idleValue = 1,
  });
}

/// Base class for animations that manipulate opacity.
class OpacityAnimation extends GetAnimatedBuilder<double> {
  OpacityAnimation({
    super.key,
    required super.duration,
    required super.delay,
    required super.child,
    super.onComplete,
    required double begin,
    required double end,
    required super.idleValue,
  }) : super(
          builder: (context, value, child) {
            return Opacity(
              opacity: value,
              child: child!,
            );
          },
          tween: Tween<double>(begin: begin, end: end),
        );
}

/// An animation that rotates its child.
class RotateAnimation extends GetAnimatedBuilder<double> {
  RotateAnimation({
    super.key,
    required super.duration,
    required super.delay,
    required super.child,
    super.onComplete,
    required double begin,
    required double end,
    super.idleValue = 0,
  }) : super(
          builder: (context, value, child) => Transform.rotate(
            angle: value,
            child: child!,
          ),
          tween: Tween<double>(begin: begin, end: end),
        );
}

/// An animation that scales its child.
class ScaleAnimation extends GetAnimatedBuilder<double> {
  ScaleAnimation({
    super.key,
    required super.duration,
    required super.delay,
    required super.child,
    super.onComplete,
    required double begin,
    required double end,
    super.idleValue = 0,
  }) : super(
          builder: (context, value, child) => Transform.scale(
            scale: value,
            child: child!,
          ),
          tween: Tween<double>(begin: begin, end: end),
        );
}

/// An animation that simulates a bouncing effect on its child.
class BounceAnimation extends GetAnimatedBuilder<double> {
  BounceAnimation({
    super.key,
    required super.duration,
    required super.delay,
    required super.child,
    super.onComplete,
    required double begin,
    required double end,
    super.idleValue = 0,
    super.curve = Curves.bounceOut,
  }) : super(
          builder: (context, value, child) => Transform.scale(
            scale: 1 + value.abs(),
            child: child!,
          ),
          tween: Tween<double>(begin: begin, end: end),
        );
}

/// An animation that rotates its child continuously.
class SpinAnimation extends GetAnimatedBuilder<double> {
  SpinAnimation({
    super.key,
    required super.duration,
    required super.delay,
    required super.child,
    super.onComplete,
    super.idleValue = 0,
  }) : super(
          builder: (context, value, child) => Transform.rotate(
            angle: value * pi / 180.0,
            child: child!,
          ),
          tween: Tween<double>(begin: 0, end: 360),
        );
}

/// An animation that adjusts the size of its child.
class SizeAnimation extends GetAnimatedBuilder<double> {
  SizeAnimation({
    super.key,
    required super.duration,
    required super.delay,
    required super.child,
    super.onComplete,
    required double begin,
    required double end,
    super.idleValue = 0,
  }) : super(
          builder: (context, value, child) => Transform.scale(
            scale: value,
            child: child!,
          ),
          tween: Tween<double>(begin: begin, end: end),
        );
}

/// An animation that applies a blur effect to its child.
class BlurAnimation extends GetAnimatedBuilder<double> {
  BlurAnimation({
    super.key,
    required super.duration,
    required super.delay,
    required super.child,
    super.onComplete,
    required double begin,
    required double end,
    super.idleValue = 0,
  }) : super(
          builder: (context, value, child) => BackdropFilter(
            filter: ImageFilter.blur(
              sigmaX: value,
              sigmaY: value,
            ),
            child: child,
          ),
          tween: Tween<double>(begin: begin, end: end),
        );
}

/// An animation that flips its child horizontally.
class FlipAnimation extends GetAnimatedBuilder<double> {
  FlipAnimation({
    super.key,
    required super.duration,
    required super.delay,
    required super.child,
    super.onComplete,
    required double begin,
    required double end,
    super.idleValue = 0,
  }) : super(
          builder: (context, value, child) {
            final radians = value * pi;
            return Transform(
              transform: Matrix4.rotationY(radians),
              alignment: Alignment.center,
              child: child,
            );
          },
          tween: Tween<double>(begin: begin, end: end),
        );
}

/// An animation that simulates a wave effect on its child.
class WaveAnimation extends GetAnimatedBuilder<double> {
  WaveAnimation({
    super.key,
    required super.duration,
    required super.delay,
    required super.child,
    super.onComplete,
    required double begin,
    required double end,
    super.idleValue = 0,
  }) : super(
          builder: (context, value, child) => Transform(
            transform: Matrix4.translationValues(
              0.0,
              20.0 * sin(value * pi * 2),
              0.0,
            ),
            child: child,
          ),
          tween: Tween<double>(begin: begin, end: end),
        );
}

/// An animation that simulates a wobble effect on its child.
class WobbleAnimation extends GetAnimatedBuilder<double> {
  WobbleAnimation({
    super.key,
    required super.duration,
    required super.delay,
    required super.child,
    super.onComplete,
    required double begin,
    required double end,
    super.idleValue = 0,
  }) : super(
          builder: (context, value, child) => Transform(
            transform: Matrix4.identity()
              ..setEntry(3, 2, 0.001)
              ..rotateZ(sin(value * pi * 2) * 0.1),
            alignment: Alignment.center,
            child: child,
          ),
          tween: Tween<double>(begin: begin, end: end),
        );
}

/// An animation that slides its child in from the left.
class SlideInLeftAnimation extends SlideAnimation {
  SlideInLeftAnimation({
    super.key,
    required super.duration,
    required super.delay,
    required super.child,
    super.onComplete,
    required super.begin,
    required super.end,
    super.idleValue,
  }) : super(
          offsetBuild: (context, value) =>
              Offset(value * MediaQuery.of(context).size.width, 0),
        );
}

/// An animation that slides its child in from the right.
class SlideInRightAnimation extends SlideAnimation {
  SlideInRightAnimation({
    super.key,
    required super.duration,
    required super.delay,
    required super.child,
    super.onComplete,
    required super.begin,
    required super.end,
    super.idleValue,
  }) : super(
          offsetBuild: (context, value) =>
              Offset((1 - value) * MediaQuery.of(context).size.width, 0),
        );
}

/// An animation that slides its child in from the top.
class SlideInUpAnimation extends SlideAnimation {
  SlideInUpAnimation({
    super.key,
    required super.duration,
    required super.delay,
    required super.child,
    super.onComplete,
    required super.begin,
    required super.end,
    super.idleValue,
  }) : super(
          offsetBuild: (context, value) =>
              Offset(0, value * MediaQuery.of(context).size.height),
        );
}

/// An animation that slides its child in from the bottom.
class SlideInDownAnimation extends SlideAnimation {
  SlideInDownAnimation({
    super.key,
    required super.duration,
    required super.delay,
    required super.child,
    super.onComplete,
    required super.begin,
    required super.end,
    super.idleValue,
  }) : super(
          offsetBuild: (context, value) =>
              Offset(0, (1 - value) * MediaQuery.of(context).size.height),
        );
}

/// An animation that slides its child by applying a translation.
class SlideAnimation extends GetAnimatedBuilder<double> {
  SlideAnimation({
    super.key,
    required super.duration,
    required super.delay,
    required super.child,
    required double begin,
    required double end,
    required OffsetBuilder offsetBuild,
    super.onComplete,
    super.idleValue = 0,
  }) : super(
          builder: (context, value, child) => Transform.translate(
            offset: offsetBuild(context, value),
            child: child,
          ),
          tween: Tween<double>(begin: begin, end: end),
        );
}

/// An animation that adjusts the scale of its child.
class ZoomAnimation extends GetAnimatedBuilder<double> {
  ZoomAnimation({
    super.key,
    required super.duration,
    required super.delay,
    required super.child,
    super.onComplete,
    required double begin,
    required double end,
    super.idleValue = 0,
  }) : super(
          builder: (context, value, child) => Transform.scale(
            scale: lerpDouble(1, end, value)!,
            child: child,
          ),
          tween: Tween<double>(begin: begin, end: end),
        );
}

/// An animation that adjusts the color of its child.
class ColorAnimation extends GetAnimatedBuilder<Color?> {
  ColorAnimation({
    super.key,
    required super.duration,
    required super.delay,
    required super.child,
    super.onComplete,
    required Color begin,
    required Color end,
    Color? idleColor,
  }) : super(
          builder: (context, value, child) => ColorFiltered(
            colorFilter: ColorFilter.mode(
              Color.lerp(begin, end, value!.value.toDouble())!,
              BlendMode.srcIn,
            ),
            child: child,
          ),
          tween: ColorTween(begin: begin, end: end),
          idleValue: idleColor ?? begin,
        );
}
