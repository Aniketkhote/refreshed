part of "../rx_types.dart";

class RxMap<K, V> extends GetListenable<Map<K, V>>
    with MapMixin<K, V>, RxObjectMixin<Map<K, V>> {
  RxMap([super.initial = const <Never, Never>{}]);

  factory RxMap.from(Map<K, V> other) => RxMap<K, V>(Map<K, V>.from(other));

  /// Creates a [LinkedHashMap] with the same keys and values as [other].
  factory RxMap.of(Map<K, V> other) => RxMap<K, V>(Map<K, V>.of(other));

  ///Creates an unmodifiable hash based map containing the entries of [other].
  factory RxMap.unmodifiable(Map<K, V> other) =>
      RxMap<K, V>(Map<K, V>.unmodifiable(other));

  /// Creates an identity map with the default implementation, [LinkedHashMap].
  factory RxMap.identity() => RxMap<K, V>(Map<K, V>.identity());

  @override
  V? operator [](Object? key) => value[key as K];

  @override
  void operator []=(K key, V value) {
    this.value[key] = value;
    refresh();
  }

  @override
  void clear() {
    value.clear();
    refresh();
  }

  @override
  Iterable<K> get keys => value.keys;

  @override
  V? remove(Object? key) {
    final V? val = value.remove(key);
    refresh();
    return val;
  }
}

extension MapExtension<K, V> on Map<K, V> {
  RxMap<K, V> get obs => RxMap<K, V>(this);

  void addIf(condition, K key, V value) {
    if (condition is Condition) {
      condition = condition();
    }
    if (condition is bool && condition) {
      this[key] = value;
    }
  }

  void addAllIf(condition, Map<K, V> values) {
    if (condition is Condition) {
      condition = condition();
    }
    if (condition is bool && condition) {
      addAll(values);
    }
  }

  void assign(K key, V val) {
    if (this is RxMap) {
      final RxMap<K, V> map = this as RxMap<K, V>;
      // map._value;
      map.value.clear();
      this[key] = val;
    } else {
      clear();
      this[key] = val;
    }
  }

  void assignAll(Map<K, V> val) {
    if (val is RxMap && this is RxMap) {
      if ((val as RxMap<K, V>).value == (this as RxMap<K, V>).value) {
        return;
      }
    }
    if (this is RxMap) {
      final RxMap<K, V> map = this as RxMap<K, V>;
      if (map.value == val) {
        return;
      }
      map.value = val;
      // ignore: invalid_use_of_protected_member
      map.refresh();
    } else {
      if (this == val) {
        return;
      }
      clear();
      addAll(val);
    }
  }
}
