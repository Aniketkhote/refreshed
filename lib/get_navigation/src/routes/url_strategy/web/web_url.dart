import "package:flutter_web_plugins/flutter_web_plugins.dart";

/// Removes the hash portion from the URL by setting the URL strategy to use path-based URLs.
void removeHash() {
  setUrlStrategy(PathUrlStrategy());
}
