import "package:flutter/material.dart";
import "package:refreshed/get_navigation/src/router_report.dart";
import "package:refreshed/instance_manager.dart";

/// A class to manage dependencies within the application.
class Dependencies {
  /// Registers a lazy singleton dependency.
  void lazyPut<S>(
    InstanceBuilderCallback<S> builder, {
    String? tag,
    bool fenix = false,
  }) {
    Get.lazyPut<S>(builder, tag: tag, fenix: fenix);
  }

  /// Finds and retrieves a dependency.
  S call<S>() => find<S>();

  /// Creates and manages a background isolate dependency.
  void spawn<S>(
    InstanceBuilderCallback<S> builder, {
    String? tag,
    bool permanent = true,
  }) =>
      Get.spawn<S>(builder, tag: tag, permanent: permanent);

  /// Finds and retrieves a dependency.
  S find<S>({String? tag}) => Get.find<S>(tag: tag);

  /// Registers a dependency.
  S put<S>(
    S dependency, {
    String? tag,
    bool permanent = false,
    InstanceBuilderCallback<S>? builder,
  }) =>
      Get.put<S>(dependency, tag: tag, permanent: permanent);

  /// Deletes a registered dependency.
  Future<bool> delete<S>({String? tag, bool force = false}) async =>
      Get.delete<S>(tag: tag, force: force);

  /// Deletes all registered dependencies.
  Future<void> deleteAll({bool force = false}) async =>
      Get.deleteAll(force: force);

  /// Reloads all registered dependencies.
  void reloadAll({bool force = false}) => Get.reloadAll(force: force);

  /// Reloads a specific dependency.
  void reload<S>({String? tag, String? key, bool force = false}) =>
      Get.reload<S>(tag: tag, key: key, force: force);

  /// Checks if a dependency is registered.
  bool isRegistered<S>({String? tag}) => Get.isRegistered<S>(tag: tag);

  /// Checks if a dependency is prepared.
  bool isPrepared<S>({String? tag}) => Get.isPrepared<S>(tag: tag);

  /// Replaces a registered dependency with a new one.
  Future<void> replace<P>(P child, {String? tag}) async {
    final InstanceInfo info = Get.getInstanceInfo<P>(tag: tag);
    final bool permanent = info.isPermanent ?? false;
    await delete<P>(tag: tag, force: permanent);
    put(child, tag: tag, permanent: permanent);
  }

  /// Registers a lazy singleton dependency, replacing any existing dependency.
  Future<void> lazyReplace<P>(
    InstanceBuilderCallback<P> builder, {
    String? tag,
    bool? fenix,
  }) async {
    final InstanceInfo info = Get.getInstanceInfo<P>(tag: tag);
    final bool permanent = info.isPermanent ?? false;
    await delete<P>(tag: tag, force: permanent);
    lazyPut(builder, tag: tag, fenix: fenix ?? permanent);
  }
}

/// Abstract class representing a module in the application.
abstract class Module extends StatefulWidget {
  /// Constructor for the Module class.
  const Module({super.key});

  /// Defines the UI of the module.
  Widget view(BuildContext context);

  /// Sets up dependencies required by the module.
  void dependencies(Dependencies i);

  @override
  ModuleState createState() => ModuleState();
}

/// This class represents the state of a module.
class ModuleState extends State<Module> {
  @override
  void initState() {
    /// Reports the current route to the router manager.
    RouterReportManager.instance.reportCurrentRoute(this);

    /// Sets up dependencies for the widget.
    widget.dependencies(Dependencies());

    super.initState();
  }

  @override
  void dispose() {
    /// Reports the disposal of the route to the router manager.
    RouterReportManager.instance.reportRouteDispose(this);

    super.dispose();
  }

  @override
  Widget build(BuildContext context) => widget.view(context);
}
