import 'package:get/get.dart';
import 'package:quanlydoisong/models/schedule.dart';
import 'package:quanlydoisong/services/data_service.dart';
import 'package:uuid/uuid.dart';

class ScheduleController extends GetxController {
  final DataService dataService = DataService();

  var schedules = <Schedule>[].obs;

  @override
  void onReady() {
    super.onReady();
    loadSchedules();
  }

  void loadSchedules() {
    schedules.assignAll(dataService.scheduleBox.values.toList());
  }

  void addSchedule(String title, DateTime startTime, DateTime endTime, String type) {
    var uuid = Uuid();
    var schedule = Schedule(
      id: uuid.v4(),
      title: title,
      startTime: startTime,
      endTime: endTime,
      type: type,
    );
    dataService.scheduleBox.put(schedule.id, schedule);
    schedules.add(schedule);
   
  }

  void removeSchedule(String id) {
    dataService.scheduleBox.delete(id);
    schedules.removeWhere((schedule) => schedule.id == id);
  }

  void updateSchedule(String id, String title, DateTime startTime, DateTime endTime, String type) {
    var schedule = dataService.scheduleBox.get(id);
    if (schedule != null) {
      schedule.title = title;
      schedule.startTime = startTime;
      schedule.endTime = endTime;
      schedule.type = type;
      schedule.save();
      loadSchedules();
    }
  }

  // Tính tổng thời gian theo loại và tháng
  Map<String, Map<int, Duration>> getTotalTimeByTypeAndMonth() {
    Map<String, Map<int, Duration>> result = {};

    for (var schedule in schedules) {
      final type = schedule.type;
      final month = schedule.startTime.month;

      final duration = schedule.endTime.difference(schedule.startTime);

      if (!result.containsKey(type)) {
        result[type] = {};
      }
      if (!result[type]!.containsKey(month)) {
        result[type]![month] = Duration.zero;
      }

      result[type]![month] = result[type]![month]! + duration;
    }

    return result;
  }

  // Getter để tính tổng thời gian của từng loại
  Duration getTotalTimeByType(String type) {
    return schedules
        .where((schedule) => schedule.type == type)
        .fold(Duration.zero, (sum, schedule) => sum + schedule.endTime.difference(schedule.startTime));
  }
}
