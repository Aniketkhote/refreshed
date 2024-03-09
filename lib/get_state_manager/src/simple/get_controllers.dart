import "package:flutter/widgets.dart";

import 'package:refreshed/instance_manager.dart';
import 'package:refreshed/get_state_manager/src/rx_flutter/rx_notifier.dart';
import 'package:refreshed/get_state_manager/src/simple/list_notifier.dart';

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
    if (!condition) {
      return;
    }
    if (ids == null) {
      refresh();
    } else {
      for (final id in ids) {
        refreshGroup(id);
      }
    }
  }
}

/// this mixin allow to fetch data when the scroll is at the bottom or on the
/// top
mixin ScrollMixin on GetLifeCycleMixin {
  final ScrollController scroll = ScrollController();

  @override
  void onInit() {
    super.onInit();
    scroll.addListener(_listener);
  }

  bool _canFetchBottom = true;

  bool _canFetchTop = true;

  void _listener() {
    if (scroll.position.atEdge) {
      _checkIfCanLoadMore();
    }
  }

  Future<void> _checkIfCanLoadMore() async {
    if (scroll.position.pixels == 0) {
      if (!_canFetchTop) return;
      _canFetchTop = false;
      await onTopScroll();
      _canFetchTop = true;
    } else {
      if (!_canFetchBottom) return;
      _canFetchBottom = false;
      await onEndScroll();
      _canFetchBottom = true;
    }
  }

  /// this method is called when the scroll is at the bottom
  Future<void> onEndScroll();

  /// this method is called when the scroll is at the top
  Future<void> onTopScroll();

  @override
  void onClose() {
    scroll.removeListener(_listener);
    super.onClose();
  }
}

/// A clean controller to be used with only Rx variables
abstract class RxController with GetLifeCycleMixin {}

/// A recommended way to use Getx with Future fetching
abstract class StateController<T> extends GetxController with StateMixin<T> {}

/// A controller with super lifecycles (including native lifecycles)
/// and StateMixins
abstract class SuperController<T> extends FullLifeCycleController
    with FullLifeCycleMixin, StateMixin<T> {}

/// A controller with super lifecycles (including native lifecycles)
abstract class FullLifeCycleController extends GetxController
    with WidgetsBindingObserver {}

/// A mixin that provides a full lifecycle implementation for controllers.
///
/// This mixin enhances a controller with lifecycle methods such as initialization,
/// disposal, and handling of app lifecycle states.
mixin FullLifeCycleMixin on FullLifeCycleController {
  /// Called when the controller is initialized.
  ///
  /// This method should be overridden to perform initialization logic
  /// specific to the controller. It is invoked after the parent's `onInit`
  /// method is called.
  @mustCallSuper
  @override
  void onInit() {
    super.onInit();
    ambiguate(Engine.instance)!.addObserver(this);
  }

  /// Called when the controller is disposed.
  ///
  /// This method should be overridden to perform cleanup logic
  /// specific to the controller. It is invoked before the parent's `onClose`
  /// method is called.
  @mustCallSuper
  @override
  void onClose() {
    ambiguate(Engine.instance)!.removeObserver(this);
    super.onClose();
  }

  /// Called when the app lifecycle state changes.
  ///
  /// This method should be overridden to handle app lifecycle state changes.
  /// The [state] parameter indicates the new app lifecycle state.
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
