import "dart:async";

/// A utility class for executing microtasks sequentially.
///
/// Microtasks added using [exec] will be executed sequentially in the order they were added.
/// Each microtask is represented by a [Function] callback provided to [exec].
/// Microtasks are executed asynchronously using [scheduleMicrotask].
class GetMicrotask {
  int _version = 0;
  int _microtask = 0;

  /// The current microtask version number.
  int get microtask => _microtask;

  /// The current version number.
  int get version => _version;

  /// Executes the provided [callback] as a microtask.
  ///
  /// If no other microtask is currently being executed (based on the current microtask version),
  /// the [callback] will be scheduled as a microtask using [scheduleMicrotask].
  /// Once the microtask is executed, the microtask version number is incremented.
  void exec(Function callback) {
    if (_microtask == _version) {
      _microtask++;
      scheduleMicrotask(() {
        _version++;
        _microtask = _version;
        callback();
      });
    }
  }
}

/// A utility class for managing a queue of asynchronous jobs.
///
/// Jobs added using [add] will be executed sequentially in the order they were added.
/// Each job is represented by a [Function] that returns a [Future].
/// The result of each job's future is stored in a [Completer].
/// Jobs are executed asynchronously using [Future] and [Completer].
class GetQueue<T> {
  final List<_Item<T>> _queue = <_Item<T>>[];
  bool _active = false;

  /// Adds a job to the queue and returns its result as a future.
  ///
  /// The provided [job] function is added to the queue of jobs to be executed.
  /// A [Completer] is used to obtain the result of the job as a future.
  Future<T> add(Function job) {
    final Completer<T> completer = Completer<T>();
    _queue.add(_Item<T>(completer, job));
    _check();
    return completer.future;
  }

  /// Cancels all jobs in the queue.
  ///
  /// Clears the queue of pending jobs, preventing them from being executed.
  void cancelAllJobs() {
    _queue.clear();
  }

  /// Checks and executes the next job in the queue if the queue is not empty and no other job is currently active.
  ///
  /// This method is called recursively after each job is executed to continue processing the queue.
  Future<void> _check() async {
    if (!_active && _queue.isNotEmpty) {
      _active = true;
      final _Item<T> item = _queue.removeAt(0);
      try {
        item.completer.complete(await item.job());
      } on Exception catch (e) {
        item.completer.completeError(e);
      }
      _active = false;
      await _check();
    }
  }
}

/// Represents an item in the job queue with its associated completer and job function.
class _Item<T> {
  /// Constructs an item with the given completer and job.
  _Item(this.completer, this.job);
  final Completer<T> completer;
  final Function job;
}
