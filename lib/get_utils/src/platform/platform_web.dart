import "package:web/web.dart" as html;

import "package:refreshed/get_utils/get_utils.dart";

html.Navigator _navigator = html.window.navigator;

/// Provides platform-specific information.
///
/// This class offers static boolean getters to determine various properties
/// of the current platform, such as whether it's a web platform, desktop platform,
/// or mobile platform.
class GeneralPlatform {
  /// Returns `true` if the current platform is the web.
  static bool get isWeb => true;

  /// Returns `true` if the current platform is macOS.
  static bool get isMacOS =>
      _navigator.appVersion.contains("Mac OS") && !GeneralPlatform.isIOS;

  /// Returns `true` if the current platform is Windows.
  static bool get isWindows => _navigator.appVersion.contains("Win");

  /// Returns `true` if the current platform is Linux.
  static bool get isLinux =>
      (_navigator.appVersion.contains("Linux") ||
          _navigator.appVersion.contains("x11")) &&
      !isAndroid;

  /// Returns `true` if the current platform is Android.
  static bool get isAndroid => _navigator.appVersion.contains("Android ");

  /// Returns `true` if the current platform is iOS.
  static bool get isIOS {
    // maxTouchPoints is needed to separate iPad iOS13 vs new MacOS
    return GetUtils.hasMatch(_navigator.platform, r"/iPad|iPhone|iPod/") ||
        (_navigator.platform == "MacIntel" && _navigator.maxTouchPoints > 1);
  }

  /// Returns `true` if the current platform is Fuchsia.
  static bool get isFuchsia => false;

  /// Returns `true` if the current platform is desktop (macOS, Windows, or Linux).
  static bool get isDesktop => isMacOS || isWindows || isLinux;
}
