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

  @override
  SynchronousFuture<RouteDecoder> parseRouteInformation(
    RouteInformation routeInformation,
  ) {
    final uri = routeInformation.uri;
    var location = uri.toString();

    // Check if location is empty or root route, and adjust accordingly
    if (location.isEmpty || location == '/') {
      // Check if there's a corresponding route registered for '/'
      if (!(Get.rootController.rootDelegate)
          .registeredRoutes
          .any((element) => element.name == '/')) {
        location = initialRoute;
        Get.log(
            'No route found for "/", redirecting to initialRoute: $initialRoute');
      } else {
        Get.log('Root route ("/") is valid, continuing with it');
      }
    }

    // Log the final route location being parsed
    Get.log('GetInformationParser: Parsing route location: $location');

    // Return the RouteDecoder based on the final location
    return SynchronousFuture(RouteDecoder.fromRoute(location));
  }

  @override
  RouteInformation restoreRouteInformation(RouteDecoder configuration) {
    final routeName = configuration.pageSettings?.name ?? '';
    final uri = Uri.tryParse(routeName);

    // Log the route being restored
    Get.log('Restoring route information for route: $routeName');

    return RouteInformation(
      uri: uri,
      state: null,
    );
  }
}
