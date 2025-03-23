import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:quanlydoisong/controllers/schedule_controller.dart';
import 'package:quanlydoisong/view/widget/weather_detail_page.dart';
import 'package:table_calendar/table_calendar.dart';

import 'chat_AI/boxchat.dart';
import 'profile_page.dart';
import 'settings_page.dart';
import 'dreamPage/dreams_page.dart'; // Import DreamsPage

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedIndex = 0;

  static const List<Widget> _widgetOptions = <Widget>[
    HomePageContent(),
    BoxChatAI(),
    ProfilePage(),
    SettingsPage(),
  ];

  void _onItemTapped(int index) {
    setState(() => _selectedIndex = index);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: const Text('Quản Lý Đời Sống',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 22)),
        backgroundColor: Colors.blueAccent,
      ),
      body: _widgetOptions[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Trang Chủ',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.chat),
            label: 'Chat AI',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Cá Nhân',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings),
            label: 'Cài Đặt',
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.blueAccent,
        unselectedItemColor: Colors.grey,
        onTap: _onItemTapped,
        showSelectedLabels: true,
        showUnselectedLabels: true,
      ),
    );
  }
}

class HomePageContent extends StatelessWidget {
  const HomePageContent({super.key});

  @override
  Widget build(BuildContext context) {
    final scheduleController = Get.put(ScheduleController());
    final today = DateTime.now();

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _buildHeader(),
          const SizedBox(height: 20),
          _buildFeatureSection(context),
          const SizedBox(height: 20),
          _buildTodaySchedule(scheduleController, today),
          const SizedBox(height: 20),
          _buildCalendarSection(),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return StreamBuilder<String>(
      stream: _fetchUsernameStream(),
      builder: (context, snapshot) {
        final username = snapshot.data ?? 'Người dùng';
        return Card(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
          elevation: 6,
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(15),
              gradient: const LinearGradient(
                  colors: [Colors.blueAccent, Colors.lightBlueAccent]),
            ),
            child: Row(
              children: [
                const CircleAvatar(
                  backgroundColor: Colors.white,
                  radius: 30,
                  child: Icon(Icons.person, size: 30, color: Colors.blueAccent),
                ),
                const SizedBox(width: 16),
                Text(
                  'Xin chào, $username!',
                  style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 20,
                      color: Colors.white),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Stream<String> _fetchUsernameStream() async* {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final doc = FirebaseFirestore.instance.collection('users').doc(user.uid);
      await for (var snapshot in doc.snapshots()) {
        yield snapshot.data()?['username'] ?? 'Người dùng';
      }
    } else {
      yield 'Khách';
    }
  }

  Widget _buildFeatureSection(BuildContext context) {
    final features = [
      {'icon': Icons.schedule, 'label': 'Thời Gian', 'route': '/schedules'},
      {'icon': Icons.book, 'label': 'Chi Tiêu', 'route': '/budget'},
      {
        'icon': Icons.star,
        'label': 'Ước mơ & Dự định',
        'route': '/dreams'
      }, // Thay thế "Lương" bằng "Ước mơ & Dự định"
      {'icon': Icons.cloud, 'label': 'Thời Tiết', 'route': '/weather'},
    ];

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: features.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2, mainAxisSpacing: 12, crossAxisSpacing: 12),
      itemBuilder: (context, index) {
        final feature = features[index];
        return GestureDetector(
          onTap: () {
            if (feature['route'] == '/weather') {
              Get.to(() => const WeatherDetailPage());
            } else if (feature['route'] == '/dreams') {
              Get.to(() => DreamsPage()); // Điều hướng tới DreamsPage
            } else {
              Get.toNamed(feature['route'] as String);
            }
          },
          child: Card(
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(feature['icon'] as IconData,
                    size: 32, color: Colors.blueAccent),
                const SizedBox(height: 8),
                Text(feature['label'] as String,
                    style: const TextStyle(
                        fontSize: 16, fontWeight: FontWeight.bold)),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildTodaySchedule(ScheduleController controller, DateTime today) {
    return Obx(() {
      final todaySchedules = controller.getTodaySchedules(today);
      final completionPercentage = controller.getCompletionPercentage(today);

      return Card(
        elevation: 5,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Lịch trình hôm nay',
                  style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.blueAccent)),
              const SizedBox(height: 8),
              LinearProgressIndicator(
                value: completionPercentage / 100,
                backgroundColor: Colors.grey.shade300,
                color: Colors.blueAccent,
                minHeight: 8,
              ),
              const SizedBox(height: 8),
              Text(
                'Hoàn thành: ${completionPercentage.toStringAsFixed(1)}%',
                style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.black),
              ),
              const SizedBox(height: 8),
              if (todaySchedules.isEmpty)
                const Center(child: Text('Hôm nay không có lịch trình nào.'))
              else
                Column(
                  children: todaySchedules.map((schedule) {
                    return ListTile(
                      leading: Checkbox(
                        value: schedule.isCompleted,
                        onChanged: (value) {
                          controller.toggleCompletion(schedule.id);
                        },
                      ),
                      title: Text(
                        schedule.title,
                        style: TextStyle(
                          color:
                              schedule.isCompleted ? Colors.grey : Colors.black,
                          decoration: schedule.isCompleted
                              ? TextDecoration.lineThrough
                              : TextDecoration.none,
                        ),
                      ),
                      subtitle: Text(
                          '${DateFormat('HH:mm').format(schedule.startTime)} - ${DateFormat('HH:mm').format(schedule.endTime)}'),
                    );
                  }).toList(),
                ),
            ],
          ),
        ),
      );
    });
  }

  Widget _buildCalendarSection() {
    return Card(
      elevation: 5,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: TableCalendar(
          locale: 'vi_VN',
          firstDay: DateTime.utc(2020, 1, 1),
          lastDay: DateTime.utc(2030, 12, 31),
          focusedDay: DateTime.now(),
          calendarStyle: const CalendarStyle(
              todayDecoration:
                  BoxDecoration(color: Colors.teal, shape: BoxShape.circle)),
          headerStyle: const HeaderStyle(
              titleCentered: true, formatButtonVisible: false),
        ),
      ),
    );
  }
}
