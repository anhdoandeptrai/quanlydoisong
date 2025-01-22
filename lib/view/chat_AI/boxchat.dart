import 'package:flutter/material.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:quanlydoisong/utils/file_storage.dart';
import 'package:quanlydoisong/utils/shared_preferences.dart';

class BoxChatAI extends StatefulWidget {
  @override
  _BoxChatAIState createState() => _BoxChatAIState();
}

class _BoxChatAIState extends State<BoxChatAI> {
  final TextEditingController controller = TextEditingController();
  final FileStorage _fileStorage = FileStorage();
  final ScrollController _scrollController = ScrollController();
  List<Map<String, String>> chatHistory = [];
  String selectedInterest = 'Chọn sở thích';
  bool isLoading = false;

  final List<String> interests = [
    'Chọn sở thích',
    'Thể thao',
    'Âm nhạc',
    'Đọc sách',
    'Du lịch',
    'Nấu ăn',
    'Làm vườn',
  ];

  @override
  void initState() {
    super.initState();
    _loadChatHistory();
  }

  Future<void> _loadChatHistory() async {
    final loadedHistory = await SharedPreferencesHelper.loadChatHistory();
    setState(() {
      chatHistory = loadedHistory;
    });
  }

  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  Future<void> geminiOutput(String prompt) async {
    setState(() {
      isLoading = true;
    });

    try {
      final model = GenerativeModel(
        model: 'gemini-1.5-flash',
        apiKey:
            "AIzaSyBpTTl44TeRj4L39ic4-dlDclXsUV52zYk", // Thay bằng API key của bạn
      );

      final formattedPrompt =
          "$prompt (ngắn gọn, chi tiết và cụ thể nhất có thể)";
      final response =
          await model.generateContent([Content.text(formattedPrompt)]);

      if (!mounted) return;

      final newChat = {
        'question': prompt,
        'answer': response.text ?? 'Không có câu trả lời',
      };

      setState(() {
        chatHistory.add(newChat);
        SharedPreferencesHelper.saveChatHistory(chatHistory);
        _fileStorage.writeChatHistory("Q: $prompt");
        _fileStorage.writeChatHistory("A: ${response.text}");
      });
      _scrollToBottom(); // Cuộn tới cuối danh sách
    } catch (e) {
      setState(() {
        chatHistory.add({
          'question': prompt,
          'answer': 'Lỗi: Không thể kết nối tới AI.',
        });
      });
      _scrollToBottom(); // Cuộn tới cuối danh sách
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  void suggestActivity() {
    if (selectedInterest != 'Chọn sở thích') {
      geminiOutput("Tôi thích $selectedInterest. Hôm nay tôi nên làm gì?");
    } else {
      setState(() {
        chatHistory.add({
          'question': 'Chưa chọn sở thích',
          'answer': 'Vui lòng chọn một sở thích để nhận gợi ý.',
        });
      });
      _scrollToBottom(); // Cuộn tới cuối danh sách
    }
  }

  void clearChatHistory() async {
    await SharedPreferencesHelper.clearChatHistory();
    await _fileStorage.clearChatHistory();
    setState(() {
      chatHistory.clear();
    });
  }

  Widget _buildChatItem(Map<String, String> chat) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _buildAvatarMessage(
          Icons.person,
          Colors.blueAccent,
          chat['question'],
          Alignment.centerRight,
          CrossAxisAlignment.end,
        ),
        const SizedBox(height: 5),
        _buildAvatarMessage(
          Icons.smart_toy,
          Colors.green,
          chat['answer'],
          Alignment.centerLeft,
          CrossAxisAlignment.start,
        ),
      ],
    );
  }

  Widget _buildAvatarMessage(
    IconData icon,
    Color color,
    String? message,
    Alignment alignment,
    CrossAxisAlignment crossAxisAlignment,
  ) {
    return Align(
      alignment: alignment,
      child: Row(
        crossAxisAlignment: crossAxisAlignment,
        mainAxisSize: MainAxisSize.min,
        children: [
          if (alignment == Alignment.centerLeft)
            CircleAvatar(
              backgroundColor: color,
              child: Icon(icon, color: Colors.white),
            ),
          if (alignment == Alignment.centerLeft) const SizedBox(width: 10),
          Expanded(
            child: Container(
              padding: const EdgeInsets.all(12),
              margin: const EdgeInsets.symmetric(vertical: 5),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                message ?? '',
                style: const TextStyle(fontSize: 16),
              ),
            ),
          ),
          if (alignment == Alignment.centerRight) const SizedBox(width: 10),
          if (alignment == Alignment.centerRight)
            CircleAvatar(
              backgroundColor: color,
              child: Icon(icon, color: Colors.white),
            ),
        ],
      ),
    );
  }

  Widget _buildDropdown() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: Row(
        children: [
          Expanded(
            child: DropdownButtonFormField<String>(
              value: selectedInterest,
              decoration: InputDecoration(
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              onChanged: (String? newValue) {
                setState(() {
                  selectedInterest = newValue!;
                });
              },
              items: interests
                  .map<DropdownMenuItem<String>>(
                      (String value) => DropdownMenuItem<String>(
                            value: value,
                            child: Text(value),
                          ))
                  .toList(),
            ),
          ),
          const SizedBox(width: 10),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              backgroundColor: Colors.blueAccent,
            ),
            onPressed: suggestActivity,
            child: const Text(
              'Gợi ý hoạt động',
              style:
                  TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInputField() {
    return Padding(
      padding: const EdgeInsets.all(10),
      child: Row(
        children: [
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: Colors.grey[200],
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: Colors.blueAccent),
              ),
              child: TextField(
                controller: controller,
                minLines: 1,
                maxLines: 3,
                decoration: const InputDecoration(
                  contentPadding: EdgeInsets.all(10),
                  hintText: 'Nhập câu hỏi...',
                  border: InputBorder.none,
                ),
              ),
            ),
          ),
          const SizedBox(width: 10),
          Container(
            decoration: BoxDecoration(
              color: Colors.blueAccent,
              borderRadius: BorderRadius.circular(50),
            ),
            child: IconButton(
              icon: const Icon(Icons.send, color: Colors.white),
              onPressed: () {
                String prompt = controller.text;
                if (prompt.isNotEmpty) {
                  geminiOutput(prompt);
                  controller.clear();
                }
              },
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: const Text(
          'Box Chat AI',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.blueAccent,
        actions: [
          IconButton(
            icon: const Icon(Icons.delete),
            onPressed: clearChatHistory,
          )
        ],
      ),
      body: Column(
        children: [
          _buildDropdown(),
          Expanded(
            child: chatHistory.isEmpty
                ? const Center(
                    child: Text(
                      'Lịch sử chat trống. Hãy bắt đầu cuộc trò chuyện!',
                      style: TextStyle(fontSize: 16),
                    ),
                  )
                : ListView.separated(
                    controller: _scrollController, // Gắn ScrollController
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    itemCount: chatHistory.length,
                    separatorBuilder: (context, index) =>
                        const SizedBox(height: 10),
                    itemBuilder: (context, index) =>
                        _buildChatItem(chatHistory[index]),
                  ),
          ),
          if (isLoading)
            const LinearProgressIndicator(
              color: Colors.blueAccent,
              minHeight: 4,
            ),
          _buildInputField(),
        ],
      ),
    );
  }
}
