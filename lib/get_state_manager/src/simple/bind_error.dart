/// A class representing an error encountered during binding resolution.
class BindError<T> extends Error {
  /// Creates a [BindError] with the provided controller and optional tag.
  BindError({required this.controller, this.tag});

  /// The type of the class the user tried to retrieve.
  final T controller;

  /// An optional tag associated with the binding.
  final String? tag;

  @override
  String toString() {
    final type = T.toString();
    if (type == "dynamic") {
      return """Error: please specify type [<T>] when calling context.listen<T>() or context.find<T>() method.""";
    }

    return """Error: No Bind<$type> ancestor found. To fix this, please add a Bind<$type> widget ancestor to the current context.""";
  }
}
