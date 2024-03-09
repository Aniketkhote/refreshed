import "package:refreshed/get_utils/src/platform/platform_web.dart"
    if (dart.library.io) "platform_io.dart";

/// Provides platform-specific information and utilities.
///
/// This class offers static boolean getters to determine the current platform
/// based on the underlying platform provided by the `GeneralPlatform` class.
class GetPlatform {
  /// Returns `true` if the current platform is the web.
  static bool get isWeb => GeneralPlatform.isWeb;

  /// Returns `true` if the current platform is macOS.
  static bool get isMacOS => GeneralPlatform.isMacOS;

  /// Returns `true` if the current platform is Windows.
  static bool get isWindows => GeneralPlatform.isWindows;

  /// Returns `true` if the current platform is Linux.
  static bool get isLinux => GeneralPlatform.isLinux;

  /// Returns `true` if the current platform is Android.
  static bool get isAndroid => GeneralPlatform.isAndroid;

  /// Returns `true` if the current platform is iOS.
  static bool get isIOS => GeneralPlatform.isIOS;

  /// Returns `true` if the current platform is Fuchsia.
  static bool get isFuchsia => GeneralPlatform.isFuchsia;

  /// Returns `true` if the current platform is mobile (iOS or Android).
  static bool get isMobile => GetPlatform.isIOS || GetPlatform.isAndroid;

  /// Returns `true` if the current platform is desktop (macOS, Windows, or Linux).
  static bool get isDesktop =>
      GetPlatform.isMacOS || GetPlatform.isWindows || GetPlatform.isLinux;
}
