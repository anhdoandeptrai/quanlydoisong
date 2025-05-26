import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final List<String> interests = [
    'Thể Thao',
    'Đọc Sách',
    'Du Lịch',
    'Nấu Ăn',
    'Làm Vườn'
  ];
  List<String> selectedInterests = [];
  String username = '';
  double height = 0.0;
  double weight = 0.0;
  double bmi = 0.0;

  final TextEditingController usernameController = TextEditingController();
  final TextEditingController heightController = TextEditingController();
  final TextEditingController weightController = TextEditingController();

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    try {
      User? currentUser = _auth.currentUser;
      if (currentUser != null) {
        DocumentSnapshot doc =
            await _firestore.collection('users').doc(currentUser.uid).get();
        if (doc.exists) {
          setState(() {
            username = doc['username'] ?? 'Người dùng';
            selectedInterests = List<String>.from(doc['interests'] ?? []);
            height = (doc['height'] ?? 0).toDouble();
            weight = (doc['weight'] ?? 0).toDouble();
            bmi = (doc['bmi'] ?? 0).toDouble();

            usernameController.text = username;
            heightController.text = height > 0 ? height.toString() : '';
            weightController.text = weight > 0 ? weight.toString() : '';
          });
        }
      }
    } catch (e) {
      print('Lỗi khi tải dữ liệu: $e');
    }
  }

  void _calculateBMI() {
    if (height > 0 && weight > 0) {
      setState(() {
        bmi = weight / (height * height);
      });
    }
  }

  Future<void> _saveUserData() async {
    try {
      User? currentUser = _auth.currentUser;
      if (currentUser != null) {
        await _firestore.collection('users').doc(currentUser.uid).set({
          'username': username,
          'interests': selectedInterests,
          'height': height,
          'weight': weight,
          'bmi': bmi,
        });
        Get.snackbar('Thành Công', 'Thông tin đã được cập nhật!',
            snackPosition: SnackPosition.TOP);
      }
    } catch (e) {
      Get.snackbar('Lỗi', 'Không thể cập nhật!',
          snackPosition: SnackPosition.TOP,
          backgroundColor: Colors.red,
          colorText: Colors.white);
    }
  }

  Color _getBMIColor() {
    if (bmi < 18.5) return Colors.blue;
    if (bmi < 24.9) return Colors.green;
    if (bmi < 29.9) return Colors.orange;
    return Colors.red;
  }

  Widget _buildInterestChip(String interest) {
    final isSelected = selectedInterests.contains(interest);
    return ChoiceChip(
      label: Text(
        interest,
        style: TextStyle(
          color: isSelected
              ? Theme.of(context).colorScheme.onPrimary
              : Theme.of(context).textTheme.bodyMedium?.color,
        ),
      ),
      selected: isSelected,
      onSelected: (selected) {
        setState(() {
          if (selected) {
            selectedInterests.add(interest);
          } else {
            selectedInterests.remove(interest);
          }
        });
      },
      selectedColor:
          Colors.lightBlueAccent, // Màu xanh dương nhạt khi được chọn
      backgroundColor:
          Theme.of(context).cardColor, // Màu nền khi không được chọn
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Thông Tin Cá Nhân',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.white, // Màu chữ trắng
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.blueAccent, // Màu nền xanh đậm
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Avatar và thông tin cá nhân
            Container(
              padding: const EdgeInsets.all(16.0),
              decoration: BoxDecoration(
                color: Colors.lightBlueAccent.withOpacity(0.1), // Nền xanh nhạt
                borderRadius: BorderRadius.circular(16), // Bo góc
              ),
              child: Column(
                children: [
                  // Avatar
                  CircleAvatar(
                    radius: 50,
                    backgroundColor: Colors.lightBlueAccent,
                    child: const Icon(
                      Icons.person,
                      size: 50,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 16),
                  // Tên người dùng
                  TextField(
                    onTapOutside: (_) {
                      FocusScope.of(context).unfocus();
                    },
                    controller: usernameController,
                    decoration: InputDecoration(
                      labelText: 'Tên Người Dùng',
                      border: const OutlineInputBorder(),
                      labelStyle: TextStyle(
                        color: Theme.of(context).textTheme.bodyMedium?.color,
                      ),
                    ),
                    style: TextStyle(
                      color: Theme.of(context).textTheme.bodyMedium?.color,
                    ),
                    onChanged: (value) => username = value.trim(),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Chiều cao và cân nặng
            Container(
              padding: const EdgeInsets.all(16.0),
              decoration: BoxDecoration(
                color: Colors.lightBlueAccent.withOpacity(0.1), // Nền xanh nhạt
                borderRadius: BorderRadius.circular(16), // Bo góc
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Thông Tin Sức Khỏe',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.lightBlueAccent, // Màu chữ xanh nhạt
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: heightController,
                          decoration: InputDecoration(
                            labelText: 'Chiều Cao (m)',
                            border: const OutlineInputBorder(),
                            labelStyle: TextStyle(
                              color:
                                  Theme.of(context).textTheme.bodyMedium?.color,
                            ),
                          ),
                          keyboardType: TextInputType.number,
                          style: TextStyle(
                            color:
                                Theme.of(context).textTheme.bodyMedium?.color,
                          ),
                          onChanged: (value) {
                            height = double.tryParse(value) ?? 0.0;
                            _calculateBMI();
                          },
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: TextField(
                          controller: weightController,
                          decoration: InputDecoration(
                            labelText: 'Cân Nặng (kg)',
                            border: const OutlineInputBorder(),
                            labelStyle: TextStyle(
                              color:
                                  Theme.of(context).textTheme.bodyMedium?.color,
                            ),
                          ),
                          keyboardType: TextInputType.number,
                          style: TextStyle(
                            color:
                                Theme.of(context).textTheme.bodyMedium?.color,
                          ),
                          onChanged: (value) {
                            weight = double.tryParse(value) ?? 0.0;
                            _calculateBMI();
                          },
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    'Chỉ Số BMI',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.lightBlueAccent, // Màu chữ xanh nhạt
                    ),
                  ),
                  const SizedBox(height: 8),
                  bmi > 0
                      ? Container(
                          width: 100,
                          height: 100,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: _getBMIColor().withOpacity(0.1),
                          ),
                          child: Center(
                            child: Text(
                              bmi.toStringAsFixed(1),
                              style: TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: _getBMIColor(),
                              ),
                            ),
                          ),
                        )
                      : Text(
                          'Chưa có dữ liệu',
                          style: TextStyle(
                            fontSize: 18,
                            color:
                                Theme.of(context).textTheme.bodyMedium?.color,
                          ),
                        ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Sở thích
            Container(
              padding: const EdgeInsets.all(16.0),
              decoration: BoxDecoration(
                color: Colors.lightBlueAccent.withOpacity(0.1), // Nền xanh nhạt
                borderRadius: BorderRadius.circular(16), // Bo góc
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Chọn Sở Thích',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.lightBlueAccent, // Màu chữ xanh nhạt
                    ),
                  ),
                  const SizedBox(height: 16),
                  Wrap(
                    spacing: 10,
                    runSpacing: 10,
                    children: interests
                        .map((interest) => _buildInterestChip(interest))
                        .toList(),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Nút cập nhật
            ElevatedButton(
              onPressed: _saveUserData,
              style: ElevatedButton.styleFrom(
                backgroundColor:
                    Colors.lightBlueAccent, // Màu xanh nhạt cho nút
                foregroundColor: Colors.white, // Màu chữ trắng
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12), // Bo góc nút
                ),
                padding: const EdgeInsets.symmetric(
                    horizontal: 24, vertical: 12), // Padding cho nút
              ),
              child: const Text(
                'Cập Nhật',
                style: TextStyle(fontWeight: FontWeight.bold), // Chữ đậm
              ),
            ),
          ],
        ),
      ),
    );
  }
}
