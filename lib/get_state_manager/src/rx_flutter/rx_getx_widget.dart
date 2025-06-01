import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:refreshed/get_core/get_core.dart';
import 'package:refreshed/get_instance/src/instance_extension.dart';
import 'package:refreshed/get_instance/src/lifecycle.dart';
import 'package:refreshed/get_state_manager/src/simple/list_notifier.dart';

/// A typedef for a function that builds a widget based on a [GetX] controller.
///
/// This function signature is used to define how the widget will be built
/// based on the state of the controller. The controller must extend [GetLifeCycleMixin].
typedef GetXControllerBuilder<T extends GetLifeCycleMixin> = Widget Function(
    T controller);

/// A widget that manages the lifecycle of a [GetX] controller and rebuilds
/// its child widget whenever the controller's state changes.
///
/// The [GetX] widget listens to the state of the controller, and whenever
/// the controller's state changes, it triggers a rebuild of the widget.
/// It is designed to work with controllers that extend [GetLifeCycleMixin].
///
/// The controller can be registered globally or locally, and the widget
/// provides hooks for lifecycle events like [initState], [dispose], and others.
class GetX<T extends GetLifeCycleMixin> extends StatefulWidget {
  /// Constructs a [GetX] widget.
  ///
  /// The [builder] function is required and is used to build the widget
  /// based on the controller's state. Other parameters control the lifecycle
  /// behavior of the controller, such as whether it should be registered globally,
  /// and whether it should be automatically removed when the widget is disposed.
  const GetX({
    required this.builder,
    super.key,
    this.tag,
    this.global = true,
    this.autoRemove = true,
    this.assignId = false,
    this.initState,
    this.dispose,
    this.didChangeDependencies,
    this.didUpdateWidget,
    this.init,
  });

  /// The function that creates the child widget based on the controller.
  final GetXControllerBuilder<T> builder;

  /// Whether the controller should be registered globally.
  ///
  /// If true, the controller will be registered globally using [Get.put].
  /// If false, the controller will not be registered globally.
  final bool global;

  /// Whether the controller should be automatically removed when the widget is disposed.
  ///
  /// If true, the controller will be removed from the global registry when the widget is disposed.
  /// If false, the controller will not be automatically removed.
  final bool autoRemove;

  /// Whether to assign a unique ID to the controller when registering globally.
  ///
  /// If true, a unique ID will be assigned to the controller when registering it globally.
  /// If false, no ID will be assigned.
  final bool assignId;

  /// Callback function called when the widget is initialized.
  final void Function(GetXState<T> state)? initState;

  /// Callback function called when the widget is disposed.
  final void Function(GetXState<T> state)? dispose;

  /// Callback function called when the widget's dependencies change.
  final void Function(GetXState<T> state)? didChangeDependencies;

  /// Callback function called when the widget is updated with new data.
  final void Function(GetX<T> oldWidget, GetXState<T> state)? didUpdateWidget;

  /// The initial controller to use.
  ///
  /// If the controller is not registered globally, this controller will be used
  /// to initialize the widget.
  final T? init;

  /// An optional tag to identify the controller when registered globally.
  final String? tag;

  @override
  GetXState<T> createState() => GetXState<T>();
}

class GetXState<T extends GetLifeCycleMixin> extends State<GetX<T>> {
  T? controller;
  bool _isCreator = false;
  final List<Disposer> disposers = [];

  @override
  void initState() {
    super.initState();

    // Register the controller globally if necessary, or use the provided local controller.
    switch ((widget.global, Get.isRegistered<T>(tag: widget.tag))) {
      case (true, false):
        // Not registered globally, register it
        controller = widget.init;
        _isCreator = true;
        if (controller != null) {
          Get.put<T>(controller!, tag: widget.tag);
        }
      case (true, true):
        // Already registered globally
        _isCreator = Get.isPrepared<T>(tag: widget.tag);
        controller = Get.find<T>(tag: widget.tag);
      case (false, _):
        // Local controller only
        controller = widget.init;
        _isCreator = true;
        controller?.onStart();
    }

    widget.initState?.call(this);

    // Trigger onStart if the controller is globally registered and smart management is enabled.
    if (widget.global && Get.smartManagement == SmartManagement.onlyBuilder) {
      controller?.onStart();
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    widget.didChangeDependencies?.call(this);
  }

  @override
  void didUpdateWidget(GetX<T> oldWidget) {
    super.didUpdateWidget(oldWidget);
    widget.didUpdateWidget?.call(oldWidget, this);
  }

  @override
  void dispose() {
    // Call the provided dispose callback, if any.
    widget.dispose?.call(this);

    // Remove the controller if it was created locally or is marked for removal.
    if ((_isCreator || widget.assignId) &&
        widget.autoRemove &&
        Get.isRegistered<T>(tag: widget.tag)) {
      Get.delete<T>(tag: widget.tag);
    }

    // Clean up any disposers.
    for (final disposer in disposers) {
      disposer();
    }
    disposers.clear();

    controller = null;
    super.dispose();
  }

  /// Updates the state of the widget.
  ///
  /// This function triggers a rebuild of the widget by calling [setState].
  void _update() => mounted ? setState(() {}) : null;

  @override
  Widget build(BuildContext context) => Notifier.instance.append(
        NotifyData(disposers: disposers, updater: _update),
        () => widget.builder(controller!),
      );

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties
      ..add(DiagnosticsProperty<T>('controller', controller))
      ..add(IterableProperty<Disposer>('disposers', disposers));
  }
}
