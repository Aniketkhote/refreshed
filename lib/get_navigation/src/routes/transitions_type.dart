import "package:flutter/widgets.dart";
import "package:refreshed/get_navigation/src/routes/default_route.dart";

/// Enum defining various types of transitions that can be applied when
/// navigating between routes.
enum Transition {
  /// Fade transition.
  fade,

  /// Fade in transition.
  fadeIn,

  /// Right to left transition.
  rightToLeft,

  /// Left to right transition.
  leftToRight,

  /// Up to down transition.
  upToDown,

  /// Down to up transition.
  downToUp,

  /// Right to left transition with fade effect.
  rightToLeftWithFade,

  /// Left to right transition with fade effect.
  leftToRightWithFade,

  /// Zoom transition.
  zoom,

  /// Top level transition.
  topLevel,

  /// No transition.
  noTransition,

  /// Cupertino-style transition.
  cupertino,

  /// Cupertino-style dialog transition.
  cupertinoDialog,

  /// Size transition.
  size,

  /// Scale transition.
  scale,

  /// Circular reveal transition.
  circularReveal,

  /// Native platform transition.
  native,
}

/// Typedef representing a function that returns a widget.
typedef GetPageBuilder = Widget Function();

/// Typedef representing a function that takes an optional [GetPageRoute] route
/// parameter and returns a widget.
typedef GetRouteAwarePageBuilder<T> = Widget Function([GetPageRoute<T>? route]);
