import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:hive/hive.dart';

part 'schedule.g.dart'; // Tự động tạo file adapter

@HiveType(typeId: 0) // Đặt typeId cho Hive
class Schedule extends HiveObject {
  @HiveField(0)
  String id;

  @HiveField(1)
  String title;

  @HiveField(2)
  DateTime startTime;

  @HiveField(3)
  DateTime endTime;

  @HiveField(4)
  String type;

  @HiveField(5)
  bool isCompleted; // Trạng thái hoàn thành

  Schedule({
    required this.id,
    required this.title,
    required this.startTime,
    required this.endTime,
    required this.type,
    this.isCompleted = false, // Mặc định là chưa hoàn thành
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'startTime': startTime.toIso8601String(),
      'endTime': endTime.toIso8601String(),
      'type': type,
    };
  }

  factory Schedule.fromFirestore(DocumentSnapshot doc) {
    Map data = doc.data() as Map<String, dynamic>;
    return Schedule(
      id: data['id'],
      title: data['title'],
      startTime: DateTime.parse(data['startTime']),
      endTime: DateTime.parse(data['endTime']),
      type: data['type'],
    );
  }
}
