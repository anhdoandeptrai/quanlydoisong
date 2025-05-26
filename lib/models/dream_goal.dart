import 'package:hive/hive.dart';

part 'dream_goal.g.dart';

@HiveType(typeId: 1)
class DreamGoal extends HiveObject {
  @HiveField(0)
  String id; // Thêm thuộc tính id

  @HiveField(1)
  String title;

  @HiveField(2)
  String description;

  @HiveField(3)
  double progress;

  @HiveField(4)
  DateTime? deadline;

  @HiveField(5)
  String? category;

  @HiveField(6)
  double investment;

  @HiveField(7)
  List<String> tasks;

  @HiveField(8)
  List<bool> tasksStatus;

  DreamGoal({
    required this.id, // Yêu cầu id khi khởi tạo
    required this.title,
    required this.description,
    this.progress = 0.0,
    this.deadline,
    this.category,
    this.investment = 0.0,
    List<String>? tasks,
  })  : tasks = tasks ?? [],
        tasksStatus = List.filled(tasks?.length ?? 0, false, growable: true);

  DreamGoal copyWith({
    String? id,
    String? title,
    String? description,
    DateTime? deadline,
    String? category,
    double? investment,
    List<String>? tasks,
    List<bool>? tasksStatus,
    double? progress,
  }) {
    return DreamGoal(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      deadline: deadline ?? this.deadline,
      category: category ?? this.category,
      investment: investment ?? this.investment,
      tasks: tasks ?? this.tasks,
    )..tasksStatus = tasksStatus ?? this.tasksStatus;
  }

  void updateTasks(List<String> newTasks) {
    tasks = newTasks;
    tasksStatus = List.filled(newTasks.length, false, growable: true);
  }
}
