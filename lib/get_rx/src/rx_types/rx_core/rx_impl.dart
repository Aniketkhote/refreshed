part of "../rx_types.dart";

/// global object that registers against `GetX` and `Obx`, and allows the
/// reactivity
/// of those `Widgets` and Rx values.

mixin RxObjectMixin<T> on GetListenable<T> {
  @override
  T call([T? v]) {
    if (v case var val?) {
      value = val;
    }
    return value;
  }

  bool firstRebuild = true;
  bool sentToStream = false;

  /// Same as `toString()` but using a getter.
  String get string => value.toString();

  @override
  String toString() => value.toString();

  /// Returns the json representation of `value`.
  dynamic toJson() => value;

  /// This equality override works for _RxImpl instances and the internal
  /// values.
  @override
  // ignore: avoid_equals_and_hash_code_on_mutable_classes
  bool operator ==(Object o) {
    // Todo, find a common implementation for the hashCode of different Types.
    if (o is T) return value == o;
    if (o is RxObjectMixin<T>) return value == o.value;
    return false;
  }

  @override
  // ignore: avoid_equals_and_hash_code_on_mutable_classes
  int get hashCode => value.hashCode;

  /// Updates the [value] and adds it to the stream, updating the observer
  /// Widget, only if it's different from the previous value.
  @override
  set value(T val) {
    // Don't update if the object is disposed
    if (isDisposed) return;

    // If value hasn't changed or it's the first rebuild, just update the stream status
    if (value == val && !firstRebuild) {
      sentToStream = false;
      return;
    }

    // Otherwise update the value and mark as sent to stream
    sentToStream = true;
    firstRebuild = false;
    super.value = val;
  }

  /// Returns a [StreamSubscription] similar to [listen], but with the
  /// added benefit that it primes the stream with the current [value], rather
  /// than waiting for the next [value]. This should not be called in [onInit]
  /// or anywhere else during the build process.
  StreamSubscription<T> listenAndPump(
    void Function(T event) onData, {
    Function? onError,
    void Function()? onDone,
    bool? cancelOnError,
  }) {
    final subscription = listen(
      onData,
      onError: onError,
      onDone: onDone,
      cancelOnError: cancelOnError,
    );

    subject.add(value);
    return subscription;
  }

  /// Binds an existing `Stream<T>` to this `Rx<T>` to keep the values in sync.
  /// You can bind multiple sources to update the value.
  /// Closing the subscription will happen automatically when the observer
  /// Widget (`GetX` or `Obx`) gets unmounted from the Widget tree.
  void bindStream(Stream<T> stream) {
    final sub = stream.listen((val) => value = val);
    reportAdd(sub.cancel);
  }
}

/// Base Rx class that manages all the stream logic for any Type.
abstract class _RxImpl<T> extends GetListenable<T> with RxObjectMixin<T> {
  _RxImpl(super.initial);

  void addError(Object error, [StackTrace? stackTrace]) {
    subject.addError(error, stackTrace);
  }

  Stream<R> map<R>(R Function(T? data) mapper) => stream.map(mapper);

  /// Uses a callback to update [value] internally, similar to [refresh],
  /// but provides the current value as the argument.
  /// Makes sense for custom Rx types (like Models).
  ///
  /// Sample:
  /// ```
  ///  class Person {
  ///     String name, last;
  ///     int age;
  ///     Person({this.name, this.last, this.age});
  ///     @override
  ///     String toString() => '$name $last, $age years old';
  ///  }
  ///
  /// final person = Person(name: 'John', last: 'Doe', age: 18).obs;
  /// person.update((person) {
  ///   person.name = 'Roi';
  /// });
  /// print( person );
  /// ```
  void update(T Function(T val) fn) => value = fn(value);

  /// Following certain practices on Rx data, we might want to react to certain
  /// listeners when a value has been provided, even if the value is the same.
  /// At the moment, we ignore part of the process if we `.call(value)` with
  /// the same value since it holds the value and there's no real
  /// need triggering the entire process for the same value inside, but
  /// there are other situations where we might be interested in
  /// triggering this.
  ///
  /// For example, supposed we have a `int seconds = 2` and we want to animate
  /// from invisible to visible a widget in two seconds:
  /// `RxEvent<int>.call(seconds);`
  /// then after a click happens, you want to call a `RxEvent<int>.call(seconds)`.
  /// By doing `call(seconds)`, if the value being held is the same,
  /// the listeners won't trigger, hence we need this new `trigger` function.
  /// This will refresh the listener of an AnimatedWidget and will keep
  /// the value if the Rx is kept in memory.
  /// Sample:
  /// ```
  /// Rx<Int> secondsRx = RxInt();
  /// secondsRx.listen((value) => print("$value seconds set"));
  ///
  /// secondsRx.call(2);      // This won't trigger any listener, since the value is the same
  /// secondsRx.trigger(2);   // This will trigger the listener independently from the value.
  /// ```
  ///
  void trigger(T v) {
    final wasFirstRebuild = firstRebuild;
    value = v;
    // Only add to stream if not first rebuild and not already sent to stream
    if (!wasFirstRebuild && !sentToStream) {
      subject.add(v);
    }
  }
}

/// A foundation class that wraps a value of type [T] in a reactive container.
/// This class provides the ability to track and manage the state of the wrapped value.
class Rx<T> extends _RxImpl<T> {
  Rx(super.initial);

  @override
  dynamic toJson() => RxJsonUtils.safeToJson(value, T.toString());
}

/// A specialized version of [Rx] for nullable types ([T?]).
class Rxn<T> extends Rx<T?> {
  Rxn([super.initial]);

  @override
  dynamic toJson() => RxJsonUtils.safeToJson(value, T.toString());
}

/// Extension on [String] providing methods to create reactive strings.
extension StringExtension on String {
  /// Returns a `RxString` with [this] `String` as initial value.
  RxString get obs => RxString(this);
}

/// Extension on [int] providing methods to create reactive integers.
extension IntExtension on int {
  /// Returns a `RxInt` with [this] `int` as initial value.
  RxInt get obs => RxInt(this);
}

/// Extension on [double] providing methods to create reactive doubles.
extension DoubleExtension on double {
  /// Returns a `RxDouble` with [this] `double` as initial value.
  RxDouble get obs => RxDouble(this);
}

/// Extension on [bool] providing methods to create reactive booleans.
extension BoolExtension on bool {
  /// Returns a `RxBool` with [this] `bool` as initial value.
  RxBool get obs => RxBool(this);
}

/// Generic extension for creating reactive instances of any custom type [T].
extension RxT<T extends Object> on T {
  /// Returns a `Rx` instance with [this] `T` as initial value.
  Rx<T> get obs => Rx<T>(this);

  /// Returns a `Rx` instance with [this] `T` as initial value.
  /// This method is identical to the `obs` getter but allows for more
  /// explicit type specification when needed.
  Rx<T> toRx() => Rx<T>(this);
}

/// A new method to replace the old `.obs` getter. This method avoids conflicts with
/// Dart 3 features by using contextual type inference to determine [T].
extension RxTnew on Object {
  /// Returns a `Rx` instance with [this] `T` as initial value.
  /// This method is preferred over the `obs` getter as it avoids conflicts
  /// with Dart 3 features by using contextual type inference.
  Rx<T> obs<T>() => Rx<T>(this as T);
}
