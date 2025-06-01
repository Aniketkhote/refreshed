import "dart:collection";

/// A mixin for implementing equality based on a list of properties.
///
/// This mixin provides an implementation of the equality operator `==` and the hash code getter `hashCode`
/// based on a list of properties (`props`). It ensures that objects are considered equal if they have the same
/// runtime type and their corresponding properties in the `props` list are deeply equal.
///
/// Example usage:
/// ```dart
/// class MyClass with Equality {
///   final int id;
///   final String name;
///
///   MyClass(this.id, this.name);
///
///   @override
///   List get props => [id, name];
/// }
/// ```
/// In this example, two `MyClass` objects are considered equal if they have the same `id` and `name`.
/// The `props` list specifies the properties that are used for determining equality.
mixin Equality {
  /// The list of properties used for determining equality.
  List get props;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Equality &&
          runtimeType == other.runtimeType &&
          const DeepCollectionEquality().equals(props, other.props);

  @override
  int get hashCode =>
      runtimeType.hashCode ^ const DeepCollectionEquality().hash(props);
}

const int _hashMask = 0x7fffffff;

/// A generic equality relation on objects.
abstract class IEquality<E> {
  const factory IEquality() = DefaultEquality<E>;

  /// Compare two elements for being equal.
  ///
  /// This should be a proper equality relation.
  bool equals(E e1, E e2);

  /// Get a hashcode of an element.
  ///
  /// The hashcode should be compatible with [equals], so that if
  /// `equals(a, b)` then `hash(a) == hash(b)`.
  int hash(E e);

  /// Test whether an object is a valid argument to [equals] and [hash].
  ///
  /// Some implementations may be restricted to only work on specific types
  /// of objects.
  bool isValidKey(Object? o);
}

/// A default equality implementation.
///
/// This class provides default equality comparison by using the equality operator (`==`)
/// for comparing objects and the `hashCode` method for hashing.
///
/// It is generic over the type of elements being compared.
class DefaultEquality<E> implements IEquality<E> {
  /// Creates a [DefaultEquality].
  const DefaultEquality();

  @override
  bool equals(Object? e1, Object? e2) => e1 == e2;
  @override
  int hash(Object? e) => e.hashCode;
  @override
  bool isValidKey(Object? o) => true;
}

/// Equality of objects that compares only the identity of the objects.
class IdentityEquality<E> implements IEquality<E> {
  const IdentityEquality();
  @override
  bool equals(E e1, E e2) => identical(e1, e2);
  @override
  int hash(E e) => identityHashCode(e);
  @override
  bool isValidKey(Object? o) => true;
}

/// A deep equality implementation for collections.
///
/// This class provides deep equality comparison for collections such as lists,
/// sets, maps, and iterables. It recursively compares the elements of collections
/// to determine if they are deeply equal.
class DeepCollectionEquality implements IEquality {
  /// Creates a [DeepCollectionEquality].
  ///
  /// By default, this equality does not allow unordered comparisons.
  const DeepCollectionEquality();
  final IEquality _base = const DefaultEquality<Never>();
  final bool _unordered = false;

  @override
  bool equals(e1, e2) => switch ((e1, e2)) {
        (Set s1, Set s2) => SetEquality(this).equals(s1, s2),
        (Map m1, Map m2) =>
          MapEquality(keys: this, values: this).equals(m1, m2),
        (List l1, List l2) => ListEquality(this).equals(l1, l2),
        (Iterable i1, Iterable i2) => IterableEquality(this).equals(i1, i2),
        _ => _base.equals(e1, e2)
      };

  @override
  int hash(Object? o) => switch (o) {
        Set s => SetEquality(this).hash(s),
        Map m => MapEquality(keys: this, values: this).hash(m),
        List l when !_unordered => ListEquality(this).hash(l),
        Iterable i when !_unordered => IterableEquality(this).hash(i),
        Iterable i when _unordered => UnorderedIterableEquality(this).hash(i),
        _ => _base.hash(o)
      };

  @override
  bool isValidKey(Object? o) =>
      o is Iterable || o is Map || _base.isValidKey(o);
}

