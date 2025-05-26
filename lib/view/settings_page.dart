import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hive/hive.dart';
import 'package:excel/excel.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  _SettingsPageState createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  late bool isDarkMode;

  @override
  void initState() {
    super.initState();
    var box = Hive.box('settings');
    isDarkMode = box.get('isDarkMode', defaultValue: false);

    // Đợi frame đầu tiên render xong rồi mới cập nhật theme
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Get.changeTheme(isDarkMode ? customDarkTheme : customLightTheme);
    });
  }

  void _toggleDarkMode(bool value) {
    setState(() {
      isDarkMode = value;
    });

    var box = Hive.box('settings');
    box.put('isDarkMode', value);

    Get.changeTheme(value ? customDarkTheme : customLightTheme);
  }

  Future<void> _exportDataToExcel() async {
    try {
      var box = Hive.box('settings');
      var data = box.toMap();

      var excel = Excel.createExcel();
      var sheet = excel['Sheet1'];

      sheet.appendRow(['Key', 'Value']);
      data.forEach((key, value) {
        sheet.appendRow([key.toString(), value.toString()]);
      });

      var directory = await getApplicationDocumentsDirectory();
      String filePath = '${directory.path}/report.xlsx';
      List<int>? fileBytes = excel.save();
      if (fileBytes != null) {
        File(filePath)
          ..createSync(recursive: true)
          ..writeAsBytesSync(fileBytes);
        Get.snackbar("Thành Công", "Báo cáo đã được lưu tại: $filePath",
            snackPosition: SnackPosition.TOP);
      }
    } catch (e) {
      Get.snackbar("Lỗi", "Không thể xuất báo cáo: ${e.toString()}",
          snackPosition: SnackPosition.TOP);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: const Text('Cài Đặt',
            style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Theme.of(context).appBarTheme.backgroundColor,
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
                SwitchListTile(
                  title:
                      const Text('Chế độ tối', style: TextStyle(fontSize: 18)),
                  value: isDarkMode,
                  onChanged: _toggleDarkMode,
                  secondary: Icon(
                    isDarkMode ? Icons.dark_mode : Icons.light_mode,
                    color: Theme.of(context).iconTheme.color,
                  ),
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () {
                    var box = Hive.box('settings');
                    box.put('isLoggedIn', false);
                    Get.offAllNamed('/welcome');
                  },
                  style: ElevatedButton.styleFrom(
                    foregroundColor: Colors.white,
                    backgroundColor: Colors.red,
                    minimumSize: const Size(double.infinity, 60),
                    textStyle: const TextStyle(fontSize: 20),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                  child: const Text('Đăng Xuất'),
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: _exportDataToExcel,
                  style: ElevatedButton.styleFrom(
                    foregroundColor: Colors.white,
                    backgroundColor: Colors.green,
                    minimumSize: const Size(double.infinity, 60),
                    textStyle: const TextStyle(fontSize: 20),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                  child: const Text('Xuất Báo Cáo Excel'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ========================
// 🎨 TUỲ CHỈNH DARK MODE
// ========================
final ThemeData customLightTheme = ThemeData.light().copyWith(
  scaffoldBackgroundColor: Colors.white, // Nền trắng
  appBarTheme: const AppBarTheme(
    backgroundColor: Colors.blueAccent, // AppBar màu xanh
    titleTextStyle: TextStyle(
        color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
    iconTheme: IconThemeData(color: Colors.white), // Icon màu trắng
  ),
  textTheme: const TextTheme(
    bodyMedium: TextStyle(color: Colors.black), // Văn bản màu đen
    titleLarge: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
  ),
  cardColor: Colors.grey[100], // Màu nền của Card
  iconTheme: const IconThemeData(color: Colors.blueAccent), // Icon màu xanh
  elevatedButtonTheme: ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      backgroundColor: Colors.blueAccent, // Button màu xanh
      foregroundColor: Colors.white, // Chữ trên button màu trắng
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    ),
  ),
);

final ThemeData customDarkTheme = ThemeData.dark().copyWith(
  scaffoldBackgroundColor: const Color(0xFF2D2F41), // Nền tối dịu mắt
  appBarTheme: const AppBarTheme(
    backgroundColor: Color(0xFF3E4155), // AppBar xám xanh nhẹ
    titleTextStyle: TextStyle(
        color: Color(0xFFE0E0E0), fontSize: 20, fontWeight: FontWeight.bold),
    iconTheme: IconThemeData(color: Color(0xFFE0E0E0)), // Icon màu trắng ngà
  ),
  textTheme: const TextTheme(
    bodyMedium: TextStyle(color: Color(0xFFE0E0E0)), // Văn bản màu trắng ngà
    titleLarge: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
  ),
  cardColor: const Color(0xFF424769), // Card tối nhưng vẫn có độ tương phản nhẹ
  iconTheme: const IconThemeData(color: Color(0xFFFF9800)), // Icon màu cam nhấn
  elevatedButtonTheme: ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      backgroundColor: const Color(0xFFFF9800), // Button màu cam nổi bật
      foregroundColor: Colors.white, // Chữ trên button màu trắng
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    ),
  ),
);
