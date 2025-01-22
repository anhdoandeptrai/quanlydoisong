import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:quanlydoisong/controllers/expense_controller.dart'; // Đảm bảo nhập đúng tệp
import 'package:quanlydoisong/models/expense.dart';

class EditExpenseView extends StatefulWidget {
  final String expenseId;

  EditExpenseView({required this.expenseId});

  @override
  _EditExpenseViewState createState() => _EditExpenseViewState();
}

class _EditExpenseViewState extends State<EditExpenseView> {
  final _formKey = GlobalKey<FormState>();
  final ExpenseController expenseController = Get.find<ExpenseController>();

  late Expense expense;
  double amount = 0.0;
  String category = '';
  DateTime? date;
  String description = '';

  @override
  void initState() {
    super.initState();
    try {
      // Tìm chi tiêu qua ID
      expense = expenseController.expenses
          .firstWhere((e) => e.id == widget.expenseId);
      amount = expense.amount;
      category = expense.category;
      date = expense.date;
      description = expense.description;
    } catch (e) {
      Get.snackbar(
        'Lỗi',
        'Không tìm thấy chi tiêu để chỉnh sửa',
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.redAccent,
        colorText: Colors.white,
      );
      Get.back();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Chỉnh Sửa Chi Tiêu'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              children: [
                TextFormField(
                  initialValue: amount.toString(),
                  decoration: InputDecoration(labelText: 'Số Tiền'),
                  keyboardType: TextInputType.numberWithOptions(decimal: true),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Vui lòng nhập số tiền';
                    }
                    if (double.tryParse(value) == null) {
                      return 'Vui lòng nhập một số hợp lệ';
                    }
                    return null;
                  },
                  onSaved: (value) {
                    amount = double.parse(value!);
                  },
                ),
                SizedBox(height: 16),
                TextFormField(
                  initialValue: category,
                  decoration: InputDecoration(labelText: 'Danh Mục'),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Vui lòng nhập danh mục';
                    }
                    return null;
                  },
                  onSaved: (value) {
                    category = value!;
                  },
                ),
                SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton(
                        child: Text(date == null
                            ? 'Chọn Ngày'
                            : 'Ngày: ${DateFormat('dd/MM/yyyy').format(date!)}'),
                        onPressed: () async {
                          final DateTime? pickedDate = await showDatePicker(
                            context: context,
                            initialDate: date ?? DateTime.now(),
                            firstDate: DateTime(2000),
                            lastDate: DateTime(2101),
                          );
                          if (pickedDate != null) {
                            setState(() {
                              date = pickedDate;
                            });
                          }
                        },
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 16),
                TextFormField(
                  initialValue: description,
                  decoration: InputDecoration(labelText: 'Mô Tả'),
                  maxLines: 3,
                  onSaved: (value) {
                    description = value ?? '';
                  },
                ),
                SizedBox(height: 24),
                ElevatedButton(
                  child: Text('Lưu Thay Đổi'),
                  onPressed: () {
                    if (_formKey.currentState!.validate()) {
                      if (date == null) {
                        Get.snackbar(
                          'Lỗi',
                          'Vui lòng chọn ngày',
                          snackPosition: SnackPosition.TOP,
                          backgroundColor: Colors.redAccent,
                          colorText: Colors.white,
                        );
                        return;
                      }
                      _formKey.currentState!.save();
                      expenseController.updateExpense(
                        expense.id,
                        amount,
                        category,
                        date!,
                        description,
                      );
                      Get.back();
                      Get.snackbar(
                        'Thành Công',
                        'Đã cập nhật chi tiêu',
                        snackPosition: SnackPosition.TOP,
                      );
                    }
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
