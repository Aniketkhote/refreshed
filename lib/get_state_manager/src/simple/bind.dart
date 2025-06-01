import 'package:flutter/material.dart';

import '../../../refreshed.dart';
import 'bind_interface.dart';

/// Abstract class representing a binding widget responsible for managing a specific type of controller.
abstract class Bind<T> extends StatelessWidget implements BindInterface<T> {
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
  @override
  final InitBuilder<T>? init;

  /// Flag indicating whether the controller should be treated as global.
  @override
  final bool global;

  /// Identifier for the widget.
  @override
  final Object? id;

  /// Tag for the widget.
  @override
  final String? tag;

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

  /// Child widget that will receive the provided bindings.
  final Widget? child;

  /// Creates a binding and puts the specified dependency into the GetX service locator.
  ///
  /// This method immediately instantiates the dependency and registers it.
  /// Use this when you need the dependency to be created right away.
  ///
  /// Parameters:
  /// - [dependency]: The instance to register
  /// - [tag]: Optional tag for identifying this specific instance
  /// - [permanent]: If true, the instance won't be removed on widget disposal
  ///
  /// Returns a binding widget that can be used in the widget tree.
  static Bind<S> put<S>(
    S dependency, {
    String? tag,
    bool permanent = false,
  }) {
    // Register the dependency with GetX
    Get.put<S>(dependency, tag: tag, permanent: permanent);

    // Return a factory binding with appropriate settings
    return _FactoryBind<S>(
      autoRemove: !permanent, // Invert permanent to get autoRemove behavior
      assignId: true,
      tag: tag,
    );
  }

  /// Creates a lazy binding and registers a builder function in the GetX service locator.
  ///
  /// The dependency will only be created when it's requested for the first time.
  /// Use this to defer instantiation until the dependency is actually needed.
  ///
  /// Parameters:
  /// - [builder]: Function that creates the dependency when needed
  /// - [tag]: Optional tag for identifying this specific instance
  /// - [fenix]: If true, the instance will be recreated after it's been deleted
  /// - [onClose]: Optional callback to run when the instance is removed
  ///
  /// Returns a binding widget that can be used in the widget tree.
  static Bind<S> lazyPut<S>(
    InstanceBuilderCallback<S> builder, {
    String? tag,
    bool fenix = false,
    VoidCallback? onClose,
  }) {
    // Register the lazy builder with GetX
    Get.lazyPut<S>(builder, tag: tag, fenix: fenix);

    // Return a factory binding with appropriate settings
    return _FactoryBind<S>(
      tag: tag,
      dispose: switch (onClose) {
        null => null,
        var callback => (_) => callback()
      },
    );
  }

  /// Creates a binding with a custom factory function.
  ///
  /// This is the most flexible binding method as it allows you to
  /// create a dependency with a custom factory function without registering
  /// it in the global GetX service locator.
  ///
  /// Parameters:
  /// - [builder]: Function that creates the dependency
  /// - [autoRemove]: If true, the instance will be removed on widget disposal
  /// - [assignId]: If true, an ID will be assigned to the instance
  /// - [tag]: Optional tag for identifying this specific instance
  ///
  /// Returns a binding widget that can be used in the widget tree.
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

