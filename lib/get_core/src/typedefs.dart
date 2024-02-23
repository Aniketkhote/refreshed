/// A function type representing a value updater.
typedef ValueUpdater<T> = T Function();

/// Allows a value of type `T` or `T?` to be treated as a value of type `T?`.
///
/// This function is used to handle nullable and non-nullable types interchangeably,
/// allowing APIs that have become non-nullable to still be used with `!` and `?`
/// to support older versions of the API as well.
///
/// Parameters:
/// - `value`: The value to be ambiguated.
///
/// Returns:
/// The ambiguated value.
T? ambiguate<T>(T? value) => value;
