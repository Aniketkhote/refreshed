/// Defines a contract for classes that provide dependencies for a specific type `T`.
// ignore: one_member_abstracts
abstract class BindingsInterface<T> {
  /// Returns an instance of type `T` containing the required dependencies.
  T dependencies();
}

/// Defines the signature for a callback used to build bindings.
typedef BindingBuilderCallback = void Function();
