import 'package:flutter/material.dart';
import 'package:refreshed/get_navigation/src/router_report.dart';
import 'package:refreshed/instance_manager.dart';
import 'package:refreshed/refreshed.dart';

/// A class to manage dependencies within the application.
/// This class provides methods to register, find, delete, and manage dependencies
/// in a centralized manner. It leverages GetX for state management and dependency
/// injection. This allows for lazy loading, lifecycle management, and the ability
/// to work with isolated instances when needed.
class Dependencies {
  /// Registers a lazy singleton dependency.
  /// The [fenix] flag determines whether the dependency should be reconstructed
  /// when disposed.
  ///
  /// [S] is the type of the dependency, [builder] is the function to create the instance,
  /// and [tag] is an optional identifier for the instance.
  void lazyPut<S>(InstanceBuilderCallback<S> builder,
      {String? tag, bool fenix = false}) {
    Get.lazyPut<S>(builder, tag: tag, fenix: fenix);
  }

  /// Finds and retrieves a dependency of type [S].
  ///
  /// [S] is the type of the dependency to find.
  S call<S>() => find<S>();

  /// Creates and manages a background isolate dependency.
  /// The [permanent] flag determines whether the instance will persist permanently.
  void spawn<S>(InstanceBuilderCallback<S> builder,
      {String? tag, bool permanent = true}) {
    Get.spawn<S>(builder, tag: tag, permanent: permanent);
  }

  /// Finds and retrieves a dependency of type [S].
  /// [tag] is an optional identifier to retrieve a tagged instance.
  S find<S>({String? tag}) => Get.find<S>(tag: tag);

  /// Registers a dependency of type [S] directly.
  /// It will be used as a singleton or as a permanent instance.
  S put<S>(S dependency,
      {String? tag,
      bool permanent = false,
      InstanceBuilderCallback<S>? builder}) {
    return Get.put<S>(dependency, tag: tag, permanent: permanent);
  }

  /// Deletes a registered dependency.
  /// [tag] is an optional identifier, and [force] determines whether to forcibly delete.
  bool delete<S>({String? tag, bool force = false}) =>
      Get.delete<S>(tag: tag, force: force);

  /// Deletes all registered dependencies in the application.
  /// [force] determines whether to force the deletion.
  void deleteAll({bool force = false}) => Get.deleteAll(force: force);

  /// Reloads all registered dependencies in the application.
  /// [force] determines whether to force the reload.
  void reloadAll({bool force = false}) => Get.reloadAll(force: force);

  /// Reloads a specific dependency of type [S].
  /// Optionally, [tag] and [key] can be provided to identify the dependency.
  void reload<S>({String? tag, String? key, bool force = false}) =>
      Get.reload<S>(tag: tag, key: key, force: force);

  /// Checks if a dependency is registered.
  bool isRegistered<S>({String? tag}) => Get.isRegistered<S>(tag: tag);

  /// Checks if a dependency is prepared.
  bool isPrepared<S>({String? tag}) => Get.isPrepared<S>(tag: tag);

  /// Replaces a registered dependency with a new one.
  /// [P] is the type of the dependency being replaced, and [child] is the new instance.
  void replace<P>(P child, {String? tag}) async {
    final InstanceInfo info = Get.getInstanceInfo<P>(tag: tag);
    final bool permanent = info.isPermanent ?? false;
    delete<P>(tag: tag, force: permanent);
    put(child, tag: tag, permanent: permanent);
  }

  /// Registers a lazy singleton dependency, replacing any existing dependency.
  /// This allows for automatic recreation of the dependency if disposed.
  void lazyReplace<P>(InstanceBuilderCallback<P> builder,
      {String? tag, bool? fenix}) {
    final InstanceInfo info = Get.getInstanceInfo<P>(tag: tag);
    final bool permanent = info.isPermanent ?? false;
    delete<P>(tag: tag, force: permanent);
    lazyPut(builder, tag: tag, fenix: fenix ?? permanent);
  }
}

/// Abstract class representing a module in the application.
/// Each module has its own UI and dependency setup.
abstract class Module extends StatefulWidget {
  const Module({super.key});

  /// Defines the UI of the module.
  /// This method should return the widget that represents the module's UI.
  Widget view(BuildContext context);

  /// Sets up dependencies required by the module.
  /// This method allows the module to register its specific dependencies.
  void dependencies(Dependencies i);

  @override
  ModuleState createState() => ModuleState();
}

/// State class that manages the lifecycle of the [Module] widget.
/// It handles setting up dependencies and reporting route information.
class ModuleState extends State<Module> {
  @override
  void initState() {
    super.initState();

    /// Report the current route to the router manager.
    RouterReportManager.instance.reportCurrentRoute(this);

    /// Set up dependencies for the module.
    widget.dependencies(Dependencies());
  }

  @override
  void dispose() {
    super.dispose();

    /// Report the route disposal to the router manager.
    RouterReportManager.instance.reportRouteDispose(this);
  }

  @override
  Widget build(BuildContext context) => widget.view(context);
}
