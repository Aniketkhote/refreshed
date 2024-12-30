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

  // Ensure that the `refresh()` method is available for the `RxMap` class
  @override
  void refresh() {
    super.refresh();
  }
}

extension MapExtension<K, V> on Map<K, V> {
  /// Converts the Map to a reactive RxMap.
  RxMap<K, V> get obs => RxMap<K, V>(this);

  /// Adds a key-value pair to the map if the condition is true.
  void addIf(bool condition, K key, V value) {
    if (condition) {
      this[key] = value;
    }
  }

  /// Adds all key-value pairs from another map if the condition is true.
  void addAllIf(bool condition, Map<K, V> values) {
    if (condition) {
      addAll(values);
    }
  }

  /// Assigns a new key-value pair to the map, clearing the existing map if it's an RxMap.
  void assign(K key, V val) {
    if (this is RxMap) {
      final RxMap<K, V> map = this as RxMap<K, V>;
      map.value.clear();
      map[key] = val;
      map.refresh();
    } else {
      clear();
      this[key] = val;
    }
  }

  /// Assigns all key-value pairs from another map to this map.
  void assignAll(Map<K, V> val) {
    if (this is RxMap) {
      final RxMap<K, V> map = this as RxMap<K, V>;
      if (map.value != val) {
        map.value = val;
        map.refresh();
      }
    } else {
      clear();
      addAll(val);
    }
  }
}
