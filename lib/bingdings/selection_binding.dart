import 'package:get/get.dart';
import 'package:quanlydoisong/controllers/selection_controller.dart%2002-18-22-645.dart';

class PreferenceBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<PreferenceController>(() => PreferenceController());
  }
}
