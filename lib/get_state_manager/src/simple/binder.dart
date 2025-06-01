import 'package:flutter/material.dart';

import '../../../get_instance/src/instance_extension.dart';
import 'bind_element.dart';
import 'bind_interface.dart';
import 'get_state.dart';

/// An inherited widget that updates its dependents when the controller sends notifications.
class Binder<T> extends InheritedWidget implements BindInterface<T> {
  /// Creates an inherited widget that updates its dependents when [controller] sends notifications.
  ///
  /// The [child] argument is required.
  const Binder({
    required super.child,
    super.key,
    this.init,
    this.create,
    this.global = true,
    this.autoRemove = true,
    this.assignId = false,
    this.lazy = true,
    this.initState,
    this.filter,
    this.tag,
    this.dispose,
    this.id,
    this.didChangeDependencies,
    this.didUpdateWidget,
  });

  /// Function to initialize the controller.
  @override
  final InitBuilder<T>? init;

  /// Function to create an instance of the controller.
  final InstanceCreateBuilderCallback? create;

  /// Flag indicating whether the controller should be treated as global.
  @override
  final bool global;

  /// Identifier for the widget.
  @override
  final Object? id;

  /// Tag for the widget.
  @override
  final String? tag;

  /// Flag indicating whether the binding should be lazy.
  final bool lazy;

  /// Flag indicating whether the widget should be automatically removed when disposed.
  @override
  final bool autoRemove;

  /// Flag indicating whether an identifier should be assigned to the widget.
  @override
  final bool assignId;

  /// Function to filter the value of the controller.
  @override
  final Object Function(T value)? filter;

  /// Callback function that is called when the widget is initialized.
  @override
  final void Function(BindElement<T> state)? initState;

  /// Callback function that is called when the widget is disposed.
  @override
  final Function(BindElement<T> state)? dispose;

  /// Callback function that is called when the widget's dependencies change.
  @override
  final Function(BindElement<T> state)? didChangeDependencies;

  /// Callback function that is called when the widget is updated.
  final void Function(Binder<T> oldWidget, BindElement<T> state)?
      didUpdateWidget;

  @override
  bool updateShouldNotify(Binder<T> oldWidget) => switch ((oldWidget, this)) {
        (var old, var current)
            when old.id != current.id ||
                old.global != current.global ||
                old.autoRemove != current.autoRemove ||
                old.assignId != current.assignId =>
          true,
        _ => false
      };

  @override
  InheritedElement createElement() => BindElement<T>(this);
}
