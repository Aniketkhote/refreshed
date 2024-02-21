import 'dart:io';

/// Provides platform-specific information and utilities using the Dart `Platform` class.
///
/// This class offers static boolean getters to determine the current platform
/// based on the Dart platform information provided by the `Platform` class.
class GeneralPlatform {
  /// Returns `true` if the current platform is the web.
  static bool get isWeb => false;

  /// Returns `true` if the current platform is macOS.
  static bool get isMacOS => Platform.isMacOS;

  /// Returns `true` if the current platform is Windows.
  static bool get isWindows => Platform.isWindows;

  /// Returns `true` if the current platform is Linux.
  static bool get isLinux => Platform.isLinux;

  /// Returns `true` if the current platform is Android.
  static bool get isAndroid => Platform.isAndroid;

  /// Returns `true` if the current platform is iOS.
  static bool get isIOS => Platform.isIOS;

  /// Returns `true` if the current platform is Fuchsia.
  static bool get isFuchsia => Platform.isFuchsia;

  /// Returns `true` if the current platform is desktop (macOS, Windows, or Linux).
  static bool get isDesktop =>
      Platform.isMacOS || Platform.isWindows || Platform.isLinux;
}
