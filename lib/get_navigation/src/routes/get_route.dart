import "dart:async";

import "package:flutter/foundation.dart";
import "package:flutter/material.dart";
import "package:refreshed/refreshed.dart";

/// A page configuration for a route within the GetX navigation system.
///
/// This class extends [Page] and provides additional properties and methods specific to GetX routing.
class GetPage<T> extends Page<T> {
  /// Creates a [GetPage] with the specified configuration.
  GetPage({
    required this.name,
    required this.page,
    this.title,
    this.participatesInRootNavigator,
    this.gestureWidth,
    this.maintainState = true,
    this.curve = Curves.linear,
    this.alignment,
    this.parameters,
    this.opaque = true,
    this.transitionDuration,
    this.reverseTransitionDuration,
    this.popGesture,
    this.binding,
    this.bindings = const <BindingsInterface<dynamic>>[],
    this.binds = const <Bind<dynamic>>[],
    this.transition,
    this.customTransition,
    this.fullscreenDialog = false,
    this.children = const <GetPage<dynamic>>[],
    this.middlewares = const <GetMiddleware<dynamic>>[],
    this.unknownRoute,
    this.arguments,
    this.showCupertinoParallax = true,
    this.preventDuplicates = true,
    this.preventDuplicateHandlingMode =
        PreventDuplicateHandlingMode.reorderRoutes,
    this.completer,
    this.inheritParentPath = true,
    LocalKey? key,
  })  : path = _nameToRegex(name),
        assert(
          name.startsWith("/"),
          "It is necessary to start route name [$name] with a slash: /$name",
        ),
        super(
          key: key ?? ValueKey<String>(name),
          name: name,
        );

  /// The builder function that returns the widget for the route.
  final GetPageBuilder page;

  /// Whether the route should support pop gesture to navigate back.
  final bool? popGesture;

  /// Parameters associated with the route.
  final Map<String, String>? parameters;

  /// The title of the route.
  final String? title;

  /// The transition animation to use when navigating to the route.
  final Transition? transition;

  /// The animation curve for the transition.
  final Curve curve;

  /// Whether the route should be displayed as a fullscreen dialog.
  final bool? participatesInRootNavigator;

  /// The alignment of the route within the screen.
  final Alignment? alignment;

  /// Whether the route should maintain its state when pushed or popped.
  final bool maintainState;

  /// Whether the route should obscure the entire screen.
  final bool opaque;

  /// The width of the gesture area for edge-swipe navigation.
  final double Function(BuildContext context)? gestureWidth;

  /// The bindings to be associated with the route.
  final BindingsInterface<dynamic>? binding;

  /// Additional bindings to be associated with the route.
  final List<BindingsInterface<dynamic>> bindings;

  /// Data binding configurations for the route.
  final List<Bind<dynamic>> binds;

  /// Custom transition animation for the route.
  final CustomTransition? customTransition;

  /// The duration of the transition animation.
  final Duration? transitionDuration;

  /// The duration of the reverse transition animation.
  final Duration? reverseTransitionDuration;

  /// Whether the route should be displayed as a fullscreen dialog.
  final bool fullscreenDialog;

  /// Whether to prevent duplicate routes.
  final bool preventDuplicates;

  /// A completer for the route.
  final Completer<T?>? completer;

  @override
  final Object? arguments;

  /// The route name.
  @override
  final String name;

  /// Whether to inherit the parent path for nested routes.
  final bool inheritParentPath;

  /// The nested routes.
  final List<GetPage<dynamic>> children;

  /// Middlewares for the route.
  final List<GetMiddleware<dynamic>> middlewares;

  /// The path regex for the route.
  final PathDecoded path;

  /// The unknown route for handling navigation to undefined routes.
  final GetPage<dynamic>? unknownRoute;

  /// Whether to show the Cupertino-style parallax effect for iOS.
  final bool showCupertinoParallax;

  /// The handling mode for preventing duplicate routes.
  final PreventDuplicateHandlingMode preventDuplicateHandlingMode;

