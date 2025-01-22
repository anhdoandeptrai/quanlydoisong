import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:intl/intl.dart';
import '../../controllers/schedule_controller.dart';
import '../../models/schedule.dart';
import 'add_schedule_view.dart';
import 'edit_schedule_view.dart';

// Extensions cho String để map type
extension ScheduleTypeExtension on String {
  String get displayTitle {
    switch (this) {
      case 'Work':
        return 'Làm Việc';
      case 'Study':
        return 'Học Tập';
      case 'Sport':
        return 'Thể Thao';
      case 'Entertainment':
        return 'Giải Trí';
      case 'Health':
        return 'Chăm Sóc Sức Khỏe';
      case 'Family':
        return 'Gia Đình';
      case 'Travel':
        return 'Du Lịch';
      case 'Volunteer':
        return 'Tình Nguyện';
      case 'Personal Development':
        return 'Học Tập và Phát Triển Bản Thân';
      default:
        return 'Khác';
    }
  }

  IconData get displayIcon {
    switch (this) {
      case 'Work':
        return Icons.work;
      case 'Study':
        return Icons.school;
      case 'Sport':
        return Icons.sports;
      case 'Entertainment':
        return Icons.local_activity;
      case 'Health':
        return Icons.health_and_safety;
      case 'Family':
        return Icons.family_restroom;
      case 'Travel':
        return Icons.travel_explore;
      case 'Volunteer':
        return Icons.volunteer_activism;
      case 'Personal Development':
        return Icons.book;
      default:
        return Icons.event;
    }
  }

  Color get displayColor {
    switch (this) {
      case 'Work':
        return Colors.blueAccent;
      case 'Study':
        return Colors.green;
      case 'Sport':
        return Colors.orangeAccent;
      case 'Entertainment':
        return Colors.purpleAccent;
      case 'Health':
        return Colors.redAccent;
      case 'Family':
        return Colors.tealAccent;
      case 'Travel':
        return Colors.lightBlueAccent;
      case 'Volunteer':
        return Colors.pinkAccent;
      case 'Personal Development':
        return Colors.indigoAccent;
      default:
        return Colors.grey;
    }
  }
}

class ScheduleListView extends StatefulWidget {
  @override
  State<ScheduleListView> createState() => _ScheduleListViewState();
}

class _ScheduleListViewState extends State<ScheduleListView> {
  final ScheduleController scheduleController = Get.find<ScheduleController>();
  DateTime _selectedDay = DateTime.now();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Lịch trình của bạn',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
        ),
        backgroundColor: Colors.blue,
        elevation: 0,
      ),
      body: Column(
        children: [
          // Calendar Section
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.cyan.shade100, Colors.cyan.shade100],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.vertical(bottom: Radius.circular(20)),
            ),
            padding: EdgeInsets.symmetric(vertical: 16, horizontal: 8),
            child: TableCalendar(
              firstDay: DateTime(2020),
              lastDay: DateTime(2050),
              focusedDay: _selectedDay,
              calendarFormat: CalendarFormat.month,
              selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
              onDaySelected: (selectedDay, focusedDay) {
                setState(() {
                  _selectedDay = selectedDay;
                });
              },
              calendarStyle: CalendarStyle(
                todayDecoration: BoxDecoration(
                  color: Colors.teal.withOpacity(0.5),
                  shape: BoxShape.circle,
                ),
                selectedDecoration: BoxDecoration(
                  color: Colors.orange,
                  shape: BoxShape.circle,
                ),
                markerDecoration: BoxDecoration(
                  color: Colors.blue,
                  shape: BoxShape.circle,
                ),
              ),
              headerStyle: HeaderStyle(
                formatButtonVisible: false,
                titleTextStyle:
                    TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                leftChevronIcon: Icon(Icons.chevron_left, color: Colors.black),
                rightChevronIcon:
                    Icon(Icons.chevron_right, color: Colors.black),
              ),
            ),
          ),
          // Schedule List Section
          Expanded(
            child: Obx(() {
              final selectedSchedules = scheduleController.schedules
                  .where((s) =>
                      isSameDay(s.startTime, _selectedDay) ||
                      isSameDay(s.endTime, _selectedDay))
                  .toList();

              if (selectedSchedules.isEmpty) {
                return Center(
                  child: Text(
                    'Không có lịch trình nào trong ngày này.',
                    style: TextStyle(fontSize: 18, color: Colors.grey),
                  ),
                );
              }

              final groupedSchedules = _groupSchedulesByType(selectedSchedules);

              return ListView(
                children: groupedSchedules.entries.map((entry) {
                  final type = entry.key;
                  final schedules = entry.value;

                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8.0),
                    child: Card(
                      margin: EdgeInsets.only(top: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 3,
                      child: ExpansionTile(
                        leading:
                            Icon(type.displayIcon, color: type.displayColor),
                        title: Text(
                          type.displayTitle,
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: type.displayColor,
                          ),
                        ),
                        children: schedules
                            .map((schedule) => ScheduleTile(schedule: schedule))
                            .toList(),
                      ),
                    ),
                  );
                }).toList(),
              );
            }),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Get.to(() => AddScheduleView()),
        child: Icon(Icons.add, color: Colors.white),
        backgroundColor: Colors.blue,
      ),
    );
  }

  // Nhóm lịch trình theo type
  Map<String, List<Schedule>> _groupSchedulesByType(List<Schedule> schedules) {
    final Map<String, List<Schedule>> groupedSchedules = {};
    for (var schedule in schedules) {
      groupedSchedules.putIfAbsent(schedule.type, () => []).add(schedule);
    }
    return groupedSchedules;
  }
}

class ScheduleTile extends StatelessWidget {
  final Schedule schedule;

  const ScheduleTile({Key? key, required this.schedule}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final formattedStart =
        DateFormat('HH:mm dd/MM/yyyy').format(schedule.startTime);
    final formattedEnd =
        DateFormat('HH:mm dd/MM/yyyy').format(schedule.endTime);

    // Màu nền dựa trên loại lịch trình
    final backgroundColor = schedule.type.displayColor.withOpacity(0.2);

    return Card(
      margin: EdgeInsets.symmetric(vertical: 4, horizontal: 16),
      color: backgroundColor, // Áp dụng màu nền
      child: ListTile(
        title: Text(
          schedule.title,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.black, // Đặt màu chữ là đen
          ),
        ),
        subtitle: Text(
          'Từ: $formattedStart\nĐến: $formattedEnd',
          style: TextStyle(
            color: Colors.black, // Đặt màu chữ là đen
          ),
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: Icon(Icons.edit, color: Colors.blue),
              onPressed: () =>
                  Get.to(() => EditScheduleView(scheduleId: schedule.id)),
            ),
            IconButton(
              icon: Icon(Icons.delete, color: Colors.red),
              onPressed: () =>
                  Get.find<ScheduleController>().removeSchedule(schedule.id),
            ),
          ],
        ),
      ),
    );
  }
}
