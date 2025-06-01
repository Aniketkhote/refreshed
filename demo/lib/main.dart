import 'package:flutter/material.dart';
import 'package:refreshed/refreshed.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(primaryColor: Colors.deepPurpleAccent),
      home: Scaffold(
        appBar: AppBar(),
        body: Center(
          child: Column(
            spacing: 24,
            children: [
              ElevatedButton(
                onPressed: () => Get.to(() => MyWidget()),
                child: Text("My Widget"),
              ),
              ElevatedButton(
                onPressed: () => Get.to(() => Menu()),
                child: Text("Menu"),
              ),
            ],
          ),
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () => Get.bottomSheet(const Menu()),
          tooltip: 'Increment',
          child: const Icon(Icons.ads_click),
        ),
      ),
    );
  }
}

class MyWidget extends StatelessWidget {
  const MyWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: GetX(
        init: RegisterController(),
        tag: DateTime.now().millisecondsSinceEpoch.toString(),
        builder: (ctrl) => Text('new controller: ${ctrl.counter.value}'),
      ),
    );
  }
}

class RegisterController extends GetxController {
  RxInt counter = 0.obs;
  final myList = RxList<int>([1, 2, 3, 4, 5]);

  Future<void> increment() async {
    counter += myList.length + 1;
    final res = List.generate(10, (index) => counter.value + index);
    myList.addAll(res);
  }

  Future<void> closeSheet() async {
    Get.close();
  }
}

class Menu extends GetView {
  const Menu({super.key});

  @override
  Widget build(BuildContext context) {
    final ctrl = Get.put(RegisterController());
    return Scaffold(
      body: ListView(
        shrinkWrap: true,
        children: List.generate(
          20,
          (index) => ListTile(
            onTap: () {
              ctrl.closeSheet();
              snackbarSuccess('Deleted post ${index + 1}', "Success");
              // Get.showSnackbar(GetSnackBar(
              //   message: 'Deleted post ${index + 1}',
              // ));
              // ScaffoldMessenger.of(context).showSnackBar(
              //   SnackBar(content: Text('This is a SnackBar')),
              // );
              // Get.defaultDialog(
              //   onConfirm: () => Get.close(),
              // );
            },
            leading: const Icon(Icons.delete, color: Colors.red),
            title: Text('Delete post ${index + 1}'),
          ),
        ),
      ),
    );
  }

  void snackbarSuccess(String message, [String? title]) {
    if (Get.isSnackbarOpen) {
      return;
    }

    Get.snackbar(
      title ?? 'Success',
      message,
      snackPosition: SnackPosition.bottom,
    );
  }
}