  /// Creates a binding and puts the specified dependency into the GetX service locator
  /// with a custom lifecycle.
  ///
  /// This method is similar to [put], but it creates a non-global instance
  /// that follows a custom lifecycle management approach.
  ///
  /// Parameters:
  /// - [builder]: Function that creates the dependency
  /// - [tag]: Optional tag for identifying this specific instance
  /// - [permanent]: If true, the instance won't be removed on widget disposal
  ///
  /// Returns a binding widget that can be used in the widget tree.
  static Bind<S> spawn<S>(
    InstanceBuilderCallback<S> builder, {
    String? tag,
    bool permanent = true,
  }) {
    // Register the dependency with GetX using spawn
    Get.spawn<S>(builder, tag: tag, permanent: permanent);

    // Return a factory binding with appropriate settings
    return _FactoryBind<S>(
      tag: tag,
      global: false, // Spawn creates non-global instances
      autoRemove: !permanent, // Invert permanent to get autoRemove behavior
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

  /// Replaces an existing dependency with a new instance.
  ///
  /// This method preserves the permanence status of the original instance
  /// when replacing it with the new one.
  ///
  /// Parameters:
  /// - [child]: The new instance to replace the existing one
  /// - [tag]: Optional tag to identify the specific instance to replace
  ///
  /// Throws an exception if the instance is not found.
  static Future<void> replace<P>(P child, {String? tag}) async {
    try {
      // Get instance info to determine if it should be permanent
      final info = Get.getInstanceInfo<P>(tag: tag);
      final permanent = info.isPermanent ?? false;

      // Delete existing instance and put the new one
      final deleted = await delete<P>(tag: tag, force: permanent);
      if (!deleted) {
        throw BindError<String>(
          controller:
              "Failed to delete existing instance before replacement for ${P.toString()}",
          tag: tag,
        );
      }

      // Register the new instance with the same permanence status
      Get.put(child, tag: tag, permanent: permanent);
    } catch (e) {
      // Rethrow with more context if it's not already a BindError
      if (e is! BindError) {
        // Create a new error with the available information
        throw BindError<String>(
          controller:
              "Error replacing instance of type ${P.toString()}: ${e.toString()}",
          tag: tag,
        );
      }
      rethrow;
    }
  }

  /// Lazily replaces an existing dependency with a new builder function.
  ///
  /// This method preserves the permanence status of the original instance
  /// when replacing it with the new lazy builder.
  ///
  /// Parameters:
  /// - [builder]: Function that creates the dependency when needed
  /// - [tag]: Optional tag to identify the specific instance to replace
  /// - [fenix]: If provided, overrides the original fenix setting
  ///
  /// Throws an exception if the instance is not found.
  static Future<void> lazyReplace<P>(
    InstanceBuilderCallback<P> builder, {
    String? tag,
    bool? fenix,
  }) async {
    try {
      // Get instance info to determine if it should be permanent
      final info = Get.getInstanceInfo<P>(tag: tag);
      final permanent = info.isPermanent ?? false;

      // Delete existing instance
      final deleted = await delete<P>(tag: tag, force: permanent);
      if (!deleted) {
        throw BindError<String>(
          controller:
              "Failed to delete existing instance before lazy replacement for ${P.toString()}",
          tag: tag,
        );
      }

      // Register the new lazy builder with appropriate fenix setting
      Get.lazyPut(
        builder,
        tag: tag,
        fenix: switch (fenix) {
          null =>
            permanent, // Default to permanent status if fenix not specified
          var value => value // Use provided value if specified
        },
      );
    } catch (e) {
      // Rethrow with more context if it's not already a BindError
      if (e is! BindError) {
        // Create a new error with the available information
        throw BindError<String>(
          controller:
              "Error replacing instance with lazy builder for type ${P.toString()}: ${e.toString()}",
          tag: tag,
        );
      }
      rethrow;
    }
  }

  /// Retrieves the dependency of type [T] from the nearest ancestor [Binder] widget.
  ///
  /// This method looks up the widget tree for a [Binder] widget of the specified type
  /// and returns its controller. It's the primary way to access dependencies from the widget tree.
  ///
  /// Parameters:
  /// - [context]: The build context to search from
  /// - [rebuild]: If true, the widget will rebuild when the controller changes
  ///
  /// Returns the controller of type [T].
  ///
  /// Throws a [BindError] if no matching [Binder] is found in the widget tree.
  static T of<T>(
    BuildContext context, {
    bool rebuild = false,
  }) {
    // Get the element for the nearest Binder of type T
    final element = context.getElementForInheritedWidgetOfExactType<Binder<T>>()
        as BindElement<T>?;

    // Use pattern matching to handle the result
    return switch (element) {
      // If no element is found, throw a descriptive error
      null => throw BindError<String>(
          controller: "No Binder for type $T found in the widget tree",
        ),

      // If element is found, optionally register for rebuilds and return the controller
      var found => () {
          // If rebuild is requested, register for dependency notifications
          if (rebuild) {
            context.dependOnInheritedElement(found);
          }
          return found.controller;
        }()
    };
  }

  // Factory method to create a copy of this binding with a different child widget
  Bind<T> _copyWithChild(Widget child);
}

class _FactoryBind<T> extends Bind<T> {
  const _FactoryBind({
    super.key,
    super.child,
    super.init,
    this.create,
    super.global = true,
    super.autoRemove = true,
    super.assignId = false,
    super.initState,
    super.filter,
    super.tag,
    super.dispose,
    super.id,
    super.didChangeDependencies,
    super.didUpdateWidget,
  });

  /// Factory function to create a controller instance with build context.
  final InstanceCreateBuilderCallback<T>? create;

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
