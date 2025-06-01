import "dart:async";

import "package:flutter/foundation.dart";
import "package:flutter/material.dart";
import "package:refreshed/get_rx/src/rx_types/rx_types.dart";
import "package:refreshed/get_state_manager/get_state_manager.dart";
import "package:refreshed/instance_manager.dart";
import "package:refreshed/utils.dart";

extension _Empty on Object {
  /// Checks if the object is empty.
  ///
  /// Returns `true` if the object is `null`, an empty `Iterable`, an empty `String`, or an empty `Map`.
  bool _isEmpty() => switch (this) {
    Iterable val => val.isEmpty,
    String val => val.trim().isEmpty,
    Map val => val.isEmpty,
    _ => false
  };
}

/// A mixin that provides state management capabilities.
mixin StateMixin<T> on ListNotifier {
  T? _value;
  GetStatus<T>? _status;

  void _fillInitialStatus() {
    _status = switch (_value) {
      null => GetStatus<T>.loading(),
      var val when val._isEmpty() => GetStatus<T>.loading(),
      var val => GetStatus<T>.success(val as T)
    };
  }

  /// Gets the current status of the state.
  GetStatus<T> get status {
    reportRead();
    return _status ??= GetStatus<T>.loading();
  }

  /// Gets the current state.
  T get state => value;

  /// Sets the status of the state.
  set status(GetStatus<T> newStatus) {
    if (newStatus == status) return;
    
    _status = newStatus;
    if (newStatus case SuccessStatus<T> success) {
      _value = success.data;
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
  void change(GetStatus<T> status) => 
      status != this.status ? this.status = status : null;

  /// Fetches data asynchronously and updates the state accordingly.
  ///
  /// The [body] function should return a `Future` which resolves to the new state.
  Future<void> futurize(
    Future<T> Function() body, {
    T? initialData,
    String? errorMessage,
  }) async {
    _value ??= initialData;

    try {
      final T newValue = await body();
      status = switch (newValue) {
        null => GetStatus<T>.loading(),
        var val when val._isEmpty() => GetStatus<T>.empty(),
        var val => GetStatus<T>.success(val)
      };
    } catch (error) {
      status = GetStatus<T>.error(errorMessage ?? error.toString());
    } finally {
      refresh();
    }
  }
}

/// A class that provides listenable behavior similar to `ValueNotifier`.
class GetListenable<T> extends ListNotifierSingle implements RxInterface<T> {
  GetListenable(T val) : _value = val;
  T _value;

  StreamController<T>? _controller;

  /// The subject stream controller for broadcasting updates.
  StreamController<T> get subject {
    _controller ??= StreamController<T>.broadcast(
        onCancel: addListener(_streamListener))..add(_value);
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
  Stream<T> get stream => subject.stream;

  @override
  T get value {
    reportRead();
    return _value;
  }

  void _notify() => refresh();

  set value(T newValue) => newValue == _value ? null : {
    _value = newValue,
    _notify()
  };

  T? call([T? v]) => switch (v) {
    var newValue? => (value = newValue, value),
    _ => value
  } as T?;

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
  /// Constructs a new `Value` with the provided initial value.
  Value(T val) {
    _value = val;
    _fillInitialStatus();
  }

  /// Retrieves the current value.
  @override
  T get value {
    reportRead();
    return _value as T;
  }

  /// Sets the new value and triggers a refresh if the value has changed.
  @override
  set value(T newValue) {
    if (_value == newValue) {
      return;
    }
    _value = newValue;
    refresh();
  }

  T? call([T? v]) => v != null ? (value = v) : value;

  T update(T Function(T? value) fn) => value = fn(_value);

  /// Returns a string representation of the current value.
  @override
  String toString() => value.toString();

  /// Converts the current value to JSON.
  ///
  /// This method assumes that the generic type `T` has a `toJson` method defined.
  dynamic toJson() => switch (value) {
    Map map => map,
    var val => (val as dynamic).toJson()
  };
}

/// A class representing a state notifier with a Get lifecycle.
///
/// Extends [Value] and implements [GetLifeCycleMixin].
abstract class GetNotifier<T> extends Value<T> with GetLifeCycleMixin {
  GetNotifier(super.val);
}

/// Extension methods for the [StateMixin] class.
extension StateExtension<T> on StateMixin<T> {
  /// Builds a widget based on the current state.
  ///
  /// This method provides a convenient way to build widgets based on the state's status.
  /// It takes a [NotifierBuilder] function as a parameter, which defines the widget to be built based on the state's value.
  Widget obx(
    NotifierBuilder<T> widget, {
    Widget Function(String? error)? onError,
    Widget? onLoading,
    Widget? onEmpty,
    WidgetBuilder? onCustom,
  }) =>
      Observer(
        builder: (context) => switch (status) {
          var s when s.isLoading => 
            onLoading ?? const Center(child: CircularProgressIndicator()),
          var s when s.isError => 
            onError != null
              ? onError(s.errorMessage)
              : Center(child: Text("An error occurred: ${s.errorMessage}")),
          var s when s.isEmpty => 
            onEmpty ?? const SizedBox.shrink(),
          var s when s.isSuccess => 
            widget(value),
          var s when s.isCustom => 
            onCustom?.call(context) ?? const SizedBox.shrink(),
          _ => widget(value)
        },
      );
}

/// A builder function for creating widgets based on a state.
typedef NotifierBuilder<T> = Widget Function(T state);

/// Represents the status of an asynchronous operation, such as loading, error, empty, success, or custom.
abstract class GetStatus<T> with Equality {
  /// Constructs a new instance of `GetStatus`.
  const GetStatus();

  /// Creates a loading status.
  factory GetStatus.loading() => LoadingStatus<T>();

  /// Creates an error status with the given error [message].
  factory GetStatus.error(String message) => ErrorStatus<T, String>(message);

  /// Creates an empty status.
  factory GetStatus.empty() => EmptyStatus<T>();

  /// Creates a success status with the provided [data].
  factory GetStatus.success(T data) => SuccessStatus<T>(data);

  /// Creates a custom status.
  factory GetStatus.custom() => CustomStatus<T>();
}

/// A custom status indicating that the state is in a custom state.
class CustomStatus<T> extends GetStatus<T> {
  @override
  List<T> get props => <T>[];
}

/// A status indicating that the state is currently loading.
class LoadingStatus<T> extends GetStatus<T> {
  @override
  List<T> get props => <T>[];
}

/// A status indicating that the state has encountered an error.
class ErrorStatus<T, S> extends GetStatus<T> {
  const ErrorStatus([this.error]);
  final S? error;

  @override
  List<S?> get props => <S?>[error];
}

/// A status indicating that the state is empty.
class EmptyStatus<T> extends GetStatus<T> {
  @override
  List<T> get props => <T>[];
}

/// Extension methods for the [GetStatus] class.
extension StatusDataExtension<T, S> on GetStatus<T> {
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

  dynamic get error => switch (this) {
    ErrorStatus err => err.error,
    _ => null
  };

  /// Gets the error message associated with the status.
  String get errorMessage => switch (this) {
    ErrorStatus<T, S> err when err.error != null => 
      err.error is String ? err.error as String : err.error.toString(),
    _ => ""
  };

  /// Gets the data associated with the status if it is a success status.
  T? get data => switch (this) {
    SuccessStatus<T> success => success.data,
    _ => null
  };
}

/// A status indicating that the state has been successfully updated with data of type `T`.
class SuccessStatus<T> extends GetStatus<T> {
  /// Constructs a [SuccessStatus] with the given [data].
  const SuccessStatus(this.data);

  /// The data associated with the success status.
  final T data;

  @override
  List<T> get props => <T>[data];
}
