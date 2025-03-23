import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:table_calendar/table_calendar.dart';

class CalendarPage extends StatefulWidget {
  final Map<String, List<Map<String, dynamic>>> transactions;

  const CalendarPage({super.key, required this.transactions});

  @override
  _CalendarPageState createState() => _CalendarPageState();
}

class _CalendarPageState extends State<CalendarPage> {
  DateTime selectedDate = DateTime.now();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.blueAccent, Colors.lightBlue],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
        title: const Text(
          'Lịch chi tiêu',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
      ),
      body: Column(
        children: [
          _buildCalendar(),
          _buildDailySummary(),
          const SizedBox(height: 10),
          _buildTransactionList(),
        ],
      ),
    );
  }

  Widget _buildCalendar() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
              color: Colors.grey.shade300,
              blurRadius: 5,
              offset: const Offset(0, 3)),
        ],
      ),
      child: TableCalendar(
        locale: 'vi_VN',
        firstDay: DateTime.utc(2020, 1, 1),
        lastDay: DateTime.utc(2030, 12, 31),
        focusedDay: selectedDate,
        selectedDayPredicate: (day) => isSameDay(day, selectedDate),
        onDaySelected: (selectedDay, focusedDay) {
          setState(() {
            selectedDate = selectedDay;
          });
        },
        calendarFormat: CalendarFormat.month,
        eventLoader: _getEventsForDay,
        calendarStyle: const CalendarStyle(
          selectedDecoration: BoxDecoration(
            color: Colors.blueAccent,
            shape: BoxShape.circle,
          ),
          todayDecoration: BoxDecoration(
            color: Colors.lightBlueAccent,
            shape: BoxShape.circle,
          ),
          markerDecoration: BoxDecoration(
            color: Color.fromARGB(255, 218, 123, 8),
            shape: BoxShape.circle,
          ),
        ),
        headerStyle: const HeaderStyle(
          formatButtonVisible: false,
          titleCentered: true,
          titleTextStyle: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }

  List<Map<String, dynamic>> _getEventsForDay(DateTime day) {
    final dateKey = DateFormat('dd/MM/yyyy').format(day);
    return widget.transactions[dateKey] ?? [];
  }

  Widget _buildDailySummary() {
    final dateKey = DateFormat('dd/MM/yyyy').format(selectedDate);
    final transactionsForDay = widget.transactions[dateKey] ?? [];
    final totalExpense = transactionsForDay
        .where((t) => t['type'] == 'expense')
        .fold(0.0, (sum, t) => sum + t['amount']);
    final totalIncome = transactionsForDay
        .where((t) => t['type'] == 'income')
        .fold(0.0, (sum, t) => sum + t['amount']);

    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildSummaryTile('Tổng chi', totalExpense, Colors.red),
          _buildSummaryTile('Tổng thu', totalIncome, Colors.green),
        ],
      ),
    );
  }

  Widget _buildSummaryTile(String title, double amount, Color color) {
    return Column(
      children: [
        Text(
          title,
          style: TextStyle(
              fontSize: 16, fontWeight: FontWeight.bold, color: color),
        ),
        const SizedBox(height: 4),
        Text(
          '${amount.toStringAsFixed(0)} VNĐ',
          style: const TextStyle(fontSize: 14, color: Colors.black),
        ),
      ],
    );
  }

  Widget _buildTransactionList() {
    final dateKey = DateFormat('dd/MM/yyyy').format(selectedDate);
    final transactionsForDay = widget.transactions[dateKey] ?? [];

    return Expanded(
      child: transactionsForDay.isEmpty
          ? const Center(
              child: Text(
                'Không có giao dịch nào',
                style: TextStyle(fontSize: 16, color: Colors.grey),
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(8),
              itemCount: transactionsForDay.length,
              itemBuilder: (context, index) {
                final transaction = transactionsForDay[index];
                return Container(
                  margin: const EdgeInsets.symmetric(vertical: 5),
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(10),
                    boxShadow: [
                      BoxShadow(
                          color: Colors.grey.shade200,
                          blurRadius: 5,
                          offset: const Offset(0, 3)),
                    ],
                  ),
                  child: Row(
                    children: [
                      CircleAvatar(
                        backgroundColor: transaction['type'] == 'expense'
                            ? Colors.red
                            : Colors.green,
                        child: Icon(
                          transaction['type'] == 'expense'
                              ? Icons.remove
                              : Icons.add,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              transaction['category'],
                              style: const TextStyle(
                                  fontWeight: FontWeight.bold, fontSize: 16),
                            ),
                            Text(transaction['note']),
                          ],
                        ),
                      ),
                      Text(
                        '${transaction['amount'].toStringAsFixed(0)} VNĐ',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: transaction['type'] == 'expense'
                              ? Colors.red
                              : Colors.green,
                        ),
                      ),
                      PopupMenuButton<String>(
                        onSelected: (value) {
                          if (value == 'edit') {
                            _editTransaction(dateKey, index, transaction);
                          } else if (value == 'delete') {
                            _deleteTransaction(dateKey, index);
                          }
                        },
                        itemBuilder: (context) => [
                          const PopupMenuItem(
                            value: 'edit',
                            child: Text('Sửa'),
                          ),
                          const PopupMenuItem(
                            value: 'delete',
                            child: Text('Xóa'),
                          ),
                        ],
                      ),
                    ],
                  ),
                );
              },
            ),
    );
  }

  void _deleteTransaction(String dateKey, int index) {
    setState(() {
      widget.transactions[dateKey]?.removeAt(index);
      if (widget.transactions[dateKey]?.isEmpty ?? true) {
        widget.transactions.remove(dateKey);
      }
    });
  }

  void _editTransaction(
      String dateKey, int index, Map<String, dynamic> transaction) async {
    final updatedTransaction = await showDialog<Map<String, dynamic>>(
      context: context,
      builder: (context) {
        return _EditTransactionDialog(transaction: transaction);
      },
    );

    if (updatedTransaction != null) {
      setState(() {
        widget.transactions[dateKey]?[index] = updatedTransaction;
      });
    }
  }
}

