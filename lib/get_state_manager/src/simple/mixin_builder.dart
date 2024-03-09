import "package:flutter/material.dart";

import 'package:refreshed/get_state_manager/src/rx_flutter/rx_obx_widget.dart';
import 'package:refreshed/get_state_manager/src/simple/get_controllers.dart';
import 'package:refreshed/get_state_manager/src/simple/get_state.dart';

/// A widget that facilitates building UI components with GetX controllers and mixins.
///
/// This widget is a convenience wrapper around GetBuilder and Obx widgets from the Get package,
/// providing an easy way to integrate GetX controllers with mixin functionality into the widget tree.
class MixinBuilder<T extends GetxController> extends StatelessWidget {

  /// Creates a MixinBuilder widget.
  const MixinBuilder({
    super.key,
    this.init,
    this.global = true,
    required this.builder,
    this.autoRemove = true,
    this.initState,
    this.dispose,
    this.id,
    this.didChangeDependencies,
    this.didUpdateWidget,
  });
  /// The function that builds the UI component using the provided controller.
  @required
  final Widget Function(T) builder;

  /// Whether the controller should be initialized globally.
  final bool global;

  /// An optional identifier for the widget to distinguish it from others.
  final String? id;

  /// Whether the widget should be automatically removed when it is no longer needed.
  final bool autoRemove;

  /// Callback function called when the widget is initialized.
  final void Function(BindElement<T> state)? initState;

  /// Callback function called when the widget is disposed.
  final void Function(BindElement<T> state)? dispose;

  /// Callback function called when the dependencies of the widget change.
  final void Function(BindElement<T> state)? didChangeDependencies;

  /// Callback function called when the widget is updated with new data.
  final void Function(Binder<T> oldWidget, BindElement<T> state)?
      didUpdateWidget;

  /// The initial controller instance to use.
  final T? init;

  @override
  Widget build(BuildContext context) {
    return GetBuilder<T>(
      init: init,
      global: global,
      autoRemove: autoRemove,
      initState: initState,
      dispose: dispose,
      id: id,
      didChangeDependencies: didChangeDependencies,
      didUpdateWidget: didUpdateWidget,
      builder: (controller) => Obx(() => builder.call(controller)),
    );
  }
}
