import 'package:get/get.dart';
import 'package:quanlydoisong/models/dream_goal.dart';

class DreamsController extends GetxController {
  var dreams = <DreamGoal>[].obs;
  var selectedFilter = "".obs;

  @override
  void onInit() {
    super.onInit();
    // Xóa các phần tử rỗng nếu có
    dreams.removeWhere(
        (dream) => dream.title.isEmpty && dream.description.isEmpty);
  }

  List<DreamGoal> get filteredDreams {
    if (selectedFilter.value.isEmpty) {
      return dreams;
    }
    return dreams
        .where((dream) => dream.category == selectedFilter.value)
        .toList();
  }

  void addDream(
      String title, String description, DateTime? deadline, String? category,
      {double investment = 0.0, List<String> tasks = const []}) {
    if (title.isNotEmpty && description.isNotEmpty) {
      final dream = DreamGoal(
        id: DateTime.now().millisecondsSinceEpoch.toString(), // Tạo id duy nhất
        title: title,
        description: description,
        progress: 0.0,
        deadline: deadline,
        category: category,
        investment: investment,
        tasks: tasks,
      );
      dream.tasksStatus = List.filled(tasks.length, false, growable: true);
      dreams.add(dream);
    }
  }

  void updateProgress(int dreamIndex) {
    final dream = dreams[dreamIndex];
    final completedTasks = dream.tasksStatus.where((status) => status).length;
    dream.progress =
        dream.tasks.isNotEmpty ? completedTasks / dream.tasks.length : 0.0;
    dreams.refresh(); // Thông báo cho GetX làm mới giao diện
  }

  void deleteDream(int index) {
    if (index >= 0 && index < dreams.length) {
      dreams.removeAt(index); // Xóa dự định
      dreams.refresh(); // Làm mới danh sách
    }
  }

  void editDream(int index, String title, String description) {
    final dream = dreams[index];
    dream.title = title;
    dream.description = description;
    dreams.refresh();
  }

  void toggleTaskStatus(int dreamIndex, int taskIndex) {
    final dream = dreams[dreamIndex];
    dream.tasksStatus[taskIndex] =
        !dream.tasksStatus[taskIndex]; // Thay đổi trạng thái
    updateProgress(dreamIndex); // Cập nhật tiến độ
    dreams.refresh(); // Thông báo cho GetX làm mới giao diện
  }

  void addTask(int dreamIndex, String task) {
    final dream = dreams[dreamIndex];
    dream.tasks.add(task);
    dream.tasksStatus.add(false); // Mặc định chưa hoàn thành
    updateProgress(dreamIndex);
    dreams.refresh();
  }

  void editTask(int dreamIndex, int taskIndex, String newTask) {
    final dream = dreams[dreamIndex];
    dream.tasks[taskIndex] = newTask;
    dreams.refresh();
  }

  void deleteTask(int dreamIndex, int taskIndex) {
    final dream = dreams[dreamIndex];
    dream.tasks.removeAt(taskIndex);
    dream.tasksStatus.removeAt(taskIndex);
    updateProgress(dreamIndex);
    dreams.refresh();
  }

  void updateDream(String id, String title, String description,
      DateTime? deadline, String? category,
      {double investment = 0.0, List<String> tasks = const []}) {
    final index = dreams.indexWhere((dream) => dream.id == id);
    if (index != -1) {
      dreams[index] = dreams[index].copyWith(
        title: title,
        description: description,
        deadline: deadline,
        category: category,
        investment: investment,
        tasks: tasks,
      );
      updateProgress(index);
      dreams.refresh(); // Thông báo cập nhật dữ liệu
    } else {
      print("Không tìm thấy ước mơ với id: $id");
    }
  }

  void resetDreams() {
    dreams.clear(); // Xóa tất cả dữ liệu trong danh sách
    dreams.refresh(); // Làm mới danh sách
  }
}
