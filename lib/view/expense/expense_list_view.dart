import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/expense_controller.dart' as controller;
import 'add_expense_view.dart';
import 'edit_expense_view.dart';
import 'package:intl/intl.dart';
import '../../models/expense.dart';

class ExpenseListView extends StatelessWidget {
  final controller.ExpenseController expenseController =
      Get.put(controller.ExpenseController());

  ExpenseListView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Quản Lý Chi Tiêu'),
        backgroundColor: Colors.blueAccent,
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.blueAccent, Colors.lightBlue],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Obx(() {
              final totalAmount = expenseController.expenses
                  .fold(0.0, (sum, expense) => sum + expense.amount);
              return Center(
                child: Text(
                  'Tổng: ${NumberFormat.currency(locale: 'vi', symbol: 'VNĐ').format(totalAmount)}',
                  style: const TextStyle(
                      fontSize: 16, fontWeight: FontWeight.bold),
                ),
              );
            }),
          ),
        ],
      ),
      body: Obx(() {
        if (expenseController.expenses.isEmpty) {
          return _buildEmptyState();
        }

        final groupedExpenses =
            _groupExpensesByCategory(expenseController.expenses);

        return ListView(
          physics: const BouncingScrollPhysics(),
          children: groupedExpenses.entries.map((entry) {
            final category = entry.key;
            final expenses = entry.value;

            return _buildExpenseCard(
              category: category,
              expenses: expenses,
              color: _mapExpenseCategoryToColor(category),
              icon: _mapExpenseCategoryToIcon(category),
            );
          }).toList(),
        );
      }),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Get.to(() => const AddExpenseView());
        },
        backgroundColor: Colors.blueAccent,
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.money_off, size: 80, color: Colors.grey),
          const SizedBox(height: 16),
          const Text(
            'Không có chi tiêu nào.',
            style: TextStyle(fontSize: 18, color: Colors.grey),
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () => Get.to(() => const AddExpenseView()),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blueAccent,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            ),
            child: const Text('Thêm Chi Tiêu Ngay'),
          ),
        ],
      ),
    );
  }

  Widget _buildExpenseCard({
    required String category,
    required List<Expense> expenses,
    required Color? color,
    required IconData icon,
  }) {
    final totalCategoryAmount =
        expenses.fold(0.0, (sum, expense) => sum + expense.amount);

    return Padding(
      padding: const EdgeInsets.all(12.0),
      child: Card(
        elevation: 8,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        child: ExpansionTile(
          title: Row(
            children: [
              Icon(icon, color: color, size: 30),
              const SizedBox(width: 10),
              Text(
                category,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
              const Spacer(),
              Text(
                'Tổng: ${NumberFormat.currency(locale: 'vi', symbol: 'VNĐ').format(totalCategoryAmount)}',
                style: const TextStyle(fontSize: 16, color: Colors.green),
              ),
            ],
          ),
          tilePadding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
          children:
              expenses.map((expense) => ExpenseTile(expense: expense)).toList(),
        ),
      ),
    );
  }

  Map<String, List<Expense>> _groupExpensesByCategory(List<Expense> expenses) {
    Map<String, List<Expense>> groupedExpenses = {};
    for (var expense in expenses) {
      if (!groupedExpenses.containsKey(expense.category)) {
        groupedExpenses[expense.category] = [];
      }
      groupedExpenses[expense.category]!.add(expense);
    }
    return groupedExpenses;
  }

  Color? _mapExpenseCategoryToColor(String category) {
    switch (category) {
      case 'Food':
        return Colors.orange;
      case 'Transport':
        return Colors.blueAccent;
      case 'Entertainment':
        return Colors.purple;
      case 'Health':
        return Colors.green;
      case 'Shopping':
        return Colors.pinkAccent;
      case 'Study':
        return Colors.indigo;
      case 'Other':
        return Colors.grey;
      default:
        return Colors.grey[100];
    }
  }

  IconData _mapExpenseCategoryToIcon(String category) {
    switch (category) {
      case 'Food':
        return Icons.restaurant;
      case 'Transport':
        return Icons.directions_car;
      case 'Entertainment':
        return Icons.movie;
      case 'Health':
        return Icons.health_and_safety;
      case 'Shopping':
        return Icons.shopping_cart;
      case 'Study':
        return Icons.school;
      case 'Other':
        return Icons.more_horiz;
      default:
        return Icons.category;
    }
  }
}

class ExpenseTile extends StatelessWidget {
  final Expense expense;

  const ExpenseTile({super.key, required this.expense});

  @override
  Widget build(BuildContext context) {
    final formattedDate = DateFormat('dd/MM/yyyy').format(expense.date);

    return ListTile(
      title: Text(
        expense.description.isEmpty ? 'Không có mô tả' : expense.description,
        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
      ),
      subtitle: Text(
        'Ngày: $formattedDate\nSố tiền: ${NumberFormat.currency(locale: 'vi', symbol: 'VNĐ').format(expense.amount)}',
        style: TextStyle(color: Colors.grey[700]),
      ),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(
            icon: const Icon(Icons.edit, color: Colors.blue),
            tooltip: 'Chỉnh sửa',
            onPressed: () {
              Get.to(() => EditExpenseView(expenseId: expense.id));
            },
          ),
          IconButton(
            icon: const Icon(Icons.delete, color: Colors.red),
            tooltip: 'Xóa',
            onPressed: () {
              Get.defaultDialog(
                title: 'Xác nhận',
                middleText: 'Bạn có chắc muốn xóa chi tiêu này không?',
                onConfirm: () {
                  Get.find<controller.ExpenseController>()
                      .removeExpense(expense.id);
                  Get.back();
                },
                onCancel: () {},
              );
            },
          ),
        ],
      ),
    );
  }
}
