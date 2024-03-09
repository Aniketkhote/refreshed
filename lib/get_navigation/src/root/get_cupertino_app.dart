import "package:flutter/cupertino.dart";
import "package:flutter/foundation.dart";
import "package:flutter/material.dart";
import "package:refreshed/get_core/get_core.dart";
import "package:refreshed/get_instance/get_instance.dart";
import "package:refreshed/get_navigation/get_navigation.dart";
import "package:refreshed/get_navigation/src/root/get_root.dart";
import "package:refreshed/get_state_manager/get_state_manager.dart";
import "package:refreshed/get_utils/get_utils.dart";

/// A CupertinoApp extension that integrates the Refreshed state management library.
///
/// This widget is similar to CupertinoApp, but with additional features provided
/// by Refreshed, such as reactive state management, dependency injection, and
/// navigation management.
class GetCupertinoApp extends StatelessWidget {
  /// Constructs a [GetCupertinoApp] widget.
  const GetCupertinoApp({
    super.key,
    this.theme,
    this.navigatorKey,
    this.home,
    Map<String, Widget Function(BuildContext)> this.routes =
        const <String, WidgetBuilder>{},
    this.initialRoute,
    this.onGenerateRoute,
    this.onGenerateInitialRoutes,
    this.onUnknownRoute,
    List<NavigatorObserver> this.navigatorObservers =
        const <NavigatorObserver>[],
    this.builder,
    this.translationsKeys,
    this.translations,
    this.textDirection,
    this.title = "",
    this.onGenerateTitle,
    this.color,
    this.customTransition,
    this.onInit,
    this.onDispose,
    this.locale,
    this.binds = const <Bind>[],
    this.scrollBehavior,
    this.fallbackLocale,
    this.localizationsDelegates,
    this.localeListResolutionCallback,
    this.localeResolutionCallback,
    this.supportedLocales = const <Locale>[Locale("en", "US")],
    this.showPerformanceOverlay = false,
    this.checkerboardRasterCacheImages = false,
    this.checkerboardOffscreenLayers = false,
    this.showSemanticsDebugger = false,
    this.debugShowCheckedModeBanner = true,
    this.shortcuts,
    this.smartManagement = SmartManagement.full,
    this.initialBinding,
    this.useInheritedMediaQuery = false,
    this.unknownRoute,
    this.routingCallback,
    this.defaultTransition,
    this.onReady,
    this.getPages,
    this.opaqueRoute,
    this.enableLog = kDebugMode,
    this.logWriterCallback,
    this.popGesture,
    this.transitionDuration,
    this.defaultGlobalState,
    this.highContrastTheme,
    this.highContrastDarkTheme,
    this.actions,
  })  : routeInformationProvider = null,
        backButtonDispatcher = null,
        routeInformationParser = null,
        routerDelegate = null,
        routerConfig = null;

