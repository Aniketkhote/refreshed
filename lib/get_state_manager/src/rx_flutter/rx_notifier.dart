import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:refreshed/utils.dart';

import '../../../get_rx/src/rx_types/rx_types.dart';
import '../../../instance_manager.dart';
import '../../get_state_manager.dart';
import '../simple/list_notifier.dart';

extension _Empty on Object {
  /// Checks if the object is empty.
  ///
  /// Returns `true` if the object is `null`, an empty `Iterable`, an empty `String`, or an empty `Map`.
  bool _isEmpty() {
    final val = this;
    var result = false;
    if (val is Iterable) {
      result = val.isEmpty;
    } else if (val is String) {
      result = val.trim().isEmpty;
    } else if (val is Map) {
      result = val.isEmpty;
    }
    return result;
  }
}

/// A mixin that provides state management capabilities.
mixin StateMixin<T> on ListNotifier {
  T? _value;
  GetStatus<T>? _status;

  void _fillInitialStatus() {
    _status = (_value == null || _value!._isEmpty())
        ? GetStatus<T>.loading()
        : GetStatus<T>.success(_value as T);
  }

  /// Gets the current status of the state.
  GetStatus<T> get status {
    reportRead();
    return _status ??= _status = GetStatus.loading();
  }

  /// Gets the current state.
  T get state => value;

  /// Sets the status of the state.
  set status(GetStatus<T> newStatus) {
    if (newStatus == status) return;
    _status = newStatus;
    if (newStatus is SuccessStatus<T>) {
      _value = newStatus.data!;
    }
    refresh();
  }

  @protected
  T get value {
    reportRead();
    return _value as T;
  }

  @protected
  set value(T newValue) {
    if (_value == newValue) return;
    _value = newValue;
    refresh();
  }

  @protected
  void change(GetStatus<T> status) {
    if (status != this.status) {
      this.status = status;
    }
  }

  /// Fetches data asynchronously and updates the state accordingly.
  ///
  /// The [body] function should return a `Future` which resolves to the new state.
  void futurize(Future<T> Function() body,
      {T? initialData, String? errorMessage, bool useEmpty = true}) {
    final compute = body;
    _value ??= initialData;
    compute().then((newValue) {
      if ((newValue == null || newValue._isEmpty()) && useEmpty) {
        status = GetStatus<T>.loading();
      } else {
        status = GetStatus<T>.success(newValue);
      }
      refresh();
    }, onError: (err) {
      status = GetStatus.error(errorMessage ?? err.toString());
      refresh();
    });
  }
}

/// A callback that returns a `Future`.
typedef FuturizeCallback<T> = Future<T> Function(VoidCallback fn);

/// A typedef representing a void callback.
typedef VoidCallback = void Function();

/// A class that provides listenable behavior similar to `ValueNotifier`.
class GetListenable<T> extends ListNotifierSingle implements RxInterface<T> {
  GetListenable(T val) : _value = val;

  StreamController<T>? _controller;

  /// The subject stream controller for broadcasting updates.
  StreamController<T> get subject {
    if (_controller == null) {
      _controller =
          StreamController<T>.broadcast(onCancel: addListener(_streamListener));
      _controller?.add(_value);

      ///TODO: report to controller dispose
    }
    return _controller!;
  }

  void _streamListener() {
    _controller?.add(_value);
  }

  @override
  @mustCallSuper
  void close() {
    removeListener(_streamListener);
    _controller?.close();
    dispose();
  }

  /// The stream of values.
  Stream<T> get stream {
    return subject.stream;
  }

  T _value;

  @override
  T get value {
    reportRead();
    return _value;
  }

  void _notify() {
    refresh();
  }

  set value(T newValue) {
    if (_value == newValue) return;
    _value = newValue;
    _notify();
  }

  T? call([T? v]) {
    if (v != null) {
      value = v;
    }
    return value;
  }

  @override
  StreamSubscription<T> listen(
    void Function(T)? onData, {
    Function? onError,
    void Function()? onDone,
    bool? cancelOnError,
  }) =>
      stream.listen(
        onData,
        onError: onError,
        onDone: onDone,
        cancelOnError: cancelOnError ?? false,
      );

  @override
  String toString() => value.toString();
}

