/// List of right-to-left (RTL) languages.
///
/// This list contains language codes representing languages
/// that are written and read from right to left.
const List<String> rtlLanguages = <String>[
  "ar", // Arabic
  "fa", // Farsi
  "he", // Hebrew
  "ps", // Pashto
  "ur", // Urdu
];

/// Abstract class representing translations for an application.
///
/// Implementations of this class should provide a map of keys
/// to translations for different languages.
abstract class Translations {
  /// A map containing keys and translations for different languages.
  ///
  /// The keys of this map represent language codes, and the values
  /// are maps containing translations for different keys in the
  /// respective language.
  Map<String, Map<String, String>> get keys;
}
