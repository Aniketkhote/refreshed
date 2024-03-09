import "package:flutter/foundation.dart";
import "package:flutter/material.dart";
import "package:refreshed/get_navigation/get_navigation.dart";
import "package:refreshed/get_navigation/src/root/get_root.dart";
import "package:refreshed/get_state_manager/get_state_manager.dart";
import "package:refreshed/get_utils/get_utils.dart";
import "package:refreshed/instance_manager.dart";

/// A MaterialApp extension that integrates the Refreshed state management library.
///
/// This widget is similar to MaterialApp, but with additional features provided
/// by Refreshed, such as reactive state management, dependency injection, and
/// navigation management.
class GetMaterialApp extends StatelessWidget {
  /// Constructs a [GetMaterialApp] widget.
  const GetMaterialApp({
    super.key,
    this.navigatorKey,
    this.scaffoldMessengerKey,
    this.home,
    Map<String, Widget Function(BuildContext)> this.routes =
        const <String, WidgetBuilder>{},
    this.initialRoute,
    this.onGenerateRoute,
    this.onGenerateInitialRoutes,
    this.onUnknownRoute,
    this.useInheritedMediaQuery = false,
    List<NavigatorObserver> this.navigatorObservers =
        const <NavigatorObserver>[],
    this.builder,
    this.textDirection,
    this.title = "",
    this.onGenerateTitle,
    this.color,
    this.theme,
    this.darkTheme,
    this.themeMode = ThemeMode.system,
    this.locale,
    this.fallbackLocale,
    this.localizationsDelegates,
    this.localeListResolutionCallback,
    this.localeResolutionCallback,
    this.supportedLocales = const <Locale>[Locale("en", "US")],
    this.debugShowMaterialGrid = false,
    this.showPerformanceOverlay = false,
    this.checkerboardRasterCacheImages = false,
    this.checkerboardOffscreenLayers = false,
    this.showSemanticsDebugger = false,
    this.debugShowCheckedModeBanner = true,
    this.shortcuts,
    this.scrollBehavior,
    this.customTransition,
    this.translationsKeys,
    this.translations,
    this.onInit,
    this.onReady,
    this.onDispose,
    this.routingCallback,
    this.defaultTransition,
    this.getPages,
    this.opaqueRoute,
    this.enableLog = kDebugMode,
    this.logWriterCallback,
    this.popGesture,
    this.transitionDuration,
    this.defaultGlobalState,
    this.smartManagement = SmartManagement.full,
    this.binds = const <Bind>[],
    this.unknownRoute,
    this.highContrastTheme,
    this.highContrastDarkTheme,
    this.actions,
  })  : routeInformationProvider = null,
        backButtonDispatcher = null,
        routeInformationParser = null,
        routerDelegate = null,
        routerConfig = null;

  /// Constructs a [GetMaterialApp] widget with router configuration.
  const GetMaterialApp.router({
    super.key,
    this.routeInformationProvider,
    this.scaffoldMessengerKey,
    this.routeInformationParser,
    this.routerDelegate,
    this.routerConfig,
    this.backButtonDispatcher,
    this.builder,
    this.title = "",
    this.onGenerateTitle,
    this.color,
    this.theme,
    this.darkTheme,
    this.useInheritedMediaQuery = false,
    this.highContrastTheme,
    this.highContrastDarkTheme,
    this.themeMode = ThemeMode.system,
    this.locale,
    this.localizationsDelegates,
    this.localeListResolutionCallback,
    this.localeResolutionCallback,
    this.supportedLocales = const <Locale>[Locale("en", "US")],
    this.debugShowMaterialGrid = false,
    this.showPerformanceOverlay = false,
    this.checkerboardRasterCacheImages = false,
    this.checkerboardOffscreenLayers = false,
    this.showSemanticsDebugger = false,
    this.debugShowCheckedModeBanner = true,
    this.shortcuts,
    this.scrollBehavior,
    this.actions,
    this.customTransition,
    this.translationsKeys,
    this.translations,
    this.textDirection,
    this.fallbackLocale,
    this.routingCallback,
    this.defaultTransition,
    this.opaqueRoute,
    this.onInit,
    this.onReady,
    this.onDispose,
    this.enableLog = kDebugMode,
    this.logWriterCallback,
    this.popGesture,
    this.smartManagement = SmartManagement.full,
    this.binds = const <Bind>[],
    this.transitionDuration,
    this.defaultGlobalState,
    this.getPages,
    this.navigatorObservers,
    this.unknownRoute,
  })  : navigatorKey = null,
        onGenerateRoute = null,
        home = null,
        onGenerateInitialRoutes = null,
        onUnknownRoute = null,
        routes = null,
        initialRoute = null;

