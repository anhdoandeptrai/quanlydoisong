import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:quanlydoisong/controllers/dreams_controller.dart';

class EditDreamPage extends StatefulWidget {
  final String dreamId;

  EditDreamPage({required this.dreamId});

  @override
  _EditDreamPageState createState() => _EditDreamPageState();
}

class _EditDreamPageState extends State<EditDreamPage> {
  final DreamsController controller = Get.find();
  final TextEditingController titleController = TextEditingController();
  final TextEditingController descController = TextEditingController();
  final TextEditingController investmentController = TextEditingController();
  final TextEditingController taskController = TextEditingController();
  DateTime? selectedDeadline;
  String? selectedCategory;
  List<Map<String, dynamic>> tasks = [];

  @override
  void initState() {
    super.initState();
    final dream = controller.dreams.firstWhere((d) => d.id == widget.dreamId);
    titleController.text = dream.title;
    descController.text = dream.description;
    investmentController.text = dream.investment.toString();
    selectedDeadline = dream.deadline;
    selectedCategory = dream.category;
    tasks = dream.tasks
        .asMap()
        .entries
        .map((entry) => {
              'title': entry.value,
              'completed': dream.tasksStatus[entry.key],
            })
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text("Chỉnh Sửa Ước Mơ",
            style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.blue,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              buildTextField(titleController, "Tiêu đề", Icons.title),
              const SizedBox(height: 12),
              buildTextField(descController, "Mô tả", Icons.description,
                  maxLines: 2),
              const SizedBox(height: 12),
              buildDropdown(),
              const SizedBox(height: 12),
              buildDatePicker(),
              const SizedBox(height: 12),
              buildTextField(investmentController, "Số tiền cần đầu tư (VNĐ)",
                  Icons.money),
              const SizedBox(height: 12),
              buildTaskList(),
              const SizedBox(height: 16),
              buildSaveButton(),
            ],
          ),
        ),
      ),
    );
  }

  Widget buildTextField(
      TextEditingController controller, String label, IconData icon,
      {int maxLines = 1}) {
    return TextField(
      controller: controller,
      maxLines: maxLines,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: Colors.blue),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  Widget buildDropdown() {
    return DropdownButtonFormField<String>(
      value: selectedCategory,
      items: ["Công việc", "Gia đình", "Sức khỏe", "Khác"]
          .map((category) =>
              DropdownMenuItem(value: category, child: Text(category)))
          .toList(),
      onChanged: (value) => setState(() => selectedCategory = value),
      decoration: InputDecoration(
        labelText: "Danh mục",
        prefixIcon: Icon(Icons.category, color: Colors.blue),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  Widget buildDatePicker() {
    return TextButton.icon(
      icon: Icon(Icons.calendar_today, color: Colors.blue),
      label: Text(
        selectedDeadline == null
            ? "Chọn ngày hạn chót"
            : "Hạn chót: ${DateFormat('dd/MM/yyyy').format(selectedDeadline!)}",
        style: TextStyle(color: Colors.blue, fontWeight: FontWeight.bold),
      ),
      onPressed: () async {
        final DateTime? picked = await showDatePicker(
          context: context,
          initialDate: selectedDeadline ?? DateTime.now(),
          firstDate: DateTime.now(),
          lastDate: DateTime(2100),
        );
        if (picked != null) setState(() => selectedDeadline = picked);
      },
    );
  }

  Widget buildTaskList() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text("Danh sách các việc cần làm:",
            style: TextStyle(fontWeight: FontWeight.bold)),
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: tasks.length,
          itemBuilder: (context, index) {
            return Card(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
              child: ListTile(
                leading: Checkbox(
                  value: tasks[index]['completed'],
                  onChanged: (bool? value) {
                    setState(() {
                      tasks[index]['completed'] = value;
                      controller.toggleTaskStatus(
                          controller.dreams.indexWhere(
                              (dream) => dream.id == widget.dreamId),
                          index);
                    });
                  },
                ),
                title: Text(tasks[index]['title']),
                trailing: IconButton(
                  icon: const Icon(Icons.delete, color: Colors.red),
                  onPressed: () {
                    setState(() => tasks.removeAt(index));
                    controller.deleteTask(
                        controller.dreams
                            .indexWhere((dream) => dream.id == widget.dreamId),
                        index);
                  },
                ),
              ),
            );
          },
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child:
                  buildTextField(taskController, "Thêm công việc", Icons.task),
            ),
            IconButton(
              icon: const Icon(Icons.add_circle, color: Colors.blue, size: 32),
              onPressed: () {
                if (taskController.text.isNotEmpty) {
                  setState(() {
                    tasks.add(
                        {'title': taskController.text, 'completed': false});
                  });
                  controller.addTask(
                      controller.dreams
                          .indexWhere((dream) => dream.id == widget.dreamId),
                      taskController.text);
                  taskController.clear();
                }
              },
            ),
          ],
        ),
      ],
    );
  }

  Widget buildSaveButton() {
    return ElevatedButton(
      onPressed: () {
        if (titleController.text.isEmpty) {
          Get.snackbar("Lỗi", "Vui lòng nhập tiêu đề.",
              snackPosition: SnackPosition.BOTTOM,
              backgroundColor: Colors.redAccent,
              colorText: Colors.white);
        } else {
          controller.updateDream(
            widget.dreamId,
            titleController.text,
            descController.text,
            selectedDeadline,
            selectedCategory,
            investment: double.tryParse(investmentController.text) ?? 0.0,
            tasks: tasks.map((task) => task['title'] as String).toList(),
          );
          Get.back();
        }
      },
      child: const Text("Lưu",
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.blue,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        padding: const EdgeInsets.symmetric(vertical: 12),
      ),
    );
  }
}
