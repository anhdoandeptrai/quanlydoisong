import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:quanlydoisong/controllers/selection_controller.dart%2002-18-22-645.dart';
import 'package:quanlydoisong/view/home_view.dart';

class PreferenceSelectionPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final controller = Get.find<PreferenceController>();

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Text(
          'Cá Nhân Hóa Sở Thích',
          style: TextStyle(fontSize: 20, color: Colors.black),
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Logo Section
            Center(
              child: Image.asset(
                'assets/logo.png',
                height: 250,
              ),
            ),
            SizedBox(height: 20),
            // Avatar Section
            Center(
              child: CircleAvatar(
                radius: 50,
                backgroundColor: Colors.blueAccent.withOpacity(0.1),
                child: Icon(
                  Icons.favorite,
                  size: 60,
                  color: Colors.blueAccent,
                ),
              ),
            ),
            SizedBox(height: 20),
            // Heading Section
            Text(
              'Chọn Sở Thích',
              style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.black),
            ),
            SizedBox(height: 16),
            // Interests Section as Chips
            Obx(
              () => Wrap(
                spacing: 10,
                runSpacing: 10,
                children: controller.interests.map((interests) {
                  bool isSelected =
                      controller.selectedPreferences.contains(interests);
                  return GestureDetector(
                    onTap: () {
                      controller.togglePreference(interests);
                    },
                    child: AnimatedContainer(
                      duration: Duration(milliseconds: 300),
                      padding:
                          EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? Colors.blueAccent
                            : Colors.grey.shade200,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: isSelected
                            ? [
                                BoxShadow(
                                  color: Colors.blueAccent.withOpacity(0.3),
                                  blurRadius: 10,
                                  offset: Offset(0, 4),
                                ),
                              ]
                            : [],
                      ),
                      child: Text(
                        interests,
                        style: TextStyle(
                          color: isSelected ? Colors.white : Colors.black,
                          fontSize: 16,
                          fontWeight:
                              isSelected ? FontWeight.bold : FontWeight.normal,
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
            SizedBox(height: 20),
            // Save Button
            Center(
              child: ElevatedButton(
                onPressed: () {
                  Get.snackbar('Thành Công', 'Thông tin đã được cập nhật!',
                      snackPosition: SnackPosition.TOP,
                      backgroundColor: Colors.white,
                      colorText: Colors.black);
                  Get.off(() => HomeView());
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blueAccent,
                  padding: EdgeInsets.symmetric(vertical: 14, horizontal: 40),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text(
                  'Lưu Sở Thích',
                  style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.white),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
