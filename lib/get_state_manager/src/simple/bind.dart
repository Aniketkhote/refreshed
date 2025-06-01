import 'package:flutter/material.dart';

import '../../../refreshed.dart';

/// Abstract class representing a binding widget responsible for managing a specific type of controller.
abstract class Bind<T> extends StatelessWidget {
  /// Constructs a [Bind] widget.
  const Bind({
    required this.child,
    super.key,
    this.init,
    this.global = true,
    this.autoRemove = true,
    this.assignId = false,
    this.initState,
    this.filter,
    this.tag,
    this.dispose,
    this.id,
    this.didChangeDependencies,
    this.didUpdateWidget,
  });

  /// Factory method to create a [Bind] widget using a builder pattern.
  factory Bind.builder({
    Widget? child,
    InitBuilder<T>? init,
    InstanceCreateBuilderCallback<T>? create,
    bool global = true,
    bool autoRemove = true,
    bool assignId = false,
    Object Function(T value)? filter,
    String? tag,
    Object? id,
    void Function(BindElement<T> state)? initState,
    void Function(BindElement<T> state)? dispose,
    void Function(BindElement<T> state)? didChangeDependencies,
    void Function(Binder<T> oldWidget, BindElement<T> state)? didUpdateWidget,
  }) =>
      _FactoryBind<T>(
        init: init,
        create: create,
        global: global,
        autoRemove: autoRemove,
        assignId: assignId,
        initState: initState,
        filter: filter,
        tag: tag,
        dispose: dispose,
        id: id,
        didChangeDependencies: didChangeDependencies,
        didUpdateWidget: didUpdateWidget,
        child: child,
      );

  /// Function to initialize the controller.
  final InitBuilder<T>? init;

  /// Flag indicating whether the controller should be treated as global.
  final bool global;

  /// Identifier for the widget.
  final Object? id;

  /// Tag for the widget.
  final String? tag;

  /// Flag indicating whether the widget should be automatically removed when disposed.
  final bool autoRemove;

  /// Flag indicating whether an identifier should be assigned to the widget.
  final bool assignId;

  /// Function to filter the value of the controller.
  final Object Function(T value)? filter;

  /// Callback function that is called when the widget is initialized.
  final void Function(BindElement<T> state)? initState;

  /// Callback function that is called when the widget is disposed.
  final Function(BindElement<T> state)? dispose;

  /// Callback function that is called when the widget's dependencies change.
  final Function(BindElement<T> state)? didChangeDependencies;

  /// Callback function that is called when the widget is updated.
  final void Function(Binder<T> oldWidget, BindElement<T> state)?
      didUpdateWidget;

  /// Child widget that will receive the provided bindings.
  final Widget? child;

  /// Creates a binding and puts the specified dependency into the GetX service locator.
  ///
  /// Returns the binding created.
  static Bind<dynamic> put<S>(
    S dependency, {
    String? tag,
    bool permanent = false,
  }) {
    Get.put<S>(dependency, tag: tag, permanent: permanent);
    return _FactoryBind<S>(
      autoRemove: permanent,
      assignId: true,
      tag: tag,
    );
  }

  /// Creates a lazy binding and puts the specified dependency into the GetX service locator.
  ///
  /// Returns the binding created.
  static Bind<dynamic> lazyPut<S>(
    InstanceBuilderCallback<S> builder, {
    String? tag,
    bool fenix = false,
    VoidCallback? onClose,
  }) {
    Get.lazyPut<S>(builder, tag: tag, fenix: fenix);
    return _FactoryBind<S>(
      tag: tag,
      dispose: switch (onClose) {
        null => null,
        var callback => (_) => callback()
      },
    );
  }

  /// Creates a binding with the specified controller factory.
  /// This is a more flexible way to create a binding, as it allows you to
  /// specify a custom factory function.
  static Bind<S> factory<S>(
    InstanceBuilderCallback<S> builder, {
    bool autoRemove = true,
    bool assignId = true,
    String? tag,
  }) =>
      _FactoryBind<S>(
        init: () => builder(),
        autoRemove: autoRemove,
        assignId: assignId,
        tag: tag,
      );

  /// Creates a binding and puts the specified dependency into the GetX service locator.
  ///
  /// Returns the binding created.
  static Bind<dynamic> spawn<S>(
    InstanceBuilderCallback<S> builder, {
    String? tag,
    bool permanent = true,
  }) {
    Get.spawn<S>(builder, tag: tag, permanent: permanent);
    return _FactoryBind<S>(
      tag: tag,
      global: false,
      autoRemove: permanent,
    );
  }

  /// Retrieves a dependency from the GetX service locator using the specified tag.
  static S find<S>({String? tag}) => Get.find<S>(tag: tag);

  /// Deletes a dependency from the GetX service locator using the specified tag.
  static Future<bool> delete<S>({String? tag, bool force = false}) async =>
      Get.delete<S>(tag: tag, force: force);

