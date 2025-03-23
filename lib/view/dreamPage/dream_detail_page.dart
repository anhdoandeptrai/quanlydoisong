import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:quanlydoisong/controllers/dreams_controller.dart';

import '../../models/dream_goal.dart';
import 'add_dream_page.dart';

class DreamDetailPage extends StatelessWidget {
  final int index;
  final DreamsController controller = Get.find();

  DreamDetailPage({required this.index});

  @override
  Widget build(BuildContext context) {
    if (index < 0 || index >= controller.dreams.length) {
      return Scaffold(
        appBar: AppBar(
          title: const Text("Lỗi"),
        ),
        body: const Center(
          child: Text("Không tìm thấy dữ liệu ước mơ."),
        ),
      );
    }

    final dream = controller.dreams[index];

    return Scaffold(
      appBar: AppBar(
        title: Text(dream.title),
        backgroundColor: Colors.blueAccent,
        actions: [
          PopupMenuButton<String>(
            onSelected: (value) {
              if (value == 'edit') {
                Get.to(() => AddDreamPage(), arguments: dream);
              } else if (value == 'add') {
                Get.to(() => AddDreamPage());
              }
            },
            itemBuilder: (BuildContext context) {
              return [
                const PopupMenuItem(
                  value: 'edit',
                  child: Text('Chỉnh sửa'),
                ),
                const PopupMenuItem(
                  value: 'add',
                  child: Text('Thêm mới'),
                ),
              ];
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Mô tả:",
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            const SizedBox(height: 8),
            Text(dream.description, style: const TextStyle(fontSize: 14)),
            const SizedBox(height: 16),
            Text(
              "Danh sách công việc (${dream.tasks.length}):",
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            const SizedBox(height: 8),
            Expanded(
              child: ListView.builder(
                itemCount: dream.tasks.length,
                itemBuilder: (context, taskIndex) {
                  final isCompleted = dream.tasksStatus[taskIndex];
                  return ListTile(
                    title: Text(
                      dream.tasks[taskIndex],
                      style: TextStyle(
                        decoration: isCompleted
                            ? TextDecoration.lineThrough
                            : TextDecoration.none,
                      ),
                    ),
                    trailing: Checkbox(
                      value: isCompleted,
                      onChanged: (value) {
                        controller.toggleTaskStatus(index, taskIndex);
                      },
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 16),
            LinearProgressIndicator(
              value: dream.progress,
              backgroundColor: Colors.grey[300],
              valueColor: AlwaysStoppedAnimation<Color>(Colors.blueAccent),
            ),
            Align(
              alignment: Alignment.centerRight,
              child: Text(
                "${(dream.progress * 100).toInt()}% hoàn thành",
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _editDream(BuildContext context, int index, DreamGoal dream) {
    final TextEditingController titleController =
        TextEditingController(text: dream.title);
    final TextEditingController descController =
        TextEditingController(text: dream.description);

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Sửa dự án"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: titleController,
                decoration: const InputDecoration(labelText: "Tiêu đề"),
              ),
              TextField(
                controller: descController,
                decoration: const InputDecoration(labelText: "Mô tả"),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Get.back(),
              child: const Text("Hủy"),
            ),
            ElevatedButton(
              onPressed: () {
                controller.dreams[index].title = titleController.text;
                controller.dreams[index].description = descController.text;
                controller.dreams.refresh();
                Get.back();
              },
              child: const Text("Lưu"),
            ),
          ],
        );
      },
    );
  }

  void _confirmDeleteDream(BuildContext context, int index) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Xóa dự án"),
          content: const Text("Bạn có chắc chắn muốn xóa dự án này?"),
          actions: [
            TextButton(
              onPressed: () => Get.back(),
              child: const Text("Hủy"),
            ),
            ElevatedButton(
              onPressed: () {
                controller.removeDream(index);
                Get.back();
                Get.back(); // Quay lại danh sách dự án
              },
              child: const Text("Xóa"),
            ),
          ],
        );
      },
    );
  }

  void _editTask(
      BuildContext context, int dreamIndex, int taskIndex, String currentTask) {
    final TextEditingController taskController =
        TextEditingController(text: currentTask);

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Sửa công việc"),
          content: TextField(
            controller: taskController,
            decoration: const InputDecoration(labelText: "Công việc"),
          ),
          actions: [
            TextButton(
              onPressed: () => Get.back(),
              child: const Text("Hủy"),
            ),
            ElevatedButton(
              onPressed: () {
                controller.dreams[dreamIndex].tasks[taskIndex] =
                    taskController.text;
                controller.dreams.refresh();
                Get.back();
              },
              child: const Text("Lưu"),
            ),
          ],
        );
      },
    );
  }

  void _deleteTask(BuildContext context, int dreamIndex, int taskIndex) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Xóa công việc"),
          content: const Text("Bạn có chắc chắn muốn xóa công việc này?"),
          actions: [
            TextButton(
              onPressed: () => Get.back(),
              child: const Text("Hủy"),
            ),
            ElevatedButton(
              onPressed: () {
                controller.deleteTask(dreamIndex,
                    taskIndex); // Sử dụng phương thức từ DreamsController
                Get.back();
              },
              child: const Text("Xóa"),
            ),
          ],
        );
      },
    );
  }
}
