import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class SharedPreferencesHelper {
  static const String _chatHistoryKey = 'chatHistory';

  // Lưu lịch sử trò chuyện
  static Future<void> saveChatHistory(List<Map<String, String>> chatHistory) async {
    final prefs = await SharedPreferences.getInstance();
    final List<String> savedChatHistory =
        chatHistory.map((item) => json.encode(item)).toList();
    await prefs.setStringList(_chatHistoryKey, savedChatHistory);
  }

  // Tải lịch sử trò chuyện
  static Future<List<Map<String, String>>> loadChatHistory() async {
    final prefs = await SharedPreferences.getInstance();
    final List<String>? savedChatHistory = prefs.getStringList(_chatHistoryKey);
    if (savedChatHistory != null) {
      return savedChatHistory
          .map((item) => Map<String, String>.from(json.decode(item)))
          .toList();
    }
    return [];
  }

  // Xóa lịch sử trò chuyện
  static Future<void> clearChatHistory() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_chatHistoryKey);
  }
}
