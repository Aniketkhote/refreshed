import "package:flutter/widgets.dart";

/// Abstract class representing a cacheable widget in GetX.
///
/// This class serves as the base for creating cacheable widgets in GetX.
/// Subclasses must implement the `createWidgetCache` method to create an instance
/// of `WidgetCache`.
abstract class GetWidgetCache extends Widget {
  /// Constructs a GetWidgetCache widget.
  const GetWidgetCache({super.key});

  @override
  GetWidgetCacheElement createElement() => GetWidgetCacheElement(this);

  /// Creates an instance of WidgetCache.
  ///
  /// Subclasses must override this method to provide the implementation
  /// for creating a WidgetCache instance.
  @protected
  @factory
  WidgetCache createWidgetCache();
}

/// Element representing a cacheable widget in GetX.
///
/// This element manages the lifecycle of a cacheable widget.
class GetWidgetCacheElement extends ComponentElement {
  GetWidgetCacheElement(GetWidgetCache widget)
      : cache = widget.createWidgetCache(),
        super(widget) {
    cache._element = this;
    cache._widget = widget;
  }

  @override
  void mount(Element? parent, dynamic newSlot) {
    cache.onInit();
    super.mount(parent, newSlot);
  }

  @override
  Widget build() => cache.build(this);

  /// The widget cache associated with this element.
  final WidgetCache<GetWidgetCache> cache;

  @override
  void activate() {
    super.activate();
    markNeedsBuild();
  }

  @override
  void unmount() {
    super.unmount();
    cache.onClose();
    cache._element = null;
  }
}

/// Abstract class representing a cache for a widget in GetX.
///
/// This class defines the methods and properties required for managing
/// the state and lifecycle of a cacheable widget.
@optionalTypeArgs
abstract class WidgetCache<T extends GetWidgetCache> {
  /// The associated widget for this cache.
  T? get widget => _widget;
  T? _widget;

  /// The build context associated with this cache.
  BuildContext? get context => _element;

  GetWidgetCacheElement? _element;

  /// Initializes the cache.
  @protected
  @mustCallSuper
  void onInit() {}

  /// Cleans up resources when the cache is closed.
  @protected
  @mustCallSuper
  void onClose() {}

  /// Builds the widget associated with this cache.
  @protected
  Widget build(BuildContext context);
}
