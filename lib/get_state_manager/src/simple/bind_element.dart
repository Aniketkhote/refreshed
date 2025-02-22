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
