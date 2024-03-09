import "package:flutter/widgets.dart";

/// A utility class for accessing the engine instance.
class Engine {
  /// Returns the instance of the widgets binding.
  ///
  /// This method ensures that the widgets binding is initialized and returns the instance.
  static WidgetsBinding get instance =>
      WidgetsFlutterBinding.ensureInitialized();
}
