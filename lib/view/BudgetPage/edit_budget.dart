import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class EditBudgetDialog extends StatefulWidget {
  final TextEditingController amountController;
  final TextEditingController categoryController;
  final TextEditingController noteController;
  final TextEditingController dateController;
  final String initialCategory;
  final VoidCallback onSave;

  const EditBudgetDialog({
    super.key,
    required this.amountController,
    required this.categoryController,
    required this.noteController,
    required this.dateController,
    required this.initialCategory,
    required this.onSave,
  });

  @override
  _EditBudgetDialogState createState() => _EditBudgetDialogState();
}

class _EditBudgetDialogState extends State<EditBudgetDialog> {
  late String selectedCategory;

  @override
  void initState() {
    super.initState();
    selectedCategory = widget.initialCategory;
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text(
        'Chỉnh sửa khoản chi/thu',
        style: TextStyle(fontWeight: FontWeight.bold),
      ),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Date Picker
            TextFormField(
              controller: widget.dateController,
              readOnly: true,
              decoration: const InputDecoration(
                labelText: 'Ngày',
                suffixIcon: Icon(Icons.calendar_today),
                border: OutlineInputBorder(),
              ),
              onTap: () => _selectDate(context),
            ),
            const SizedBox(height: 10),
            // Note Input
            TextField(
              controller: widget.noteController,
              decoration: const InputDecoration(
                labelText: 'Ghi chú',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 10),
            // Amount Input
            TextField(
              controller: widget.amountController,
              decoration: const InputDecoration(
                labelText: 'Số tiền',
                suffixText: 'đ',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 10),
            // Categories Grid
            SizedBox(
              height: 300, // Giới hạn chiều cao của GridView
              child: GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: _categories().length,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  childAspectRatio: 1,
                  crossAxisSpacing: 8,
                  mainAxisSpacing: 8,
                ),
                itemBuilder: (context, index) {
                  final category = _categories()[index];
                  final isSelected = category['name'] == selectedCategory;

                  return GestureDetector(
                    onTap: () => _showCategoryActionDialog(context, category),
                    child: Container(
                      decoration: BoxDecoration(
                        color: isSelected
                            ? Colors.blue.withOpacity(0.2)
                            : Colors.white,
                        border: Border.all(
                          color: isSelected ? Colors.blue : Colors.grey,
                          width: 2,
                        ),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(category['icon'],
                              size: 40, color: category['color']),
                          const SizedBox(height: 8),
                          Text(
                            category['name'],
                            style: const TextStyle(fontWeight: FontWeight.bold),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Hủy'),
        ),
        ElevatedButton(
          onPressed: () {
            if (widget.amountController.text.isEmpty ||
                double.tryParse(widget.amountController.text) == null) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Vui lòng nhập số tiền hợp lệ!')),
              );
              return;
            }
            if (widget.categoryController.text.isEmpty) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Vui lòng chọn danh mục!')),
              );
              return;
            }
            widget.onSave();
            Navigator.pop(context);
          },
          child: const Text('Lưu'),
        ),
      ],
    );
  }

  List<Map<String, dynamic>> _categories() {
    return [
      {'name': 'Ăn uống', 'icon': Icons.fastfood, 'color': Colors.orange},
      {'name': 'Sinh hoạt', 'icon': Icons.shopping_bag, 'color': Colors.green},
      {'name': 'Quần áo', 'icon': Icons.checkroom, 'color': Colors.blue},
      {'name': 'Mỹ phẩm', 'icon': Icons.brush, 'color': Colors.pink},
      {'name': 'Giao lưu', 'icon': Icons.emoji_people, 'color': Colors.yellow},
      {'name': 'Y tế', 'icon': Icons.medical_services, 'color': Colors.teal},
      {'name': 'Giáo dục', 'icon': Icons.school, 'color': Colors.red},
      {
        'name': 'Tiền điện',
        'icon': Icons.lightbulb_outline,
        'color': Colors.cyan
      },
      {'name': 'Liên lạc', 'icon': Icons.phone, 'color': Colors.black},
    ];
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (picked != null) {
      setState(() {
        widget.dateController.text =
            DateFormat('dd/MM/yyyy (EEE)').format(picked);
      });
    }
  }

  // Show a dialog for editing or deleting the selected category
  void _showCategoryActionDialog(
      BuildContext context, Map<String, dynamic> category) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Chọn hành động'),
          content:
              Text('Bạn muốn thay đổi hoặc xoá mục "${category['name']}"?'),
          actions: [
            TextButton(
              onPressed: () {
                setState(() {
                  selectedCategory = category['name'];
                  widget.categoryController.text = selectedCategory;
                });
                Navigator.pop(context);
              },
              child: const Text('Thay đổi'),
            ),
            TextButton(
              onPressed: () {
                setState(() {
                  selectedCategory = ''; // Reset category selection
                  widget.categoryController
                      .clear(); // Clear the category controller
                });
                Navigator.pop(context);
              },
              child: const Text('Xoá'),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Hủy'),
            ),
          ],
        );
      },
    );
  }
}
