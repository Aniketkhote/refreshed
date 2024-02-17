import 'package:flutter/widgets.dart';

import '../../../refreshed.dart';

/// A mixin that facilitates building responsive widgets by providing methods
/// to conditionally choose which widget to build based on the screen type.
///
/// This mixin requires the implementation of two getters: `screen` and
/// `alwaysUseBuilder`. The `screen` getter should return a [ResponsiveScreen]
/// object, which provides information about the screen size and type. The
/// `alwaysUseBuilder` getter should return a boolean value indicating whether
/// the `builder` method should always be used, regardless of the screen type.
///
/// The `build` method is overridden to conditionally choose which widget to
/// build based on the screen type and the provided methods (`builder`,
/// `desktop`, `phone`, `tablet`, `watch`). If `alwaysUseBuilder` is set to true
/// and `builder` is not null, the `builder` method is always used. Otherwise,
/// the method corresponding to the current screen type is invoked. If a method
/// corresponding to the current screen type is null, the method corresponding
/// to a larger screen type is used as a fallback. If none of the methods are
/// provided, the `builder` method is used as a final fallback.
mixin GetResponsiveMixin on Widget {
  /// Gets the [ResponsiveScreen] object, which provides information about the
  /// screen size and type.
  ResponsiveScreen get screen;

  /// Gets a boolean value indicating whether the `builder` method should always
  /// be used, regardless of the screen type.
  bool get alwaysUseBuilder;

  /// Overrides the build method to conditionally choose which widget to build
  /// based on the screen type and the provided methods (`builder`, `desktop`,
  /// `phone`, `tablet`, `watch`).
  ///
  /// If `alwaysUseBuilder` is set to true and `builder` is not null, the
  /// `builder` method is always used. Otherwise, the method corresponding to
  /// the current screen type is invoked. If a method corresponding to the
  /// current screen type is null, the method corresponding to a larger screen
  /// type is used as a fallback. If none of the methods are provided, the
  /// `builder` method is used as a final fallback.
  @protected
  Widget build(BuildContext context) {
    screen.context = context;
    Widget? widget;
    if (alwaysUseBuilder) {
      widget = builder();
      if (widget != null) return widget;
    }
    if (screen.isDesktop) {
      widget = desktop() ?? widget;
      if (widget != null) return widget;
    }
    if (screen.isTablet) {
      widget = tablet() ?? desktop();
      if (widget != null) return widget;
    }
    if (screen.isPhone) {
      widget = phone() ?? tablet() ?? desktop();
      if (widget != null) return widget;
    }
    return watch() ?? phone() ?? tablet() ?? desktop() ?? builder()!;
  }

  /// A method to build the widget when the screen type matches no specific
  /// condition.
  Widget? builder() => null;

  /// A method to build the widget specifically for desktop screens.
  Widget? desktop() => null;

  /// A method to build the widget specifically for phone screens.
  Widget? phone() => null;

  /// A method to build the widget specifically for tablet screens.
  Widget? tablet() => null;

  /// A method to build the widget specifically for watch screens.
  Widget? watch() => null;
}

/// Extend this widget to build responsive view.
/// this widget contains the `screen` property that have all
/// information about the screen size and type.
/// You have two options to build it.
/// 1- with `builder` method you return the widget to build.
/// 2- with methods `desktop`, `tablet`,`phone`, `watch`. the specific
/// method will be built when the screen type matches the method
/// when the screen is [ScreenType.Tablet] the `tablet` method
/// will be exuded and so on.
/// Note if you use this method please set the
/// property `alwaysUseBuilder` to false
/// With `settings` property you can set the width limit for the screen types.
class GetResponsiveView<T> extends GetView<T> with GetResponsiveMixin {
  @override
  final bool alwaysUseBuilder;

  @override
  final ResponsiveScreen screen;

  GetResponsiveView({
    this.alwaysUseBuilder = false,
    ResponsiveScreenSettings settings = const ResponsiveScreenSettings(),
    super.key,
  }) : screen = ResponsiveScreen(settings);
}

/// A widget that provides responsiveness functionality by dynamically choosing
/// which widget to build based on the screen type.
class GetResponsiveWidget<T extends GetLifeCycleMixin> extends GetWidget<T>
    with GetResponsiveMixin {
  /// Determines whether to always use the `builder` method for building widgets.
  @override
  final bool alwaysUseBuilder;

  /// The screen information used for determining the screen type.
  @override
  final ResponsiveScreen screen;

  /// Constructs a [GetResponsiveWidget] with the given parameters.
  GetResponsiveWidget({
    this.alwaysUseBuilder = false,
    ResponsiveScreenSettings settings = const ResponsiveScreenSettings(),
    super.key,
  }) : screen = ResponsiveScreen(settings);
}

/// A class containing settings for responsive screen behavior.
class ResponsiveScreenSettings {
  /// The width threshold for switching to desktop mode.
  final double desktopChangePoint;

  /// The width threshold for switching to tablet mode.
  final double tabletChangePoint;

  /// The width threshold for switching to watch mode.
  final double watchChangePoint;

  /// Constructs a [ResponsiveScreenSettings] with the specified thresholds.
  const ResponsiveScreenSettings({
    this.desktopChangePoint = 1200,
    this.tabletChangePoint = 600,
    this.watchChangePoint = 300,
  });
}

/// A class that provides information about the current screen size and type.
class ResponsiveScreen {
  /// The context used for obtaining screen dimensions.
  late BuildContext context;

  /// The settings used for determining screen type.
  final ResponsiveScreenSettings settings;

  /// Indicates whether the platform is a desktop.
  late bool _isPlatformDesktop;

  /// Constructs a [ResponsiveScreen] with the given settings.
  ResponsiveScreen(this.settings) {
    _isPlatformDesktop = GetPlatform.isDesktop;
  }

  /// Returns the height of the screen.
  double get height => context.height;

  /// Returns the width of the screen.
  double get width => context.width;

  /// Checks if the screen type is desktop.
  bool get isDesktop => (screenType == ScreenType.desktop);

  /// Checks if the screen type is tablet.
  bool get isTablet => (screenType == ScreenType.tablet);

  /// Checks if the screen type is phone.
  bool get isPhone => (screenType == ScreenType.phone);

  /// Checks if the screen type is watch.
  bool get isWatch => (screenType == ScreenType.watch);

  /// Returns the width of the screen based on the platform.
  double get _getDeviceWidth {
    if (_isPlatformDesktop) {
      return width;
    }
    return context.mediaQueryShortestSide;
  }

  /// Determines the screen type based on the current screen width.
  ScreenType get screenType {
    final deviceWidth = _getDeviceWidth;
    if (deviceWidth >= settings.desktopChangePoint) return ScreenType.desktop;
    if (deviceWidth >= settings.tabletChangePoint) return ScreenType.tablet;
    if (deviceWidth < settings.watchChangePoint) return ScreenType.watch;
    return ScreenType.phone;
  }

  /// Returns a widget based on the current screen type, with fallback options.
  T? responsiveValue<T>({
    T? mobile,
    T? tablet,
    T? desktop,
    T? watch,
  }) {
    if (isDesktop && desktop != null) return desktop;
    if (isTablet && tablet != null) return tablet;
    if (isPhone && mobile != null) return mobile;
    return watch;
  }
}

/// An enumeration representing different types of screens.
enum ScreenType { watch, phone, tablet, desktop }
