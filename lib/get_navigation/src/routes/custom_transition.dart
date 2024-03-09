import "package:flutter/widgets.dart";

/// An abstract class representing a custom transition for animated route transitions.
///
/// Implementations of this class define how a transition animation should be built
/// for a specific route transition.
abstract class CustomTransition {
  /// Builds the transition animation for a route.
  ///
  /// This method should be implemented to define the transition animation for a route.
  ///
  /// - `context`: The build context.
  /// - `curve`: The curve to be used for the animation.
  /// - `alignment`: The alignment of the transition animation.
  /// - `animation`: The animation controlling the transition.
  /// - `secondaryAnimation`: The animation controlling the transition of secondary elements.
  /// - `child`: The child widget to be transitioned.
  ///
  /// Returns the widget representing the transition animation.
  Widget buildTransition(
    BuildContext context,
    Curve? curve,
    Alignment? alignment,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  );
}