  /// A key to identify the navigator state.
  final GlobalKey<NavigatorState>? navigatorKey;

  /// A key to identify the scaffold messenger state.
  final GlobalKey<ScaffoldMessengerState>? scaffoldMessengerKey;

  /// The default widget to show when the app is first run.
  final Widget? home;

  /// A map of named routes and their corresponding builder functions.
  final Map<String, WidgetBuilder>? routes;

  /// The name of the initial route the app should navigate to.
  final String? initialRoute;

  /// A function that generates routes for navigation.
  final RouteFactory? onGenerateRoute;

  /// A function that generates a list of initial routes for navigation.
  final InitialRouteListFactory? onGenerateInitialRoutes;

  /// A function that generates a route when no other route matches.
  final RouteFactory? onUnknownRoute;

  /// A list of observers for navigation events.
  final List<NavigatorObserver>? navigatorObservers;

  /// A builder function to customize transitions between routes.
  final TransitionBuilder? builder;

  /// The title of the app, displayed in the device's title bar.
  final String title;

  /// A function to generate the app's title dynamically.
  final GenerateAppTitle? onGenerateTitle;

  /// The theme data to use when the device's theme mode is light.
  final ThemeData? theme;

  /// The theme data to use when the device's theme mode is dark.
  final ThemeData? darkTheme;

  /// The theme mode to use for the app.
  final ThemeMode themeMode;

  /// A custom transition configuration for route transitions.
  final CustomTransition? customTransition;

  /// The primary color of the app.
  final Color? color;

  /// A map of translations keys for localization.
  final Map<String, Map<String, String>>? translationsKeys;

  /// The translations object for localization.
  final Translations? translations;

  /// The text direction for the app's layout.
  final TextDirection? textDirection;

  /// The locale for the app's localization.
  final Locale? locale;

  /// The fallback locale for the app's localization.
  final Locale? fallbackLocale;

  /// The delegates for localizations in the app.
  final Iterable<LocalizationsDelegate<dynamic>>? localizationsDelegates;

  /// A callback to resolve the locale list.
  final LocaleListResolutionCallback? localeListResolutionCallback;

  /// A callback to resolve the locale.
  final LocaleResolutionCallback? localeResolutionCallback;

  /// The supported locales for the app's localization.
  final Iterable<Locale> supportedLocales;

  /// Whether to show performance overlay.
  final bool showPerformanceOverlay;

  /// Whether to checkerboard raster cache images.
  final bool checkerboardRasterCacheImages;

  /// Whether to checkerboard offscreen layers.
  final bool checkerboardOffscreenLayers;

  /// Whether to show semantics debugger.
  final bool showSemanticsDebugger;

  /// Whether to show the checked mode banner.
  final bool debugShowCheckedModeBanner;

  /// A map of shortcuts for keyboard shortcuts.
  final Map<LogicalKeySet, Intent>? shortcuts;

  /// The scroll behavior for the app's scrolling widgets.
  final ScrollBehavior? scrollBehavior;

  /// The high contrast theme data for the app.
  final ThemeData? highContrastTheme;

  /// The high contrast dark theme data for the app.
  final ThemeData? highContrastDarkTheme;

  /// The actions for the app.
  final Map<Type, Action<Intent>>? actions;

  /// Whether to show material grid in debug mode.
  final bool debugShowMaterialGrid;

  /// A callback for routing events.
  final ValueChanged<Routing?>? routingCallback;

  /// The default transition for page transitions.
  final Transition? defaultTransition;

  /// Whether the routes are opaque.
  final bool? opaqueRoute;

  /// A callback for initializing the app.
  final VoidCallback? onInit;

  /// A callback for when the app is ready.
  final VoidCallback? onReady;

  /// A callback for when the app is disposed.
  final VoidCallback? onDispose;

