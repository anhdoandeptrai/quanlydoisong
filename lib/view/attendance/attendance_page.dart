import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:quanlydoisong/view/attendance/history_page.dart';

import 'report_page.dart';

class AttendancePage extends StatefulWidget {
  const AttendancePage({Key? key}) : super(key: key);

  @override
  State<AttendancePage> createState() => _AttendancePageState();
}

class _AttendancePageState extends State<AttendancePage> {
  DateTime? startTime;
  DateTime? endTime;
  final TextEditingController rateController = TextEditingController();

  double get totalHours {
    if (startTime == null || endTime == null) return 0;
    final duration = endTime!.difference(startTime!);
    return duration.inMinutes / 60;
  }

  double get totalEarnings {
    final rate = double.tryParse(rateController.text.trim()) ?? 0;
    return totalHours * rate;
  }

  Future<void> _saveAttendance(BuildContext context) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      _showSnackBar('Vui lòng đăng nhập để lưu thông tin!', context);
      return;
    }

    if (startTime == null || endTime == null) {
      _showSnackBar('Vui lòng chọn thời gian bắt đầu và kết thúc!', context);
      return;
    }

    final hourlyRate = double.tryParse(rateController.text.trim()) ?? 0;
    if (hourlyRate <= 0) {
      _showSnackBar('Vui lòng nhập số tiền hợp lệ!', context);
      return;
    }

    try {
      final userRef =
          FirebaseFirestore.instance.collection('users').doc(user.uid);
      final attendanceRef = userRef.collection('attendanceRecords');
      final formattedDate = DateFormat('yyyy-MM-dd').format(startTime!);

      await attendanceRef.add({
        'date': formattedDate,
        'startTime': startTime,
        'endTime': endTime,
        'hoursWorked': totalHours,
        'hourlyRate': hourlyRate,
        'totalEarnings': totalEarnings,
        'timestamp': FieldValue.serverTimestamp(),
      });

      _showSnackBar('Lưu thông tin thành công!', context);

      // Reset dữ liệu sau khi lưu thành công
      setState(() {
        startTime = null;
        endTime = null;
        rateController.clear();
      });
    } catch (e) {
      _showSnackBar('Lỗi: ${e.toString()}', context);
    }
  }

  void _showSnackBar(String message, BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        action: SnackBarAction(
          label: 'Đóng',
          textColor: Colors.yellow,
          onPressed: () {},
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Quản Lý Công Việc'),
        backgroundColor: Colors.indigo,
        elevation: 4,
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.indigo, Colors.blueAccent],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        _buildSummaryCard('Thời gian',
                            '${totalHours.toStringAsFixed(2)} giờ'),
                        _buildSummaryCard('Tổng tiền',
                            '${totalEarnings.toStringAsFixed(2)} VND'),
                      ],
                    ),
                    const Divider(),
                    _buildDateTimePicker(
                      context,
                      'Thời Gian Bắt Đầu',
                      startTime,
                      (newValue) => setState(() => startTime = newValue),
                    ),
                    const SizedBox(height: 20),
                    _buildDateTimePicker(
                      context,
                      'Thời Gian Kết Thúc',
                      endTime,
                      (newValue) => setState(() => endTime = newValue),
                    ),
                    const SizedBox(height: 20),
                    TextField(
                      controller: rateController,
                      keyboardType: TextInputType.number,
                      onChanged: (_) => setState(() {}),
                      decoration: InputDecoration(
                        labelText: 'Số tiền mỗi giờ',
                        filled: true,
                        fillColor: Colors.grey[200],
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    ElevatedButton(
                      onPressed: () => _saveAttendance(context),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.orangeAccent,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text('Lưu Thông Tin'),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: Colors.indigo,
        selectedItemColor: Colors.white,
        unselectedItemColor: Colors.white70,
        onTap: (index) {
          if (index == 0) {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const HistoryPage()),
            );
          } else if (index == 1) {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const ReportPage()),
            );
          }
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.history),
            label: 'Lịch Sử',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.bar_chart),
            label: 'Báo Cáo',
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryCard(String title, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.green,
          ),
        ),
      ],
    );
  }

  Widget _buildDateTimePicker(
    BuildContext context,
    String label,
    DateTime? currentValue,
    Function(DateTime?) onValueChanged,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        GestureDetector(
          onTap: () async {
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
                onValueChanged(DateTime(
                  pickedDate.year,
                  pickedDate.month,
                  pickedDate.day,
                  pickedTime.hour,
                  pickedTime.minute,
                ));
              }
            }
          },
          child: Chip(
            label: Text(
              currentValue == null
                  ? 'Chọn $label'
                  : DateFormat('dd/MM/yyyy – HH:mm').format(currentValue),
              style: const TextStyle(color: Colors.white),
            ),
            backgroundColor: Colors.indigoAccent,
            avatar: const Icon(Icons.access_time, color: Colors.white),
          ),
        ),
      ],
    );
  }
}
