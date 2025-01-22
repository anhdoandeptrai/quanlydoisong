import 'package:get/get.dart';
import 'package:quanlydoisong/controllers/budget_controller.dart';

class BudgetBinding extends Bindings {
  @override
  void dependencies() {
    // Khởi tạo BudgetController và đưa vào GetX dependency injection
    Get.lazyPut<BudgetController>(() => BudgetController());
  }
}
