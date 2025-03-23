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
      label: Text(interest,
          style: TextStyle(color: isSelected ? Colors.white : Colors.black)),
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
      selectedColor: Colors.blueAccent,
      backgroundColor: Colors.grey.shade300,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          title: const Text('Thông Tin Cá Nhân'),
          centerTitle: true,
          backgroundColor: Colors.blueAccent),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            CircleAvatar(
              radius: 50,
              backgroundColor: Colors.blueAccent.withOpacity(0.1),
              child:
                  const Icon(Icons.person, size: 60, color: Colors.blueAccent),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: usernameController,
              decoration: const InputDecoration(
                  labelText: 'Tên Người Dùng', border: OutlineInputBorder()),
              onChanged: (value) => username = value.trim(),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: heightController,
                    decoration: const InputDecoration(
                        labelText: 'Chiều Cao (m)',
                        border: OutlineInputBorder()),
                    keyboardType: TextInputType.number,
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
                    decoration: const InputDecoration(
                        labelText: 'Cân Nặng (kg)',
                        border: OutlineInputBorder()),
                    keyboardType: TextInputType.number,
                    onChanged: (value) {
                      weight = double.tryParse(value) ?? 0.0;
                      _calculateBMI();
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            const Text('Chỉ Số BMI',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            bmi > 0
                ? Container(
                    width: 100,
                    height: 100,
                    decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: _getBMIColor().withOpacity(0.1)),
                    child: Center(
                      child: Text(
                        bmi.toStringAsFixed(1),
                        style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: _getBMIColor()),
                      ),
                    ),
                  )
                : const Text('Chưa có dữ liệu', style: TextStyle(fontSize: 18)),
            const SizedBox(height: 20),
            const Text('Chọn Sở Thích',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: interests
                  .map((interest) => _buildInterestChip(interest))
                  .toList(),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _saveUserData,
              style:
                  ElevatedButton.styleFrom(backgroundColor: Colors.blueAccent),
              child:
                  const Text('Cập Nhật', style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
      ),
    );
  }
}
