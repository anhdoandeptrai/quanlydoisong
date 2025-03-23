import 'package:hive/hive.dart';

part 'dream_goal.g.dart';

@HiveType(typeId: 1)
class DreamGoal extends HiveObject {
  @HiveField(0)
  String title;

  @HiveField(1)
  String description;

  @HiveField(2)
  double progress;

  @HiveField(3)
  DateTime? deadline;

  @HiveField(4)
  String? category;

  @HiveField(5)
  double investment;

  @HiveField(6)
  List<String> tasks;

  @HiveField(7)
  List<bool> tasksStatus;

  DreamGoal({
    required this.title,
    required this.description,
    this.progress = 0.0,
    this.deadline,
    this.category,
    this.investment = 0.0,
    List<String>? tasks,
  })  : tasks = tasks ?? [],
        tasksStatus = List.filled(tasks?.length ?? 0, false, growable: true);

  void updateTasks(List<String> newTasks) {
    tasks = newTasks;
    tasksStatus = List.filled(newTasks.length, false, growable: true);
  }
}
