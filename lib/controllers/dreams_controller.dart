import 'package:get/get.dart';
import 'package:quanlydoisong/models/dream_goal.dart';

class DreamsController extends GetxController {
  var dreams = <DreamGoal>[].obs;
  var selectedFilter = "".obs;

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
    final dream = DreamGoal(
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

  void updateProgress(int dreamIndex, double progress) {
    final dream = dreams[dreamIndex];
    final totalTasks = dream.tasks.length;
    if (totalTasks > 0) {
      final completedTasks = dream.tasksStatus.where((status) => status).length;
      dream.progress = completedTasks / totalTasks;
    } else {
      dream.progress = 0.0;
    }
    dreams.refresh();
  }

  void removeDream(int index) {
    dreams.removeAt(index);
  }

  void toggleTaskStatus(int dreamIndex, int taskIndex) {
    final dream = dreams[dreamIndex];
    dream.tasksStatus[taskIndex] = !dream.tasksStatus[taskIndex];
    updateProgress(dreamIndex, dream.progress);
  }

  void addTask(int dreamIndex, String task) {
    final dream = dreams[dreamIndex];
    dream.tasks.add(task);
    dream.tasksStatus.add(false);
    updateProgress(dreamIndex, dream.progress);
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
    updateProgress(dreamIndex, dream.progress);
  }
}