  /// Creates a copy of this [GetPage] with the given fields replaced by the new values.
  GetPage<T> copyWith({
    LocalKey? key,
    String? name,
    GetPageBuilder? page,
    bool? popGesture,
    Map<String, String>? parameters,
    String? title,
    Transition? transition,
    Curve? curve,
    Alignment? alignment,
    bool? maintainState,
    bool? opaque,
    List<BindingsInterface<dynamic>>? bindings,
    BindingsInterface<T>? binding,
    List<Bind<dynamic>>? binds,
    CustomTransition? customTransition,
    Duration? transitionDuration,
    Duration? reverseTransitionDuration,
    bool? fullscreenDialog,
    RouteSettings? settings,
    List<GetPage<T>>? children,
    GetPage<dynamic>? unknownRoute,
    List<GetMiddleware<dynamic>>? middlewares,
    bool? preventDuplicates,
    double Function(BuildContext context)? gestureWidth,
    bool? participatesInRootNavigator,
    Object? arguments,
    bool? showCupertinoParallax,
    Completer<T?>? completer,
    bool? inheritParentPath,
  }) =>
      GetPage<T>(
        key: key ?? this.key,
        participatesInRootNavigator:
            participatesInRootNavigator ?? this.participatesInRootNavigator,
        preventDuplicates: preventDuplicates ?? this.preventDuplicates,
        name: name ?? this.name,
        page: page ?? this.page,
        popGesture: popGesture ?? this.popGesture,
        parameters: parameters ?? this.parameters,
        title: title ?? this.title,
        transition: transition ?? this.transition,
        curve: curve ?? this.curve,
        alignment: alignment ?? this.alignment,
        maintainState: maintainState ?? this.maintainState,
        opaque: opaque ?? this.opaque,
        bindings: bindings ?? this.bindings,
        binds: binds ?? this.binds,
        binding: binding ?? this.binding,
        customTransition: customTransition ?? this.customTransition,
        transitionDuration: transitionDuration ?? this.transitionDuration,
        reverseTransitionDuration:
            reverseTransitionDuration ?? this.reverseTransitionDuration,
        fullscreenDialog: fullscreenDialog ?? this.fullscreenDialog,
        children: children ?? this.children,
        unknownRoute: unknownRoute ?? this.unknownRoute,
        middlewares: middlewares ?? this.middlewares,
        gestureWidth: gestureWidth ?? this.gestureWidth,
        arguments: arguments ?? this.arguments,
        showCupertinoParallax:
            showCupertinoParallax ?? this.showCupertinoParallax,
        completer: completer ?? this.completer,
        inheritParentPath: inheritParentPath ?? this.inheritParentPath,
      );

  @override
  Route<T> createRoute(BuildContext context) {
    final GetPageRoute<T> page = PageRedirect(
      route: this,
      settings: this,
      unknownRoute: unknownRoute,
    ).getPageToRoute<T>(this, unknownRoute, context);

    return page;
  }

  static PathDecoded _nameToRegex(String path) {
    final List<String?> keys = <String?>[];

    String recursiveReplace(Match pattern) {
      final StringBuffer buffer = StringBuffer("(?:");

      if (pattern[1] != null) {
        buffer.write(".");
      }
      buffer.write(r"([\w%+-._~!$&'()*,;=:@]+))");
      if (pattern[3] != null) {
        buffer.write("?");
      }

      keys.add(pattern[2]);
      return "$buffer";
    }

    final String stringPath = "$path/?"
        .replaceAllMapped(RegExp(r"(\.)?:(\w+)(\?)?"), recursiveReplace)
        .replaceAll("//", "/");

    return PathDecoded(RegExp("^$stringPath\$"), keys);
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }
    return other is GetPage<T> && other.key == key;
  }

  @override
  String toString() =>
      '${objectRuntimeType(this, 'Page')}("$name", $key, $arguments)';

  @override
  int get hashCode => key.hashCode;
}

/// Represents a decoded path pattern used for route matching.
@immutable
class PathDecoded {
  /// Creates a [PathDecoded] with the specified regex and keys.
  const PathDecoded(this.regex, this.keys);

  /// The regular expression used for route matching.
  final RegExp regex;

  /// The list of keys extracted from the path pattern.
  final List<String?> keys;

  @override
  int get hashCode => regex.hashCode;

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }

    return other is PathDecoded && other.regex == regex;
  }
}
