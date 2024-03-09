import "dart:async";

import 'package:refreshed/get_core/src/get_interface.dart';

/// Extension providing additional loop event methods for GetInterface.
extension LoopEventsExt on GetInterface {
  /// Delays the execution of the given computation until the end of the event loop.
  ///
  /// Useful for ensuring that certain computations are executed after the current event loop has completed.
  ///
  /// Example:
  /// ```dart
  /// await Get.toEnd(() async {
  ///   // Some asynchronous computation
  /// });
  /// ```
  Future<T> toEnd<T>(FutureOr<T> Function() computation) async {
    await Future.delayed(Duration.zero);
    final val = computation();
    return val;
  }

  /// Executes the given computation as soon as possible, optionally based on a condition.
  ///
  /// If the [condition] is provided and evaluates to `true`, the computation will be executed immediately.
  /// Otherwise, it will be executed after the current event loop has completed.
  ///
  /// Example:
  /// ```dart
  /// await Get.asap(() {
  ///   // Some synchronous computation
  /// });
  /// ```
  /// If a condition is provided:
  /// ```dart
  /// await Get.asap(() {
  ///   // Some synchronous computation
  /// }, condition: () {
  ///   // Some condition
  ///   return true; // Execute the computation immediately
  /// });
  /// ```
  FutureOr<T> asap<T>(T Function() computation,
      {bool Function()? condition,}) async {
    T val;
    if (condition == null || !condition()) {
      await Future.delayed(Duration.zero);
      val = computation();
    } else {
      val = computation();
    }
    return val;
  }
}
