import 'package:get/get.dart';
import '../controllers/dreams_controller.dart';

class DreamsBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<DreamsController>(() => DreamsController());
  }
}
