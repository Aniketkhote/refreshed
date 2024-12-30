part of "../rx_types.dart";

class RxSet<E> extends GetListenable<Set<E>>
    with SetMixin<E>, RxObjectMixin<Set<E>> {
  RxSet([super.initial = const <Never>{}]);

  /// Special override to push() element(s) in a reactive way
  /// inside the List,
  RxSet<E> operator +(Set<E> val) {
    addAll(val);
    return this;
  }

  void update(void Function(Iterable<E>? value) fn) {
    fn(value);
    refresh();
  }

  @override
  bool add(E value) {
    final bool hasAdded = this.value.add(value);
    if (hasAdded) {
      refresh();
    }
    return hasAdded;
  }

  @override
  bool contains(Object? element) => value.contains(element);

  @override
  Iterator<E> get iterator => value.iterator;

  @override
  int get length => value.length;

  @override
  E? lookup(Object? element) => value.lookup(element);

  @override
  bool remove(Object? value) {
    final bool hasRemoved = this.value.remove(value);
    if (hasRemoved) {
      refresh();
    }
    return hasRemoved;
  }

  @override
  Set<E> toSet() => value.toSet();

  @override
  void addAll(Iterable<E> elements) {
    value.addAll(elements);
    refresh();
  }

  @override
  void clear() {
    value.clear();
    refresh();
  }

  @override
  void removeAll(Iterable<Object?> elements) {
    value.removeAll(elements);
    refresh();
  }

  @override
  void retainAll(Iterable<Object?> elements) {
    value.retainAll(elements);
    refresh();
  }

  @override
  void retainWhere(bool Function(E) test) {
    value.retainWhere(test);
    refresh();
  }
}

extension SetExtension<E> on Set<E> {
  /// Converts the Set to a reactive RxSet.
  RxSet<E> get obs => RxSet<E>(<E>{})..addAll(this);

  /// Add [item] to the Set only if [condition] is true.
  void addIf(bool condition, E item) {
    if (condition) {
      add(item);
    }
  }

  /// Adds [Iterable<E>] to the Set only if [condition] is true.
  void addAllIf(bool condition, Iterable<E> items) {
    if (condition) {
      addAll(items);
    }
  }

  /// Replaces all existing items of this Set with [item]
  void assign(E item) {
    clear();
    add(item);
  }

  /// Replaces all existing items of this Set with [items]
  void assignAll(Iterable<E> items) {
    clear();
    addAll(items);
  }
}
