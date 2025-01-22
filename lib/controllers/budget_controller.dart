import 'package:get/get.dart';
import 'package:quanlydoisong/models/budget.dart';

class BudgetController extends GetxController {
  // Danh sách các Budget
  final budgets = <Budget>[].obs;

  // Thêm một giao dịch
  void addBudget(Budget budget) {
    budgets.add(budget);
  }

  // Xóa một giao dịch theo chỉ số
  void removeBudget(int index) {
    if (index >= 0 && index < budgets.length) {
      budgets.removeAt(index);
    }
  }

  // Cập nhật một giao dịch tại vị trí cụ thể
  void updateBudget(int index, Budget updatedBudget) {
    if (index >= 0 && index < budgets.length) {
      budgets[index] = updatedBudget;
    }
  }

  // Lấy tổng số tiền giao dịch theo loại (income hoặc expense)
  double getTotalByType(String type) {
    return budgets
        .where((budget) => budget.type == type)
        .fold(0.0, (sum, item) => sum + (item.amount));
  }

  // Tìm kiếm giao dịch theo danh mục
  List<Budget> searchByCategory(String category) {
    return budgets.where((budget) => budget.category == category).toList();
  }

  // Lấy tất cả giao dịch theo ngày
  List<Budget> getTransactionsByDate(String date) {
  return budgets.where((budget) => budget.date == date).toList();
}

void updateTransaction(String dateKey, Budget updatedBudget, int index) {
  final transactionsForDay = getTransactionsByDate(dateKey);
  if (index >= 0 && index < transactionsForDay.length) {
    final actualIndex = budgets.indexWhere((budget) =>
        budget.date == dateKey && budget.category == transactionsForDay[index].category);

    if (actualIndex != -1) {
      budgets[actualIndex] = updatedBudget;
    }
  }
}

}
