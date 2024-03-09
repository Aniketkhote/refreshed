import "package:flutter/foundation.dart";
import "package:flutter/material.dart";
import "package:refreshed/get_navigation/src/router_report.dart";
import "package:refreshed/refreshed.dart";

/// A class that holds configuration data for the application.
class ConfigData {
  /// Constructs a new [ConfigData] instance.
  ConfigData({
    required this.routingCallback,
    required this.defaultTransition,
    required this.onInit,
    required this.onReady,
    required this.onDispose,
    required this.enableLog,
    required this.logWriterCallback,
    required this.smartManagement,
    required this.binds,
    required this.transitionDuration,
    required this.defaultGlobalState,
    required this.getPages,
    required this.unknownRoute,
    required this.routeInformationProvider,
    required this.routeInformationParser,
    required this.routerDelegate,
    required this.backButtonDispatcher,
    required this.navigatorObservers,
    required this.navigatorKey,
    required this.scaffoldMessengerKey,
    required this.translationsKeys,
    required this.translations,
    required this.locale,
    required this.fallbackLocale,
    required this.initialRoute,
    required this.customTransition,
    required this.home,
    this.theme,
    this.darkTheme,
    this.themeMode,
    this.unikey,
    this.testMode = false,
    this.defaultOpaqueRoute = true,
    this.defaultTransitionDuration = const Duration(milliseconds: 300),
    this.defaultTransitionCurve = Curves.easeOutQuad,
    this.defaultDialogTransitionCurve = Curves.easeOutQuad,
    this.defaultDialogTransitionDuration = const Duration(milliseconds: 300),
    this.parameters = const <String, String?>{},
    Routing? routing,
    bool? defaultPopGesture,
  })  : defaultPopGesture = defaultPopGesture ?? GetPlatform.isIOS,
        routing = routing ?? Routing();

  /// Callback for routing changes.
  final ValueChanged<Routing?>? routingCallback;

  /// Default transition animation for route changes.
  final Transition? defaultTransition;

  /// Callback function called when the application initializes.
  final VoidCallback? onInit;

  /// Callback function called when the application is ready.
  final VoidCallback? onReady;

  /// Callback function called when the application is disposed.
  final VoidCallback? onDispose;

  /// Flag to enable or disable logging.
  final bool? enableLog;

  /// Callback function for custom log writing.
  final LogWriterCallback? logWriterCallback;

  /// Smart management strategy for state management.
  final SmartManagement smartManagement;

  /// List of bindings for dependency injection.
  final List<Bind> binds;

  /// Duration for route transition animations.
  final Duration? transitionDuration;

  /// Flag indicating whether to use global state by default.
  final bool? defaultGlobalState;

  /// List of routes/pages in the application.
  final List<GetPage>? getPages;

  /// Route to use when an unknown route is encountered.
  final GetPage? unknownRoute;

  /// Provider for route information.
  final RouteInformationProvider? routeInformationProvider;

  /// Parser for route information.
  final RouteInformationParser<Object>? routeInformationParser;

  /// Delegate for managing routing and navigation.
  final RouterDelegate<Object>? routerDelegate;

  /// Dispatcher for back button events.
  final BackButtonDispatcher? backButtonDispatcher;

  /// List of observers for the navigator.
  final List<NavigatorObserver>? navigatorObservers;

  /// GlobalKey for the navigator.
  final GlobalKey<NavigatorState>? navigatorKey;

  /// GlobalKey for the ScaffoldMessenger.
  final GlobalKey<ScaffoldMessengerState>? scaffoldMessengerKey;

  /// Localization keys for translations.
  final Map<String, Map<String, String>>? translationsKeys;

  /// Translations for localization.
  final Translations? translations;

  /// Locale to use for localization.
  final Locale? locale;

  /// Fallback locale to use when the requested locale is not available.
  final Locale? fallbackLocale;

  /// Initial route of the application.
  final String? initialRoute;

  /// Custom transition animation for route changes.
  final CustomTransition? customTransition;

  /// Widget to use as the home screen.
  final Widget? home;

  /// Theme data for light mode.
  final ThemeData? theme;

  /// Theme data for dark mode.
  final ThemeData? darkTheme;

  /// Mode for applying themes (e.g., light, dark, system).
  final ThemeMode? themeMode;

  /// Flag indicating whether to enable default pop gesture behavior.
  final bool defaultPopGesture;

