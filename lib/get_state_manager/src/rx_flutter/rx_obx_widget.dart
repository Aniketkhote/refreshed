import "package:flutter/widgets.dart";

import "../../../state_manager.dart";

/// Callback signature for a widget builder function.
///
/// The callback should return a [Widget].
typedef WidgetCallback = Widget Function();

/// The base class for all GetX reactive widgets.
/// This class is used as a foundation for widgets that react to changes in
/// GetX observables.
abstract class ObxWidget extends ObxStatelessWidget {
  /// Constructs an [ObxWidget].
  const ObxWidget({super.key});
}

/// A reactive widget that rebuilds whenever the observed state changes.
///
/// To use this widget, pass your Rx variable in the root scope of the
/// [builder] function. The widget will automatically register for changes.
///
/// Example:
/// ```dart
/// final _name = "GetX".obs;
/// Obx(() => Text(_name.value)),
/// ```
class Obx extends ObxWidget {
  /// Constructs an [Obx] widget with the given [builder].
  ///
  /// The [builder] parameter is a callback function that returns the widget
  /// to be built based on the observed state.
  const Obx(this.builder, {super.key});

  /// A callback function that returns the widget to be built based on the
  /// observed state.
  final WidgetCallback builder;

  @override
  Widget build(BuildContext context) => builder();
}

/// A reactive widget similar to [Obx], but manages a local state.
/// Pass the initial data in the constructor. This is useful for simple local
/// states, like toggles, visibility, themes, button states, etc.
///
/// Example:
/// ```dart
/// ObxValue(
///   (data) => Switch(
///     value: data.value,
///     onChanged: (flag) => data.value = flag,
///   ),
///   false.obs,
/// ),
/// ```
class ObxValue<T extends RxInterface> extends ObxWidget {
  /// Constructs an [ObxValue] widget with the given [builder] and [data].
  ///
  /// The [builder] is a callback function that takes the observed data and
  /// returns the widget to be built. The [data] is the observable data that
  /// the widget will react to.
  const ObxValue(this.builder, this.data, {super.key});

  /// A callback function that takes the observed data of type [T] and
  /// returns the widget to be built.
  final Widget Function(T) builder;

  /// The observed data of type [T].
  final T data;

  @override
  Widget build(BuildContext context) => builder(data);
}
