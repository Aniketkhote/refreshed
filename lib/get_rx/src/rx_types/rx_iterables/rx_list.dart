part of '../rx_types.dart';

/// A reactive list that extends functionality similar to `List<T>` and provides automatic notifications on changes.
class RxList<E> extends GetListenable<List<E>>
    with ListMixin<E>, RxObjectMixin<List<E>> {
  /// Constructs an RxList.
  ///
  /// Optionally, an initial list can be provided.
  RxList([List<E> initial = const []])
      : super(initial.isNotEmpty ? initial : List<E>.empty(growable: true));

  /// Constructs an RxList filled with a [fill] value.
  factory RxList.filled(int length, E fill, {bool growable = false}) {
    return RxList(List.filled(length, fill, growable: growable));
  }

  /// Constructs an empty RxList.
  ///
  /// If [growable] is true, the list is growable; otherwise, it's fixed-length.
  factory RxList.empty({bool growable = false}) {
    return RxList(List.empty(growable: growable));
  }

  /// Constructs an RxList containing all [elements].
  ///
  /// If [growable] is true, the list is growable; otherwise, it's fixed-length.
  factory RxList.from(Iterable elements, {bool growable = true}) {
    return RxList(List.from(elements, growable: growable));
  }

  /// Constructs an RxList from [elements].
  ///
  /// If [growable] is true, the list is growable; otherwise, it's fixed-length.
  factory RxList.of(Iterable<E> elements, {bool growable = true}) {
    return RxList(List.of(elements, growable: growable));
  }

  /// Constructs an RxList by generating values.
  ///
  /// If [growable] is true, the list is growable; otherwise, it's fixed-length.
  factory RxList.generate(int length, E Function(int index) generator,
      {bool growable = true}) {
    return RxList(List.generate(length, generator, growable: growable));
  }

  /// Constructs an unmodifiable RxList containing all [elements].
  factory RxList.unmodifiable(Iterable<E> elements) {
    return RxList(List.unmodifiable(elements));
  }

  @override
  Iterator<E> get iterator => value.iterator;

  @override
  void operator []=(int index, E val) {
    value[index] = val;
    refresh();
  }

  /// Special override to push element(s) in a reactive way inside the list.
  @override
  RxList<E> operator +(Iterable<E> val) {
    addAll(val);
    // refresh();
    return this;
  }

  @override
  E operator [](int index) {
    return value[index];
  }

  @override
  void add(E element) {
    value.add(element);
    refresh();
  }

  @override
  void addAll(Iterable<E> iterable) {
    value.addAll(iterable);
    refresh();
  }

  @override
  bool remove(Object? element) {
    final removed = value.remove(element);
    refresh();
    return removed;
  }

  @override
  void removeWhere(bool Function(E element) test) {
    value.removeWhere(test);
    refresh();
  }

  @override
  void retainWhere(bool Function(E element) test) {
    value.retainWhere(test);
    refresh();
  }

  @override
  int get length => value.length;

  @override
  set length(int newLength) {
    value.length = newLength;
    refresh();
  }

  @override
  void insertAll(int index, Iterable<E> iterable) {
    value.insertAll(index, iterable);
    refresh();
  }

  @override
  Iterable<E> get reversed => value.reversed;

  @override
  Iterable<E> where(bool Function(E) test) {
    return value.where(test);
  }

  @override
  Iterable<T> whereType<T>() {
    return value.whereType<T>();
  }

  @override
  void sort([int Function(E a, E b)? compare]) {
    value.sort(compare);
    refresh();
  }
}

extension ListExtension<E> on List<E> {
  /// Converts a List<E> into an RxList<E>.
  RxList<E> get obs => RxList<E>(this);

  /// Add [item] to [List<E>] only if [item] is not null.
  ///
  /// If [item] is not null, it is added to the list.
  void addNonNull(E item) {
    if (item != null) add(item);
  }

  /// Add [item] to List<E> only if [condition] is true.
  ///
  /// If [condition] is a boolean value and evaluates to true, [item] is added to the list.
  void addIf(dynamic condition, E item) {
    if (condition is Condition) condition = condition();
    if (condition is bool && condition) add(item);
  }

  /// Adds [Iterable<E>] to [List<E>] only if [condition] is true.
  ///
  /// If [condition] is a boolean value and evaluates to true, [items] are added to the list.
  void addAllIf(dynamic condition, Iterable<E> items) {
    if (condition is Condition) condition = condition();
    if (condition is bool && condition) addAll(items);
  }

  /// Replaces all existing items of this list with [item].
  ///
  /// Clears the list and adds [item].
  void assign(E item) {
    if (this is RxList) {
      (this as RxList).value.clear();
    }
    add(item);
  }

  /// Replaces all existing items of this list with [items].
  ///
  /// Clears the list and adds all elements from [items].
  void assignAll(Iterable<E> items) {
    if (this is RxList) {
      (this as RxList).value.clear();
    }
    //clear();
    addAll(items);
  }
}