  /// Flag indicating whether to make routes opaque by default.
  final bool defaultOpaqueRoute;

  /// Duration for default transition animations.
  final Duration defaultTransitionDuration;

  /// Curve for default transition animations.
  final Curve defaultTransitionCurve;

  /// Curve for default dialog transition animations.
  final Curve defaultDialogTransitionCurve;

  /// Duration for default dialog transition animations.
  final Duration defaultDialogTransitionDuration;

  /// Routing configuration.
  final Routing routing;

  /// Additional parameters for configuration.
  final Map<String, String?> parameters;

  /// Key for uniquely identifying the configuration instance.
  final Key? unikey;

  /// Flag indicating whether the application is in test mode.
  final bool testMode;

  final SnackBarQueue snackBarQueue = SnackBarQueue();

  ConfigData copyWith({
    ValueChanged<Routing?>? routingCallback,
    Transition? defaultTransition,
    VoidCallback? onInit,
    VoidCallback? onReady,
    VoidCallback? onDispose,
    bool? enableLog,
    LogWriterCallback? logWriterCallback,
    SmartManagement? smartManagement,
    List<Bind>? binds,
    Duration? transitionDuration,
    bool? defaultGlobalState,
    List<GetPage>? getPages,
    GetPage? unknownRoute,
    RouteInformationProvider? routeInformationProvider,
    RouteInformationParser<Object>? routeInformationParser,
    RouterDelegate<Object>? routerDelegate,
    BackButtonDispatcher? backButtonDispatcher,
    List<NavigatorObserver>? navigatorObservers,
    GlobalKey<NavigatorState>? navigatorKey,
    GlobalKey<ScaffoldMessengerState>? scaffoldMessengerKey,
    Map<String, Map<String, String>>? translationsKeys,
    Translations? translations,
    Locale? locale,
    Locale? fallbackLocale,
    String? initialRoute,
    CustomTransition? customTransition,
    Widget? home,
    bool? testMode,
    Key? unikey,
    ThemeData? theme,
    ThemeData? darkTheme,
    ThemeMode? themeMode,
    bool? defaultPopGesture,
    bool? defaultOpaqueRoute,
    Duration? defaultTransitionDuration,
    Curve? defaultTransitionCurve,
    Curve? defaultDialogTransitionCurve,
    Duration? defaultDialogTransitionDuration,
    Routing? routing,
    Map<String, String?>? parameters,
  }) =>
      ConfigData(
        routingCallback: routingCallback ?? this.routingCallback,
        defaultTransition: defaultTransition ?? this.defaultTransition,
        onInit: onInit ?? this.onInit,
        onReady: onReady ?? this.onReady,
        onDispose: onDispose ?? this.onDispose,
        enableLog: enableLog ?? this.enableLog,
        logWriterCallback: logWriterCallback ?? this.logWriterCallback,
        smartManagement: smartManagement ?? this.smartManagement,
        binds: binds ?? this.binds,
        transitionDuration: transitionDuration ?? this.transitionDuration,
        defaultGlobalState: defaultGlobalState ?? this.defaultGlobalState,
        getPages: getPages ?? this.getPages,
        unknownRoute: unknownRoute ?? this.unknownRoute,
        routeInformationProvider:
            routeInformationProvider ?? this.routeInformationProvider,
        routeInformationParser:
            routeInformationParser ?? this.routeInformationParser,
        routerDelegate: routerDelegate ?? this.routerDelegate,
        backButtonDispatcher: backButtonDispatcher ?? this.backButtonDispatcher,
        navigatorObservers: navigatorObservers ?? this.navigatorObservers,
        navigatorKey: navigatorKey ?? this.navigatorKey,
        scaffoldMessengerKey: scaffoldMessengerKey ?? this.scaffoldMessengerKey,
        translationsKeys: translationsKeys ?? this.translationsKeys,
        translations: translations ?? this.translations,
        locale: locale ?? this.locale,
        fallbackLocale: fallbackLocale ?? this.fallbackLocale,
        initialRoute: initialRoute ?? this.initialRoute,
        customTransition: customTransition ?? this.customTransition,
        home: home ?? this.home,
        testMode: testMode ?? this.testMode,
        unikey: unikey ?? this.unikey,
        theme: theme ?? this.theme,
        darkTheme: darkTheme ?? this.darkTheme,
        themeMode: themeMode ?? this.themeMode,
        defaultPopGesture: defaultPopGesture ?? this.defaultPopGesture,
        defaultOpaqueRoute: defaultOpaqueRoute ?? this.defaultOpaqueRoute,
        defaultTransitionDuration:
            defaultTransitionDuration ?? this.defaultTransitionDuration,
        defaultTransitionCurve:
            defaultTransitionCurve ?? this.defaultTransitionCurve,
        defaultDialogTransitionCurve:
            defaultDialogTransitionCurve ?? this.defaultDialogTransitionCurve,
        defaultDialogTransitionDuration: defaultDialogTransitionDuration ??
            this.defaultDialogTransitionDuration,
        routing: routing ?? this.routing,
        parameters: parameters ?? this.parameters,
      );

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is ConfigData &&
        other.routingCallback == routingCallback &&
        other.defaultTransition == defaultTransition &&
        other.onInit == onInit &&
        other.onReady == onReady &&
        other.onDispose == onDispose &&
        other.enableLog == enableLog &&
        other.logWriterCallback == logWriterCallback &&
        other.smartManagement == smartManagement &&
        listEquals(other.binds, binds) &&
        other.transitionDuration == transitionDuration &&
        other.defaultGlobalState == defaultGlobalState &&
        listEquals(other.getPages, getPages) &&
        other.unknownRoute == unknownRoute &&
        other.routeInformationProvider == routeInformationProvider &&
        other.routeInformationParser == routeInformationParser &&
        other.routerDelegate == routerDelegate &&
        other.backButtonDispatcher == backButtonDispatcher &&
        listEquals(other.navigatorObservers, navigatorObservers) &&
        other.navigatorKey == navigatorKey &&
        other.scaffoldMessengerKey == scaffoldMessengerKey &&
        mapEquals(other.translationsKeys, translationsKeys) &&
        other.translations == translations &&
        other.locale == locale &&
        other.fallbackLocale == fallbackLocale &&
        other.initialRoute == initialRoute &&
        other.customTransition == customTransition &&
        other.home == home &&
        other.testMode == testMode &&
        other.unikey == unikey &&
        other.theme == theme &&
        other.darkTheme == darkTheme &&
        other.themeMode == themeMode &&
        other.defaultPopGesture == defaultPopGesture &&
        other.defaultOpaqueRoute == defaultOpaqueRoute &&
        other.defaultTransitionDuration == defaultTransitionDuration &&
        other.defaultTransitionCurve == defaultTransitionCurve &&
        other.defaultDialogTransitionCurve == defaultDialogTransitionCurve &&
        other.defaultDialogTransitionDuration ==
            defaultDialogTransitionDuration &&
        other.routing == routing &&
        mapEquals(other.parameters, parameters);
  }

  @override
  int get hashCode =>
      routingCallback.hashCode ^
      defaultTransition.hashCode ^
      onInit.hashCode ^
      onReady.hashCode ^
      onDispose.hashCode ^
      enableLog.hashCode ^
      logWriterCallback.hashCode ^
      smartManagement.hashCode ^
      binds.hashCode ^
      transitionDuration.hashCode ^
      defaultGlobalState.hashCode ^
      getPages.hashCode ^
      unknownRoute.hashCode ^
      routeInformationProvider.hashCode ^
      routeInformationParser.hashCode ^
      routerDelegate.hashCode ^
      backButtonDispatcher.hashCode ^
      navigatorObservers.hashCode ^
      navigatorKey.hashCode ^
      scaffoldMessengerKey.hashCode ^
      translationsKeys.hashCode ^
      translations.hashCode ^
      locale.hashCode ^
      fallbackLocale.hashCode ^
      initialRoute.hashCode ^
      customTransition.hashCode ^
      home.hashCode ^
      testMode.hashCode ^
      unikey.hashCode ^
      theme.hashCode ^
      darkTheme.hashCode ^
      themeMode.hashCode ^
      defaultPopGesture.hashCode ^
      defaultOpaqueRoute.hashCode ^
      defaultTransitionDuration.hashCode ^
      defaultTransitionCurve.hashCode ^
      defaultDialogTransitionCurve.hashCode ^
      defaultDialogTransitionDuration.hashCode ^
      routing.hashCode ^
      parameters.hashCode;
}

