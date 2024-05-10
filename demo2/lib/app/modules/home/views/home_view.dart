import 'package:demo2/app/routes/app_pages.dart';
import 'package:flutter/material.dart';
import 'package:refreshed/refreshed.dart';

import '../controllers/home_controller.dart';

class HomeView extends GetView<HomeController> {
  const HomeView({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('HomeView'),
        centerTitle: true,
      ),
      body: Center(
        child: Column(
          children: [
            const Text(
              'HomeView is working',
              style: TextStyle(fontSize: 20),
            ),
            ElevatedButton(
              onPressed: () => Get.toNamed(Routes.profile),
              child: const Text("Goto Profile"),
            ),
          ],
        ),
      ),
    );
  }
}
