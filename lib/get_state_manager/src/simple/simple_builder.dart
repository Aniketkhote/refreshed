import 'dart:async';

import 'package:flutter/widgets.dart';

import 'list_notifier.dart';

/// A callback function that is called when the value builder updates its value.
typedef ValueBuilderUpdateCallback<T> = void Function(T snapshot);

/// A function that builds a widget based on the current value and an updater function.
typedef ValueBuilderBuilder<T> = Widget Function(
  T snapshot,
  ValueBuilderUpdateCallback<T> updater,
);

/// Manages a local state like ObxValue, but uses a callback instead of
/// a Rx value.
///
/// Example:
/// ```
///  ValueBuilder<bool>(
///    initialValue: false,
///    builder: (value, update) => Switch(
///    value: value,
///    onChanged: (flag) {
///       update(flag);
///    },),
///    onUpdate: (value) => print("Value updated: $value"),
///  ),
///  ```
class ValueBuilder<T> extends StatefulWidget {
  /// The initial value of the state managed by the ValueBuilder.
  final T initialValue;

  /// The builder function that constructs the widget based on the current value and an updater function.
  final ValueBuilderBuilder<T> builder;

  /// A function that is called when the ValueBuilder is disposed.
  final void Function()? onDispose;

  /// A function that is called when the value managed by the ValueBuilder is updated.
  final void Function(T)? onUpdate;

  const ValueBuilder({
    super.key,
    required this.initialValue,
    this.onDispose,
    this.onUpdate,
    required this.builder,
  });

  @override
  ValueBuilderState<T> createState() => ValueBuilderState<T>();
}

/// The state associated with the ValueBuilder widget.
class ValueBuilderState<T> extends State<ValueBuilder<T>> {
  late T _value;

  @override
  void initState() {
    _value = widget.initialValue;
    super.initState();
  }

  @override
  Widget build(BuildContext context) => widget.builder(_value, _updater);

  /// An updater function that updates the value managed by the ValueBuilder.
  void _updater(T newValue) {
    if (widget.onUpdate != null) {
      widget.onUpdate!(newValue);
    }
    setState(() {
      _value = newValue;
    });
  }

  @override
  void dispose() {
    super.dispose();
    widget.onDispose?.call();
  }
}

/// A wrapper around a [StatelessElement] that enables observation of changes in the stateless widget's reactive dependencies.
///
/// This element extends [StatelessElement] to provide additional functionality for observing changes using GetX's reactive programming capabilities.
class ObxElement = StatelessElement with StatelessObserverComponent;

/// It's an experimental feature.
class Observer extends ObxStatelessWidget {
  final WidgetBuilder builder;

  const Observer({super.key, required this.builder});

  @override
  Widget build(BuildContext context) => builder(context);
}

/// A stateless widget that can listen to reactive changes.
abstract class ObxStatelessWidget extends StatelessWidget {
  /// Initializes [key] for subclasses.
  const ObxStatelessWidget({super.key});

  @override
  StatelessElement createElement() => ObxElement(this);
}

/// A component that can track changes in a reactive variable.
mixin StatelessObserverComponent on StatelessElement {
  List<Disposer>? _disposers = <Disposer>[];

  void _getUpdate() {
    scheduleMicrotask(markNeedsBuild);
  }

  @override
  Widget build() {
    return Notifier.instance.append(
      NotifyData(disposers: _disposers!, updater: _getUpdate),
      super.build,
    );
  }

  @override
  void unmount() {
    super.unmount();
    for (final disposer in _disposers!) {
      disposer();
    }
    _disposers!.clear();
    _disposers = null;
  }
}
