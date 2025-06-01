part of '../rx_types.dart';

/// Utility functions for safer JSON conversion in reactive classes.
class RxJsonUtils {
  /// Safely converts a value to JSON by attempting to call toJson() on it.
  ///
  /// This handles common error cases:
  /// - Returns null if the value is null
  /// - Throws a descriptive exception if the value doesn't have a toJson method
  /// - Catches and wraps any errors that occur during conversion
  ///
  /// @param value The value to convert to JSON
  /// @param typeName The name of the type for error messages
  /// @returns The JSON representation of the value
  static dynamic safeToJson<T>(dynamic value, String typeName) {
    if (value == null) return null;

    try {
      return value.toJson();
    } on NoSuchMethodError catch (_) {
      throw Exception("$typeName has no method [toJson]");
    } catch (e) {
      throw Exception("Error in toJson for $typeName: $e");
    }
  }

  /// Converts a list of objects to a JSON list by applying toJson to each element.
  ///
  /// This is useful for collections of objects that each have their own toJson method.
  /// If any element doesn't support toJson, an exception will be thrown.
  ///
  /// @param list The list to convert
  /// @param elementTypeName The type name of the elements for error messages
  /// @returns A list of JSON representations of the elements
  static List<dynamic>? listToJson<T>(List<T>? list, String elementTypeName) {
    if (list == null) return null;
    return list.map((item) => safeToJson(item, elementTypeName)).toList();
  }

  /// Converts a map to a JSON map by applying toJson to each value.
  ///
  /// The keys are converted to strings, and the values are converted using toJson.
  /// This is useful for maps where the values have their own toJson method.
  ///
  /// @param map The map to convert
  /// @param valueTypeName The type name of the values for error messages
  /// @returns A map with string keys and JSON representations of the values
  static Map<String, dynamic>? mapToJson<K, V>(
      Map<K, V>? map, String valueTypeName) {
    if (map == null) return null;

    final result = <String, dynamic>{};
    map.forEach((key, value) {
      result[key.toString()] = safeToJson(value, valueTypeName);
    });
    return result;
  }

  /// Attempts to convert a value to JSON, falling back to a default value if conversion fails.
  ///
  /// This is useful when you want to avoid exceptions and provide a fallback value.
  ///
  /// @param value The value to convert
  /// @param defaultValue The default value to return if conversion fails
  /// @returns The JSON representation or the default value
  static dynamic tryToJson<T>(dynamic value, [dynamic defaultValue]) {
    if (value == null) return defaultValue;

    try {
      return value.toJson();
    } catch (_) {
      return defaultValue;
    }
  }
}
