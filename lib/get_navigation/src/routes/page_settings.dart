import "package:flutter/widgets.dart";

import 'package:refreshed/route_manager.dart';

/// Extension methods for [BuildContext] to provide convenient access to page-related information.
///
/// These extension methods facilitate accessing page settings, arguments, parameters,
/// router information, and delegate within a build context.
///
/// Example usage:
///
/// ```dart
/// final settings = context.settings;
/// final pageSettings = context.pageSettings;
/// final arguments = context.arguments;
/// final params = context.params;
/// final router = context.router;
/// final location = context.location;
/// final delegate = context.delegate;
/// ```
extension PageArgExt on BuildContext {
  /// Retrieves the route settings associated with the current modal route.
  RouteSettings? get settings {
    return ModalRoute.of(this)!.settings;
  }

  /// Retrieves the [PageSettings] associated with the current modal route's settings arguments.
  PageSettings? get pageSettings {
    final args = ModalRoute.of(this)?.settings.arguments;
    if (args is PageSettings) {
      return args;
    }
    return null;
  }

  /// Retrieves the arguments associated with the current modal route's settings.
  dynamic get arguments {
    final args = settings?.arguments;
    if (args is PageSettings) {
      return args.arguments;
    } else {
      return args;
    }
  }

  /// Retrieves the parameters associated with the current modal route's settings arguments.
  Map<String, String> get params {
    final args = settings?.arguments;
    if (args is PageSettings) {
      return args.params;
    } else {
      return {};
    }
  }

  /// Retrieves the [Router] associated with the current build context.
  Router get router {
    return Router.of(this);
  }

  /// Retrieves the location (path) associated with the current build context.
  String get location {
    final parser = router.routeInformationParser;
    final config = delegate.currentConfiguration;
    return parser?.restoreRouteInformation(config)?.uri.path ?? "/";
  }

  /// Retrieves the delegate associated with the current router.
  GetDelegate get delegate {
    return router.routerDelegate as GetDelegate;
  }
}

/// A custom implementation of [RouteSettings] representing settings specific to a page.
///
/// This class extends [RouteSettings] to provide additional functionality and data
/// related to a page's URI, path, parameters, and query parameters.
///
/// Example usage:
///
/// ```dart
/// final pageSettings = PageSettings(Uri.parse('/example'));
/// final path = pageSettings.path;
/// final queryParameters = pageSettings.query;
/// ```
class PageSettings extends RouteSettings {
  /// Constructs a [PageSettings] object with the given URI and optional arguments.
  ///
  /// The [uri] parameter specifies the URI associated with the page settings.
  /// The optional [arguments] parameter can be provided to pass additional arguments.
  PageSettings(
    this.uri, [
    Object? arguments,
  ]) : super(arguments: arguments);

  @override
  String get name => "$uri";

  /// The URI associated with the page settings.
  final Uri uri;

  /// Parameters associated with the page.
  final params = <String, String>{};

  /// Retrieves the path component of the URI.
  String get path => uri.path;

  /// Retrieves the path segments of the URI.
  List<String> get paths => uri.pathSegments;

  /// Retrieves the query parameters of the URI.
  Map<String, String> get query => uri.queryParameters;

  /// Retrieves all the query parameters of the URI.
  Map<String, List<String>> get queries => uri.queryParametersAll;

  @override
  String toString() => name;

  /// Creates a copy of this [PageSettings] object with optional parameters overridden.
  ///
  /// The optional [uri] parameter allows specifying a new URI for the copy.
  /// The optional [arguments] parameter allows specifying new arguments for the copy.
  PageSettings copy({
    Uri? uri,
    Object? arguments,
  }) {
    return PageSettings(
      uri ?? this.uri,
      arguments ?? this.arguments,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is PageSettings &&
        other.uri == uri &&
        other.arguments == arguments;
  }

  @override
  int get hashCode => uri.hashCode ^ arguments.hashCode;
}
