import "package:flutter/material.dart";
import "package:refreshed/refreshed.dart";

/// Signature for a function that creates an object of type `T`.
typedef InitBuilder<T> = T Function();

/// Signature for a function that builds a widget with a controller of type `T`.
typedef GetControllerBuilder<T extends GetLifeCycleMixin> = Widget Function(
  T controller,
);

/// Extension methods for accessing state in the context of a widget build.
extension StateAccessExtension on BuildContext {
  /// Listens for state changes of type `T` and rebuilds the widget when it changes.
  ///
  /// This method is used to listen for changes to a specific state type `T` and rebuilds
  /// the widget whenever the state changes.
  T listen<T>() => Bind.of(this, rebuild: true);

  /// Gets the current value of state of type `T` without rebuilding the widget.
  ///
  /// This method is used to get the current value of a specific state type `T` without
  /// triggering a widget rebuild.
  T get<T>() => Bind.of(this);
}

/// A widget that builds itself based on the latest value of a [GetxController].
///
/// The [GetBuilder] widget listens to changes in a specified [GetxController],
/// and rebuilds its child widget whenever the controller changes its state.
class GetBuilder<T extends GetxController> extends StatelessWidget {
  /// Constructs a [GetBuilder] widget.
  const GetBuilder({
    required this.builder,
    super.key,
    this.init,
    this.global = true,
    this.autoRemove = true,
    this.assignId = false,
    this.initState,
    this.filter,
    this.tag,
    this.dispose,
    this.id,
    this.didChangeDependencies,
    this.didUpdateWidget,
  });

  /// A function that builds the widget based on the latest state of the controller.
  final GetControllerBuilder<T> builder;

  /// A flag indicating whether the controller should be treated as global.
  final bool global;

  /// An identifier for the widget.
  final Object? id;

  /// A tag for the widget.
  final String? tag;

  /// A flag indicating whether the widget should be automatically removed when disposed.
  final bool autoRemove;

  /// A flag indicating whether an identifier should be assigned to the widget.
  final bool assignId;

  /// A function that filters the value of the controller.
  final Object Function(T value)? filter;

  /// A callback function that is called when the widget is initialized.
  final void Function(BindElement<T> state)? initState;

  /// A callback function that is called when the widget is disposed.
  final Function(BindElement<T> state)? dispose;

  /// A callback function that is called when the widget's dependencies change.
  final Function(BindElement<T> state)? didChangeDependencies;

  /// A callback function that is called when the widget is updated.
  final void Function(Binder<T> oldWidget, BindElement<T> state)?
      didUpdateWidget;

  /// An initial value for the controller.
  final T? init;

  @override
  Widget build(BuildContext context) => Binder<T>(
        init: init != null ? () => init! : null,
        global: global,
        autoRemove: autoRemove,
        assignId: assignId,
        initState: initState,
        filter: filter,
        tag: tag,
        dispose: dispose,
        id: id,
        lazy: false,
        didChangeDependencies: didChangeDependencies,
        didUpdateWidget: didUpdateWidget,
        child: Builder(
          builder: (context) => builder(Bind.of<T>(context, rebuild: true)),
        ),
      );
}

/// [Binding] should be extended.
/// When using `GetMaterialApp`, all `GetPage`s and navigation
/// methods (like Get.to()) have a `binding` property that takes an
/// instance of Bindings to manage the
/// dependencies() (via Get.put()) for the Route you are opening.
// ignore: one_member_abstracts
abstract class Binding<T> extends BindingsInterface<List<Bind<T>>> {}