/// A widget representing the root of a GetX application.
///
/// The [GetRoot] widget serves as the root of a GetX application.
/// It provides configuration data and a child widget to be rendered
/// within the application.
///
/// The [config] parameter is used to provide configuration data
/// for the application.
///
/// The [child] parameter specifies the child widget that will be
/// rendered within the application.
///
/// To access the state of the [GetRoot] widget, you can use the
/// [of] static method, passing the [BuildContext] of the widget
/// where you want to access the state.
class GetRoot extends StatefulWidget {
  /// Constructs a [GetRoot] widget.
  ///
  /// The [config] parameter specifies the configuration data for the application.
  /// The [child] parameter specifies the child widget to be rendered within the application.
  const GetRoot({
    required this.config,
    required this.child,
    super.key,
  });

  /// Configuration data for the application.
  final ConfigData config;

  /// The child widget to be rendered within the application.
  final Widget child;

  @override
  State<GetRoot> createState() => GetRootState();

  /// Retrieves the state of the [GetRoot] widget from the given [BuildContext].
  ///
  /// This method is used to access the state of the [GetRoot] widget from any
  /// descendant widget's [BuildContext].
  ///
  /// If the [BuildContext] provided is not associated with a [GetRoot] widget,
  /// this method will throw a [FlutterError].
  static GetRootState of(BuildContext context) {
    // Handles the case where the input context is a navigator element.
    GetRootState? root;
    if (context is StatefulElement && context.state is GetRootState) {
      root = context.state as GetRootState;
    }
    root = context.findRootAncestorStateOfType<GetRootState>() ?? root;
    assert(() {
      if (root == null) {
        throw FlutterError(
          "GetRoot operation requested with a context that does not include a GetRoot.\n"
          "The context used must be that of a "
          "widget that is a descendant of a GetRoot widget.",
        );
      }
      return true;
    }());
    return root!;
  }
}

