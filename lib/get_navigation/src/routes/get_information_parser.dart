import "package:flutter/foundation.dart";
import "package:flutter/widgets.dart";
import "package:refreshed/refreshed.dart";

/// A route information parser for decoding route information into [RouteDecoder].
class GetInformationParser<T> extends RouteInformationParser<RouteDecoder<T>> {
  /// Creates a [GetInformationParser] instance with the provided initial route.
  ///
  /// The [initialRoute] parameter specifies the route to navigate to if the current location is empty or "/"
  /// and there is no corresponding page registered.
  GetInformationParser({
    required this.initialRoute,
  }) {
    Get.log("GetInformationParser is created !");
  }

  /// Creates a [GetInformationParser] instance with the provided initial route.
  ///
  /// This is a named constructor that provides a more readable way to create an instance of [GetInformationParser].
  factory GetInformationParser.createInformationParser({
    String initialRoute = "/",
  }) =>
      GetInformationParser<T>(initialRoute: initialRoute);

  /// The initial route to navigate to if the current location is empty or "/" and there is no corresponding page registered.
  final String initialRoute;

  @override
  SynchronousFuture<RouteDecoder<T>> parseRouteInformation(
    RouteInformation routeInformation,
  ) {
    final Uri uri = routeInformation.uri;
    String location = uri.toString();
    if (location == "/") {
      // Check if there is a corresponding page. If not, relocate to initialRoute.
      if (!(Get.rootController.rootDelegate.registeredRoutes
              as List<GetPage<T>>)
          .any((GetPage<T> element) => element.name == "/")) {
        location = initialRoute;
      }
    } else if (location.isEmpty) {
      location = initialRoute;
    }

    Get.log("GetInformationParser: route location: $location");

    return SynchronousFuture<RouteDecoder<T>>(
      RouteDecoder<T>.fromRoute(location),
    );
  }

  @override
  RouteInformation restoreRouteInformation(RouteDecoder<T> configuration) =>
      RouteInformation(
        uri: Uri.tryParse(configuration.pageSettings?.name ?? ""),
      );
}
