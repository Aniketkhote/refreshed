import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';

import '../../../refreshed.dart';

class GetInformationParser extends RouteInformationParser<RouteDecoder> {
  factory GetInformationParser.createInformationParser({
    String initialRoute = '/',
  }) {
    return GetInformationParser(initialRoute: initialRoute);
  }

  final String initialRoute;

  GetInformationParser({
    required this.initialRoute,
  }) {
    Get.log(
        'GetInformationParser has been created with initial route: $initialRoute');
  }

  /// Parses route information from the platform and converts it to a RouteDecoder
  ///
  /// This method handles:
  /// 1. Empty or root routes, checking if a registered route exists
  /// 2. Falling back to initialRoute when no root route is registered
  /// 3. Using the provided path for all other routes
  @override
  SynchronousFuture<RouteDecoder> parseRouteInformation(
    RouteInformation routeInformation,
  ) {
    final uri = routeInformation.uri;
    final pathString = uri.toString();
    
    // Determine the location using pattern matching on the path and root route existence
    final String location;
    
    // Check empty/root path with pattern matching on root route existence
    if (pathString.isEmpty || pathString == '/') {
      if (!_hasRegisteredRootRoute()) {
        // No registered root route - use initialRoute
        Get.log('No route found, redirecting to initialRoute: $initialRoute');
        location = initialRoute;
      } else {
        // Registered root route exists - use root path
        location = '/';
      }
    } else {
      // Any other path - use as is
      location = pathString;
    }

    // Log the final route location being parsed
    Get.log('GetInformationParser: Parsing route location: $location');

    // Return the RouteDecoder based on the final location
    return SynchronousFuture(RouteDecoder.fromRoute(location));
  }
  
  /// Helper method to check if a root route ('/') is registered
  bool _hasRegisteredRootRoute() => 
      (Get.rootController.rootDelegate)
          .registeredRoutes
          .any((element) => element.name == '/');

  /// Restores route information from a RouteDecoder for platform navigation
  ///
  /// This method:
  /// 1. Extracts the route name from the configuration
  /// 2. Parses it into a URI
  /// 3. Creates a RouteInformation object for the platform
  @override
  RouteInformation restoreRouteInformation(RouteDecoder configuration) {
    // Extract route name and parse URI using pattern matching
    final (routeName, uri) = switch (configuration.pageSettings?.name) {
      // When name is available, use it and parse to URI
      String name => (name, Uri.tryParse(name)),
      // When name is null, use empty string with null URI
      null => ('', null),
    };

    // Log the route being restored
    Get.log('Restoring route information for route: $routeName');

    // Return route information with the parsed URI
    return RouteInformation(
      uri: uri,
      state: null,
    );
  }
}
