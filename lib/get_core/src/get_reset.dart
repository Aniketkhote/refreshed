import "package:refreshed/refreshed.dart";

/// Extension method to reset the Get instance.
extension ResetExtension on GetInterface {
  /// Resets the Get instance, clearing route bindings and translations by default.
  ///
  /// Optionally, you can specify whether to clear route bindings.
  /// By default, it clears route bindings and translations.
  void reset({bool clearRouteBindings = true}) {
    Get
      ..resetInstance(clearRouteBindings: clearRouteBindings)
      ..clearTranslations();
  }
}
