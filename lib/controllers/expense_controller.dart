import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:uuid/uuid.dart';
import '../models/expense.dart';
import '../services/data_service.dart';

class ExpenseController extends GetxController {
  final DataService dataService = DataService();

  var expenses = <Expense>[].obs;

  void loadExpenses() {
    // Lấy tất cả chi tiêu từ DataService và đồng bộ vào danh sách quan sát
    expenses.assignAll(dataService.expenseBox.values.toList());
  }

  @override
  void onInit() {
    super.onInit();
    loadExpenses();
  }

  void addExpense(
      double amount, String category, DateTime date, String description) {
    var uuid = const Uuid();
    var expense = Expense(
      id: uuid.v4(),
      amount: amount,
      category: category,
      date: date,
      description: description,
    );

    // Lưu vào Hive box và danh sách quan sát
    dataService.expenseBox.put(expense.id, expense);
    loadExpenses();
  }

  void removeExpense(String id) {
    // Xóa khỏi Hive box và danh sách quan sát
    dataService.expenseBox.delete(id);
    loadExpenses();
  }

  void updateExpense(String id, double amount, String category, DateTime date,
      String description) {
    final index = expenses.indexWhere((e) => e.id == id);
    if (index != -1) {
      expenses[index] = Expense(
        id: id,
        amount: amount,
        category: category,
        date: date,
        description: description,
      );
      expenses.refresh();
    } else {
      Get.snackbar(
        'Lỗi',
        'Không tìm thấy chi tiêu để cập nhật',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.redAccent,
        colorText: Colors.white,
      );
    }
  }
}
