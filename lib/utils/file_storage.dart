import 'dart:io';
import 'package:path_provider/path_provider.dart';

class FileStorage {
  Future<String> get _localPath async {
    final directory = await getApplicationDocumentsDirectory();
    return directory.path;
  }

  Future<File> get _localFile async {
    final path = await _localPath;
    return File('$path/chat_history.txt');
  }

  Future<void> writeChatHistory(String chatHistory) async {
    final file = await _localFile;
    await file.writeAsString('$chatHistory\n', mode: FileMode.append);
  }

  Future<String> readChatHistory() async {
    try {
      final file = await _localFile;
      return await file.readAsString();
    } catch (e) {
      return 'Lịch sử chat trống';
    }
  }

  Future<void> clearChatHistory() async {
    final file = await _localFile;
    await file.writeAsString('');
  }
}
