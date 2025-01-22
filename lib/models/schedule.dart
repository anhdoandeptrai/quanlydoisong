import 'package:hive/hive.dart';

part 'schedule.g.dart';

@HiveType(typeId: 0)
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
  String type; // "Study" or "Work"

  Schedule({
    required this.id,
    required this.title,
    required this.startTime,
    required this.endTime,
    required this.type,
  });
}
