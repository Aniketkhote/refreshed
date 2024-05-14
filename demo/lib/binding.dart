import 'package:flutter/material.dart';
import 'package:refreshed/refreshed.dart';

// Controller to manage state
class CountController extends GetxController {
  var count = 0.obs;

  void increment() => count++;

  void show() => Get.rawSnackbar();
}

class ProfileController extends GetxController {}

// Binding class to initialize dependencies
class HomeBinding extends Binding {
  @override
  List<Bind> dependencies() {
    return [
      Bind.lazyPut<CountController>(() => CountController()), // With type
      Bind.lazyPut(() => ProfileController()), // Without type
    ];
  }
}

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'GetX Example',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      binds: HomeBinding().dependencies(),
      home: const HomeScreen(),
    );
  }
}

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key}); // Access controller

  @override
  Widget build(BuildContext context) {
    final CountController controller = Get.find();

    return Scaffold(
      appBar: AppBar(
        title: const Text('GetX Example'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Obx(() =>
                Text('Count: ${controller.count}')), // Observe count changes
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () => controller.increment(),
              child: const Text('Increment'),
            ),
            ElevatedButton(
              onPressed: () => Get.to(() => const ProfileScreen()),
              child: const Text('Profile Screen'),
            ),
          ],
        ),
      ),
    );
  }
}

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key}); // Access controller

  @override
  Widget build(BuildContext context) {
    final ProfileController controller = Get.find();
    return Scaffold(
      appBar: AppBar(
        title: const Text('GetX Example'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const SizedBox(height: 20),
            Text(
              'Profile Screen controller initialized : ${controller.initialized}',
            ),
          ],
        ),
      ),
    );
  }
}
