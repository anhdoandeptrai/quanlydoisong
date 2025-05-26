import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:quanlydoisong/controllers/dreams_controller.dart';
import 'package:percent_indicator/linear_percent_indicator.dart';

class DreamDetailPage extends StatelessWidget {
  final int index;
  final DreamsController controller = Get.find();

  DreamDetailPage({super.key, required this.index});

  @override
  Widget build(BuildContext context) {
    if (index < 0 || index >= controller.dreams.length) {
      return Scaffold(
        appBar: AppBar(title: const Text("Lỗi")),
        body: const Center(child: Text("Không tìm thấy dữ liệu ước mơ.")),
      );
    }

    final dream = controller.dreams[index];

    return Scaffold(
      backgroundColor: Colors.blue.shade50,
      appBar: AppBar(
        title: Text(dream.title),
        backgroundColor: Colors.blueAccent,
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () {
              _showEditDreamDialog(
                  context, index, dream.title, dream.description);
            },
          ),
          IconButton(
            icon: const Icon(Icons.delete),
            onPressed: () {
              controller.deleteDream(index);
              if (controller.dreams.isEmpty) {
                Get.back(); // Quay lại trang trước nếu danh sách rỗng
              }
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Hero(
              tag: "dream_${dream.title}",
              child: Icon(Icons.star_rounded,
                  size: 60, color: Colors.orangeAccent),
            ),
            const SizedBox(height: 16),
            Text(
              "Mô tả:",
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
            ),
            const SizedBox(height: 8),
            Text(dream.description,
                style: const TextStyle(fontSize: 16, color: Colors.grey)),
            const SizedBox(height: 16),
            Text(
              "Danh sách công việc (${dream.tasks.length}):",
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
            ),
            Expanded(
              child: Obx(() {
                if (controller.dreams.isEmpty || dream.tasks.isEmpty) {
                  return const Center(
                    child: Text("Không có công việc nào."),
                  );
                }
                return ListView.builder(
                  itemCount: dream.tasks.length,
                  itemBuilder: (context, taskIndex) {
                    return ListTile(
                      title: Text(
                        dream.tasks[taskIndex],
                        style: TextStyle(
                          decoration: dream.tasksStatus[taskIndex]
                              ? TextDecoration.lineThrough
                              : TextDecoration.none,
                        ),
                      ),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.edit, color: Colors.blue),
                            onPressed: () {
                              _showEditTaskDialog(context, index, taskIndex,
                                  dream.tasks[taskIndex]);
                            },
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete, color: Colors.red),
                            onPressed: () {
                              controller.deleteTask(index, taskIndex);
                            },
                          ),
                          Checkbox(
                            value: dream.tasksStatus[taskIndex],
                            onChanged: (value) {
                              controller.toggleTaskStatus(index, taskIndex);
                            },
                          ),
                        ],
                      ),
                    );
                  },
                );
              }),
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: () {
                _showAddTaskDialog(context, index);
              },
              icon: const Icon(Icons.add),
              label: const Text("Thêm công việc"),
            ),
            const SizedBox(height: 16),
            Obx(() {
              if (controller.dreams.isEmpty) {
                return const SizedBox.shrink();
              }
              final dream = controller.dreams[index];
              return LinearPercentIndicator(
                lineHeight: 14,
                percent: dream.progress,
                backgroundColor: Colors.grey[300],
                progressColor: Colors.blueAccent,
                barRadius: const Radius.circular(10),
                center: Text(
                  "${(dream.progress * 100).toInt()}%",
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              );
            }),
          ],
        ),
      ),
    );
  }

  void _showEditDreamDialog(BuildContext context, int index,
      String currentTitle, String currentDesc) {
    final titleController = TextEditingController(text: currentTitle);
    final descController = TextEditingController(text: currentDesc);

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Sửa dự định"),
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
                controller.editDream(
                    index, titleController.text, descController.text);
                Get.back();
              },
              child: const Text("Lưu"),
            ),
          ],
        );
      },
    );
  }

  void _showAddTaskDialog(BuildContext context, int dreamIndex) {
    final taskController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Thêm công việc"),
          content: TextField(
            controller: taskController,
            decoration: const InputDecoration(labelText: "Tên công việc"),
          ),
          actions: [
            TextButton(
              onPressed: () => Get.back(),
              child: const Text("Hủy"),
            ),
            ElevatedButton(
              onPressed: () {
                controller.addTask(dreamIndex, taskController.text);
                Get.back();
              },
              child: const Text("Thêm"),
            ),
          ],
        );
      },
    );
  }

  void _showEditTaskDialog(
      BuildContext context, int dreamIndex, int taskIndex, String currentTask) {
    final taskController = TextEditingController(text: currentTask);

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Sửa công việc"),
          content: TextField(
            controller: taskController,
            decoration: const InputDecoration(labelText: "Tên công việc"),
          ),
          actions: [
            TextButton(
              onPressed: () => Get.back(),
              child: const Text("Hủy"),
            ),
            ElevatedButton(
              onPressed: () {
                controller.editTask(dreamIndex, taskIndex, taskController.text);
                Get.back();
              },
              child: const Text("Lưu"),
            ),
          ],
        );
      },
    );
  }
}
