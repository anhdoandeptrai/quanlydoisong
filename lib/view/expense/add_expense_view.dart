import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/expense_controller.dart';
import 'package:intl/intl.dart';

class AddExpenseView extends StatefulWidget {
  @override
  _AddExpenseViewState createState() => _AddExpenseViewState();
}

class _AddExpenseViewState extends State<AddExpenseView> {
  final _formKey = GlobalKey<FormState>();
  final ExpenseController expenseController = Get.find<ExpenseController>();

  double? amount;
  String category = 'Ăn Uống';
  DateTime? date;
  String description = '';

  final List<String> categories = [
    'Ăn Uống',
    'Đi Lại',
    'Giải Trí',
    'Học Tập',
    'Sức Khỏe',
    'Khác',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Thêm Chi Tiêu Mới'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              children: [
                // Số tiền
                TextFormField(
                  decoration: InputDecoration(labelText: 'Số Tiền (VND)'),
                  keyboardType: TextInputType.numberWithOptions(decimal: true),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Vui lòng nhập số tiền';
                    }
                    if (double.tryParse(value) == null ||
                        double.parse(value) <= 0) {
                      return 'Vui lòng nhập số tiền hợp lệ';
                    }
                    return null;
                  },
                  onSaved: (value) {
                    amount = double.parse(value!);
                  },
                ),
                SizedBox(height: 16),

                // Danh mục chi tiêu
                DropdownButtonFormField<String>(
                  value: category,
                  decoration: InputDecoration(labelText: 'Danh Mục'),
                  items: categories.map((String category) {
                    return DropdownMenuItem<String>(
                      value: category,
                      child: Text(category),
                    );
                  }).toList(),
                  onChanged: (newValue) {
                    setState(() {
                      category = newValue!;
                    });
                  },
                  validator: (value) {
                    if (value == null) {
                      return 'Vui lòng chọn danh mục';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 16),

                // Chọn ngày chi tiêu
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
                            initialDate: DateTime.now(),
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

                // Mô tả chi tiêu
                TextFormField(
                  decoration: InputDecoration(labelText: 'Mô Tả'),
                  maxLines: 3,
                  onSaved: (value) {
                    description = value ?? '';
                  },
                ),
                SizedBox(height: 24),

                // Nút Thêm
                ElevatedButton(
                  child: Text('Thêm Chi Tiêu'),
                  onPressed: () {
                    if (_formKey.currentState!.validate() && date != null) {
                      _formKey.currentState!.save();
                      expenseController.addExpense(
                          amount!, category, date!, description);
                      Get.back();
                      Get.snackbar(
                        'Thành Công',
                        'Đã thêm chi tiêu mới',
                        snackPosition: SnackPosition.BOTTOM,
                      );
                    } else {
                      Get.snackbar(
                        'Lỗi',
                        'Vui lòng điền đầy đủ thông tin và chọn ngày chi tiêu',
                        snackPosition: SnackPosition.TOP,
                        backgroundColor: Colors.redAccent,
                        colorText: Colors.white,
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
