import 'package:get/get.dart';
import 'package:hive/hive.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class PreferenceController extends GetxController {
  var interests = [
    'Thể Thao',
    'Đọc Sách',
    'Du Lịch',
    'Nấu Ăn',
    'Làm Vườn',
  ].obs;

  var selectedPreferences = <String>[].obs;

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  @override
  void onInit() {
    super.onInit();
    _loadPreferences();
  }

  void togglePreference(String interest) {
    if (selectedPreferences.contains(interest)) {
      selectedPreferences.remove(interest);
    } else {
      selectedPreferences.add(interest);
    }
  }

  Future<void> savePreferences() async {
    // Lưu vào Hive
    final box = await Hive.openBox('interests');
    await box.put('interests', selectedPreferences.toList());

    // Lưu vào Firestore
    try {
      User? currentUser = _auth.currentUser;
      if (currentUser != null) {
        await _firestore.collection('users').doc(currentUser.uid).set({
          'interests': selectedPreferences.toList(),
        }, SetOptions(merge: true));
      }
    } catch (e) {
      print('Error saving interests to Firestore: $e');
    }
  }

  void _loadPreferences() async {
    // Tải từ Hive
    final box = await Hive.openBox('interests');
    final savedPreferences = box.get('interests', defaultValue: []);
    selectedPreferences.assignAll(List<String>.from(savedPreferences));

    // Tải từ Firestore
    try {
      User? currentUser = _auth.currentUser;
      if (currentUser != null) {
        final doc =
            await _firestore.collection('users').doc(currentUser.uid).get();
        if (doc.exists && doc.data() != null) {
          final firestorePreferences =
              List<String>.from(doc.data()!['interests'] ?? []);
          selectedPreferences.assignAll(firestorePreferences);

          // Cập nhật Hive để đồng bộ dữ liệu
          await box.put('interests', selectedPreferences.toList());
        }
      }
    } catch (e) {
      print('Error loading preferences from Firestore: $e');
    }
  }
}
