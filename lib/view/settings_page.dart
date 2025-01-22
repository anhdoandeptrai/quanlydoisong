import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hive/hive.dart';
import 'package:excel/excel.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';

class SettingsPage extends StatelessWidget {
  const SettingsPage({Key? key}) : super(key: key);

  Future<void> _exportDataToExcel() async {
    try {
      // Step 1: Load data from Hive
      var box = Hive.box('settings');
      var data = box.toMap();

      // Step 2: Create an Excel file
      var excel = Excel.createExcel();
      var sheet = excel['Sheet1'];

      // Add headers
      sheet.appendRow(['Key', 'Value']);

      // Add data rows
      data.forEach((key, value) {
        sheet.appendRow([key.toString(), value.toString()]);
      });

      // Step 3: Save the file
      var directory = await getApplicationDocumentsDirectory();
      String filePath = '${directory.path}/report.xlsx';
      List<int>? fileBytes = excel.save();
      if (fileBytes != null) {
        File(filePath)
          ..createSync(recursive: true)
          ..writeAsBytesSync(fileBytes);
        print('File saved: $filePath');
      }

      // Show success message
      Get.snackbar("Thành Công", "Báo cáo đã được xuất: $filePath",
          snackPosition: SnackPosition.TOP);
    } catch (e) {
      print('Error exporting data: $e');
      Get.snackbar("Lỗi", "Không thể xuất báo cáo",
          snackPosition: SnackPosition.TOP);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: const Text('Cài Đặt',
            style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.blueAccent,
        elevation: 4.0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Center(
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 50),
                ElevatedButton(
                  onPressed: () {
                    var box = Hive.box('settings');
                    box.put('isLoggedIn', false);
                    Get.offAllNamed('/');
                  },
                  child: const Text('Đăng Xuất'),
                  style: ElevatedButton.styleFrom(
                    foregroundColor: Colors.white,
                    backgroundColor: Colors.red,
                    minimumSize: const Size(double.infinity, 60),
                    textStyle: const TextStyle(fontSize: 20),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: _exportDataToExcel,
                  child: const Text('Xuất Báo Cáo Excel'),
                  style: ElevatedButton.styleFrom(
                    foregroundColor: Colors.white,
                    backgroundColor: Colors.green,
                    minimumSize: const Size(double.infinity, 60),
                    textStyle: const TextStyle(fontSize: 20),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
