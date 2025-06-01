import 'bind_element.dart';
import 'get_state.dart';

/// An interface that defines common fields for binding widgets.
///
/// This interface is implemented by both [Bind] and [Binder] classes to eliminate code duplication
/// and ensure consistent behavior across binding implementations.
abstract class BindInterface<T> {
  /// Function to initialize the controller.
  InitBuilder<T>? get init;

  /// Flag indicating whether the controller should be treated as global.
  bool get global;

  /// Identifier for the widget.
  Object? get id;

  /// Tag for the widget.
  String? get tag;

  /// Flag indicating whether the widget should be automatically removed when disposed.
  bool get autoRemove;

  /// Flag indicating whether an identifier should be assigned to the widget.
  bool get assignId;

  /// Function to filter the value of the controller.
  Object Function(T value)? get filter;

  /// Callback function that is called when the widget is initialized.
  void Function(BindElement<T> state)? get initState;

  /// Callback function that is called when the widget is disposed.
  Function(BindElement<T> state)? get dispose;

  /// Callback function that is called when the widget's dependencies change.
  Function(BindElement<T> state)? get didChangeDependencies;
}
