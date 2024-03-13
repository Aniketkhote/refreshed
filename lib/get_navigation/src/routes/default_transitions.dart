import "package:flutter/cupertino.dart";
import "package:flutter/material.dart";

/// A class representing a left-to-right fade transition animation.
class LeftToRightFadeTransition {
  /// Builds the transition animation.
  Widget buildTransitions(
    BuildContext context,
    Curve? curve,
    Alignment? alignment,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) =>
      SlideTransition(
        position: Tween<Offset>(
          begin: const Offset(-1, 0),
          end: Offset.zero,
        ).animate(animation),
        child: FadeTransition(
          opacity: animation,
          child: SlideTransition(
            position: Tween<Offset>(
              begin: Offset.zero,
              end: const Offset(1, 0),
            ).animate(secondaryAnimation),
            child: child,
          ),
        ),
      );
}

/// A class representing a right-to-left fade transition animation.
class RightToLeftFadeTransition {
  /// Builds the transition animation.
  Widget buildTransitions(
    BuildContext context,
    Curve? curve,
    Alignment? alignment,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) =>
      SlideTransition(
        position: Tween<Offset>(
          begin: const Offset(1, 0),
          end: Offset.zero,
        ).animate(animation),
        child: FadeTransition(
          opacity: animation,
          child: SlideTransition(
            position: Tween<Offset>(
              begin: Offset.zero,
              end: const Offset(-1, 0),
            ).animate(secondaryAnimation),
            child: child,
          ),
        ),
      );
}

/// A class representing a no transition animation.
class NoTransition {
  /// Builds the transition animation.
  Widget buildTransitions(
    BuildContext context,
    Curve curve,
    Alignment alignment,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) =>
      child;
}

/// A class representing a fade-in transition animation.
class FadeInTransition {
  /// Builds the transition animation.
  Widget buildTransitions(
    BuildContext context,
    Curve? curve,
    Alignment? alignment,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) =>
      FadeTransition(opacity: animation, child: child);
}

/// A class representing a slide-down transition animation.
class SlideDownTransition {
  /// Builds the transition animation.
  Widget buildTransitions(
    BuildContext context,
    Curve? curve,
    Alignment? alignment,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) =>
      SlideTransition(
        position: Tween<Offset>(
          begin: const Offset(0, 1),
          end: Offset.zero,
        ).animate(animation),
        child: child,
      );
}

/// A class representing a slide-left transition animation.
class SlideLeftTransition {
  /// Builds the transition animation.
  Widget buildTransitions(
    BuildContext context,
    Curve? curve,
    Alignment? alignment,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) =>
      SlideTransition(
        position: Tween<Offset>(
          begin: const Offset(-1, 0),
          end: Offset.zero,
        ).animate(animation),
        child: child,
      );
}

/// A class representing a slide-right transition animation.
class SlideRightTransition {
  /// Builds the transition animation.
  Widget buildTransitions(
    BuildContext context,
    Curve? curve,
    Alignment? alignment,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) =>
      SlideTransition(
        position: Tween<Offset>(
          begin: const Offset(1, 0),
          end: Offset.zero,
        ).animate(animation),
        child: child,
      );
}

/// A class representing a slide-top transition animation.
class SlideTopTransition {
  /// Builds the transition animation.
  Widget buildTransitions(
    BuildContext context,
    Curve? curve,
    Alignment? alignment,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) =>
      SlideTransition(
        position: Tween<Offset>(
          begin: const Offset(0, -1),
          end: Offset.zero,
        ).animate(animation),
        child: child,
      );
}

/// A class representing a zoom-in transition animation.
class ZoomInTransition {
  /// Builds the transition animation.
  Widget buildTransitions(
    BuildContext context,
    Curve? curve,
    Alignment? alignment,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) =>
      ScaleTransition(
        scale: animation,
        child: child,
      );
}

/// A class representing a size transition animation.
class SizeTransitions {
  /// Builds the transition animation.
  Widget buildTransitions(
    BuildContext context,
    Curve curve,
    Alignment? alignment,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) =>
      Align(
        child: SizeTransition(
          sizeFactor: CurvedAnimation(
            parent: animation,
            curve: curve,
          ),
          child: child,
        ),
      );
}
