import "dart:async";

/// A debouncer implementation that delays the execution of a function until a specified duration has passed.
///
/// Example:
/// ```dart
/// final delayed = Debouncer(delay: Duration(seconds: 1));
/// print('The next function will be called after 1 second');
/// delayed(() => print('Called after 1 second'));
/// ```
class Debouncer {
  /// Constructs a Debouncer with the specified delay duration.
  Debouncer({required this.delay});

  /// The duration to delay the function execution.
  final Duration delay;

  Timer? _timer;

  /// Calls the function after the specified delay duration.
  ///
  /// If another call is made before the delay duration has passed,
  /// the previous call is cancelled, and the timer is reset.
  void call(void Function() action) {
    _timer?.cancel();
    _timer = Timer(delay, action);
  }

  /// Returns `true` if a delayed call is currently active, otherwise `false`.
  bool get isRunning => _timer?.isActive ?? false;

  /// Cancels the current delayed call, if any.
  void cancel() => _timer?.cancel();
}
