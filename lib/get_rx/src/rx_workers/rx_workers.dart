import "dart:async";

import "package:refreshed/get_core/get_core.dart";
import "package:refreshed/get_state_manager/src/rx_flutter/rx_notifier.dart";
import "package:refreshed/get_rx/src/rx_types/rx_types.dart";
import "package:refreshed/get_rx/src/rx_workers/utils/debouncer.dart";

/// A utility function to evaluate a condition and return a boolean value.
///
/// If [condition] is `null`, returns `true`. If [condition] is already a boolean value,
/// returns it as is. If [condition] is a function that returns a boolean value, invokes
/// the function and returns its result. Otherwise, returns `true`.
bool _conditional(dynamic condition) {
  if (condition == null) return true;
  if (condition is bool) return condition;
  if (condition is bool Function()) return condition();
  return true;
}

/// A typedef representing a callback function used by workers.
///
/// The [WorkerCallback] typedef defines a function signature that takes
/// a callback of type [T] as input.
typedef WorkerCallback<T> = Function(T callback);

/// A class for managing a collection of workers and disposing them when necessary.
class Workers {
  /// Constructs a new [Workers] instance with the provided [workers].
  Workers(this.workers);

  /// The list of workers to manage.
  final List<Worker> workers;

  /// Disposes all workers in the collection that have not already been disposed.
  void dispose() {
    for (final worker in workers) {
      if (!worker._disposed) {
        worker.dispose();
      }
    }
  }
}

///
/// Called every time [listener] changes. As long as the [condition]
/// returns true.
///
/// Sample:
/// Every time increment() is called, ever() will process the [condition]
/// (can be a [bool] expression or a `bool Function()`), and only call
/// the callback when [condition] is true.
/// In our case, only when count is bigger to 5. In order to "dispose"
/// this Worker
/// that will run forever, we made a `worker` variable. So, when the count value
/// reaches 10, the worker gets disposed, and releases any memory resources.
///
/// ```
/// // imagine some counter widget...
///
/// class _CountController extends GetxController {
///   final count = 0.obs;
///   Worker worker;
///
///   void onInit() {
///     worker = ever(count, (value) {
///       print('counter changed to: $value');
///       if (value == 10) worker.dispose();
///     }, condition: () => count > 5);
///   }
///
///   void increment() => count + 1;
/// }
/// ```
Worker ever<T>(
  GetListenable<T> listener,
  WorkerCallback<T> callback, {
  dynamic condition = true,
  Function? onError,
  void Function()? onDone,
  bool? cancelOnError,
}) {
  final StreamSubscription sub = listener.listen(
    (event) {
      if (_conditional(condition)) callback(event);
    },
    onError: onError,
    onDone: onDone,
    cancelOnError: cancelOnError,
  );
  return Worker(sub.cancel, "[ever]");
}

/// Similar to [ever], but takes a list of [listeners], the condition
/// for the [callback] is common to all [listeners],
/// and the [callback] is executed to each one of them. The [Worker] is
/// common to all, so `worker.dispose()` will cancel all streams.
Worker everAll(
  List<RxInterface> listeners,
  WorkerCallback callback, {
  dynamic condition = true,
  Function? onError,
  void Function()? onDone,
  bool? cancelOnError,
}) {
  final evers = <StreamSubscription>[];
  for (var i in listeners) {
    final sub = i.listen(
      (event) {
        if (_conditional(condition)) callback(event);
      },
      onError: onError,
      onDone: onDone,
      cancelOnError: cancelOnError,
    );
    evers.add(sub);
  }

  Future<void> cancel() async {
    for (var i in evers) {
      i.cancel();
    }
  }

  return Worker(cancel, "[everAll]");
}

