import 'package:get/get.dart';
import 'package:quanlydoisong/controllers/attendance_controller.dart';

class AttendanceBinding extends Bindings {
  @override
  void dependencies() {
    // Đưa AttendanceController vào bộ nhớ để sử dụng trong AttendancePage
    Get.lazyPut(() => AttendanceController());
  }
}