/// Equality on lists.
///
/// Two lists are equal if they have the same length and their elements
/// at each index are equal.
class ListEquality<E> implements IEquality<List<E>> {
  const ListEquality([
    IEquality<E> elementEquality = const DefaultEquality<Never>(),
  ]) : _elementEquality = elementEquality;
  final IEquality<E> _elementEquality;

  @override
  bool equals(List<E>? list1, List<E>? list2) => switch ((list1, list2)) {
        (var l1, var l2) when identical(l1, l2) => true,
        (null, _) || (_, null) => false,
        (List<E> l1, List<E> l2) when l1.length != l2.length => false,
        (List<E> l1, List<E> l2) => () {
            for (int i = 0; i < l1.length; i++) {
              if (!_elementEquality.equals(l1[i], l2[i])) return false;
            }
            return true;
          }()
      };

  @override
  int hash(List<E>? list) => switch (list) {
        null => null.hashCode,
        List<E> l => () {
            // Jenkins's one-at-a-time hash function.
            // This code is almost identical to the one in IterableEquality, except
            // that it uses indexing instead of iterating to get the elements.
            int hash = 0;
            for (int i = 0; i < l.length; i++) {
              final int c = _elementEquality.hash(l[i]);
              hash = (hash + c) & _hashMask;
              hash = (hash + (hash << 10)) & _hashMask;
              hash ^= hash >> 6;
            }
            hash = (hash + (hash << 3)) & _hashMask;
            hash ^= hash >> 11;
            hash = (hash + (hash << 15)) & _hashMask;
            return hash;
          }()
      };

  @override
  bool isValidKey(Object? o) => o is List<E>;
}

/// Equality on maps.
///
/// Two maps are equal if they have the same number of entries, and if the
/// entries of the two maps are pairwise equal on both key and value.
class MapEquality<K, V> implements IEquality<Map<K, V>> {
  const MapEquality({
    IEquality<K> keys = const DefaultEquality<Never>(),
    IEquality<V> values = const DefaultEquality<Never>(),
  })  : _keyEquality = keys,
        _valueEquality = values;
  final IEquality<K> _keyEquality;
  final IEquality<V> _valueEquality;

  @override
  bool equals(Map<K, V>? map1, Map<K, V>? map2) => switch ((map1, map2)) {
        (var m1, var m2) when identical(m1, m2) => true,
        (null, _) || (_, null) => false,
        (Map<K, V> m1, Map<K, V> m2) when m1.length != m2.length => false,
        (Map<K, V> m1, Map<K, V> m2) => () {
            final Map<_MapEntry, int> equalElementCounts =
                HashMap<_MapEntry, int>();

            // Count entries in first map
            for (final K key in m1.keys) {
              final _MapEntry entry = _MapEntry(this, key, m1[key]);
              final int count = equalElementCounts[entry] ?? 0;
              equalElementCounts[entry] = count + 1;
            }

            // Check entries in second map
            for (final K key in m2.keys) {
              final _MapEntry entry = _MapEntry(this, key, m2[key]);
              final int? count = equalElementCounts[entry];
              if (count == null || count == 0) return false;
              equalElementCounts[entry] = count - 1;
            }

            return true;
          }()
      };

  @override
  int hash(Map<K, V>? map) => switch (map) {
        null => null.hashCode,
        Map<K, V> m => () {
            int hash = 0;
            for (final K key in m.keys) {
              final int keyHash = _keyEquality.hash(key);
              final int valueHash = _valueEquality.hash(m[key] as V);
              hash = (hash + 3 * keyHash + 7 * valueHash) & _hashMask;
            }
            hash = (hash + (hash << 3)) & _hashMask;
            hash ^= hash >> 11;
            hash = (hash + (hash << 15)) & _hashMask;
            return hash;
          }()
      };

  @override
  bool isValidKey(Object? o) => o is Map<K, V>;
}

class _MapEntry {
  _MapEntry(this.equality, this.key, this.value);
  final MapEquality equality;
  final Object? key;
  final Object? value;

  @override
  int get hashCode =>
      (3 * equality._keyEquality.hash(key) +
          7 * equality._valueEquality.hash(value)) &
      _hashMask;

  @override
  bool operator ==(Object other) => switch (other) {
        _MapEntry entry => equality._keyEquality.equals(key, entry.key) &&
            equality._valueEquality.equals(value, entry.value),
        _ => false
      };
}

