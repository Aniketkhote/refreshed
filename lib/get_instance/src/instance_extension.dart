import "dart:async";

import "package:flutter/material.dart";
import "package:refreshed/get_core/get_core.dart";
import "package:refreshed/get_instance/src/lifecycle.dart";
import "package:refreshed/get_navigation/src/router_report.dart";

/// A class that holds information about an instance.
class InstanceInfo {
  /// Creates an InstanceInfo object with the given parameters.
  const InstanceInfo({
    required this.isPermanent,
    required this.isSingleton,
    required this.isRegistered,
    required this.isPrepared,
    required this.isInit,
  });

  /// Indicates whether the instance is permanent.
  final bool? isPermanent;

  /// Indicates whether the instance is a singleton.
  final bool? isSingleton;

  /// Indicates whether the instance is created.
  bool get isCreate => !isSingleton!;

  /// Indicates whether the instance is registered.
  final bool isRegistered;

  /// Indicates whether the instance is prepared.
  final bool isPrepared;

  /// Indicates whether the instance is initialized.
  final bool? isInit;

  @override
  String toString() =>
      "InstanceInfo(isPermanent: $isPermanent, isSingleton: $isSingleton, isRegistered: $isRegistered, isPrepared: $isPrepared, isInit: $isInit)";
}

/// Extension on GetInterface providing a method to reset all registered instances.
extension ResetInstance<T> on GetInterface {
  /// Clears all registered instances and/or tags.
  /// This method is particularly useful for cleaning up resources at the end or tearDown of unit tests.
  ///
  /// [clearRouteBindings] specifies whether to clear instances associated with routes.
  /// If set to `true`, instances associated with routes will be cleared.
  ///
  /// Returns `true` if the reset operation is successful.
  bool resetInstance({bool clearRouteBindings = true}) {
    if (clearRouteBindings) {
      RouterReportManager.instance.clearRouteKeys();
    }
    InstanceExtension._singl.clear();

    return true;
  }
}

/// Extension on `GetInterface` providing a convenient method to find instances of type `T`.
extension InstanceExtension<T> on GetInterface {
  /// Calls `find<T>()` to retrieve an instance of type `T`.
  T call() => find<T>();

  /// Holds references to every registered Instance when using
  /// `Get.put()`
  static final Map<String, _InstanceBuilderFactory<dynamic>> _singl =
      <String, _InstanceBuilderFactory<dynamic>>{};

  /// async version of `Get.put()`.
  /// Awaits for the resolution of the Future from `builder()` parameter and
  /// stores the Instance returned.
  Future<S> putAsync<S>(
    AsyncInstanceBuilderCallback<S> builder, {
    String? tag,
    bool permanent = false,
  }) async =>
      put<S>(await builder(), tag: tag, permanent: permanent);

  /// Injects an instance `<S>` in memory to be globally accessible.
  ///
  /// No need to define the generic type `<S>` as it's inferred from
  /// the [dependency]
  ///
  /// - [dependency] The Instance to be injected.
  /// - [tag] optionally, use a [tag] as an "id" to create multiple records of
  /// the same Type<[S]>
  /// - [permanent] keeps the Instance in memory, not following
  /// `Get.smartManagement` rules.
  S put<S>(
    S dependency, {
    String? tag,
    bool permanent = false,
  }) {
    _insert(
      isSingleton: true,
      name: tag,
      permanent: permanent,
      builder: () => dependency,
    );
    return find<S>(tag: tag);
  }

