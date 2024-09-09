import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:refreshed/get_core/get_core.dart';
import 'package:refreshed/get_instance/src/instance_extension.dart';
import 'package:refreshed/get_instance/src/lifecycle.dart';
import 'package:refreshed/get_state_manager/src/simple/list_notifier.dart';

/// A typedef for a function that builds a widget based on a [GetX] controller.
///
/// This typedef defines the signature of a builder function that takes a [T] controller,
/// which extends [GetLifeCycleMixin], and returns a [Widget].
typedef GetXControllerBuilder<T extends GetLifeCycleMixin> = Widget Function(
    T controller);

/// A widget that manages the lifecycle of a [GetX] controller and rebuilds
/// its child widget whenever the controller's state changes.
///
/// The [GetX] widget is designed to work with controllers that extend [GetLifeCycleMixin].
/// It manages the lifecycle of the controller and updates its child widget when the controller's state changes.
class GetX<T extends GetLifeCycleMixin> extends StatefulWidget {
  /// Constructs a [GetX] widget.
  ///
  /// [builder] is required and must not be null. It is used to build the widget
  /// based on the controller's state.
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
  final T? init;

  /// An optional tag to identify the controller when registered globally.
  final String? tag;

  @override
  StatefulElement createElement() => StatefulElement(this);

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties
      ..add(DiagnosticsProperty<T>('controller', init))
      ..add(DiagnosticsProperty<String>('tag', tag))
      ..add(
          ObjectFlagProperty<GetXControllerBuilder<T>>.has('builder', builder))
      ..add(DiagnosticsProperty<bool>('global', global))
      ..add(DiagnosticsProperty<bool>('autoRemove', autoRemove))
      ..add(DiagnosticsProperty<bool>('assignId', assignId))
      ..add(ObjectFlagProperty<void Function(GetXState<T>)?>.has(
          'initState', initState))
      ..add(ObjectFlagProperty<void Function(GetXState<T>)?>.has(
          'dispose', dispose))
      ..add(ObjectFlagProperty<void Function(GetXState<T>)?>.has(
          'didChangeDependencies', didChangeDependencies))
      ..add(ObjectFlagProperty<void Function(GetX<T>, GetXState<T>)?>.has(
          'didUpdateWidget', didUpdateWidget));
  }

  @override
  GetXState<T> createState() => GetXState<T>();
}

/// The state for the [GetX] widget.
///
/// Manages the lifecycle of the controller and rebuilds the child widget
/// whenever the controller's state changes.
class GetXState<T extends GetLifeCycleMixin> extends State<GetX<T>> {
  T? controller;
  bool? _isCreator = false;
  final List<Disposer> disposers = <Disposer>[];

  @override
  void initState() {
    super.initState();

    if (widget.global) {
      final bool isRegistered = Get.isRegistered<T>(tag: widget.tag);

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
    if (widget.dispose != null) {
      widget.dispose!(this);
    }

    if (_isCreator! || widget.assignId) {
      if (widget.autoRemove && Get.isRegistered<T>(tag: widget.tag)) {
        Get.delete<T>(tag: widget.tag);
      }
    }

    for (final Disposer disposer in disposers) {
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

  @override
  Widget build(BuildContext context) {
    return Notifier.instance.append(
      NotifyData(disposers: disposers, updater: _update),
      () => widget.builder(controller!),
    );
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties
      ..add(DiagnosticsProperty<T>('controller', controller))
      ..add(IterableProperty<Disposer>('disposers', disposers));
  }
}
