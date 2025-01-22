import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import 'package:quanlydoisong/models/attendance_model.dart';

class AttendanceController extends GetxController {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Danh sách chấm công
  RxList<Attendance> attendances = <Attendance>[].obs;

  @override
  void onInit() {
    super.onInit();
    fetchAttendances();
  }

  // Lấy danh sách chấm công từ Firestore
  void fetchAttendances() {
    final userId = 'user-id'; // Thay bằng logic lấy user hiện tại
    _firestore
        .collection('attendances')
        .doc(userId)
        .collection('records')
        .snapshots()
        .listen((snapshot) {
      final data = snapshot.docs.map((doc) {
        return Attendance.fromMap(doc.id, doc.data());
      }).toList();
      attendances.assignAll(data);
    });
  }

  // Thêm chấm công mới
  void addAttendance(DateTime clockInTime) {
    final userId = 'user-id'; // Thay bằng logic lấy user hiện tại
    final attendanceId = _firestore.collection('attendances').doc().id;
    final newAttendance = Attendance(
      id: attendanceId,
      clockInTime: clockInTime,
    );

    _firestore
        .collection('attendances')
        .doc(userId)
        .collection('records')
        .doc(attendanceId)
        .set(newAttendance.toMap());
  }

  // Cập nhật giờ ra
  void updateAttendance(String id, DateTime clockOutTime) {
    final userId = 'user-id'; // Thay bằng logic lấy user hiện tại
    _firestore
        .collection('attendances')
        .doc(userId)
        .collection('records')
        .doc(id)
        .update({'clockOutTime': clockOutTime});
  }
}