  /// Constructs a [GetCupertinoApp] widget with router configuration.
  const GetCupertinoApp.router({
    super.key,
    this.theme,
    this.routeInformationProvider,
    this.routeInformationParser,
    this.routerDelegate,
    this.routerConfig,
    this.backButtonDispatcher,
    this.builder,
    this.title = "",
    this.onGenerateTitle,
    this.useInheritedMediaQuery = false,
    this.color,
    this.highContrastTheme,
    this.highContrastDarkTheme,
    this.locale,
    this.localizationsDelegates,
    this.localeListResolutionCallback,
    this.localeResolutionCallback,
    this.supportedLocales = const <Locale>[Locale("en", "US")],
    this.showPerformanceOverlay = false,
    this.checkerboardRasterCacheImages = false,
    this.checkerboardOffscreenLayers = false,
    this.showSemanticsDebugger = false,
    this.debugShowCheckedModeBanner = true,
    this.shortcuts,
    this.binds = const <Bind>[],
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
    this.initialBinding,
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

  /// A custom transition configuration for route transitions.
  final CustomTransition? customTransition;

  /// The primary color of the app.
  final Color? color;

  /// A map of translation keys for internationalization.
  final Map<String, Map<String, String>>? translationsKeys;

  /// The translations for internationalization.
  final Translations? translations;

  /// The text direction of the app.
  final TextDirection? textDirection;

  /// The locale to use for localization.
  final Locale? locale;

  /// The fallback locale to use if the specified locale is not available.
  final Locale? fallbackLocale;

  /// The localizations delegates for internationalization.
  final Iterable<LocalizationsDelegate<dynamic>>? localizationsDelegates;

  /// The locale list resolution callback for internationalization.
  final LocaleListResolutionCallback? localeListResolutionCallback;

  /// The locale resolution callback for internationalization.
  final LocaleResolutionCallback? localeResolutionCallback;

  /// The supported locales for internationalization.
  final Iterable<Locale> supportedLocales;

  /// Whether to show performance overlay for debugging.
  final bool showPerformanceOverlay;

  /// Whether to show raster cache images checkerboard for debugging.
  final bool checkerboardRasterCacheImages;

  /// Whether to show offscreen layers checkerboard for debugging.
  final bool checkerboardOffscreenLayers;

  /// Whether to show semantics debugger for debugging.
  final bool showSemanticsDebugger;

  /// Whether to show checked mode banner in debug mode.
  final bool debugShowCheckedModeBanner;

  /// The shortcuts for keyboard shortcuts.
  final Map<LogicalKeySet, Intent>? shortcuts;

  /// The high contrast theme for accessibility.
  final ThemeData? highContrastTheme;

  /// The high contrast dark theme for accessibility.
  final ThemeData? highContrastDarkTheme;

  /// The actions for shortcuts.
  final Map<Type, Action<Intent>>? actions;

  /// The callback for routing events.
  final Function(Routing?)? routingCallback;

  /// The default transition animation type.
  final Transition? defaultTransition;

  /// Whether routes should be opaque.
  final bool? opaqueRoute;

  /// The callback for initializing the app.
  final VoidCallback? onInit;

  /// The callback for when the app is ready.
  final VoidCallback? onReady;

  /// The callback for when the app is disposed.
  final VoidCallback? onDispose;

  /// Whether logging is enabled.
  final bool? enableLog;

  /// The callback for writing logs.
  final LogWriterCallback? logWriterCallback;

  /// Whether pop gesture is enabled.
  final bool? popGesture;

  /// The smart management strategy for state management.
  final SmartManagement smartManagement;

  /// The initial bindings for dependency injection.
  final BindingsInterface? initialBinding;

  /// The duration for transition animations.
  final Duration? transitionDuration;

  /// Whether the default global state is enabled.
  final bool? defaultGlobalState;

  /// The pages for navigation.
  final List<GetPage>? getPages;

  /// The unknown route page for navigation.
  final GetPage? unknownRoute;

  /// The route information provider for routing.
  final RouteInformationProvider? routeInformationProvider;

  /// The route information parser for routing.
  final RouteInformationParser<Object>? routeInformationParser;

  /// The router delegate for routing.
  final RouterDelegate<Object>? routerDelegate;

  /// The router configuration for routing.
  final RouterConfig<Object>? routerConfig;

  /// The back button dispatcher for routing.
  final BackButtonDispatcher? backButtonDispatcher;

  /// The Cupertino theme data for styling.
  final CupertinoThemeData? theme;

  /// Whether to use inherited media query.
  final bool useInheritedMediaQuery;

  /// The list of bindings for dependency injection.
  final List<Bind> binds;

  /// The scroll behavior for scrolling.
  final ScrollBehavior? scrollBehavior;

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
          scaffoldMessengerKey: GlobalKey<ScaffoldMessengerState>(),
          smartManagement: smartManagement,
          transitionDuration: transitionDuration,
          translations: translations,
          translationsKeys: translationsKeys,
          unknownRoute: unknownRoute,
        ),
        child: Builder(
          builder: (BuildContext context) {
            final GetRootState controller = GetRoot.of(context);
            return CupertinoApp.router(
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
              theme: theme,
              locale: Get.locale ?? locale,
              localizationsDelegates: localizationsDelegates,
              localeListResolutionCallback: localeListResolutionCallback,
              localeResolutionCallback: localeResolutionCallback,
              supportedLocales: supportedLocales,
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
