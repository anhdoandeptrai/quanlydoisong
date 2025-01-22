import 'package:hive/hive.dart';
import 'package:quanlydoisong/models/transaction_model.dart';

import '../models/schedule.dart';
import '../models/expense.dart';

class DataService {
  // Schedules
  Box<Schedule> get scheduleBox => Hive.box<Schedule>('schedules');

  // Attendances

  // Expenses
  Box<Expense> get expenseBox => Hive.box<Expense>('expenses');
  // Transactions
  Box<TransactionModel> get transactionBox => Hive.box<TransactionModel>('transactions');
}