/// `once()` will execute only 1 time when [condition] is met and cancel
/// the subscription to the [listener] stream right after that.
/// [condition] defines when [callback] is called, and
/// can be a [bool] or a `bool Function()`.
///
/// Sample:
/// ```
///  class _CountController extends GetxController {
///   final count = 0.obs;
///   Worker worker;
///
///   @override
///   Future<void> onInit() async {
///     worker = once(count, (value) {
///       print("counter reached $value before 3 seconds.");
///     }, condition: () => count() > 2);
///     3.delay(worker.dispose);
///   }
///   void increment() => count + 1;
/// }
///```
Worker once<T>(
  GetListenable<T> listener,
  WorkerCallback<T> callback, {
  dynamic condition = true,
  Function? onError,
  void Function()? onDone,
  bool? cancelOnError,
}) {
  late Worker ref;
  StreamSubscription? sub;
  sub = listener.listen(
    (event) {
      if (!_conditional(condition)) return;
      ref._disposed = true;
      ref._log("called");
      sub?.cancel();
      callback(event);
    },
    onError: onError,
    onDone: onDone,
    cancelOnError: cancelOnError,
  );
  ref = Worker(sub.cancel, "[once]");
  return ref;
}

/// Ignore all changes in [listener] during [time] (1 sec by default) or until
/// [condition] is met (can be a [bool] expression or a `bool Function()`),
/// It brings the 1st "value" since the period of time, so
/// if you click a counter button 3 times in 1 sec, it will show you "1"
/// (after 1 sec of the first press)
/// click counter 3 times in 1 sec, it will show you "4" (after 1 sec)
/// click counter 2 times in 1 sec, it will show you "7" (after 1 sec).
///
/// Sample:
/// // wait 1 sec each time an event starts, only if counter is lower than 20.
/// worker = interval(
///    count,
///    (value) => print(value),
///    time: 1.seconds,
///    condition: () => count < 20,
/// );
/// ```
Worker interval<T>(
  GetListenable<T> listener,
  WorkerCallback<T> callback, {
  Duration time = const Duration(seconds: 1),
  dynamic condition = true,
  Function? onError,
  void Function()? onDone,
  bool? cancelOnError,
}) {
  var debounceActive = false;
  final StreamSubscription sub = listener.listen(
    (event) async {
      if (debounceActive || !_conditional(condition)) return;
      debounceActive = true;
      await Future.delayed(time);
      debounceActive = false;
      callback(event);
    },
    onError: onError,
    onDone: onDone,
    cancelOnError: cancelOnError,
  );
  return Worker(sub.cancel, "[interval]");
}

/// [debounce] is similar to [interval], but sends the last value.
/// Useful for Anti DDos, every time the user stops typing for 1 second,
/// for instance.
/// When [listener] emits the last "value", when [time] hits,
/// it calls [callback] with the last "value" emitted.
///
/// Sample:
///
/// ```
/// worker = debounce(
///      count,
///      (value) {
///        print(value);
///        if( value > 20 ) worker.dispose();
///      },
///      time: 1.seconds,
///    );
///  }
///  ```
Worker debounce<T>(
  GetListenable<T> listener,
  WorkerCallback<T> callback, {
  Duration? time,
  Function? onError,
  void Function()? onDone,
  bool? cancelOnError,
}) {
  final newDebouncer =
      Debouncer(delay: time ?? const Duration(milliseconds: 800));
  final StreamSubscription sub = listener.listen(
    (event) {
      newDebouncer(() {
        callback(event);
      });
    },
    onError: onError,
    onDone: onDone,
    cancelOnError: cancelOnError,
  );
  return Worker(sub.cancel, "[debounce]");
}

/// A class representing a worker for executing asynchronous tasks with disposal functionality.
class Worker {
  /// Constructs a new [Worker] with the provided [worker] callback and [type].
  Worker(this.worker, this.type);

  /// Callback function representing the asynchronous task to be executed.
  final Future<void> Function() worker;

  /// Type of the worker (e.g., debounce, interval, ever).
  final String type;

  bool _disposed = false;

  /// Indicates whether the worker has been disposed.
  bool get disposed => _disposed;

  /// Internal logging method for debugging purposes.
  void _log(String msg) {
    //  if (!_verbose) return;
    Get.log("$runtimeType $type $msg");
  }

  /// Disposes of the worker, cancelling its associated asynchronous task.
  ///
  /// If the worker has already been disposed, this method does nothing.
  void dispose() {
    if (_disposed) {
      _log("already disposed");
      return;
    }
    _disposed = true;
    worker();
    _log("disposed");
  }

  /// Alias for the [dispose] method, allowing the [Worker] instance to be called directly for disposal.
  void call() => dispose();
}
