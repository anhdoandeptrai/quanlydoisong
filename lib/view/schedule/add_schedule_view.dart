import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/schedule_controller.dart';
import 'package:intl/intl.dart';

class AddScheduleView extends StatefulWidget {
  const AddScheduleView({super.key});

  @override
  _AddScheduleViewState createState() => _AddScheduleViewState();
}

class _AddScheduleViewState extends State<AddScheduleView> {
  final _formKey = GlobalKey<FormState>();
  final ScheduleController scheduleController = Get.find<ScheduleController>();

  String title = '';
  String type = 'Study'; // Default category
  DateTime? startTime;
  DateTime? endTime;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Thêm Lịch Trình Mới',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        backgroundColor: Colors.blueAccent,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 20.0),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                Card(
                  elevation: 3,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Schedule Title Input
                        const Text(
                          'Tiêu Đề',
                          style: TextStyle(
                              fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 8),
                        TextFormField(
                          decoration: InputDecoration(
                            hintText: 'Nhập tiêu đề',
                            border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12)),
                          ),
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
                        const SizedBox(height: 20),
                        // Schedule Type Dropdown
                        const Text(
                          'Loại Lịch Trình',
                          style: TextStyle(
                              fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 8),
                        DropdownButtonFormField<String>(
                          value: type,
                          decoration: InputDecoration(
                            contentPadding: const EdgeInsets.symmetric(
                                horizontal: 12, vertical: 16),
                            border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12)),
                          ),
                          items: [
                            {'key': 'Study', 'value': 'Học Tập'},
                            {'key': 'Work', 'value': 'Làm Việc'},
                            {'key': 'Sport', 'value': 'Thể Thao'},
                            {'key': 'Entertainment', 'value': 'Giải Trí'},
                            {'key': 'Health', 'value': 'Chăm Sóc Sức Khỏe'},
                            {'key': 'Family', 'value': 'Gia Đình'},
                            {'key': 'Travel', 'value': 'Du Lịch'},
                            {'key': 'Volunteer', 'value': 'Tình Nguyện'},
                            {
                              'key': 'Personal Development',
                              'value': 'Phát Triển Bản Thân'
                            },
                            {'key': 'Other', 'value': 'Khác'},
                          ].map((item) {
                            return DropdownMenuItem<String>(
                              value: item['key'],
                              child: Text(item['value']!),
                            );
                          }).toList(),
                          onChanged: (newValue) {
                            setState(() {
                              type = newValue!;
                            });
                          },
                        ),
                        const SizedBox(height: 20),
                        // Start Time Picker
                        const Text(
                          'Thời Gian Bắt Đầu',
                          style: TextStyle(
                              fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 8),
                        OutlinedButton.icon(
                          icon: const Icon(Icons.calendar_today),
                          label: Text(
                            startTime == null
                                ? 'Chọn Thời Gian Bắt Đầu'
                                : DateFormat('dd/MM/yyyy – HH:mm')
                                    .format(startTime!),
                          ),
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          onPressed: () async {
                            final pickedDate = await showDatePicker(
                              context: context,
                              initialDate: DateTime.now(),
                              firstDate: DateTime(2000),
                              lastDate: DateTime(2101),
                            );
                            if (pickedDate != null) {
                              final pickedTime = await showTimePicker(
                                context: context,
                                initialTime: TimeOfDay.now(),
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
                        const SizedBox(height: 20),
                        // End Time Picker
                        const Text(
                          'Thời Gian Kết Thúc',
                          style: TextStyle(
                              fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 8),
                        OutlinedButton.icon(
                          icon: const Icon(Icons.calendar_today_outlined),
                          label: Text(
                            endTime == null
                                ? 'Chọn Thời Gian Kết Thúc'
                                : DateFormat('dd/MM/yyyy – HH:mm')
                                    .format(endTime!),
                          ),
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          onPressed: () async {
                            final pickedDate = await showDatePicker(
                              context: context,
                              initialDate: startTime ?? DateTime.now(),
                              firstDate: startTime ?? DateTime.now(),
                              lastDate: DateTime(2101),
                            );
                            if (pickedDate != null) {
                              final pickedTime = await showTimePicker(
                                context: context,
                                initialTime: TimeOfDay.now(),
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
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                // Add Schedule Button
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size(double.infinity, 50),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    backgroundColor: Colors.blue,
                  ),
                  child: const Text(
                    'Thêm Lịch Trình',
                    style: TextStyle(fontSize: 18, color: Colors.white),
                  ),
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
                      final controller = Get.find<ScheduleController>();
                      controller.addSchedule(
                        title,
                        startTime!,
                        endTime!,
                        type,
                      );
                      Get.back();
                      Get.snackbar(
                        'Thành Công',
                        'Đã thêm lịch trình mới',
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