  /// Whether logging is enabled.
  final bool? enableLog;

  /// A callback for writing logs.
  final LogWriterCallback? logWriterCallback;

  /// Whether to enable pop gesture.
  final bool? popGesture;

  /// The smart management strategy for the app.
  final SmartManagement smartManagement;

  /// The bindings for the app.
  final List<Bind> binds;

  /// The transition duration for page transitions.
  final Duration? transitionDuration;

  /// Whether to use default global state.
  final bool? defaultGlobalState;

  /// The pages for the app's navigation.
  final List<GetPage>? getPages;

  /// The unknown route for the app.
  final GetPage? unknownRoute;

  /// The route information provider for the app.
  final RouteInformationProvider? routeInformationProvider;

  /// The route information parser for the app.
  final RouteInformationParser<Object>? routeInformationParser;

  /// The router delegate for the app.
  final RouterDelegate<Object>? routerDelegate;

  /// The router config for the app.
  final RouterConfig<Object>? routerConfig;

  /// The back button dispatcher for the app.
  final BackButtonDispatcher? backButtonDispatcher;

  /// Whether to use inherited media query.
  final bool useInheritedMediaQuery;

  @override
  Widget build(BuildContext context) => GetRoot(
        config: ConfigData(
          backButtonDispatcher: backButtonDispatcher,
          binds: binds,
          customTransition: customTransition,
          defaultGlobalState: defaultGlobalState,
          defaultTransition: defaultTransition,
          enableLog: enableLog,
          fallbackLocale: fallbackLocale,
          getPages: getPages,
          home: home,
          initialRoute: initialRoute,
          locale: locale,
          logWriterCallback: logWriterCallback,
          navigatorKey: navigatorKey,
          navigatorObservers: navigatorObservers,
          onDispose: onDispose,
          onInit: onInit,
          onReady: onReady,
          routeInformationParser: routeInformationParser,
          routeInformationProvider: routeInformationProvider,
          routerDelegate: routerDelegate,
          routingCallback: routingCallback,
          scaffoldMessengerKey: scaffoldMessengerKey,
          smartManagement: smartManagement,
          transitionDuration: transitionDuration,
          translations: translations,
          translationsKeys: translationsKeys,
          unknownRoute: unknownRoute,
          theme: theme,
          darkTheme: darkTheme,
          themeMode: themeMode,
        ),
        child: Builder(
          builder: (BuildContext context) {
            final GetRootState controller = GetRoot.of(context);
            return MaterialApp.router(
              routerDelegate: controller.config.routerDelegate,
              routeInformationParser: controller.config.routeInformationParser,
              backButtonDispatcher: backButtonDispatcher,
              routeInformationProvider: routeInformationProvider,
              routerConfig: routerConfig,
              key: controller.config.unikey,
              builder: (BuildContext context, Widget? child) => Directionality(
                textDirection: textDirection ??
                    (rtlLanguages.contains(Get.locale?.languageCode)
                        ? TextDirection.rtl
                        : TextDirection.ltr),
                child: builder == null
                    ? (child ?? const Material())
                    : builder!(context, child ?? const Material()),
              ),
              title: title,
              onGenerateTitle: onGenerateTitle,
              color: color,
              theme: controller.config.theme ?? ThemeData.fallback(),
              darkTheme: controller.config.darkTheme ??
                  controller.config.theme ??
                  ThemeData.fallback(),
              themeMode: controller.config.themeMode,
              locale: Get.locale ?? locale,
              scaffoldMessengerKey: controller.config.scaffoldMessengerKey,
              localizationsDelegates: localizationsDelegates,
              localeListResolutionCallback: localeListResolutionCallback,
              localeResolutionCallback: localeResolutionCallback,
              supportedLocales: supportedLocales,
              debugShowMaterialGrid: debugShowMaterialGrid,
              showPerformanceOverlay: showPerformanceOverlay,
              checkerboardRasterCacheImages: checkerboardRasterCacheImages,
              checkerboardOffscreenLayers: checkerboardOffscreenLayers,
              showSemanticsDebugger: showSemanticsDebugger,
              debugShowCheckedModeBanner: debugShowCheckedModeBanner,
              shortcuts: shortcuts,
              scrollBehavior: scrollBehavior,
            );
          },
        ),
      );
}
