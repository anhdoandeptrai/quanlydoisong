import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:quanlydoisong/view/BudgetPage/calender_page.dart';
import 'report_page.dart';

class BudgetPage extends StatefulWidget {
  final String title;

  const BudgetPage({super.key, required this.title});

  @override
  _BudgetPageState createState() => _BudgetPageState();
}

class _BudgetPageState extends State<BudgetPage> {
  DateTime selectedDate = DateTime.now();
  String? selectedCategory;
  Map<String, List<Map<String, dynamic>>> transactions = {};
  final TextEditingController amountController = TextEditingController();
  final TextEditingController noteController = TextEditingController();
  final TextEditingController dateController = TextEditingController();
  int _selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    dateController.text = DateFormat('dd/MM/yyyy (EEE)').format(selectedDate);
  }

  @override
  void dispose() {
    amountController.dispose();
    noteController.dispose();
    dateController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.blueAccent,
          title: const Text(('Quản Lý Thu Chi'),
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          bottom: const TabBar(
            tabs: [
              Tab(
                  icon: Icon(Icons.attach_money, color: Colors.black),
                  child: Text(
                    'Tiền chi',
                    style: TextStyle(color: Colors.black),
                  )),
              Tab(
                  icon: Icon(Icons.money, color: Colors.black),
                  child: Text(
                    'Tiền thu',
                    style: TextStyle(color: Colors.black),
                  )),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            _buildForm(context, 'Tiền chi', _expenseCategories()),
            _buildForm(context, 'Tiền thu', _incomeCategories()),
          ],
        ),
        bottomNavigationBar: BottomNavigationBar(
          currentIndex: _selectedIndex,
          onTap: (int index) {
            setState(() {
              _selectedIndex = index;
            });
            _navigateToPage(
              context,
              index == 0
                  ? CalendarPage(transactions: transactions)
                  : ReportPage(transactions: transactions),
            );
          },
          items: const <BottomNavigationBarItem>[
            BottomNavigationBarItem(
              icon: Icon(Icons.calendar_today),
              label: 'Lịch',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.bar_chart),
              label: 'Báo cáo',
            ),
          ],
        ),
      ),
    );
  }

  void _navigateToPage(BuildContext context, Widget page) {
    Navigator.push(context, MaterialPageRoute(builder: (context) => page));
  }

  Widget _buildForm(BuildContext context, String title,
      List<Map<String, dynamic>> categories) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildDatePicker(),
          const SizedBox(height: 10),
          _buildTextField('Ghi chú', 'Chưa nhập vào', noteController),
          const SizedBox(height: 10),
          _buildTextField(title, '0', amountController,
              suffixText: 'đ', isNumber: true),
          const SizedBox(height: 10),
          _buildCategoryGrid(categories),
          const SizedBox(height: 10),
          Center(
            child: ElevatedButton(
              onPressed: () => _addTransaction(title),
              child: Text('Nhập khoản ${title == 'Tiền chi' ? 'chi' : 'thu'}'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDatePicker() {
    return Row(
      children: [
        IconButton(
          icon: const Icon(Icons.chevron_left),
          onPressed: () => _changeDate(-1),
        ),
        Expanded(
          child: TextFormField(
            readOnly: true,
            controller: dateController,
            decoration: const InputDecoration(
              labelText: 'Ngày',
              suffixIcon: Icon(Icons.calendar_today),
              border: OutlineInputBorder(),
            ),
            onTap: () => _selectDate(context),
          ),
        ),
        IconButton(
          icon: const Icon(Icons.chevron_right),
          onPressed: () => _changeDate(1),
        ),
      ],
    );
  }

  Widget _buildTextField(
      String label, String hint, TextEditingController controller,
      {String? suffixText, bool isNumber = false}) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        suffixText: suffixText,
        border: const OutlineInputBorder(),
      ),
      keyboardType: isNumber ? TextInputType.number : TextInputType.text,
    );
  }

  Widget _buildCategoryGrid(List<Map<String, dynamic>> categories) {
    return GridView.builder(
      shrinkWrap: true,
      itemCount: categories.length,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        childAspectRatio: 1,
        crossAxisSpacing: 8,
        mainAxisSpacing: 8,
      ),
      itemBuilder: (context, index) {
        return _buildCategoryItem(categories[index]);
      },
    );
  }

  Widget _buildCategoryItem(Map<String, dynamic> category) {
    final isSelected = category['name'] == selectedCategory;
    return GestureDetector(
      onTap: () => setState(() {
        selectedCategory = category['name'];
      }),
      child: Container(
        decoration: BoxDecoration(
          color: isSelected ? Colors.blue.withOpacity(0.2) : Colors.white,
          border: Border.all(
              color: isSelected ? Colors.blue : Colors.grey, width: 2),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(category['icon'], size: 40, color: category['color']),
            const SizedBox(height: 8),
            Text(category['name'],
                style: const TextStyle(fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }

  void _addTransaction(String title) {
    if (selectedCategory == null || amountController.text.isEmpty) {
      Get.snackbar(
        'Lỗi',
        'Vui lòng nhập số tiền và chọn danh mục',
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.redAccent,
        colorText: Colors.white,
      );
      return;
    }

    try {
      final amount = double.parse(amountController.text);
      final transaction = {
        'date': DateFormat('dd/MM/yyyy').format(selectedDate),
        'category': selectedCategory,
        'amount': amount,
        'note': noteController.text,
        'type': title == 'Tiền chi' ? 'expense' : 'income',
      };

      setState(() {
        final dateKey = DateFormat('dd/MM/yyyy').format(selectedDate);
        transactions.putIfAbsent(dateKey, () => []).add(transaction);
        selectedCategory = null;
        amountController.clear();
        noteController.clear();
      });

      Get.snackbar(
        'Thành công',
        'Đã nhập khoản ${title == 'Tiền chi' ? 'chi' : 'thu'} thành công!',
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.greenAccent,
        colorText: Colors.black,
        mainButton: TextButton(
          onPressed: () {
            setState(() {
              transactions[DateFormat('dd/MM/yyyy').format(selectedDate)]
                  ?.remove(transaction);
            });
          },
          child: const Text('Hoàn tác', style: TextStyle(color: Colors.white)),
        ),
      );
    } catch (e) {
      Get.snackbar(
        'Lỗi',
        'Số tiền không hợp lệ',
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.redAccent,
        colorText: Colors.white,
      );
    }
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (picked != null && picked != selectedDate) {
      setState(() {
        selectedDate = picked;
        dateController.text =
            DateFormat('dd/MM/yyyy (EEE)').format(selectedDate);
      });
    }
  }

  void _changeDate(int dayDifference) {
    setState(() {
      selectedDate = selectedDate.add(Duration(days: dayDifference));
      dateController.text = DateFormat('dd/MM/yyyy (EEE)').format(selectedDate);
    });
  }

  List<Map<String, dynamic>> _expenseCategories() => [
        {'name': 'Ăn uống', 'icon': Icons.fastfood, 'color': Colors.orange},
        {
          'name': 'Sinh hoạt',
          'icon': Icons.shopping_bag,
          'color': Colors.green
        },
        {'name': 'Quần áo', 'icon': Icons.checkroom, 'color': Colors.blue},
        {'name': 'Mỹ phẩm', 'icon': Icons.brush, 'color': Colors.pink},
        {
          'name': 'Phương tiện',
          'icon': Icons.directions_car,
          'color': Colors.purple
        },
        {'name': 'Khác', 'icon': Icons.more_horiz, 'color': Colors.grey},
      ];

  List<Map<String, dynamic>> _incomeCategories() => [
        {
          'name': 'Tiền lương',
          'icon': Icons.attach_money,
          'color': Colors.green
        },
        {'name': 'Thưởng', 'icon': Icons.star, 'color': Colors.yellow},
        {'name': 'Đầu tư', 'icon': Icons.trending_up, 'color': Colors.blue},
        {'name': 'Bán hàng', 'icon': Icons.store, 'color': Colors.orange},
        {
          'name': 'Lãi suất',
          'icon': Icons.monetization_on,
          'color': Colors.purple
        },
        {'name': 'Khác', 'icon': Icons.more_horiz, 'color': Colors.grey},
      ];
  void _addCustomCategory(List<Map<String, dynamic>> categories) {
    String? categoryName;
    IconData? categoryIcon;
    Color? categoryColor;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Thêm danh mục mới'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                decoration: const InputDecoration(
                  labelText: 'Tên danh mục',
                  border: OutlineInputBorder(),
                ),
                onChanged: (value) {
                  categoryName = value.trim();
                },
              ),
              const SizedBox(height: 10),
              DropdownButtonFormField<IconData>(
                decoration: const InputDecoration(
                  labelText: 'Biểu tượng',
                  border: OutlineInputBorder(),
                ),
                items: const [
                  DropdownMenuItem(
                    value: Icons.category,
                    child: Text('Mặc định'),
                  ),
                  DropdownMenuItem(
                    value: Icons.fastfood,
                    child: Text('Ăn uống'),
                  ),
                  DropdownMenuItem(
                    value: Icons.shopping_bag,
                    child: Text('Mua sắm'),
                  ),
                  // Thêm các biểu tượng khác
                ],
                onChanged: (value) {
                  categoryIcon = value;
                },
              ),
              const SizedBox(height: 10),
              DropdownButtonFormField<Color>(
                decoration: const InputDecoration(
                  labelText: 'Màu sắc',
                  border: OutlineInputBorder(),
                ),
                items: const [
                  DropdownMenuItem(
                    value: Colors.orange,
                    child: Text('Cam'),
                  ),
                  DropdownMenuItem(
                    value: Colors.green,
                    child: Text('Xanh lá'),
                  ),
                  DropdownMenuItem(
                    value: Colors.blue,
                    child: Text('Xanh dương'),
                  ),
                  // Thêm các màu khác
                ],
                onChanged: (value) {
                  categoryColor = value;
                },
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Đóng dialog
              },
              child: const Text('Hủy'),
            ),
            ElevatedButton(
              onPressed: () {
                if (categoryName != null &&
                    categoryName!.isNotEmpty &&
                    categoryIcon != null &&
                    categoryColor != null) {
                  setState(() {
                    categories.add({
                      'name': categoryName,
                      'icon': categoryIcon,
                      'color': categoryColor,
                    });
                  });
                  Navigator.of(context).pop(); // Đóng dialog
                } else {
                  Get.snackbar(
                    'Lỗi',
                    'Vui lòng điền đầy đủ thông tin',
                    snackPosition: SnackPosition.TOP,
                    backgroundColor: Colors.redAccent,
                    colorText: Colors.white,
                  );
                }
              },
              child: const Text('Thêm'),
            ),
          ],
        );
      },
    );
  }

  void _manageCustomCategory(List<Map<String, dynamic>> categories) {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.add),
              title: const Text('Thêm danh mục mới'),
              onTap: () {
                Navigator.of(context).pop(); // Đóng hộp thoại
                _addCustomCategory(categories); // Gọi hàm thêm danh mục
              },
            ),
            ...categories
                .where((category) =>
                    category['name'] != 'Khác') // Không cho xóa "Khác"
                .map((category) => ListTile(
                      leading: const Icon(Icons.delete),
                      title: Text('Xóa "${category['name']}"'),
                      onTap: () {
                        setState(() {
                          categories.remove(category);
                        });
                        Navigator.of(context).pop(); // Đóng hộp thoại
                      },
                    )),
          ],
        );
      },
    );
  }

  Widget _buildCategoryItemWithManage(
      Map<String, dynamic> category, List<Map<String, dynamic>> categories) {
    final isSelected = category['name'] == selectedCategory;

    return GestureDetector(
      onTap: () {
        if (category['name'] == 'Khác') {
          _manageCustomCategory(categories); // Quản lý thêm/xóa danh mục
        } else {
          setState(() {
            selectedCategory = category['name'];
          });
        }
      },
      child: Container(
        decoration: BoxDecoration(
          color: isSelected ? Colors.blue.withOpacity(0.2) : Colors.white,
          border: Border.all(
              color: isSelected ? Colors.blue : Colors.grey, width: 2),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(category['icon'], size: 40, color: category['color']),
            const SizedBox(height: 8),
            Text(category['name'],
                style: const TextStyle(fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }
}
