import 'package:hive/hive.dart';
import 'package:quanlydoisong/models/dream_goal.dart';
import 'package:quanlydoisong/models/transaction_model.dart';
import '../models/schedule.dart';

class DataService {
  Future<void> initHive() async {
    await Hive.openBox<DreamGoal>('dreams');
  }

  Box<Schedule> get scheduleBox => Hive.box<Schedule>('schedules');
  Box<TransactionModel> get transactionBox =>
      Hive.box<TransactionModel>('transactions');
  Box<DreamGoal> get dreamBox => Hive.box<DreamGoal>('dreams');

  void saveDream(DreamGoal dream) {
    dreamBox.add(dream);
  }

  List<DreamGoal> loadDreams() {
    return dreamBox.values.toList();
  }
}
