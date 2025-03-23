import 'package:get/get.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:uuid/uuid.dart';
import '../models/schedule.dart';

class ScheduleController extends GetxController {
  final RxList<Schedule> schedules = <Schedule>[].obs;
  late final Box<Schedule> _scheduleBox = Hive.box<Schedule>('schedules');

  @override
  void onInit() {
    super.onInit();
    _loadSchedules();
    Hive.box<Schedule>('schedules').listenable().addListener(_loadSchedules);
  }

  void _loadSchedules() {
    final box = Hive.box<Schedule>('schedules');
    schedules.value = box.values.toList();
  }

  void addSchedule(
      String title, DateTime startTime, DateTime endTime, String type) {
    var uuid = const Uuid();
    var schedule = Schedule(
      id: uuid.v4(),
      title: title,
      startTime: startTime,
      endTime: endTime,
      type: type,
    );
    schedules.add(schedule);
    _scheduleBox.put(schedule.id, schedule); // Lưu vào Hive
  }

  void removeSchedule(String id) {
    schedules.removeWhere((schedule) => schedule.id == id);
    _scheduleBox.delete(id); // Xóa khỏi Hive
  }

  void updateSchedule(String id, String title, DateTime startTime,
      DateTime endTime, String type) {
    var schedule = schedules.firstWhere((s) => s.id == id);
    schedule.title = title;
    schedule.startTime = startTime;
    schedule.endTime = endTime;
    schedule.type = type;
    schedules.refresh();
    _scheduleBox.put(schedule.id, schedule); // Cập nhật trong Hive
  }

  void toggleCompletion(String id) {
    var schedule = schedules.firstWhere((s) => s.id == id);
    schedule.isCompleted = !schedule.isCompleted;
    schedules.refresh();
    _scheduleBox.put(schedule.id, schedule); // Cập nhật trạng thái trong Hive
  }

  List<Schedule> getTodaySchedules(DateTime today) {
    return schedules.where((schedule) {
      return schedule.startTime.year == today.year &&
          schedule.startTime.month == today.month &&
          schedule.startTime.day == today.day;
    }).toList();
  }

  double getCompletionPercentage(DateTime today) {
    final todaySchedules = getTodaySchedules(today);
    if (todaySchedules.isEmpty) return 0.0;

    final completedCount =
        todaySchedules.where((schedule) => schedule.isCompleted).length;
    return (completedCount / todaySchedules.length) * 100;
  }
}
