import 'package:flutter/material.dart';
import 'package:refreshed/refreshed.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'GetX Navigation Test',
      initialRoute: '/',
      getPages: [
        GetPage(name: '/', page: () => HomeScreen()),
        GetPage(name: '/screenA', page: () => ScreenA()),
        GetPage(name: '/screenB', page: () => ScreenB()),
        GetPage(name: '/details/:id', page: () => DetailsScreen()),
      ],
      defaultTransition: Transition.noTransition,
    );
  }
}

class HomeScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Home Screen')),
      body: Center(
        child: Column(
          spacing: 16,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: () => Get.toNamed('/screenAjj'),
              child: Text('Go to Screen A'),
            ),
            ElevatedButton(
              onPressed: () => Get.toNamed('/screenB'),
              child: Text('Go to Screen B'),
            ),
            ElevatedButton(
              onPressed: () => Get.toNamed('/details/123'),
              child: Text('Go to Details with ID 123'),
            ),
            ElevatedButton(
              onPressed: () =>
                  Get.snackbar('Navigation', 'This is a snackbar test!'),
              child: Text('Show Snackbar'),
            ),
          ],
        ),
      ),
    );
  }
}

class ScreenA extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Screen A')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('This is Screen A'),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () => Get.offNamed('/'),
              child: Text('Back to Home'),
            ),
            ElevatedButton(
              onPressed: () => Get.toNamed('/screenB'),
              child: Text('Go to Screen B'),
            ),
          ],
        ),
      ),
    );
  }
}

class ScreenB extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Screen B')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('This is Screen B'),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () => Get.offNamed('/'),
              child: Text('Back to Home'),
            ),
            ElevatedButton(
              onPressed: () => Get.toNamed('/screenA'),
              child: Text('Go to Screen A'),
            ),
          ],
        ),
      ),
    );
  }
}

class DetailsScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final id = Get.parameters['id'];
    return Scaffold(
      appBar: AppBar(title: Text('Details Screen')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('Details Screen with ID: $id'),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () => Get.back(),
              child: Text('Back to Home'),
            ),
          ],
        ),
      ),
    );
  }
}
