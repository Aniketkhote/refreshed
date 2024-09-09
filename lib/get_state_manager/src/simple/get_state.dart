import "dart:async";

import "package:flutter/material.dart";
import "package:refreshed/refreshed.dart";

/// Signature for a function that creates an object of type `T`.
typedef InitBuilder<T> = T Function();

/// Signature for a function that builds a widget with a controller of type `T`.
typedef GetControllerBuilder<T extends GetLifeCycleMixin> = Widget Function(
  T controller,
);

/// Extension methods for accessing state in the context of a widget build.
extension StateAccessExtension on BuildContext {
  /// Listens for state changes of type `T` and rebuilds the widget when it changes.
  ///
  /// This method is used to listen for changes to a specific state type `T` and rebuilds
  /// the widget whenever the state changes.
  T listen<T>() => Bind.of(this, rebuild: true);

  /// Gets the current value of state of type `T` without rebuilding the widget.
  ///
  /// This method is used to get the current value of a specific state type `T` without
  /// triggering a widget rebuild.
  T get<T>() => Bind.of(this);
}

/// A widget that builds itself based on the latest value of a [GetxController].
///
/// The [GetBuilder] widget listens to changes in a specified [GetxController],
/// and rebuilds its child widget whenever the controller changes its state.
class GetBuilder<T extends GetxController> extends StatelessWidget {
  /// Constructs a [GetBuilder] widget.
  const GetBuilder({
    required this.builder,
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

  /// A function that builds the widget based on the latest state of the controller.
  final GetControllerBuilder<T> builder;

  /// A flag indicating whether the controller should be treated as global.
  final bool global;

  /// An identifier for the widget.
  final Object? id;

  /// A tag for the widget.
  final String? tag;

  /// A flag indicating whether the widget should be automatically removed when disposed.
  final bool autoRemove;

  /// A flag indicating whether an identifier should be assigned to the widget.
  final bool assignId;

  /// A function that filters the value of the controller.
  final Object Function(T value)? filter;

  /// A callback function that is called when the widget is initialized.
  final void Function(BindElement<T> state)? initState;

  /// A callback function that is called when the widget is disposed.
  final Function(BindElement<T> state)? dispose;

  /// A callback function that is called when the widget's dependencies change.
  final Function(BindElement<T> state)? didChangeDependencies;

  /// A callback function that is called when the widget is updated.
  final void Function(Binder<T> oldWidget, BindElement<T> state)?
      didUpdateWidget;

  /// An initial value for the controller.
  final T? init;

  @override
  Widget build(BuildContext context) => Binder<T>(
        init: init == null ? null : () => init!,
        global: global,
        autoRemove: autoRemove,
        assignId: assignId,
        initState: initState,
        filter: filter,
        tag: tag,
        dispose: dispose,
        id: id,
        lazy: false,
        didChangeDependencies: didChangeDependencies,
        didUpdateWidget: didUpdateWidget,
        child: Builder(
          builder: (BuildContext context) {
            final T controller = Bind.of<T>(context, rebuild: true);
            return builder(controller);
          },
        ),
      );
}

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
    bool fenix = true,
    VoidCallback? onClose,
  }) {
    Get.lazyPut<S>(builder, tag: tag, fenix: fenix);
    return _FactoryBind<S>(
      tag: tag,
      dispose: (_) {
        onClose?.call();
      },
    );
  }

  /// Creates a binding and puts the specified dependency into the GetX service locator.
  ///
  /// Returns the binding created.
  static Bind<dynamic> create<S>(
    InstanceCreateBuilderCallback<S> builder, {
    String? tag,
    bool permanent = true,
  }) =>
      _FactoryBind<S>(
        create: builder,
        tag: tag,
        global: false,
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
  static Future<void> deleteAll({bool force = false}) async =>
      Get.deleteAll(force: force);

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
    final InstanceInfo info = Get.getInstanceInfo<P>(tag: tag);
    final bool permanent = info.isPermanent ?? false;
    await delete<P>(tag: tag, force: permanent);
    Get.put(child, tag: tag, permanent: permanent);
  }

  /// Lazily replaces the specified child widget with a new one.
  static Future<void> lazyReplace<P>(
    InstanceBuilderCallback<P> builder, {
    String? tag,
    bool? fenix,
  }) async {
    final InstanceInfo info = Get.getInstanceInfo<P>(tag: tag);
    final bool permanent = info.isPermanent ?? false;
    await delete<P>(tag: tag, force: permanent);
    Get.lazyPut(builder, tag: tag, fenix: fenix ?? permanent);
  }

  /// Retrieves the dependency of type [T] from the nearest ancestor [Binder] widget.
  static T of<T>(
    BuildContext context, {
    bool rebuild = false,
    // Object Function(T value)? filter,
  }) {
    final BindElement<T>? inheritedElement =
        context.getElementForInheritedWidgetOfExactType<Binder<T>>()
            as BindElement<T>?;

    if (inheritedElement == null) {
      throw BindError<String>(controller: "$T");
    }

    if (rebuild) {
      context.dependOnInheritedElement(inheritedElement);
    }

    final T controller = inheritedElement.controller;

    return controller;
  }

  @factory
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
  Widget build(BuildContext context) => Binder<T>(
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
        child: child!,
      );
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
  Widget build(BuildContext context) => binds.reversed
      .fold(child, (Widget widget, Bind<S> e) => e._copyWithChild(widget));
}

