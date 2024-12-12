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
      home: Scaffold(
        appBar: AppBar(),
        body: const SafeArea(child: Menu()),
        floatingActionButton: FloatingActionButton(
          // onPressed: () => Get.snackbar(
          //   "Title",
          //   "Message",
          //   snackPosition: SnackPosition.bottom,
          //   leftBarIndicatorColor: Colors.deepOrange,
          // ),
          onPressed: () => Get.bottomSheet(const Menu()),
          tooltip: 'Increment',
          child: const Icon(Icons.ads_click),
        ),
      ),
    );
  }
}

class MyController extends GetxController {
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

class Menu extends StatelessWidget {
  const Menu({super.key});

  @override
  Widget build(BuildContext context) {
    final ctrl = Get.put(MyController());
    return Scaffold(
      body: ListView(
        shrinkWrap: true,
        children: [
          ListTile(
            onTap: () {
              ctrl.closeSheet();
            },
            leading: const Icon(
              Icons.delete,
              color: Colors.red,
            ),
            title: const Text('Delete post'),
          ),
          ListTile(
            onTap: () {
              ctrl.closeSheet();
            },
            leading: const Icon(
              Icons.delete,
              color: Colors.red,
            ),
            title: const Text('Delete post'),
          ),
          ListTile(
            onTap: () {
              ctrl.closeSheet();
            },
            leading: const Icon(
              Icons.delete,
              color: Colors.red,
            ),
            title: const Text('Delete post'),
          ),
          ListTile(
            onTap: () {
              ctrl.closeSheet();
            },
            leading: const Icon(
              Icons.delete,
              color: Colors.red,
            ),
            title: const Text('Delete post'),
          ),
          ListTile(
            onTap: () {
              ctrl.closeSheet();
            },
            leading: const Icon(
              Icons.delete,
              color: Colors.red,
            ),
            title: const Text('Delete post'),
          ),
          ListTile(
            onTap: () {
              ctrl.closeSheet();
            },
            leading: const Icon(
              Icons.delete,
              color: Colors.red,
            ),
            title: const Text('Delete post'),
          ),
          ListTile(
            onTap: () {
              ctrl.closeSheet();
            },
            leading: const Icon(
              Icons.delete,
              color: Colors.red,
            ),
            title: const Text('Delete post'),
          ),
          ListTile(
            onTap: () {
              ctrl.closeSheet();
            },
            leading: const Icon(
              Icons.delete,
              color: Colors.red,
            ),
            title: const Text('Delete post'),
          ),
          ListTile(
            onTap: () {
              ctrl.closeSheet();
            },
            leading: const Icon(
              Icons.delete,
              color: Colors.red,
            ),
            title: const Text('Delete post'),
          ),
          ListTile(
            onTap: () {
              ctrl.closeSheet();
            },
            leading: const Icon(
              Icons.delete,
              color: Colors.red,
            ),
            title: const Text('Delete post'),
          ),
          ListTile(
            onTap: () {
              ctrl.closeSheet();
            },
            leading: const Icon(
              Icons.delete,
              color: Colors.red,
            ),
            title: const Text('Delete post'),
          ),
          ListTile(
            onTap: () {
              ctrl.closeSheet();
            },
            leading: const Icon(
              Icons.delete,
              color: Colors.red,
            ),
            title: const Text('Delete post'),
          ),
          ListTile(
            onTap: () {
              ctrl.closeSheet();
            },
            leading: const Icon(
              Icons.delete,
              color: Colors.red,
            ),
            title: const Text('Delete post'),
          ),
          ListTile(
            onTap: () {
              ctrl.closeSheet();
            },
            leading: const Icon(
              Icons.delete,
              color: Colors.red,
            ),
            title: const Text('Delete post'),
          ),
        ],
      ),
    );
  }
}
