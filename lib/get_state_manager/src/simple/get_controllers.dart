import "package:flutter/widgets.dart";
import "package:refreshed/get_state_manager/src/rx_flutter/rx_notifier.dart";
import "package:refreshed/get_state_manager/src/simple/list_notifier.dart";
import "package:refreshed/instance_manager.dart";

// Core lifecycle capabilities

/// Mixin that provides update capabilities for controllers.
/// This separates the update logic from the controller base class.
mixin UpdateMixin on ListNotifier {
  /// Rebuilds the associated widgets.
  ///
  /// Calling `update()` will trigger a rebuild of all associated widgets
  /// unless a list of [ids] is provided, in which case only the widgets
  /// with matching ids will be rebuilt.
  ///
  /// The [condition] parameter determines whether the rebuild should occur.
  void update([List<Object>? ids, bool condition = true]) {
    if (!condition) return;
    
    switch (ids) {
      case null:
        refresh();
      case var idList:
        final uniqueIds = idList.toSet();
        for (final id in uniqueIds) {
          refreshGroup(id);
        }
    }
  }
}

/// Mixin that provides app lifecycle observation capabilities.
/// This separates the app lifecycle logic from the controller hierarchy.
mixin AppLifecycleMixin on WidgetsBindingObserver {
  /// Registers this mixin as an app lifecycle observer.
  void registerLifecycleObserver() {
    Engine.instance.addObserver(this);
  }

  /// Unregisters this mixin as an app lifecycle observer.
  void unregisterLifecycleObserver() {
    Engine.instance.removeObserver(this);
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) => switch (state) {
    AppLifecycleState.resumed => onResumed(),
    AppLifecycleState.inactive => onInactive(),
    AppLifecycleState.paused => onPaused(),
    AppLifecycleState.detached => onDetached(),
    AppLifecycleState.hidden => onHidden(),
  };

  /// Called when the app is resumed from a paused state.
  void onResumed() {}

  /// Called when the app is paused.
  void onPaused() {}

  /// Called when the app is in an inactive state.
  void onInactive() {}

  /// Called when the app is detached.
  void onDetached() {}

  /// Called when the app is hidden.
  void onHidden() {}
}

// Controller implementations

/// Base controller class that provides state management capabilities.
/// This is the foundation for all other controllers.
abstract class GetxController extends ListNotifier with GetLifeCycleMixin, UpdateMixin {}

/// A controller for managing scroll events.
/// Instead of a mixin, this is now a concrete controller class that can be extended.
abstract class GetxScrollController extends GetxController {
  late final ScrollController scroll;
  
  bool _canFetchBottom = true;
  bool _canFetchTop = true;

  @override
  void onInit() {
    super.onInit();
    scroll = ScrollController();
    scroll.addListener(_scrollListener);
  }

  Future<void> _scrollListener() async {
    if (scroll.position.atEdge) {
      await _handleScrollEdge();
    }
  }

  Future<void> _handleScrollEdge() async => switch (scroll.position.pixels) {
    0 when _canFetchTop => {
      _canFetchTop = false,
      await _safeScrollCallback(onTopScroll),
      _canFetchTop = true
    },
    _ when _canFetchBottom => {
      _canFetchBottom = false,
      await _safeScrollCallback(onEndScroll),
      _canFetchBottom = true
    },
    _ => null
  };

  Future<void> _safeScrollCallback(Future<void> Function() callback) async {
    try {
      await callback();
    } catch (e) {
      // Optionally handle any exceptions here
    }
  }

  /// Called when the scroll reaches the bottom.
  Future<void> onEndScroll();

  /// Called when the scroll reaches the top.
  Future<void> onTopScroll();

  @override
  void onClose() {
    scroll.removeListener(_scrollListener);
    scroll.dispose();
    super.onClose();
  }
}

/// A lightweight controller designed for use with reactive (Rx) variables.
abstract class RxController extends ListNotifier with GetLifeCycleMixin {}

/// A controller with state management capabilities for async operations.
abstract class StateController<T> extends GetxController with StateMixin<T> {}

/// A controller with full app lifecycle observation capabilities.
abstract class LifecycleController extends GetxController with WidgetsBindingObserver, AppLifecycleMixin {
  @override
  void onInit() {
    super.onInit();
    registerLifecycleObserver();
  }

  @override
  void onClose() {
    unregisterLifecycleObserver();
    super.onClose();
  }
}

/// A controller with both state management and lifecycle observation capabilities.
abstract class FullController<T> extends LifecycleController with StateMixin<T> {}

// Backward compatibility aliases

/// Alias for LifecycleController to maintain backward compatibility.
@Deprecated('Use LifecycleController instead')
abstract class FullLifeCycleController extends LifecycleController {}

/// Mixin that provides backward compatibility with the old lifecycle implementation.
@Deprecated('Use AppLifecycleMixin directly instead')
mixin FullLifeCycleMixin on FullLifeCycleController {
  // This mixin is empty as its functionality is now in AppLifecycleMixin
  // and LifecycleController. It exists only for backward compatibility.
}

/// Alias for FullController to maintain backward compatibility.
@Deprecated('Use FullController<T> instead')
abstract class SuperController<T> extends FullController<T> {}

/// Alias for GetxScrollController to maintain backward compatibility.
@Deprecated('Use GetxScrollController instead')
mixin ScrollMixin on GetLifeCycleMixin {
  // This mixin is empty as its functionality is now in GetxScrollController.
  // It exists only for backward compatibility.
  // Implementations should migrate to extending GetxScrollController instead.
}