class _EditTransactionDialog extends StatefulWidget {
  final Map<String, dynamic> transaction;

  const _EditTransactionDialog({required this.transaction});

  @override
  State<_EditTransactionDialog> createState() => _EditTransactionDialogState();
}

class _EditTransactionDialogState extends State<_EditTransactionDialog> {
  late TextEditingController categoryController;
  late TextEditingController noteController;
  late TextEditingController amountController;
  late String type;

  @override
  void initState() {
    super.initState();
    categoryController =
        TextEditingController(text: widget.transaction['category']);
    noteController = TextEditingController(text: widget.transaction['note']);
    amountController =
        TextEditingController(text: widget.transaction['amount'].toString());
    type = widget.transaction['type'];
  }

  @override
  void dispose() {
    categoryController.dispose();
    noteController.dispose();
    amountController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Sửa giao dịch'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: categoryController,
            decoration: const InputDecoration(labelText: 'Danh mục'),
          ),
          TextField(
            controller: noteController,
            decoration: const InputDecoration(labelText: 'Ghi chú'),
          ),
          TextField(
            controller: amountController,
            decoration: const InputDecoration(labelText: 'Số tiền'),
            keyboardType: TextInputType.number,
          ),
          DropdownButton<String>(
            value: type,
            onChanged: (value) {
              setState(() {
                type = value!;
              });
            },
            items: const [
              DropdownMenuItem(value: 'income', child: Text('Thu nhập')),
              DropdownMenuItem(value: 'expense', child: Text('Chi tiêu')),
            ],
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Hủy'),
        ),
        TextButton(
          onPressed: () {
            Navigator.of(context).pop({
              'category': categoryController.text,
              'note': noteController.text,
              'amount': double.parse(amountController.text),
              'type': type,
            });
          },
          child: const Text('Lưu'),
        ),
      ],
    );
  }
}