/// An inherited widget that updates its dependents when the controller sends notifications.
class Binder<T> extends InheritedWidget {
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
  final InitBuilder<T>? init;

  /// Function to create an instance of the controller.
  final InstanceCreateBuilderCallback? create;

  /// Flag indicating whether the controller should be treated as global.
  final bool global;

  /// Identifier for the widget.
  final Object? id;

  /// Tag for the widget.
  final String? tag;

  /// Flag indicating whether the binding should be lazy.
  final bool lazy;

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

  @override
  bool updateShouldNotify(Binder<T> oldWidget) =>
      oldWidget.id != id ||
      oldWidget.global != global ||
      oldWidget.autoRemove != autoRemove ||
      oldWidget.assignId != assignId;

  @override
  InheritedElement createElement() => BindElement<T>(this);
}

/// The BindElement is responsible for injecting dependencies into the widget
/// tree so that they can be observed.
class BindElement<T> extends InheritedElement {
  /// Creates a [BindElement] associated with the given [Binder].
  BindElement(Binder<T> super.widget) {
    initState();
  }

  /// List of disposer functions.
  final List<Disposer> disposers = <Disposer>[];

  InitBuilder<T>? _controllerBuilder;

  T? _controller;

  /// Getter for the controller instance.
  T get controller {
    if (_controller == null) {
      _controller = _controllerBuilder?.call();
      _subscribeToController();
      if (_controller == null) {
        throw BindError<String>(controller: "$T", tag: widget.tag);
      }
      return _controller!;
    } else {
      return _controller!;
    }
  }

  bool? _isCreator = false;
  bool? _needStart = false;
  bool _wasStarted = false;
  VoidCallback? _remove;
  Object? _filter;

  void initState() {
    widget.initState?.call(this);

    final bool isRegistered = Get.isRegistered<T>(tag: widget.tag);

    if (widget.global) {
      if (isRegistered) {
        if (Get.isPrepared<T>(tag: widget.tag)) {
          _isCreator = true;
        } else {
          _isCreator = false;
        }

        _controllerBuilder = () => Get.find<T>(tag: widget.tag);
      } else {
        _controllerBuilder =
            () => (widget.create?.call(this) ?? widget.init?.call()) as T;
        _isCreator = true;
        if (widget.lazy) {
          Get.lazyPut<T>(_controllerBuilder!, tag: widget.tag);
        } else {
          Get.put<T>(_controllerBuilder!(), tag: widget.tag);
        }
      }
    } else {
      if (widget.create != null) {
        _controllerBuilder = () => widget.create!.call(this) as T;
        Get.spawn<T>(_controllerBuilder!, tag: widget.tag, permanent: false);
      } else {
        _controllerBuilder = widget.init;
      }
      _controllerBuilder = (widget.create != null
              ? () => widget.create!.call(this) as T
              : null) ??
          widget.init;
      _isCreator = true;
      _needStart = true;
    }
  }

