import "package:flutter/widgets.dart";
import "package:refreshed/get_state_manager/src/simple/get_widget_cache.dart";
import "package:refreshed/instance_manager.dart";
import "package:refreshed/utils.dart";

import "binder.dart";

/// GetView is a great way of quickly access your Controller
/// without having to call `Get.find<AwesomeController>()` yourself.
///
/// Sample:
/// ```
/// class AwesomeController extends GetxController {
///   final String title = 'My Awesome View';
/// }
///
/// class AwesomeView extends GetView<AwesomeController> {
///   /// if you need you can pass the tag for
///   /// Get.find<AwesomeController>(tag:"myTag");
///   @override
///   final String tag = "myTag";
///
///   AwesomeView({Key key}):super(key:key);
///
///   @override
///   Widget build(BuildContext context) {
///     return Container(
///       padding: EdgeInsets.all(20),
///       child: Text( controller.title ),
///     );
///   }
/// }
///``
abstract class GetView<T> extends StatelessWidget {
  /// Creates a GetView associated with a specific key.
  const GetView({super.key});

  /// The tag used to locate the associated controller.
  /// If null, the first instance of the controller type will be used.
  String? get tag => null;

  /// Retrieves the controller associated with this view.
  ///
  /// The controller is retrieved using GetX's `Get.find()` method, using the specified tag if provided.
  T get controller => Get.find<T>(tag: tag)!;

  @override
  Widget build(BuildContext context);
}

/// GetWidget is a great way of quickly access your individual Controller
/// without having to call `Get.find<AwesomeController>()` yourself.
/// Get save you controller on cache, so, you can to use Get.create() safely
/// GetWidget is perfect to multiples instance of a same controller. Each
/// GetWidget will have your own controller, and will be call events as `onInit`
/// and `onClose` when the controller get in/get out on memory.
abstract class GetWidget<S extends GetLifeCycleMixin> extends GetWidgetCache {
  /// Creates a GetView associated with a specific key.
  const GetWidget({super.key});

  /// The tag used to locate the associated controller.
  /// If null, the first instance of the controller type will be used.
  @protected
  String? get tag => null;

  /// Retrieves the controller associated with this view.
  S get controller => GetWidget._cache[this]! as S;

  static final Expando<GetLifeCycleMixin> _cache = Expando<GetLifeCycleMixin>();

  @protected
  Widget build(BuildContext context);

  @override
  WidgetCache createWidgetCache() => _GetCache<S>();
}

class _GetCache<S extends GetLifeCycleMixin> extends WidgetCache<GetWidget<S>> {
  S? _controller;
  bool _isCreator = false;
  InstanceInfo? info;
  @override
  void onInit() {
    info = Get.getInstanceInfo<S>(tag: widget!.tag);

    _isCreator = info!.isPrepared && info!.isCreate;

    if (info!.isRegistered) {
      _controller = Get.find<S>(tag: widget!.tag);
    }

    GetWidget._cache[widget!] = _controller;

    super.onInit();
  }

  @override
  Future<void> onClose() async {
    if (_isCreator) {
      Get.asap(() {
        widget!.controller.onDelete();
        Get.log('"${widget!.controller.runtimeType}" onClose() called');
        Get.log('"${widget!.controller.runtimeType}" deleted from memory');
      });
    }
    info = null;
    super.onClose();
  }

  @override
  Widget build(BuildContext context) => Binder<S?>(
        init: () => _controller,
        child: widget!.build(context),
      );
}
