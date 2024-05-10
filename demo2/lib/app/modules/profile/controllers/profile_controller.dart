import 'package:refreshed/refreshed.dart';

class ProfileController extends GetxController {
  final count = 0.obs;
  @override
  void onInit() {
    super.onInit();
  }

  void increment() => count.value++;
}
