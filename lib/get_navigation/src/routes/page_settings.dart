import "package:flutter/widgets.dart";
import "package:refreshed/route_manager.dart";

/// Extension methods for [BuildContext] to provide convenient access to page-related information.
///
/// These extension methods facilitate accessing page settings, arguments, parameters,
/// router information, and delegate within a build context.
extension PageArgExtension<T> on BuildContext {
  /// Retrieves the route settings associated with the current modal route.
  RouteSettings? get settings => ModalRoute.of(this)!.settings;

  /// Retrieves the [PageSettings] associated with the current modal route's settings arguments.
  PageSettings? get pageSettings => settings?.arguments is PageSettings
      ? settings!.arguments as PageSettings
      : null;

  /// Retrieves the arguments associated with the current modal route's settings.
  dynamic get arguments => pageSettings?.arguments ?? settings?.arguments;

  /// Retrieves the parameters associated with the current modal route's settings arguments.
  Map<String, String> get params => pageSettings?.params ?? {};

  /// Retrieves the [Router] associated with the current build context.
  Router<T> get router => Router.of(this);

  /// Retrieves the location (path) associated with the current build context.
  String get location {
    final RouteInformationParser? parser = router.routeInformationParser;
    final RouteDecoder? config = delegate.currentConfiguration;
    return parser?.restoreRouteInformation(config)?.uri.path ?? "/";
  }

  /// Retrieves the delegate associated with the current router.
  GetDelegate get delegate => router.routerDelegate as GetDelegate;
}

/// A custom implementation of [RouteSettings] representing settings specific to a page.
class PageSettings extends RouteSettings {
  /// Constructs a [PageSettings] object with the given URI and optional arguments.
  PageSettings(
    this.uri, [
    Object? arguments,
  ]) : super(arguments: arguments);

  @override
  String get name => "$uri";

  /// The URI associated with the page settings.
  final Uri uri;

  /// Parameters associated with the page.
  final Map<String, String> params = <String, String>{};

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
  PageSettings copy({
    Uri? uri,
    Object? arguments,
  }) =>
      PageSettings(
        uri ?? this.uri,
        arguments ?? this.arguments,
      );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is PageSettings &&
          other.uri == uri &&
          other.arguments == arguments);

  @override
  int get hashCode => Object.hash(uri, arguments);
}