  /// Register to listen Controller's events.
  /// It gets a reference to the remove() callback, to delete the
  /// setState "link" from the Controller.
  void _subscribeToController() {
    if (widget.filter != null) {
      _filter = widget.filter!(controller);
    }
    final void Function() filter = _filter != null ? _filterUpdate : getUpdate;
    final T? localController = _controller;

    if (_needStart! && localController is GetLifeCycleMixin) {
      localController.onStart();
      _needStart = false;
      _wasStarted = true;
    }

    if (localController is GetxController) {
      _remove?.call();
      _remove = (widget.id == null)
          ? localController.addListener(filter)
          : localController.addListenerId(widget.id, filter);
    } else if (localController is Listenable) {
      _remove?.call();
      localController.addListener(filter);
      _remove = () => localController.removeListener(filter);
    } else if (localController is StreamController<T>) {
      _remove?.call();
      final StreamSubscription<T> stream =
          localController.stream.listen((_) => filter());
      _remove = stream.cancel;
    }
  }

  void _filterUpdate() {
    final Object newFilter = widget.filter!(controller);
    if (newFilter != _filter) {
      _filter = newFilter;
      getUpdate();
    }
  }

  /// Disposes the resources associated with this element.
  void dispose() {
    widget.dispose?.call(this);
    if (_isCreator! || widget.assignId) {
      if (widget.autoRemove && Get.isRegistered<T>(tag: widget.tag)) {
        Get.delete<T>(tag: widget.tag);
      }
    }

    for (final Disposer disposer in disposers) {
      disposer();
    }

    disposers.clear();

    _remove?.call();
    _controller = null;
    _isCreator = null;
    _remove = null;
    _filter = null;
    _needStart = null;
    _controllerBuilder = null;
    _controller = null;
  }

  @override
  Binder<T> get widget => super.widget as Binder<T>;

  bool _dirty = false;

  @override
  void update(Binder<T> newWidget) {
    final Object? oldNotifier = widget.id;
    final Object? newNotifier = newWidget.id;
    if (oldNotifier != newNotifier && _wasStarted) {
      _subscribeToController();
    }
    widget.didUpdateWidget?.call(widget, this);
    super.update(newWidget);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    widget.didChangeDependencies?.call(this);
  }

  @override
  Widget build() {
    if (_dirty) {
      notifyClients(widget);
    }

    return super.build();
  }

  /// Marks the widget as dirty and schedules a rebuild.
  ///
  /// This method sets the `_dirty` flag to `true`, indicating that the widget needs to be updated.
  /// It then schedules a rebuild of the widget by calling [markNeedsBuild()].
  void getUpdate() {
    _dirty = true;
    markNeedsBuild();
  }

  @override
  void notifyClients(Binder<T> oldWidget) {
    super.notifyClients(oldWidget);
    _dirty = false;
  }

  @override
  void unmount() {
    dispose();
    super.unmount();
  }
}

/// A class representing an error encountered during binding resolution.
class BindError<T> extends Error {
  /// Creates a [BindError] with the provided controller and optional tag.
  BindError({required this.controller, this.tag});

  /// The type of the class the user tried to retrieve.
  final T controller;

  /// An optional tag associated with the binding.
  final String? tag;

  @override
  String toString() {
    final type = T.toString();
    if (type == "dynamic") {
      return """Error: please specify type [<T>] when calling context.listen<T>() or context.find<T>() method.""";
    }

    return """Error: No Bind<$type> ancestor found. To fix this, please add a Bind<$type> widget ancestor to the current context.""";
  }
}

/// [Binding] should be extended.
/// When using `GetMaterialApp`, all `GetPage`s and navigation
/// methods (like Get.to()) have a `binding` property that takes an
/// instance of Bindings to manage the
/// dependencies() (via Get.put()) for the Route you are opening.
// ignore: one_member_abstracts
abstract class Binding<T> extends BindingsInterface<List<Bind<T>>> {}