/// Equality on iterables.
///
/// Two iterables are equal if they have the same elements in the same order.
class IterableEquality<E> implements IEquality<Iterable<E>> {
  const IterableEquality([
    IEquality<E> elementEquality = const DefaultEquality<Never>(),
  ]) : _elementEquality = elementEquality;
  final IEquality<E?> _elementEquality;

  @override
  bool equals(Iterable<E>? elements1, Iterable<E>? elements2) =>
      switch ((elements1, elements2)) {
        (var e1, var e2) when identical(e1, e2) => true,
        (null, _) || (_, null) => false,
        (Iterable<E> e1, Iterable<E> e2) => () {
            final Iterator<E> it1 = e1.iterator;
            final Iterator<E> it2 = e2.iterator;

            while (true) {
              final bool hasNext = it1.moveNext();
              if (hasNext != it2.moveNext()) return false;
              if (!hasNext) return true;
              if (!_elementEquality.equals(it1.current, it2.current)) {
                return false;
              }
            }
          }()
      };

  @override
  int hash(Iterable<E>? elements) => switch (elements) {
        null => null.hashCode,
        Iterable<E> e => () {
            // Jenkins's one-at-a-time hash function.
            int hash = 0;
            for (final E element in e) {
              final int c = _elementEquality.hash(element);
              hash = (hash + c) & _hashMask;
              hash = (hash + (hash << 10)) & _hashMask;
              hash ^= hash >> 6;
            }
            hash = (hash + (hash << 3)) & _hashMask;
            hash ^= hash >> 11;
            hash = (hash + (hash << 15)) & _hashMask;
            return hash;
          }()
      };

  @override
  bool isValidKey(Object? o) => o is Iterable<E>;
}

/// Equality of sets.
///
/// Two sets are considered equal if they have the same number of elements,
/// and the elements of one set can be paired with the elements
/// of the other set, so that each pair are equal.
class SetEquality<E> extends _UnorderedEquality<E, Set<E>> {
  const SetEquality([super.elementEquality = const DefaultEquality<Never>()]);

  @override
  bool isValidKey(Object? o) => o is Set<E>;
}

abstract class _UnorderedEquality<E, T extends Iterable<E>>
    implements IEquality<T> {
  const _UnorderedEquality(this._elementEquality);
  final IEquality<E> _elementEquality;

  @override
  bool equals(T? elements1, T? elements2) => switch ((elements1, elements2)) {
        (var e1, var e2) when identical(e1, e2) => true,
        (null, _) || (_, null) => false,
        (T e1, T e2) => () {
            final HashMap<E, int> counts = HashMap<E, int>(
              equals: _elementEquality.equals,
              hashCode: _elementEquality.hash,
              isValidKey: _elementEquality.isValidKey,
            );

            // Count elements in first collection
            int length = 0;
            for (final E e in e1) {
              final int count = counts[e] ?? 0;
              counts[e] = count + 1;
              length++;
            }

            // Check elements in second collection
            for (final E e in e2) {
              final int? count = counts[e];
              if (count == null || count == 0) return false;
              counts[e] = count - 1;
              length--;
            }

            return length == 0;
          }()
      };

  @override
  int hash(T? elements) => switch (elements) {
        null => null.hashCode,
        T e => () {
            int hash = 0;
            for (final E element in e) {
              final int c = _elementEquality.hash(element);
              hash = (hash + c) & _hashMask;
            }
            hash = (hash + (hash << 3)) & _hashMask;
            hash ^= hash >> 11;
            hash = (hash + (hash << 15)) & _hashMask;
            return hash;
          }()
      };
}

/// Equality of the elements of two iterables without considering order.
///
/// Two iterables are considered equal if they have the same number of elements,
/// and the elements of one set can be paired with the elements
/// of the other iterable, so that each pair are equal.
class UnorderedIterableEquality<E> extends _UnorderedEquality<E, Iterable<E>> {
  const UnorderedIterableEquality([
    super.elementEquality = const DefaultEquality<Never>(),
  ]);

  @override
  bool isValidKey(Object? o) => o is Iterable<E>;
}