  /// Creates a new Instance<S> lazily from the `<S>builder()` callback.
  ///
  /// The first time you call `Get.find()`, the `builder()` callback will create
  /// the Instance and persisted as a Singleton (like you would
  /// use `Get.put()`).
  ///
  /// Using `Get.smartManagement` as [SmartManagement.keepFactory] has
  /// the same outcome as using `fenix:true` :
  /// The internal register of `builder()` will remain in memory to recreate
  /// the Instance if the Instance has been removed with `Get.delete()`.
  /// Therefore, future calls to `Get.find()` will return the same Instance.
  ///
  /// If you need to make use of GetxController's life-cycle
  /// (`onInit(), onStart(), onClose()`) [fenix] is a great choice to mix with
  /// `GetBuilder()` and `GetX()` widgets, and/or `GetMaterialApp` Navigation.
  ///
  /// You could use `Get.lazyPut(fenix:true)` in your app's `main()` instead
  /// of `Bindings()` for each `GetPage`.
  /// And the memory management will be similar.
  ///
  /// Subsequent calls to `Get.lazyPut()` with the same parameters
  /// (<[S]> and optionally [tag] will **not** override the original).
  void lazyPut<S>(
    InstanceBuilderCallback<S> builder, {
    String? tag,
    bool? fenix,
    bool permanent = false,
  }) {
    _insert(
      isSingleton: true,
      name: tag,
      permanent: permanent,
      builder: builder,
      fenix: fenix ?? Get.smartManagement == SmartManagement.keepFactory,
    );
  }

  /// Creates a new Class Instance [S] from the builder callback[S].
  /// Every time [find]<[S]>() is used, it calls the builder method to generate
  /// a new Instance [S].
  /// It also registers each `instance.onClose()` with the current
  /// Route `Get.reference` to keep the lifecycle active.
  /// Is important to know that the instances created are only stored per Route.
  /// So, if you call `Get.delete<T>()` the "instance factory" used in this
  /// method (`Get.spawn<T>()`) will be removed, but NOT the instances
  /// already created by it.
  ///
  /// Example:
  ///
  /// ```Get.spawn(() => Repl());
  /// Repl a = find();
  /// Repl b = find();
  /// print(a==b); (false)```
  void spawn<S>(
    InstanceBuilderCallback<S> builder, {
    String? tag,
    bool permanent = true,
  }) {
    _insert(
      isSingleton: false,
      name: tag,
      builder: builder,
      permanent: permanent,
    );
  }

  /// Injects the Instance [S] builder into the `_singleton` HashMap.
  void _insert<S>({
    required InstanceBuilderCallback<S> builder,
    bool? isSingleton,
    String? name,
    bool permanent = false,
    bool fenix = false,
  }) {
    final String key = _getKey(S, name);

    _InstanceBuilderFactory<S>? dep;
    if (_singl.containsKey(key)) {
      final _InstanceBuilderFactory<T> newDep =
          _singl[key]! as _InstanceBuilderFactory<T>;
      if (!newDep.isDirty) {
        return;
      } else {
        dep = newDep as _InstanceBuilderFactory<S>;
      }
    }
    _singl[key] = _InstanceBuilderFactory<S>(
      isSingleton: isSingleton,
      builderFunc: builder,
      permanent: permanent,
      isInit: false,
      fenix: fenix,
      tag: name,
      lateRemove: dep,
    );
  }

  /// Initializes the dependencies for a Class Instance [S] (or tag),
  /// If its a Controller, it starts the lifecycle process.
  /// Optionally associating the current Route to the lifetime of the instance,
  /// if `Get.smartManagement` is marked as [SmartManagement.full] or
  /// [SmartManagement.keepFactory]
  /// Only flags `isInit` if it's using `Get.create()`
  /// (not for Singletons access).
  /// Returns the instance if not initialized, required for Get.create() to
  /// work properly.
  S? _initDependencies<S>({String? name}) {
    final String key = _getKey(S, name);
    final bool isInit = _singl[key]!.isInit;
    S? i;
    if (!isInit) {
      final bool isSingleton = _singl[key]?.isSingleton ?? false;
      if (isSingleton) {
        _singl[key]!.isInit = true;
      }
      i = _startController<S>(tag: name);

      if (isSingleton) {
        if (Get.smartManagement != SmartManagement.onlyBuilder) {
          RouterReportManager.instance
              .reportDependencyLinkedToRoute(_getKey(S, name));
        }
      }
    }
    return i;
  }

  /// Get instance info
  InstanceInfo getInstanceInfo<S>({String? tag}) {
    final _InstanceBuilderFactory<T>? build = _getDependency<S>(tag: tag);

    return InstanceInfo(
      isPermanent: build?.permanent,
      isSingleton: build?.isSingleton,
      isRegistered: isRegistered<S>(tag: tag),
      isPrepared: !(build?.isInit ?? true),
      isInit: build?.isInit,
    );
  }

