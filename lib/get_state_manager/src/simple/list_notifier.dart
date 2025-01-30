import "dart:collection";

import "package:flutter/foundation.dart";
import "package:refreshed/refreshed.dart";

/// This callback removes the listener when called.
typedef Disposer = void Function();

/// Replaces StateSetter, returning whether the Widget is mounted for extra validation.
/// If this brings overhead, consider removing the extra call.
typedef GetStateUpdate = void Function();

/// A notifier that supports both single and grouped listeners.
class ListNotifier extends Listenable
    with ListNotifierSingleMixin, ListNotifierGroupMixin {}

/// A Notifier that supports single listeners.
class ListNotifierSingle extends ListNotifier with ListNotifierSingleMixin {}

/// A Notifier that supports a group of listeners identified by an ID.
class ListNotifierGroup extends ListNotifier with ListNotifierGroupMixin {}

/// This mixin adds listener management capabilities to Listenable.
mixin ListNotifierSingleMixin on Listenable {
  List<GetStateUpdate>? _updaters = <GetStateUpdate>[];

  /// Adds a listener and returns a [Disposer] to remove it later.
  @override
  Disposer addListener(GetStateUpdate listener) {
    assert(_debugAssertNotDisposed());
    _updaters!.add(listener);
    return () => _updaters!.remove(listener);
  }

  /// Checks if a given listener is already registered.
  bool containsListener(GetStateUpdate listener) =>
      _updaters?.contains(listener) ?? false;

  /// Removes a registered listener.
  @override
  void removeListener(VoidCallback listener) {
    assert(_debugAssertNotDisposed());
    _updaters!.remove(listener);
  }

  /// Notifies all registered listeners of an update.
  @protected
  void refresh() {
    assert(_debugAssertNotDisposed());
    _notifyUpdate();
  }

  /// Reports that a read operation has occurred.
  @protected
  void reportRead() {
    Notifier.instance.read(this);
  }

  /// Reports a new listener addition.
  @protected
  void reportAdd(VoidCallback disposer) {
    Notifier.instance.add(disposer);
  }

  void _notifyUpdate() {
    final List<GetStateUpdate> list = _updaters?.toList() ?? <GetStateUpdate>[];
    for (final GetStateUpdate element in list) {
      element();
    }
  }

  /// Checks if the notifier has been disposed.
  bool get isDisposed => _updaters == null;

  bool _debugAssertNotDisposed() {
    assert(() {
      if (isDisposed) {
        throw FlutterError("A $runtimeType was used after being disposed.\n"
            "Once you have called dispose() on a $runtimeType, "
            "it can no longer be used.");
      }
      return true;
    }());
    return true;
  }

  /// Returns the number of active listeners.
  int get listenersLength {
    assert(_debugAssertNotDisposed());
    return _updaters!.length;
  }

  /// Disposes of the notifier, preventing further updates.
  @mustCallSuper
  void dispose() {
    assert(_debugAssertNotDisposed());
    _updaters = null;
  }
}

/// A mixin for managing a group of listeners identified by an ID.
mixin ListNotifierGroupMixin on Listenable {
  HashMap<Object?, ListNotifierSingleMixin>? _updatersGroupIds =
      HashMap<Object?, ListNotifierSingleMixin>();

  void _notifyGroupUpdate(Object id) {
    if (_updatersGroupIds!.containsKey(id)) {
      _updatersGroupIds![id]!._notifyUpdate();
    }
  }

  /// Notifies all children of a given group ID.
  @protected
  void notifyGroupChildren(Object id) {
    assert(_debugAssertNotDisposed());
    Notifier.instance.read(_updatersGroupIds![id]!);
  }

  /// Checks if a specific ID exists in the group.
  bool containsId(Object id) => _updatersGroupIds?.containsKey(id) ?? false;

  /// Refreshes all listeners associated with a specific ID.
  @protected
  void refreshGroup(Object id) {
    assert(_debugAssertNotDisposed());
    _notifyGroupUpdate(id);
  }

  bool _debugAssertNotDisposed() {
    assert(() {
      if (_updatersGroupIds == null) {
        throw FlutterError("A $runtimeType was used after being disposed.\n"
            "Once you have called dispose() on a $runtimeType, "
            "it can no longer be used.");
      }
      return true;
    }());
    return true;
  }

  /// Removes a specific listener from a group by ID.
  void removeListenerId(Object id, VoidCallback listener) {
    assert(_debugAssertNotDisposed());
    if (_updatersGroupIds!.containsKey(id)) {
      _updatersGroupIds![id]!.removeListener(listener);
    }
  }

  /// Disposes all listeners in the group.
  @mustCallSuper
  void dispose() {
    assert(_debugAssertNotDisposed());
    _updatersGroupIds?.forEach(
      (Object? key, ListNotifierSingleMixin value) => value.dispose(),
    );
    _updatersGroupIds = null;
  }

  /// Adds a listener to a specific group ID.
  Disposer addListenerId(Object? key, GetStateUpdate listener) {
    _updatersGroupIds![key] ??= ListNotifierSingle();
    return _updatersGroupIds![key]!.addListener(listener);
  }

  /// Disposes of a specific ID from future updates.
  void disposeId(Object id) {
    _updatersGroupIds?[id]?.dispose();
    _updatersGroupIds!.remove(id);
  }
}

/// A class responsible for managing notifications and listeners.
class Notifier {
  /// Constructs a [Notifier] instance.
  Notifier._();

  /// Singleton instance of [Notifier].
  static Notifier? _instance;

  /// Singleton instance of [Notifier].
  static Notifier get instance => _instance ??= Notifier._();

  NotifyData? _notifyData;

  /// Adds a listener to the list of disposers.
  void add(VoidCallback listener) {
    _notifyData?.disposers.add(listener);
  }

  /// Reads data from the provided [updaters] and adds listeners accordingly.
  void read(ListNotifierSingleMixin updaters) {
    final GetStateUpdate? listener = _notifyData?.updater;
    if (listener != null && !updaters.containsListener(listener)) {
      updaters.addListener(listener);
      add(() => updaters.removeListener(listener));
    }
  }

  /// Appends data to the provided [data] and executes the [builder] function.
  T append<T>(NotifyData data, T Function() builder) {
    _notifyData = data;
    final T result = builder();
    if (data.disposers.isEmpty && data.throwException) {
      throw ObxError();
    }
    _notifyData = null;
    return result;
  }
}

/// Data class containing information about notifications and listeners.
class NotifyData {
  /// Constructs a [NotifyData] instance.
  const NotifyData({
    required this.updater,
    required this.disposers,
    this.throwException = true,
  });

  /// Function that updates the state.
  final GetStateUpdate updater;

  /// List of disposers.
  final List<VoidCallback> disposers;

  /// Flag indicating whether to throw an exception if no disposers are present.
  final bool throwException;
}
