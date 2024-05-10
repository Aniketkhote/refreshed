import 'package:flutter/material.dart';
import 'package:refreshed/refreshed.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'GetPage Example',
      initialRoute: '/home',
      getPages: [
        GetPage(
          name: '/home',
          page: () => const HomeScreen(),
          binding: HomeBinding(),
        ),
        GetPage(
          name: '/profile',
          page: () => const ProfileScreen(),
          binding: ProfileBinding(),
        ),
      ],
    );
  }
}

// Controller for home screen
class HomeController extends GetxController {
  var count = 0.obs;

  void increment() {
    count++;
  }
}

// Binding for home screen
class HomeBinding extends Binding {
  @override
  List<Bind> dependencies() {
    return [Bind.lazyPut<HomeController>(() => HomeController())];
  }
}

// Home screen
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final HomeController controller = Get.find();
    return Scaffold(
      appBar: AppBar(
        title: const Text('Home'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Obx(() => Text('Count: ${controller.count}')),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () => controller.increment(),
              child: const Text('Increment'),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () => Get.toNamed('/profile'),
              child: const Text('Go to Profile'),
            ),
          ],
        ),
      ),
    );
  }
}

// Controller for profile screen
class ProfileController extends GetxController {}

// Binding for profile screen
class ProfileBinding extends Binding {
  @override
  List<Bind> dependencies() {
    return [Bind.lazyPut<ProfileController>(() => ProfileController())];
  }
}

// Profile screen
class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final ProfileController controller = Get.find();
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
      ),
      body: Center(
        child: Text('Profile Screen ${controller.initialized}'),
      ),
    );
  }
}
