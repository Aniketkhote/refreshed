import "dart:ui";

import "package:refreshed/get_core/get_core.dart";

/// Internal class for managing internationalization settings and translations.
class _IntlHost {
  /// The current locale being used for translations.
  Locale? locale;

  /// The fallback locale to use if a translation for the current locale is not available.
  Locale? fallbackLocale;

  /// Map containing translation data for different languages.
  /// The outer map's keys are language codes, and the inner map's keys are translation keys.
  Map<String, Map<String, String>> translations =
      <String, Map<String, String>>{};
}

/// Extension methods for handling internationalization within GetX.
extension LocalesIntl on GetInterface {
  static final _IntlHost _intlHost = _IntlHost();

  /// Gets the current locale.
  Locale? get locale => _intlHost.locale;

  /// Gets the fallback locale.
  Locale? get fallbackLocale => _intlHost.fallbackLocale;

  /// Sets the current locale.
  set locale(Locale? newLocale) => _intlHost.locale = newLocale;

  /// Sets the fallback locale.
  set fallbackLocale(Locale? newLocale) => _intlHost.fallbackLocale = newLocale;

  /// Gets the translations.
  Map<String, Map<String, String>> get translations => _intlHost.translations;

  /// Adds translations.
  void addTranslations(Map<String, Map<String, String>> tr) {
    translations.addAll(tr);
  }

  /// Clears all translations.
  void clearTranslations() {
    translations.clear();
  }

  /// Appends translations.
  void appendTranslations(Map<String, Map<String, String>> tr) {
    tr.forEach((String key, Map<String, String> map) {
      if (translations.containsKey(key)) {
        translations[key]!.addAll(map);
      } else {
        translations[key] = map;
      }
    });
  }
}

/// Extension providing localization capabilities to strings.
extension TranslationExtension on String {
  // Checks whether the language code and country code are present, and
  // whether the key is also present.
  bool get _fullLocaleAndKey =>
      Get.translations.containsKey(
        "${Get.locale!.languageCode}_${Get.locale!.countryCode}",
      ) &&
      Get.translations[
              "${Get.locale!.languageCode}_${Get.locale!.countryCode}"]!
          .containsKey(this);

  // Checks if there is a callback language in the absence of the specific
  // country, and if it contains that key.
  Map<String, String>? get _getSimilarLanguageTranslation {
    final Map<String, Map<String, String>> translationsWithNoCountry =
        Get.translations.map(
      (String key, Map<String, String> value) =>
          MapEntry<String, Map<String, String>>(key.split("_").first, value),
    );
    final bool containsKey = translationsWithNoCountry
        .containsKey(Get.locale!.languageCode.split("_").first);

    if (!containsKey) {
      return null;
    }

    return translationsWithNoCountry[Get.locale!.languageCode.split("_").first];
  }

  String get tr => switch ((
        Get.locale?.languageCode,
        _fullLocaleAndKey,
        _getSimilarLanguageTranslation
      )) {
        // Returns the key if locale is null
        (null, _, _) => this,

        // Full locale and key match
        (_, true, _) => Get.translations[
            "${Get.locale!.languageCode}_${Get.locale!.countryCode}"]![this]!,

        // Similar language translation available
        (_, _, Map<String, String> similar) when similar.containsKey(this) =>
          similar[this]!,

        // Fallback locale handling
        (_, _, _) when Get.fallbackLocale != null => () {
            final fallback = Get.fallbackLocale!;
            final String key =
                "${fallback.languageCode}_${fallback.countryCode}";

            if (Get.translations.containsKey(key) &&
                Get.translations[key]!.containsKey(this)) {
              return Get.translations[key]![this]!;
            }
            if (Get.translations.containsKey(fallback.languageCode) &&
                Get.translations[fallback.languageCode]!.containsKey(this)) {
              return Get.translations[fallback.languageCode]![this]!;
            }
            return this;
          }(),

        // Default case - return the key itself
        _ => this
      };

  /// Returns a translated string with arguments replaced.
  ///
  /// [args] is a list of strings representing arguments to be replaced in the translated string.
  String trArgs([List<String> args = const <String>[]]) {
    String key = tr;
    if (args.isNotEmpty) {
      for (final String arg in args) {
        key = key.replaceFirst(RegExp("%s"), arg);
      }
    }
    return key;
  }

  /// Returns a translated string with pluralization support and arguments replaced.
  ///
  /// If [i] is 1, returns [trArgs] with [args] replaced. Otherwise, returns [pluralKey] translated string with [args] replaced.
  String trPlural([
    String? pluralKey,
    int? i,
    List<String> args = const <String>[],
  ]) =>
      switch (i) { 1 => trArgs(args), _ => pluralKey!.trArgs(args) };

  /// Returns a translated string with parameters replaced.
  ///
  /// [params] is a map where keys represent parameter placeholders in the translated string (e.g., '@key') and values represent the replacement strings.
  String trParams([Map<String, String> params = const <String, String>{}]) {
    String trans = tr;
    if (params.isNotEmpty) {
      params.forEach((String key, String value) {
        trans = trans.replaceAll("@$key", value);
      });
    }
    return trans;
  }

  /// Returns a translated string with pluralization support and parameters replaced.
  ///
  /// If [i] is 1, returns [trParams] with [params] replaced. Otherwise, returns [pluralKey] translated string with [params] replaced.
  String trPluralParams([
    String? pluralKey,
    int? i,
    Map<String, String> params = const <String, String>{},
  ]) =>
      switch (i) { 1 => trParams(params), _ => pluralKey!.trParams(params) };
}