/// A class similar to `ValueNotifier` with additional state management capabilities.
class Value<T> extends ListNotifier
    with StateMixin<T>
    implements ValueListenable<T?> {
  Value(T val) {
    _value = val;
    _fillInitialStatus();
  }

  @override
  T get value {
    reportRead();
    return _value as T;
  }

  @override
  set value(T newValue) {
    if (_value == newValue) return;
    _value = newValue;
    refresh();
  }

  T? call([T? v]) {
    if (v != null) {
      value = v;
    }
    return value;
  }

  void update(T Function(T? value) fn) {
    value = fn(value);
    // refresh();
  }

  @override
  String toString() => value.toString();

  dynamic toJson() => (value as dynamic)?.toJson();
}

/// A class representing a state notifier with a Get lifecycle.
///
/// Extends [Value] and implements [GetLifeCycleMixin].
abstract class GetNotifier<T> extends Value<T> with GetLifeCycleMixin {
  GetNotifier(super.initial);
}

/// Extension methods for the [StateMixin] class.
extension StateExt<T> on StateMixin<T> {
  /// Builds a widget based on the current state.
  ///
  /// This method provides a convenient way to build widgets based on the state's status.
  /// It takes a [NotifierBuilder] function as a parameter, which defines the widget to be built based on the state's value.
  Widget obx(
    NotifierBuilder<T?> widget, {
    Widget Function(String? error)? onError,
    Widget? onLoading,
    Widget? onEmpty,
    WidgetBuilder? onCustom,
  }) {
    return Observer(builder: (_) {
      if (status.isLoading) {
        return onLoading ?? const Center(child: CircularProgressIndicator());
      } else if (status.isError) {
        return onError != null
            ? onError(status.errorMessage)
            : Center(child: Text('An error occurred: ${status.errorMessage}'));
      } else if (status.isEmpty) {
        return onEmpty ??
            const SizedBox.shrink(); // Also can be widget(null); but is risky
      } else if (status.isSuccess) {
        return widget(value);
      } else if (status.isCustom) {
        return onCustom?.call(_) ??
            const SizedBox.shrink(); // Also can be widget(null); but is risky
      }
      return widget(value);
    });
  }
}

/// A builder function for creating widgets based on a state.
typedef NotifierBuilder<T> = Widget Function(T state);

/// A class representing the status of a state.
abstract class GetStatus<T> with Equality {
  const GetStatus();

  factory GetStatus.loading() => LoadingStatus<T>();

  factory GetStatus.error(String message) => ErrorStatus<T, String>(message);

  factory GetStatus.empty() => EmptyStatus<T>();

  factory GetStatus.success(T data) => SuccessStatus<T>(data);

  factory GetStatus.custom() => CustomStatus<T>();
}

/// A custom status indicating that the state is in a custom state.
class CustomStatus<T> extends GetStatus<T> {
  @override
  List get props => [];
}

/// A status indicating that the state is currently loading.
class LoadingStatus<T> extends GetStatus<T> {
  @override
  List get props => [];
}

/// A status indicating that the state has encountered an error.
class ErrorStatus<T, S> extends GetStatus<T> {
  final S? error;

  const ErrorStatus([this.error]);

  @override
  List get props => [error];
}

/// A status indicating that the state is empty.
class EmptyStatus<T> extends GetStatus<T> {
  @override
  List get props => [];
}

/// Extension methods for the [GetStatus] class.
extension StatusDataExt<T> on GetStatus<T> {
  /// Checks if the status indicates that the state is loading.
  bool get isLoading => this is LoadingStatus;

  /// Checks if the status indicates that the state is successful.
  bool get isSuccess => this is SuccessStatus;

  /// Checks if the status indicates that the state has encountered an error.
  bool get isError => this is ErrorStatus;

  /// Checks if the status indicates that the state is empty.
  bool get isEmpty => this is EmptyStatus;

  /// Checks if the status is a custom status.
  bool get isCustom => !isLoading && !isSuccess && !isError && !isEmpty;

  /// Gets the error message associated with the status.
  String get errorMessage {
    final isError = this is ErrorStatus;
    if (isError) {
      final err = this as ErrorStatus;
      if (err.error != null && err.error is String) {
        return err.error as String;
      }
    }
    return '';
  }

  /// Gets the data associated with the status if it is a success status.
  T? get data {
    if (this is SuccessStatus<T>) {
      final success = this as SuccessStatus<T>;
      return success.data;
    }
    return null;
  }
}

/// A status indicating that the state has been successfully updated with data of type `T`.
class SuccessStatus<T> extends GetStatus<T> {
  /// The data associated with the success status.
  final T data;

  /// Constructs a [SuccessStatus] with the given [data].
  const SuccessStatus(this.data);

  @override
  List get props => [data];
}
