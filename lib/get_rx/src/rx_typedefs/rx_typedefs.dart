/// A typedef representing a condition function that returns a boolean value.
///
/// The [Condition] typedef defines a function signature for conditions used in various
/// scenarios, such as determining when to execute certain actions or make decisions.
typedef Condition = bool Function();

/// A typedef representing a callback function that accepts data of type [T].
///
/// The [OnData<T>] typedef defines a function signature for callbacks that handle
/// incoming data of type [T], typically used in asynchronous operations or event
/// handling scenarios.
typedef OnData<T> = void Function(T data);

/// A typedef representing a callback function with no parameters or return value.
///
/// The [Callback] typedef defines a function signature for simple callbacks that
/// perform actions or trigger events without requiring any parameters or return values.
typedef Callback = void Function();
