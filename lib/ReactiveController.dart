import 'package:get/get.dart';

class ReactiveController extends GetxController {
  RxInt counter = 0.obs;

  void increase() {
    counter++;
  }
}