  _InstanceBuilderFactory<T>? _getDependency<S>({String? tag, String? key}) {
    final String newKey = key ?? _getKey(S, tag);

    if (!_singl.containsKey(newKey)) {
      Get.log('Instance "$newKey" is not registered.', isError: true);
      return null;
    } else {
      return _singl[newKey]! as _InstanceBuilderFactory<T>;
    }
  }

  /// Mark instance as a dirty
  void markAsDirty<S>({String? tag, String? key}) {
    final String newKey = key ?? _getKey(S, tag);
    if (_singl.containsKey(newKey)) {
      final _InstanceBuilderFactory<T> dep =
          _singl[newKey]! as _InstanceBuilderFactory<T>;
      if (!dep.permanent) {
        dep.isDirty = true;
      }
    }
  }

  /// Initializes the controller
  S _startController<S>({String? tag}) {
    final String key = _getKey(S, tag);
    final S i = _singl[key]!.getDependency() as S;
    if (i is GetLifeCycleMixin) {
      i.onStart();
      if (tag == null) {
        Get.log('Instance "$S" has been initialized');
      } else {
        Get.log('Instance "$S" with tag "$tag" has been initialized');
      }
      if (!_singl[key]!.isSingleton!) {
        RouterReportManager.instance.appendRouteByCreate(i);
      }
    }
    return i;
  }

  /// Registerd instance and if already exists  then it will return
  S putOrFind<S>(InstanceBuilderCallback<S> dep, {String? tag}) {
    final String key = _getKey(S, tag);

    if (_singl.containsKey(key)) {
      return _singl[key]!.getDependency() as S;
    } else {
      return put(dep(), tag: tag);
    }
  }

  /// Finds the registered type <[S]> (or [tag])
  /// In case of using Get.[create] to register a type <[S]> or [tag],
  /// it will create an instance each time you call [find].
  /// If the registered type <[S]> (or [tag]) is a Controller,
  /// it will initialize it's lifecycle.
  S find<S>({String? tag}) {
    final String key = _getKey(S, tag);
    if (isRegistered<S>(tag: tag)) {
      final _InstanceBuilderFactory<T> dep =
          _singl[key]! as _InstanceBuilderFactory<T>;

      /// although dirty solution, the lifecycle starts inside
      /// `initDependencies`, so we have to return the instance from there
      /// to make it compatible with `Get.create()`.
      final S? i = _initDependencies<S>(name: tag);
      return i ?? dep.getDependency() as S;
    } else {
      throw Exception(
        '"$S" not found. You need to call "Get.put($S())" or "Get.lazyPut(()=>$S())"',
      );
    }
  }

  /// The findOrNull method will return the instance if it is registered;
  /// otherwise, it will return null.
  S? findOrNull<S>({String? tag}) {
    if (isRegistered<S>(tag: tag)) {
      return find<S>(tag: tag);
    }
    return null;
  }

  /// Replace a parent instance of a class in dependency management
  /// with a [child] instance
  /// - [tag] optional, if you use a [tag] to register the Instance.
  void replace<P>(P child, {String? tag}) {
    final InstanceInfo info = getInstanceInfo<P>(tag: tag);
    final bool permanent = info.isPermanent ?? false;
    delete<P>(tag: tag, force: permanent);
    put(child, tag: tag, permanent: permanent);
  }

  /// Replaces a parent instance with a new Instance<P> lazily from the
  /// `<P>builder()` callback.
  /// - [tag] optional, if you use a [tag] to register the Instance.
  /// - [fenix] optional
  ///
  ///  Note: if fenix is not provided it will be set to true if
  /// the parent instance was permanent
  void lazyReplace<P>(
    InstanceBuilderCallback<P> builder, {
    String? tag,
    bool? fenix,
  }) {
    final InstanceInfo info = getInstanceInfo<P>(tag: tag);
    final bool permanent = info.isPermanent ?? false;
    delete<P>(tag: tag, force: permanent);
    lazyPut(builder, tag: tag, fenix: fenix ?? permanent);
  }

  /// Generates the key based on [type] (and optionally a [name])
  /// to register an Instance Builder in the hashmap.
  String _getKey(Type type, String? name) =>
      name == null ? type.toString() : type.toString() + name;

