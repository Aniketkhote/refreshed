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
  PageSettings? get pageSettings => switch (settings?.arguments) {
        PageSettings ps => ps,
        _ => null,
      };

  /// Retrieves the arguments associated with the current modal route's settings.
  dynamic get arguments => pageSettings?.arguments ?? settings?.arguments;

  /// Retrieves the parameters associated with the current modal route's settings arguments.
  Map<String, String> get params => pageSettings?.params ?? {};

  /// Retrieves the [Router] associated with the current build context.
  Router<T> get router => Router.of(this);

  /// Retrieves the location (path) associated with the current build context.
  String get location =>
      switch ((delegate.currentConfiguration, router.routeInformationParser)) {
        // No configuration available, return root path
        (null, _) => "/",

        // Configuration exists and parser is compatible
        (RouteDecoder config, RouteInformationParser<RouteDecoder> parser) =>
          parser.restoreRouteInformation(config)?.uri.path ?? "/",

        // Configuration exists but parser is not compatible
        _ => "/",
      };

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
  ///
  /// Uses the cascade operator for cleaner syntax when creating a new instance with
  /// mostly the same properties as the original.
  PageSettings copy({
    Uri? uri,
    Object? arguments,
  }) =>
      PageSettings(
        uri ?? this.uri,
        arguments ?? this.arguments,
      );

  @override
  bool operator ==(Object other) => switch (other) {
        PageSettings ps => uri == ps.uri && arguments == ps.arguments,
        _ => identical(this, other),
      };

  @override
  int get hashCode => Object.hash(uri, arguments);
}
