import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:quanlydoisong/view/widget/weather_detail_page.dart';
import 'package:table_calendar/table_calendar.dart';

class HomePage extends StatelessWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: const Text(
          'Quản Lý Đời Sống',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 22),
        ),
        backgroundColor: Colors.blueAccent,
        elevation: 4.0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            StreamBuilder<String>(
              stream: _fetchUsernameStream(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return _buildHeader('Đang tải...');
                } else if (snapshot.hasError) {
                  return _buildHeader('Lỗi: Không thể tải tên');
                } else {
                  final username = snapshot.data ?? 'Người dùng';
                  return _buildHeader(username);
                }
              },
            ),
            const SizedBox(height: 16),
            _buildFeatureSection(context),
            const SizedBox(height: 24),
            _buildCalendarSection(),
          ],
        ),
      ),
    );
  }

  // Hàm lấy tên người dùng qua Firestore
  Stream<String> _fetchUsernameStream() async* {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        yield 'Khách';
      } else {
        final doc =
            FirebaseFirestore.instance.collection('users').doc(user.uid);
        await for (var snapshot in doc.snapshots()) {
          yield snapshot.data()?['username'] ?? 'Người dùng';
        }
      }
    } catch (e) {
      yield 'Lỗi';
    }
  }

  // Header hiển thị lời chào người dùng
  Widget _buildHeader(String username) {
    return Card(
      elevation: 6,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(15),
          gradient: const LinearGradient(
            colors: [Colors.blueAccent, Colors.lightBlueAccent],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Row(
          children: [
            const CircleAvatar(
              backgroundColor: Colors.white,
              radius: 30,
              child: Icon(
                Icons.person,
                size: 30,
                color: Colors.blueAccent,
              ),
            ),
            const SizedBox(width: 16),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Xin chào, $username!',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Text(
                  'Quản lý đời sống dễ dàng hơn',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // Khu vực các chức năng chính
  Widget _buildFeatureSection(BuildContext context) {
    final features = [
      {
        'icon': Icons.schedule,
        'label': 'Quản Lý Thời Gian',
        'color': Colors.blueAccent,
        'route': '/schedules'
      },
      {
        'icon': Icons.book,
        'label': 'Sổ Chi Tiêu',
        'color': Colors.green,
        'route': '/budget'
      },
      {
        'icon': Icons.ad_units,
        'label': 'Chấm Công',
        'color': Colors.purple,
        'route': '/attendance'
      },
      {
        'icon': Icons.cloud,
        'label': 'Thời Tiết',
        'color': Colors.lightBlue,
        'route': '/weather'
      },
    ];

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        childAspectRatio: 1.2,
      ),
      itemCount: features.length,
      itemBuilder: (context, index) {
        final feature = features[index];
        return _buildFeatureCard(
          icon: feature['icon'] as IconData,
          label: feature['label'] as String,
          color: feature['color'] as Color,
          onPressed: () {
            if (feature['route'] == '/weather') {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => WeatherDetailPage()),
              );
            } else {
              Get.toNamed(feature['route'] as String);
            }
          },
        );
      },
    );
  }

  // Lịch (Calendar)
  Widget _buildCalendarSection() {
    return Card(
      elevation: 5,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Lịch',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.blueAccent,
              ),
            ),
            Divider(color: Colors.grey[300], thickness: 1),
            TableCalendar(
              locale: 'vi_VN',
              firstDay: DateTime.utc(2020, 1, 1),
              lastDay: DateTime.utc(2030, 12, 31),
              focusedDay: DateTime.now(),
              calendarStyle: const CalendarStyle(
                todayDecoration: BoxDecoration(
                  color: Colors.teal,
                  shape: BoxShape.circle,
                ),
                selectedDecoration: BoxDecoration(
                  color: Colors.blueAccent,
                  shape: BoxShape.circle,
                ),
                weekendTextStyle: TextStyle(color: Colors.red),
                outsideDaysVisible: false,
              ),
              headerStyle: const HeaderStyle(
                formatButtonVisible: false,
                titleCentered: true,
                titleTextStyle: TextStyle(
                  fontSize: 18.0,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Card của từng chức năng
  Widget _buildFeatureCard({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onPressed,
  }) {
    return InkWell(
      onTap: onPressed,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(15),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.shade200,
              blurRadius: 10,
              spreadRadius: 2,
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircleAvatar(
              backgroundColor: color.withOpacity(0.2),
              radius: 30,
              child: Icon(icon, size: 30, color: color),
            ),
            const SizedBox(height: 10),
            Text(
              label,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
