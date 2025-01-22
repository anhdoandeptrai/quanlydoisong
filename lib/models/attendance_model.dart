import 'package:cloud_firestore/cloud_firestore.dart';

class Attendance {
  final String id;
  final DateTime clockInTime;
  DateTime? clockOutTime;

  Attendance({
    required this.id,
    required this.clockInTime,
    this.clockOutTime,
  });

  // Phương thức từ Map (Firebase hoặc API)
  factory Attendance.fromMap(String id, Map<String, dynamic> data) {
    return Attendance(
      id: id,
      clockInTime: (data['clockInTime'] as Timestamp).toDate(),
      clockOutTime: data['clockOutTime'] != null
          ? (data['clockOutTime'] as Timestamp).toDate()
          : null,
    );
  }

  // Chuyển về Map để lưu trữ (Firebase hoặc API)
  Map<String, dynamic> toMap() {
    return {
      'clockInTime': clockInTime,
      'clockOutTime': clockOutTime,
    };
  }
}
