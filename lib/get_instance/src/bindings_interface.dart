/// Defines a contract for classes that provide dependencies for a specific type `T`.
abstract class BindingsInterface<T> {
  /// Returns an instance of type `T` containing the required dependencies.
  T dependencies();
}

// /// Simplifies Bindings generation from a single callback.
// /// To avoid the creation of a custom Binding instance per route.
// ///
// /// Example:
// /// ```
// /// GetPage(
// ///   name: '/',
// ///   page: () => Home(),
// ///   // This might cause you an error.
// ///   // binding: BindingsBuilder(() => Get.put(HomeController())),
// ///   binding: BindingsBuilder(() { Get.put(HomeController(); })),
// ///   // Using .lazyPut() works fine.
// ///   // binding: BindingsBuilder(() => Get.lazyPut(() => HomeController())),
// /// ),
// /// ```
// class BindingsBuilder<T> extends Bindings {
//   /// Register your dependencies in the [builder] callback.
//   final BindingBuilderCallback builder;

//   /// Shortcut to register 1 Controller with Get.put(),
//   /// Prevents the issue of the fat arrow function with the constructor.
//   /// BindingsBuilder(() => Get.put(HomeController())),
//   ///
//   /// Sample:
//   /// ```
//   /// GetPage(
//   ///   name: '/',
//   ///   page: () => Home(),
//   ///   binding: BindingsBuilder.put(() => HomeController()),
//   /// ),
//   /// ```
//   factory BindingsBuilder.put(InstanceBuilderCallback<T> builder,
//       {String? tag, bool permanent = false}) {
//     return BindingsBuilder(
//         () => Get.put<T>(builder(), tag: tag, permanent: permanent));
//   }

//   /// WARNING: don't use `()=> Get.put(Controller())`,
//   /// if only passing 1 callback use `BindingsBuilder.put(Controller())`
//   /// or `BindingsBuilder(()=> Get.lazyPut(Controller()))`
//   BindingsBuilder(this.builder);

//   @override
//   void dependencies() {
//     builder();
//   }
// }

/// Defines the signature for a callback used to build bindings.
typedef BindingBuilderCallback = void Function();
