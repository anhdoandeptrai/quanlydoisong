import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/schedule_controller.dart';
import '../../models/schedule.dart';
import 'package:intl/intl.dart';

class EditScheduleView extends StatefulWidget {
  final String scheduleId;

  EditScheduleView({required this.scheduleId});

  @override
  _EditScheduleViewState createState() => _EditScheduleViewState();
}

class _EditScheduleViewState extends State<EditScheduleView> {
  final _formKey = GlobalKey<FormState>();
  final ScheduleController scheduleController = Get.find<ScheduleController>();

  late Schedule schedule;
  String title = '';
  String type = 'Study'; // Mặc định là Học tập
  DateTime? startTime;
  DateTime? endTime;

  @override
  void initState() {
    super.initState();
    // Lấy lịch trình cần chỉnh sửa từ controller
    schedule = scheduleController.schedules
        .firstWhere((s) => s.id == widget.scheduleId);
    title = schedule.title;
    type = schedule.type;
    startTime = schedule.startTime;
    endTime = schedule.endTime;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Chỉnh Sửa Lịch Trình'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              children: [
                // Tiêu đề lịch trình
                TextFormField(
                  initialValue: title,
                  decoration: InputDecoration(labelText: 'Tiêu Đề'),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Vui lòng nhập tiêu đề';
                    }
                    return null;
                  },
                  onSaved: (value) {
                    title = value!;
                  },
                ),
                SizedBox(height: 16),
                // Loại lịch trình (Học tập hoặc Làm việc)
                DropdownButtonFormField<String>(
                  value: type,
                  decoration: InputDecoration(labelText: 'Loại'),
                  items: [
                    'Study',
                    'Work',
                    'Sport',
                    'Entertainment',
                    'Health',
                    'Family',
                    'Travel',
                    'Volunteer',
                    'Personal Development'
                  ].map((String category) {
                    return DropdownMenuItem<String>(
                      value: category,
                      child: Text(category == 'Study'
                          ? 'Học Tập'
                          : category == 'Work'
                              ? 'Làm Việc'
                              : category == 'Sport'
                                  ? 'Thể Thao'
                                  : category == 'Entertainment'
                                      ? 'Giải Trí'
                                      : category == 'Health'
                                          ? 'Chăm Sóc Sức Khỏe'
                                          : category == 'Family'
                                              ? 'Gia Đình'
                                              : category == 'Travel'
                                                  ? 'Du Lịch'
                                                  : category == 'Volunteer'
                                                      ? 'Tình Nguyện'
                                                      : 'Học Tập và Phát Triển Bản Thân'),
                    );
                  }).toList(),
                  onChanged: (newValue) {
                    setState(() {
                      type = newValue!;
                    });
                  },
                ),
                SizedBox(height: 16),
                // Chọn thời gian bắt đầu
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton(
                        child: Text(startTime == null
                            ? 'Chọn Thời Gian Bắt Đầu'
                            : 'Bắt Đầu: ${DateFormat('dd/MM/yyyy – HH:mm').format(startTime!)}'),
                        onPressed: () async {
                          final DateTime? pickedDate = await showDatePicker(
                            context: context,
                            initialDate: startTime ?? DateTime.now(),
                            firstDate: DateTime(2000),
                            lastDate: DateTime(2101),
                          );
                          if (pickedDate != null) {
                            final TimeOfDay? pickedTime = await showTimePicker(
                              context: context,
                              initialTime: TimeOfDay.fromDateTime(
                                  startTime ?? DateTime.now()),
                            );
                            if (pickedTime != null) {
                              setState(() {
                                startTime = DateTime(
                                  pickedDate.year,
                                  pickedDate.month,
                                  pickedDate.day,
                                  pickedTime.hour,
                                  pickedTime.minute,
                                );
                              });
                            }
                          }
                        },
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 16),
                // Chọn thời gian kết thúc
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton(
                        child: Text(endTime == null
                            ? 'Chọn Thời Gian Kết Thúc'
                            : 'Kết Thúc: ${DateFormat('dd/MM/yyyy – HH:mm').format(endTime!)}'),
                        onPressed: () async {
                          final DateTime? pickedDate = await showDatePicker(
                            context: context,
                            initialDate: endTime ??
                                (startTime ?? DateTime.now())
                                    .add(Duration(hours: 1)),
                            firstDate: startTime ?? DateTime.now(),
                            lastDate: DateTime(2101),
                          );
                          if (pickedDate != null) {
                            final TimeOfDay? pickedTime = await showTimePicker(
                              context: context,
                              initialTime: TimeOfDay.fromDateTime(
                                  endTime ?? DateTime.now()),
                            );
                            if (pickedTime != null) {
                              setState(() {
                                endTime = DateTime(
                                  pickedDate.year,
                                  pickedDate.month,
                                  pickedDate.day,
                                  pickedTime.hour,
                                  pickedTime.minute,
                                );
                              });
                            }
                          }
                        },
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 24),
                // Nút Lưu
                ElevatedButton(
                  child: Text('Lưu Thay Đổi'),
                  onPressed: () {
                    if (_formKey.currentState!.validate() &&
                        startTime != null &&
                        endTime != null) {
                      if (endTime!.isBefore(startTime!)) {
                        Get.snackbar(
                          'Lỗi',
                          'Thời gian kết thúc phải sau thời gian bắt đầu',
                          snackPosition: SnackPosition.TOP,
                          backgroundColor: Colors.redAccent,
                          colorText: Colors.white,
                        );
                        return;
                      }
                      _formKey.currentState!.save();
                      scheduleController.updateSchedule(
                        schedule.id,
                        title,
                        startTime!,
                        endTime!,
                        type,
                      );
                      Get.back();
                      Get.snackbar(
                        'Thành Công',
                        'Đã cập nhật lịch trình',
                        snackPosition: SnackPosition.TOP,
                      );
                    } else {
                      Get.snackbar(
                        'Lỗi',
                        'Vui lòng điền đầy đủ thông tin',
                        snackPosition: SnackPosition.TOP,
                        backgroundColor: Colors.redAccent,
                        colorText: Colors.white,
                      );
                    }
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
