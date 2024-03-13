import "package:refreshed/get_navigation/src/routes/url_strategy/web/web_url.dart"
    if (dart.library.io) "io/io_url.dart";

/// Sets the URL strategy to remove the hash from the URL.
void setUrlStrategy() {
  removeHash();
}

/// Removes the last history entry from the browser history stack.
///
/// [url] The URL of the history entry to be removed.
void removeLastHistory(String? url) {
  removeLastHistory(url);
}
