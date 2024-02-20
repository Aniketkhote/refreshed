import 'dart:async';

import '../../../utils.dart';

extension GetNumUtils on num {
  /// Checks if this number is lower than the given [b].
  bool isLowerThan(num b) => GetUtils.isLowerThan(this, b);

  /// Checks if this number is greater than the given [b].
  bool isGreaterThan(num b) => GetUtils.isGreaterThan(this, b);

  /// Checks if this number is equal to the given [b].
  bool isEqual(num b) => GetUtils.isEqual(this, b);

  /// Delays the execution of a callback or code block by the specified number of seconds.
  ///
  /// The [callback] parameter is an optional function that will be executed after
  /// the specified delay. If provided, it will be called asynchronously once the
  /// delay has completed.
  ///
  /// Example:
  /// ```dart
  /// void main() async {
  ///   print('+ wait for 2 seconds');
  ///   await 2.delay();
  ///   print('- 2 seconds completed');
  ///   print('+ callback in 1.2sec');
  ///   1.delay(() => print('- 1.2sec callback called'));
  ///   print('currently running callback 1.2sec');
  /// }
  ///```
  ///
  /// The above example waits for 2 seconds before printing '- 2 seconds completed'.
  /// It then waits for an additional 1.2 seconds before executing the callback
  /// that prints '- 1.2sec callback called'. Finally, it prints 'currently running
  /// callback 1.2sec'.
  Future delay([FutureOr Function()? callback]) async {
    final completer = Completer<void>();
    Timer(Duration(milliseconds: (this * 1000).round()), () {
      if (!completer.isCompleted) {
        completer.complete();
        callback?.call();
      }
    });
    return completer.future;
  }
}
