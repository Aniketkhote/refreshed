import "package:flutter/widgets.dart";
import "package:refreshed/get_rx/src/rx_types/rx_types.dart";
import "package:refreshed/get_state_manager/src/simple/simple_builder.dart";

/// Callback signature for a widget builder function.
typedef WidgetCallback = Widget Function();

/// The [ObxWidget] is the base for all GetX reactive widgets.
///
/// See also:
/// - [Obx]
/// - [ObxValue]
abstract class ObxWidget extends ObxStatelessWidget {
  /// Constructs an [ObxWidget].
  const ObxWidget({super.key});
}

/// The simplest reactive widget in GetX.
///
/// Just pass your Rx variable in the root scope of the callback to have it
/// automatically registered for changes.
///
/// Example:
/// ```dart
/// final _name = "GetX".obs;
/// Obx(() => Text(_name.value)),
/// ```
class Obx extends ObxWidget {
  /// Constructs an [Obx] widget with the given [builder].
  ///
  /// The [builder] parameter is a callback function that returns the widget to be built.
  const Obx(this.builder, {super.key});

  /// A callback function that returns the widget to be built based on the observed state.
  final WidgetCallback builder;

  @override
  Widget build(BuildContext context) => builder();
}

/// Similar to [Obx], but manages a local state.
/// Pass the initial data in the constructor.
/// Useful for simple local states, like toggles, visibility, themes,
/// button states, etc.
///
/// Example:
/// ```dart
/// ObxValue((data) => Switch(
///   value: data.value,
///   onChanged: (flag) => data.value = flag,
/// ),
/// false.obs,
/// ),
/// ```
class ObxValue<T extends RxInterface> extends ObxWidget {
  /// Constructs an [ObxValue] widget with the given [builder] and [data].
  const ObxValue(this.builder, this.data, {super.key});

  /// A callback function that takes the observed data and returns the widget to be built.
  final Widget Function(T) builder;

  /// The observed data.
  final T data;

  @override
  Widget build(BuildContext context) => builder(data);
}
