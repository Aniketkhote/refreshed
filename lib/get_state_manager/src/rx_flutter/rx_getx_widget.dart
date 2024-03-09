import "package:flutter/foundation.dart";
import "package:flutter/widgets.dart";

import 'package:refreshed/get_core/get_core.dart';
import 'package:refreshed/get_instance/src/extension_instance.dart';
import 'package:refreshed/get_instance/src/lifecycle.dart';
import 'package:refreshed/get_state_manager/src/simple/list_notifier.dart';

/// A typedef representing a builder function for GetX controllers.
///
/// This typedef defines a function signature for building widgets based on GetX controllers.
/// It takes a single parameter of type [T], which is expected to be a subclass of [GetLifeCycleMixin],
/// and returns a [Widget].
typedef GetXControllerBuilder<T extends GetLifeCycleMixin> = Widget Function(
    T controller,);

/// A widget that manages the lifecycle of a controller and rebuilds its child widget whenever the controller changes.
///
/// The [GetX] widget is designed to work with controllers that extend [GetLifeCycleMixin].
/// It can be used to manage the lifecycle of a controller and rebuild its child widget whenever the controller changes.
class GetX<T extends GetLifeCycleMixin> extends StatefulWidget {

  /// Constructs a [GetX] widget.
  ///
  /// The [builder] argument is required and must not be null.
  const GetX({
    super.key,
    this.tag,
    required this.builder,
    this.global = true,
    this.autoRemove = true,
    this.initState,
    this.assignId = false,
    this.dispose,
    this.didChangeDependencies,
    this.didUpdateWidget,
    this.init,
  });
  /// The builder function that creates the child widget based on the controller.
  final GetXControllerBuilder<T> builder;

  /// Whether the controller should be registered globally.
  ///
  /// If set to `true`, the controller will be registered globally using [Get.put].
  /// If set to `false`, the controller will not be registered globally.
  final bool global;

  /// Whether the controller should be automatically removed when the widget is disposed.
  ///
  /// If set to `true`, the controller will be removed from the global registry when the widget is disposed.
  /// If set to `false`, the controller will not be automatically removed.
  final bool autoRemove;

  /// Whether to assign a unique ID to the controller when registering globally.
  ///
  /// If set to `true`, a unique ID will be assigned to the controller when registering it globally.
  /// If set to `false`, no ID will be assigned.
  final bool assignId;

  /// Callback function called when the widget is initialized.
  final void Function(GetXState<T> state)? initState;

  /// Callback function called when the widget is disposed.
  final void Function(GetXState<T> state)? dispose;

  /// Callback function called when the widget's dependencies change.
  final void Function(GetXState<T> state)? didChangeDependencies;

  /// Callback function called when the widget is updated with new data.
  final void Function(GetX oldWidget, GetXState<T> state)? didUpdateWidget;

  /// The initial controller to use.
  final T? init;

  /// An optional tag to identify the controller when registered globally.
  final String? tag;

  @override
  StatefulElement createElement() => StatefulElement(this);

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties
      ..add(
        DiagnosticsProperty<T>("controller", init),
      )
      ..add(DiagnosticsProperty<String>("tag", tag))
      ..add(
          ObjectFlagProperty<GetXControllerBuilder<T>>.has("builder", builder),);
  }

  @override
  GetXState<T> createState() => GetXState<T>();
}

/// The state for the [GetX] widget.
///
/// Manages the lifecycle of the controller and rebuilds the child widget whenever the controller changes.
class GetXState<T extends GetLifeCycleMixin> extends State<GetX<T>> {
  T? controller;
  bool? _isCreator = false;

  @override
  void initState() {
    // var isPrepared = Get.isPrepared<T>(tag: widget.tag);
    final isRegistered = Get.isRegistered<T>(tag: widget.tag);

    if (widget.global) {
      if (isRegistered) {
        _isCreator = Get.isPrepared<T>(tag: widget.tag);
        controller = Get.find<T>(tag: widget.tag);
      } else {
        controller = widget.init;
        _isCreator = true;
        Get.put<T>(controller!, tag: widget.tag);
      }
    } else {
      controller = widget.init;
      _isCreator = true;
      controller?.onStart();
    }
    widget.initState?.call(this);
    if (widget.global && Get.smartManagement == SmartManagement.onlyBuilder) {
      controller?.onStart();
    }

    super.initState();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (widget.didChangeDependencies != null) {
      widget.didChangeDependencies!(this);
    }
  }

  @override
  void didUpdateWidget(GetX oldWidget) {
    super.didUpdateWidget(oldWidget as GetX<T>);
    widget.didUpdateWidget?.call(oldWidget, this);
  }

  @override
  void dispose() {
    if (widget.dispose != null) widget.dispose!(this);
    if (_isCreator! || widget.assignId) {
      if (widget.autoRemove && Get.isRegistered<T>(tag: widget.tag)) {
        Get.delete<T>(tag: widget.tag);
      }
    }

    for (final disposer in disposers) {
      disposer();
    }

    disposers.clear();

    controller = null;
    _isCreator = null;
    super.dispose();
  }

  void _update() {
    if (mounted) {
      setState(() {});
    }
  }

  final disposers = <Disposer>[];

  @override
  Widget build(BuildContext context) => Notifier.instance.append(
      NotifyData(disposers: disposers, updater: _update),
      () => widget.builder(controller!),);

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(DiagnosticsProperty<T>("controller", controller));
  }
}