  /// Deletes all dependencies from the GetX service locator.
  static Future<void> deleteAll({bool force = false}) async {
    Get.deleteAll(force: force);
  }

  /// Reloads all dependencies from the GetX service locator.
  static void reloadAll({bool force = false}) => Get.reloadAll(force: force);

  /// Reloads a dependency from the GetX service locator using the specified tag.
  static void reload<S>({String? tag, String? key, bool force = false}) =>
      Get.reload<S>(tag: tag, key: key, force: force);

  /// Checks if a dependency is registered in the GetX service locator using the specified tag.
  static bool isRegistered<S>({String? tag}) => Get.isRegistered<S>(tag: tag);

  /// Checks if a dependency is prepared in the GetX service locator using the specified tag.
  static bool isPrepared<S>({String? tag}) => Get.isPrepared<S>(tag: tag);

  /// Replaces the specified child widget with a new one.
  static Future<void> replace<P>(P child, {String? tag}) async {
    final info = Get.getInstanceInfo<P>(tag: tag);
    final permanent = info.isPermanent ?? false;

    // Delete existing instance and put the new one
    await delete<P>(tag: tag, force: permanent);
    Get.put(child, tag: tag, permanent: permanent);
  }

  /// Lazily replaces the specified child widget with a new one.
  static Future<void> lazyReplace<P>(
    InstanceBuilderCallback<P> builder, {
    String? tag,
    bool? fenix,
  }) async {
    // Get instance info and determine if it should be permanent
    final info = Get.getInstanceInfo<P>(tag: tag);
    final permanent = info.isPermanent ?? false;

    // Delete existing instance and register the new lazy builder
    await delete<P>(tag: tag, force: permanent);
    Get.lazyPut(builder,
        tag: tag,
        fenix: switch (fenix) { null => permanent, var value => value });
  }

  /// Retrieves the dependency of type [T] from the nearest ancestor [Binder] widget.
  static T of<T>(
    BuildContext context, {
    bool rebuild = false,
    // Object Function(T value)? filter,
  }) =>
      switch (context.getElementForInheritedWidgetOfExactType<Binder<T>>()
          as BindElement<T>?) {
        null => throw BindError<String>(controller: "$T"),
        var element => () {
            if (rebuild) context.dependOnInheritedElement(element);
            return element.controller;
          }()
      };

  // Factory method to create a copy of this binding with a different child widget
  Bind<T> _copyWithChild(Widget child);
}

class _FactoryBind<T> extends Bind<T> {
  const _FactoryBind({
    super.key,
    this.child,
    this.init,
    this.create,
    this.global = true,
    this.autoRemove = true,
    this.assignId = false,
    this.initState,
    this.filter,
    this.tag,
    this.dispose,
    this.id,
    this.didChangeDependencies,
    this.didUpdateWidget,
  }) : super(child: child);

  @override
  final InitBuilder<T>? init;

  final InstanceCreateBuilderCallback<T>? create;

  @override
  final bool global;
  @override
  final Object? id;
  @override
  final String? tag;
  @override
  final bool autoRemove;
  @override
  final bool assignId;
  @override
  final Object Function(T value)? filter;

  @override
  final void Function(BindElement<T> state)? initState;
  @override
  final Function(BindElement<T> state)? dispose;
  @override
  final Function(BindElement<T> state)? didChangeDependencies;
  @override
  final void Function(Binder<T> oldWidget, BindElement<T> state)?
      didUpdateWidget;

  @override
  final Widget? child;

  @override
  Bind<T> _copyWithChild(Widget child) => Bind<T>.builder(
        init: init,
        create: create,
        global: global,
        autoRemove: autoRemove,
        assignId: assignId,
        initState: initState,
        filter: filter,
        tag: tag,
        dispose: dispose,
        id: id,
        didChangeDependencies: didChangeDependencies,
        didUpdateWidget: didUpdateWidget,
        child: child,
      );

  @override
  Widget build(BuildContext context) => switch ((create, child)) {
        (final createFn?, _) => createFn(context) is Widget
            ? createFn(context) as Widget
            : const SizedBox.shrink(),
        (_, final childWidget?) => childWidget,
        _ => const SizedBox.shrink(),
      };
}

/// A widget responsible for managing a list of bindings and providing them to its child widget.
class Binds<S> extends StatelessWidget {
  /// Constructs a [Binds] widget with the provided bindings and child widget.
  Binds({
    required this.binds,
    required this.child,
    super.key,
  }) : assert(binds.isNotEmpty, "binds should not be empty");

  /// A list of bindings to be provided to the child widget.
  final List<Bind<S>> binds;

  /// The child widget that will receive the provided bindings.
  final Widget child;

  @override
  Widget build(BuildContext context) => binds.reversed.fold(
        child,
        (widget, bind) => bind._copyWithChild(widget),
      );
}
