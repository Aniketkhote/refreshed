import "package:flutter/foundation.dart";
import "package:refreshed/get_navigation/src/routes/new_path_route.dart";
import "package:refreshed/refreshed.dart";

@immutable
class RouteDecoder<T> {
  const RouteDecoder(
    this.currentTreeBranch,
    this.pageSettings,
  );

  factory RouteDecoder.fromRoute(String location) {
    final Uri uri = Uri.parse(location);
    final PageSettings args = PageSettings(uri);
    final RouteDecoder<T> decoder = Get.rootController.rootDelegate
        .matchRoute(location, arguments: args) as RouteDecoder<T>;
    decoder.route = decoder.route?.copyWith(
      completer: null,
      arguments: args,
      parameters: args.params,
    );
    return decoder;
  }
  final List<GetPage<T>> currentTreeBranch;
  final PageSettings? pageSettings;

  GetPage<T>? get route =>
      currentTreeBranch.isEmpty ? null : currentTreeBranch.last;

  GetPage routeOrUnknown(GetPage onUnknow) =>
      currentTreeBranch.isEmpty ? onUnknow : currentTreeBranch.last;

  set route(GetPage<T>? getPage) {
    if (getPage == null) {
      return;
    }
    if (currentTreeBranch.isEmpty) {
      currentTreeBranch.add(getPage);
    } else {
      currentTreeBranch[currentTreeBranch.length - 1] = getPage;
    }
  }

  List<GetPage<T>>? get currentChildren => route!.children as List<GetPage<T>>;

  Map<String, String> get parameters =>
      pageSettings?.params ?? <String, String>{};

  dynamic get args => pageSettings?.arguments;

  T? arguments() {
    final Object? args = pageSettings?.arguments;
    if (args is T) {
      return pageSettings?.arguments as T;
    } else {
      return null;
    }
  }

  void replaceArguments(Object? arguments) {
    final GetPage<T>? newRoute = route;
    if (newRoute != null) {
      final int index = currentTreeBranch.indexOf(newRoute);
      currentTreeBranch[index] = newRoute.copyWith(arguments: arguments);
    }
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }

    return other is RouteDecoder &&
        listEquals(other.currentTreeBranch, currentTreeBranch) &&
        other.pageSettings == pageSettings;
  }

  @override
  int get hashCode => currentTreeBranch.hashCode ^ pageSettings.hashCode;

  @override
  String toString() =>
      "RouteDecoder(currentTreeBranch: $currentTreeBranch, pageSettings: $pageSettings)";
}

class ParseRouteTree<T> {
  ParseRouteTree({
    required this.routes,
  });

  final List<GetPage<T>> routes;

  RouteDecoder<T> matchRoute(String name, {PageSettings? arguments}) {
    final Uri uri = Uri.parse(name);
    final Iterable<String> split =
        uri.path.split("/").where((String element) => element.isNotEmpty);
    String curPath = "/";
    final List<String> cumulativePaths = <String>[
      "/",
    ];
    for (final String item in split) {
      if (curPath.endsWith("/")) {
        curPath += item;
      } else {
        curPath += "/$item";
      }
      cumulativePaths.add(curPath);
    }

    final List<MapEntry<String, GetPage<T>>> treeBranch = cumulativePaths
        .map((String e) => MapEntry<String, GetPage<T>?>(e, _findRoute(e)))
        .where((MapEntry<String, GetPage<T>?> element) => element.value != null)

        ///Prevent page be disposed
        .map(
          (MapEntry<String, GetPage<T>?> e) => MapEntry<String, GetPage<T>>(
            e.key,
            e.value!.copyWith(
              key: ValueKey<String>(e.key),
            ),
          ),
        )
        .toList();

    final Map<String, String> params =
        Map<String, String>.from(uri.queryParameters);
    if (treeBranch.isNotEmpty) {
      //route is found, do further parsing to get nested query params
      final MapEntry<String, GetPage<T>> lastRoute = treeBranch.last;
      final Map<String, String> parsedParams =
          _parseParams(name, lastRoute.value.path);
      if (parsedParams.isNotEmpty) {
        params.addAll(parsedParams);
      }
      //copy parameters to all pages.
      final List<GetPage<T>> mappedTreeBranch = treeBranch
          .map(
            (MapEntry<String, GetPage<T>> e) => e.value.copyWith(
              parameters: <String, String>{
                if (e.value.parameters != null) ...e.value.parameters!,
                ...params,
              },
              name: e.key,
            ),
          )
          .toList();
      arguments?.params.clear();
      arguments?.params.addAll(params);
      return RouteDecoder<T>(
        mappedTreeBranch,
        arguments,
      );
    }

    arguments?.params.clear();
    arguments?.params.addAll(params);

    //route not found
    return RouteDecoder<T>(
      treeBranch.map((MapEntry<String, GetPage<T>> e) => e.value).toList(),
      arguments,
    );
  }