  /// Delete registered Class Instance [S] (or [tag]) and, closes any open
  /// controllers `DisposableInterface`, cleans up the memory
  ///
  /// /// Deletes the Instance<[S]>, cleaning the memory.
  //  ///
  //  /// - [tag] Optional "tag" used to register the Instance
  //  /// - [key] For internal usage, is the processed key used to register
  //  ///   the Instance. **don't use** it unless you know what you are doing.

  /// Deletes the Instance<[S]>, cleaning the memory and closes any open
  /// controllers (`DisposableInterface`).
  ///
  /// - [tag] Optional "tag" used to register the Instance
  /// - [key] For internal usage, is the processed key used to register
  ///   the Instance. **don't use** it unless you know what you are doing.
  /// - [force] Will delete an Instance even if marked as `permanent`.
  bool delete<S>({String? tag, String? key, bool force = false}) {
    final String newKey = key ?? _getKey(S, tag);

    if (!_singl.containsKey(newKey)) {
      Get.log('Instance "$newKey" already removed.', isError: true);
      return false;
    }

    final _InstanceBuilderFactory<T> dep =
        _singl[newKey]! as _InstanceBuilderFactory<T>;

    final _InstanceBuilderFactory<T> builder;
    if (dep.isDirty) {
      builder = dep.lateRemove ?? dep;
    } else {
      builder = dep;
    }

    if (builder.permanent && !force) {
      Get.log(
        '"$newKey" has been marked as permanent, SmartManagement is not authorized to delete it.',
        isError: true,
      );
      return false;
    }
    final S? i = builder.dependency as S?;

    if (i is GetxServiceMixin && !force) {
      return false;
    }

    if (i is GetLifeCycleMixin) {
      i.onDelete();
      Get.log('"$newKey" onDelete() called');
    }

    if (builder.fenix) {
      builder.dependency = null;
      builder.isInit = false;
      return true;
    } else {
      if (dep.lateRemove != null) {
        dep.lateRemove = null;
        Get.log('"$newKey" deleted from memory');
        return false;
      } else {
        _singl.remove(newKey);
        if (_singl.containsKey(newKey)) {
          Get.log('Error removing object "$newKey"', isError: true);
        } else {
          Get.log('"$newKey" deleted from memory');
        }
        return true;
      }
    }
  }

  /// Deletes all registered class instances and closes any open controllers that implement `DisposableInterface`.
  ///
  /// This method clears the memory by removing all registered instances. If [force] is set to true,
  /// instances marked as `permanent` will also be deleted.
  ///
  /// Example:
  /// ```dart
  /// // Deletes all instances.
  /// Get.deleteAll();
  ///
  /// // Deletes all instances, including permanent ones.
  /// Get.deleteAll(force: true);
  /// ```
  void deleteAll({bool force = false}) {
    final List<String> keys = _singl.keys.toList();
    for (final String key in keys) {
      delete(key: key, force: force);
    }
  }

  /// Reloads all registered class instances.
  ///
  /// If [force] is set to true, instances marked as `permanent` will also be reloaded.
  ///
  /// Example:
  /// ```dart
  /// // Reloads all instances.
  /// Get.reloadAll();
  ///
  /// // Reloads all instances, including permanent ones.
  /// Get.reloadAll(force: true);
  /// ```
  void reloadAll({bool force = false}) {
    (_singl as Map<String, _InstanceBuilderFactory<T>>)
        .forEach((String key, _InstanceBuilderFactory<T> value) {
      if (value.permanent && !force) {
        Get.log('Instance "$key" is permanent. Skipping reload');
      } else {
        value.dependency = null;
        value.isInit = false;
        Get.log('Instance "$key" was reloaded.');
      }
    });
  }