/// Manages the state and lifecycle of the [GetRoot] widget.
///
/// [GetRootState] extends [State] and implements [WidgetsBindingObserver]
/// to handle the state and lifecycle of the [GetRoot] widget. It initializes
/// configuration, manages dependencies, and responds to changes in the application's
/// lifecycle.
class GetRootState extends State<GetRoot> with WidgetsBindingObserver {
  static GetRootState? _controller;

  /// The singleton controller for [GetRootState].
  ///
  /// [controller] provides a singleton instance of [GetRootState]
  /// for accessing its methods and properties.
  static GetRootState get controller {
    if (_controller == null) {
      throw Exception("GetRoot is not part of the three");
    } else {
      return _controller!;
    }
  }

  /// Configuration data for the application.
  late ConfigData config;

  @override
  void initState() {
    config = widget.config;
    GetRootState._controller = this;
    ambiguate(Engine.instance)!.addObserver(this);
    onInit();
    super.initState();
  }

  /// Handles cleanup and disposal operations.
  ///
  /// This method is called when the widget is disposed.
  void onClose() {
    config.onDispose?.call();
    Get.clearTranslations();
    config.snackBarQueue.disposeControllers();
    RouterReportManager.instance.clearRouteKeys();
    RouterReportManager.dispose();
    Get.resetInstance();
    _controller = null;
    ambiguate(Engine.instance)!.removeObserver(this);
  }

  @override
  void dispose() {
    onClose();
    super.dispose();
  }

  /// Initializes the widget.
  ///
  /// This method sets up initial configuration, routes, and observers
  /// for the widget.
  void onInit() {
    if (config.getPages == null && config.home == null) {
      throw "You need add pages or home";
    }

    if (config.routerDelegate == null) {
      final GetDelegate newDelegate = GetDelegate.createDelegate(
        pages: config.getPages ??
            <GetPage>[
              GetPage(
                name: cleanRouteName("/${config.home.runtimeType}"),
                page: () => config.home!,
              ),
            ],
        notFoundRoute: config.unknownRoute,
        navigatorKey: config.navigatorKey,
        navigatorObservers: (config.navigatorObservers == null
            ? <NavigatorObserver>[
                GetObserver(config.routingCallback, Get.routing),
              ]
            : <NavigatorObserver>[
                GetObserver(config.routingCallback, config.routing),
                ...config.navigatorObservers!,
              ]),
      );
      config = config.copyWith(routerDelegate: newDelegate);
    }

    if (config.routeInformationParser == null) {
      final GetInformationParser newRouteInformationParser =
          GetInformationParser.createInformationParser(
        initialRoute: config.initialRoute ??
            config.getPages?.first.name ??
            cleanRouteName("/${config.home.runtimeType}"),
      );

      config =
          config.copyWith(routeInformationParser: newRouteInformationParser);
    }

    if (config.locale != null) Get.locale = config.locale;

    if (config.fallbackLocale != null) {
      Get.fallbackLocale = config.fallbackLocale;
    }

    if (config.translations != null) {
      Get.addTranslations(config.translations!.keys);
    } else if (config.translationsKeys != null) {
      Get.addTranslations(config.translationsKeys!);
    }

    Get.smartManagement = config.smartManagement;
    config.onInit?.call();

    Get.isLogEnable = config.enableLog ?? kDebugMode;
    Get.log = config.logWriterCallback ?? defaultLogWriterCallback;

    if (config.defaultTransition == null) {
      config = config.copyWith(defaultTransition: getThemeTransition());
    }

    Future(onReady);
  }

