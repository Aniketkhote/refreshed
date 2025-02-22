import "package:flutter/widgets.dart";
import "package:refreshed/get_state_manager/src/rx_flutter/rx_notifier.dart";
import "package:refreshed/get_state_manager/src/simple/list_notifier.dart";
import "package:refreshed/instance_manager.dart";

/// Abstract class representing a GetX controller.
///
/// This class provides functionality for managing the state of
/// a widget or a group of widgets. It extends [ListNotifier] for
/// list change notification and implements [GetLifeCycleMixin] for
/// lifecycle management.
abstract class GetxController extends ListNotifier with GetLifeCycleMixin {
  /// Rebuilds the associated `GetBuilder` widgets.
  ///
  /// Calling `update()` will trigger a rebuild of all associated `GetBuilder`
  /// widgets unless a list of [ids] is provided, in which case only the `GetBuilder`
  /// widgets with matching ids will be rebuilt.
  ///
  /// The [condition] parameter determines whether the rebuild should occur.
  /// If [condition] is `false`, no rebuild will be triggered.
  void update([List<Object>? ids, bool condition = true]) {
    if (!condition) return;
    if (ids == null) {
      refresh();
    } else {
      final uniqueIds = ids.toSet(); // Use a Set to avoid duplicate ids
      for (final id in uniqueIds) {
        refreshGroup(id);
      }
    }
  }
}

/// Mixin to manage scroll events when the scroll position is at the top or bottom.
mixin ScrollMixin on GetLifeCycleMixin {
  late final ScrollController scroll;

  @override
  void onInit() {
    super.onInit();
    scroll = ScrollController();
    scroll.addListener(_scrollListener);
  }

  bool _canFetchBottom = true;
  bool _canFetchTop = true;

  Future<void> _scrollListener() async {
    if (scroll.position.atEdge) {
      await _handleScrollEdge();
    }
  }

  Future<void> _handleScrollEdge() async {
    if (scroll.position.pixels == 0) {
      if (_canFetchTop) {
        _canFetchTop = false;
        await _safeScrollCallback(onTopScroll);
        _canFetchTop = true;
      }
    } else {
      if (_canFetchBottom) {
        _canFetchBottom = false;
        await _safeScrollCallback(onEndScroll);
        _canFetchBottom = true;
      }
    }
  }

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

/// A clean controller to be used with only Rx variables.
abstract class RxController with GetLifeCycleMixin {}

/// A recommended way to use Getx with Future fetching.
abstract class StateController<T> extends GetxController with StateMixin<T> {}

/// A controller with super lifecycles (including native lifecycles)
/// and StateMixins.
abstract class SuperController<T> extends FullLifeCycleController
    with FullLifeCycleMixin, StateMixin<T> {}

/// A controller with super lifecycles (including native lifecycles).
abstract class FullLifeCycleController extends GetxController
    with WidgetsBindingObserver {}

/// Mixin that provides a full lifecycle implementation for controllers.
///
/// This mixin enhances a controller with lifecycle methods such as initialization,
/// disposal, and handling of app lifecycle states.
mixin FullLifeCycleMixin on FullLifeCycleController {
  @mustCallSuper
  @override
  void onInit() {
    super.onInit();
    Engine.instance.addObserver(this);
  }

  @mustCallSuper
  @override
  void onClose() {
    Engine.instance.removeObserver(this);
    super.onClose();
  }

  @mustCallSuper
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    switch (state) {
      case AppLifecycleState.resumed:
        onResumed();
        break;
      case AppLifecycleState.inactive:
        onInactive();
        break;
      case AppLifecycleState.paused:
        onPaused();
        break;
      case AppLifecycleState.detached:
        onDetached();
        break;
      case AppLifecycleState.hidden:
        onHidden();
        break;
    }
  }

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