  /// Reloads the instance of type `S`.
  ///
  /// If [tag] is provided, the instance associated with that tag is reloaded.
  /// If [key] is provided, it will be used as the identifier for the instance to reload.
  /// If [force] is set to true, the instance will be reloaded even if it is marked as permanent.
  ///
  /// This method is used to restart an instance, clearing its existing state and recreating it.
  ///
  /// Example:
  /// ```dart
  /// // Reloads the instance of type `MyController`.
  /// Get.reload<MyController>();
  ///
  /// // Reloads the instance associated with the tag 'myTag'.
  /// Get.reload<MyService>(tag: 'myTag');
  /// ```
  void reload<S>({
    String? tag,
    String? key,
    bool force = false,
  }) {
    final String newKey = key ?? _getKey(S, tag);

    final _InstanceBuilderFactory<T>? builder =
        _getDependency<S>(tag: tag, key: newKey);
    if (builder == null) {
      return;
    }

    if (builder.permanent && !force) {
      Get.log(
        '''Instance "$newKey" is permanent. Use [force = true] to force the restart.''',
        isError: true,
      );
      return;
    }

    final S? i = builder.dependency as S?;

    if (i is GetxServiceMixin && !force) {
      return;
    }

    if (i is GetLifeCycleMixin) {
      i.onDelete();
      Get.log('"$newKey" onDelete() called');
    }

    builder.dependency = null;
    builder.isInit = false;
    Get.log('Instance "$newKey" was restarted.');
  }

  /// Check if a Class Instance<[S]> (or [tag]) is registered in memory.
  /// - [tag] is optional, if you used a [tag] to register the Instance.
  bool isRegistered<S>({String? tag}) => _singl.containsKey(_getKey(S, tag));

  /// Checks if a lazy factory callback `Get.lazyPut()` that returns an
  /// Instance<[S]> is registered in memory.
  /// - [tag] is optional, if you used a [tag] to register the lazy Instance.
  bool isPrepared<S>({String? tag}) {
    final String newKey = _getKey(S, tag);

    final _InstanceBuilderFactory<T>? builder =
        _getDependency<S>(tag: tag, key: newKey);
    if (builder == null) {
      return false;
    }

    if (!builder.isInit) {
      return true;
    }
    return false;
  }
}

/// A callback function used to construct instances of type `S`.
///
/// The function takes no parameters and returns an instance of type `S`.
typedef InstanceBuilderCallback<S> = S Function();

/// A callback function used to construct instances of type `S` with access to the current `BuildContext`.
///
/// The function takes a `BuildContext` parameter and returns an instance of type `S`.
typedef InstanceCreateBuilderCallback<S> = S Function(BuildContext _);

/// A callback function used to asynchronously construct instances of type `S`.
///
/// The function takes no parameters and returns a `Future` that resolves to an instance of type `S`.
typedef AsyncInstanceBuilderCallback<S> = Future<S> Function();

/// Internal class used by GetX to register instances with `Get.put<S>()`.
class _InstanceBuilderFactory<T> {
  _InstanceBuilderFactory({
    required this.isSingleton,
    required this.builderFunc,
    required this.permanent,
    required this.isInit,
    required this.fenix,
    required this.tag,
    required this.lateRemove,
  });

  /// Marks the Builder as a single instance.
  /// For reusing [dependency] instead of [builderFunc]
  bool? isSingleton;

  /// When fenix mode is available, when a new instance is needed,
  /// the Instance manager will recreate a new instance of S.
  bool fenix;

  /// Stores the actual object instance when [isSingleton]=true.
  T? dependency;

  /// Generates (and regenerates) the instance when [isSingleton]=false.
  /// Usually used by factory methods.
  InstanceBuilderCallback<T> builderFunc;

  /// Flag to persist the instance in memory,
  /// without considering `Get.smartManagement`.
  bool permanent = false;

  /// Indicates whether the instance has been initialized.
  bool isInit = false;

  /// Reference to the instance that will be removed late (not immediately).
  _InstanceBuilderFactory<T>? lateRemove;

  /// Flag to indicate whether the instance is dirty and needs to be refreshed.
  bool isDirty = false;

  /// The tag associated with the instance.
  String? tag;

  void _showInitLog() {
    if (tag == null) {
      Get.log('Instance "$T" has been created');
    } else {
      Get.log('Instance "$T" has been created with tag "$tag"');
    }
  }

  /// Gets the actual instance by its [builderFunc] or the persisted instance.
  T getDependency() {
    if (isSingleton!) {
      if (dependency == null) {
        _showInitLog();
        dependency = builderFunc();
      }
      return dependency!;
    } else {
      return builderFunc();
    }
  }
}