  /// Sets parameters for the application.
  set parameters(Map<String, String?> newParameters) {
    // rootController.parameters = newParameters;
    config = config.copyWith(parameters: newParameters);
  }

  /// Sets test mode for the application.
  set testMode(bool isTest) {
    config = config.copyWith(testMode: isTest);
    // _getxController.testMode = isTest;
  }

  /// Performs actions when the widget is ready.
  ///
  /// This method is called when the widget is fully initialized and ready
  /// to be used.
  void onReady() {
    config.onReady?.call();
  }

  /// Retrieves the theme transition based on the platform.

  Transition? getThemeTransition() {
    final TargetPlatform platform = context.theme.platform;
    final PageTransitionsBuilder? matchingTransition =
        Get.theme.pageTransitionsTheme.builders[platform];
    switch (matchingTransition) {
      case CupertinoPageTransitionsBuilder():
        return Transition.cupertino;
      case ZoomPageTransitionsBuilder():
        return Transition.zoom;
      case FadeUpwardsPageTransitionsBuilder():
        return Transition.fade;
      case OpenUpwardsPageTransitionsBuilder():
        return Transition.native;
      default:
        return null;
    }
  }

  @override
  void didChangeLocales(List<Locale>? locales) {
    Get.asap(() {
      final Locale? locale = Get.deviceLocale;
      if (locale != null) {
        Get.updateLocale(locale);
      }
    });
  }

  /// Sets the theme for the application.
  void setTheme(ThemeData value) {
    if (value.brightness == Brightness.light || config.darkTheme == null) {
      config = config.copyWith(theme: value);
    } else {
      config = config.copyWith(darkTheme: value);
    }
    update();
  }

  /// Sets the theme mode for the application.
  void setThemeMode(ThemeMode value) {
    config = config.copyWith(themeMode: value);
    update();
  }

  /// Restarts the application.
  void restartApp() {
    config = config.copyWith(unikey: UniqueKey());
    update();
  }

  /// Updates the widget state.
  void update() {
    context.visitAncestorElements((Element element) {
      element.markNeedsBuild();
      return false;
    });
  }

  /// Retrieves the key of the root navigator.
  GlobalKey<NavigatorState> get key => rootDelegate.navigatorKey;

  /// Retrieves the root delegate.
  GetDelegate get rootDelegate => config.routerDelegate! as GetDelegate;

  /// Retrieves the route information parser.
  RouteInformationParser<Object> get informationParser =>
      config.routeInformationParser!;

  /// Adds a new key to the navigator.
  ///
  /// Returns the updated navigator key.
  GlobalKey<NavigatorState>? addKey(GlobalKey<NavigatorState> newKey) {
    rootDelegate.navigatorKey = newKey;
    return key;
  }

  Map<String, GetDelegate> keys = <String, GetDelegate>{};

  /// Nested key management for routing.
  ///
  /// Returns a delegate associated with the provided key.
  GetDelegate? nestedKey(String? key) {
    if (key == null) {
      return rootDelegate;
    }
    keys.putIfAbsent(
      key,
      () => GetDelegate(
        showHashOnUrl: true,
        //debugLabel: 'Getx nested key: ${key.toString()}',
        pages: RouteDecoder.fromRoute(key).currentChildren ?? <GetPage>[],
      ),
    );
    return keys[key];
  }

  @override
  Widget build(BuildContext context) => widget.child;
}