  void addRoutes(List<GetPage<T>> getPages) {
    for (final GetPage<T> route in getPages) {
      addRoute(route);
    }
  }

  void removeRoutes(List<GetPage<T>> getPages) {
    for (final GetPage<T> route in getPages) {
      removeRoute(route);
    }
  }

  void removeRoute(GetPage<T> route) {
    routes.remove(route);
    for (final GetPage<T> page in _flattenPage(route)) {
      removeRoute(page);
    }
  }

  void addRoute(GetPage<T> route) {
    routes.add(route);

    // Add Page children.
    for (final GetPage<T> page in _flattenPage(route)) {
      addRoute(page);
    }
  }

  List<GetPage<T>> _flattenPage(GetPage<T> route) {
    final List<GetPage<T>> result = <GetPage<T>>[];
    if (route.children.isEmpty) {
      return result;
    }

    final String parentPath = route.name;
    for (final GetPage<T> page in route.children as List<GetPage<T>>) {
      // Add Parent middlewares to children
      final List<GetMiddleware<T>> parentMiddlewares = <GetMiddleware<T>>[
        if (page.middlewares.isNotEmpty)
          ...page.middlewares as List<GetMiddleware<T>>,
        if (route.middlewares.isNotEmpty)
          ...route.middlewares as List<GetMiddleware<T>>,
      ];

      final List<BindingsInterface<T>> parentBindings = <BindingsInterface<T>>[
        if (page.binding != null) page.binding! as BindingsInterface<T>,
        if (page.bindings.isNotEmpty)
          ...page.bindings as List<BindingsInterface<T>>,
        if (route.bindings.isNotEmpty)
          ...route.bindings as List<BindingsInterface<T>>,
      ];

      final List<Bind<T>> parentBinds = <Bind<T>>[
        if (page.binds.isNotEmpty) ...page.binds as List<Bind<T>>,
        if (route.binds.isNotEmpty) ...route.binds as List<Bind<T>>,
      ];

      result.add(
        _addChild(
          page,
          parentPath,
          parentMiddlewares,
          parentBindings,
          parentBinds,
        ),
      );

      final List<GetPage<T>> children = _flattenPage(page);
      for (final GetPage<T> child in children) {
        result.add(
          _addChild(
            child,
            parentPath,
            <GetMiddleware<T>>[
              ...parentMiddlewares,
              if (child.middlewares.isNotEmpty)
                ...child.middlewares as List<GetMiddleware<T>>,
            ],
            <BindingsInterface<T>>[
              ...parentBindings,
              if (child.binding != null) child.binding! as BindingsInterface<T>,
              if (child.bindings.isNotEmpty)
                ...child.bindings as List<BindingsInterface<T>>,
            ],
            <Bind<T>>[
              ...parentBinds,
              if (child.binds.isNotEmpty) ...child.binds as List<Bind<T>>,
            ],
          ),
        );
      }
    }
    return result;
  }

  /// Change the Path for a [GetPage]
  GetPage<T> _addChild(
    GetPage<T> origin,
    String parentPath,
    List<GetMiddleware<T>> middlewares,
    List<BindingsInterface<T>> bindings,
    List<Bind<T>> binds,
  ) =>
      origin.copyWith(
        middlewares: middlewares,
        name: origin.inheritParentPath
            ? (parentPath + origin.name).replaceAll("//", "/")
            : origin.name,
        bindings: bindings,
        binds: binds,
        // key:
      );

  GetPage<T>? _findRoute(String name) {
    final GetPage<T>? value = routes.firstWhereOrNull(
      (GetPage<T> route) => route.path.regex.hasMatch(name),
    );

    return value;
  }

  Map<String, String> _parseParams(String path, PathDecoded routePath) {
    final Map<String, String> params = <String, String>{};
    final int idx = path.indexOf("?");
    if (idx > -1) {
      path = path.substring(0, idx);
      final Uri? uri = Uri.tryParse(path);
      if (uri != null) {
        params.addAll(uri.queryParameters);
      }
    }
    final RegExpMatch? paramsMatch = routePath.regex.firstMatch(path);

    for (int i = 0; i < routePath.keys.length; i++) {
      final String param = Uri.decodeQueryComponent(paramsMatch![i + 1]!);
      params[routePath.keys[i]!] = param;
    }
    return params;
  }
}
