import 'dart:async';

import 'package:flutter/material.dart';

import '../../../refreshed.dart';

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
  T get controller =>
      _controller ??
      (() {
        final instance = _controllerBuilder?.call();
        _controller = instance;
        _subscribeToController();
        return _controller ??
            (throw BindError<String>(controller: "$T", tag: widget.tag));
      })();

  bool? _isCreator = false;
  bool? _needStart = false;
  bool _wasStarted = false;
  VoidCallback? _remove;
  Object? _filter;

  void initState() {
    widget.initState?.call(this);

    final isRegistered = Get.isRegistered<T>(tag: widget.tag);

    if (widget.global) {
      switch ((isRegistered, widget.lazy)) {
        case (true, _):
          _isCreator = Get.isPrepared<T>(tag: widget.tag);
          _controllerBuilder = () => Get.find<T>(tag: widget.tag);

        case (false, true):
          _controllerBuilder =
              () => (widget.create?.call(this) ?? widget.init?.call()) as T;
          _isCreator = true;
          Get.lazyPut<T>(_controllerBuilder!, tag: widget.tag);

        case (false, false):
          _controllerBuilder =
              () => (widget.create?.call(this) ?? widget.init?.call()) as T;
          _isCreator = true;
          Get.put<T>(_controllerBuilder!(), tag: widget.tag);
      }
    } else {
      // For non-global controllers, handle creation and initialization
      _controllerBuilder = switch (widget.create) {
        var createFn? => () => createFn(this) as T,
        _ => widget.init
      };
      _isCreator = true;
      _needStart = true;
    }
  }

  /// Register to listen Controller's events.
  /// It gets a reference to the remove() callback, to delete the
  /// setState "link" from the Controller.
  void _subscribeToController() {
    // Apply filter if provided
    _filter = widget.filter?.call(controller);

    // Determine which update function to use based on filter
    final updateFn = _filter != null ? _filterUpdate : getUpdate;
    final localController = _controller;

    // Handle lifecycle for controllers that implement GetLifeCycleMixin
    if (_needStart == true && localController is GetLifeCycleMixin) {
      localController.onStart();
      _needStart = false;
      _wasStarted = true;
    }

    // Clean up previous subscription if any
    _remove?.call();

    // Set up new subscription based on controller type
    _remove = _setupControllerListener(localController, updateFn);
  }

  /// Sets up a listener for a GetxController.
  /// Returns a disposer function to remove the listener.
  Disposer? _setupGetxControllerListener(
      GetxController controller, VoidCallback updateFn) {
    return widget.id == null
        ? controller.addListener(updateFn)
        : controller.addListenerId(widget.id, updateFn);
  }

  /// Sets up a listener for a Listenable (like ChangeNotifier).
  /// Returns a disposer function to remove the listener.
  Disposer _setupListenableListener(
      Listenable listenable, VoidCallback updateFn) {
    listenable.addListener(updateFn);
    return () => listenable.removeListener(updateFn);
  }

  /// Sets up a listener for a StreamController.
  /// Returns a disposer function to cancel the subscription.
  Disposer _setupStreamControllerListener(
      StreamController<dynamic> streamController, VoidCallback updateFn) {
    final subscription = streamController.stream.listen((_) => updateFn());
    return subscription.cancel;
  }

  /// Sets up the appropriate listener based on the controller type.
  /// Returns a disposer function or null if the controller type is not supported.
  Disposer? _setupControllerListener(
      dynamic controller, VoidCallback updateFn) {
    if (controller is GetxController) {
      return _setupGetxControllerListener(controller, updateFn);
    } else if (controller is Listenable) {
      return _setupListenableListener(controller, updateFn);
    } else if (controller is StreamController) {
      return _setupStreamControllerListener(controller, updateFn);
    }
    return null;
  }

  void _filterUpdate() => switch (widget.filter?.call(controller)) {
        var newFilter when newFilter != _filter => {
            _filter = newFilter,
            getUpdate()
          },
        _ => null
      };

  /// Disposes the resources associated with this element.
  void dispose() {
    // Call custom dispose callback if provided
    widget.dispose?.call(this);

    // Clean up controller if this element created it or has assignId
    switch ((_isCreator == true || widget.assignId, widget.autoRemove)) {
      case (true, true) when Get.isRegistered<T>(tag: widget.tag):
        Get.delete<T>(tag: widget.tag);
      case _:
      // No action needed
    }

    // Execute all registered disposers and clear the list
    for (final disposer in disposers) {
      disposer();
    }
    disposers.clear();

    // Clean up listener
    _remove?.call();

    // Reset all fields
    _controller = null;
    _isCreator = null;
    _remove = null;
    _filter = null;
    _needStart = null;
    _controllerBuilder = null;
  }

  @override
  Binder<T> get widget => super.widget as Binder<T>;

  bool _dirty = false;

  @override
  void update(Binder<T> newWidget) {
    // Resubscribe if the ID changed and controller was started
    switch ((widget.id != newWidget.id, _wasStarted)) {
      case (true, true):
        _subscribeToController();
      case _:
      // No resubscription needed
    }

    // Call custom update callback if provided
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
  void getUpdate() => {_dirty = true, markNeedsBuild()};

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
