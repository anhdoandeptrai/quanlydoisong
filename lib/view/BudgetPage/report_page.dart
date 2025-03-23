import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

class ReportPage extends StatelessWidget {
  final Map<String, List<Map<String, dynamic>>> transactions;

  const ReportPage({super.key, required this.transactions});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Báo cáo thu chi'),
          centerTitle: true,
          bottom: const TabBar(
            indicatorColor: Colors.white,
            tabs: [
              Tab(text: 'Chi tiêu'),
              Tab(text: 'Thu nhập'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            ReportContent(transactions: transactions, reportType: 'expense'),
            ReportContent(transactions: transactions, reportType: 'income'),
          ],
        ),
      ),
    );
  }
}

class ReportContent extends StatelessWidget {
  final Map<String, List<Map<String, dynamic>>> transactions;
  final String reportType;

  const ReportContent(
      {super.key, required this.transactions, required this.reportType});

  @override
  Widget build(BuildContext context) {
    double totalAmount = 0;
    Map<String, double> categorySums = {};

    transactions.forEach((_, value) {
      for (var transaction in value) {
        if (transaction['type'] == reportType) {
          totalAmount += transaction['amount'];
          categorySums[transaction['category']] =
              (categorySums[transaction['category']] ?? 0) +
                  transaction['amount'];
        }
      }
    });

    return Column(
      children: [
        _buildSummaryCard(reportType, totalAmount),
        const SizedBox(height: 10),
        Expanded(
          child: categorySums.isEmpty
              ? _buildEmptyState()
              : _buildPieChartAndList(context, totalAmount, categorySums),
        ),
      ],
    );
  }

  Widget _buildSummaryCard(String reportType, double totalAmount) {
    String title = reportType == 'expense' ? 'Tổng Chi tiêu' : 'Tổng Thu nhập';

    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: reportType == 'expense'
              ? [Colors.redAccent, Colors.red]
              : [Colors.greenAccent, Colors.green],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: const TextStyle(
                color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
          ),
          Text(
            '${totalAmount.toStringAsFixed(0)}đ',
            style: const TextStyle(
                color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.inbox, size: 60, color: Colors.grey),
          SizedBox(height: 10),
          Text(
            'Không có giao dịch nào để hiển thị',
            style: TextStyle(fontSize: 16, color: Colors.grey),
          ),
        ],
      ),
    );
  }

  Widget _buildPieChartAndList(BuildContext context, double totalAmount,
      Map<String, double> categorySums) {
    return Column(
      children: [
        Expanded(
          flex: 2,
          child: PieChartWidget(
              totalAmount: totalAmount, categorySums: categorySums),
        ),
        Expanded(
          flex: 3,
          child: ListView.builder(
            itemCount: categorySums.length,
            itemBuilder: (context, index) {
              String category = categorySums.keys.elementAt(index);
              double amount = categorySums[category]!;
              return ListTile(
                leading: CircleAvatar(
                  backgroundColor: Colors
                      .primaries[category.hashCode % Colors.primaries.length],
                  child: const Icon(Icons.category, color: Colors.white),
                ),
                title: Text(category,
                    style: const TextStyle(fontWeight: FontWeight.bold)),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text('${amount.toStringAsFixed(0)}đ',
                        style: const TextStyle(fontWeight: FontWeight.bold)),
                    IconButton(
                      icon: const Icon(Icons.edit, color: Colors.blue),
                      onPressed: () {
                        _editTransaction(context, category, amount);
                      },
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete, color: Colors.red),
                      onPressed: () {
                        _deleteTransaction(context, category);
                      },
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  void _editTransaction(BuildContext context, String category, double amount) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Chỉnh sửa giao dịch'),
          content:
              Text('Chức năng chỉnh sửa cho $category đang được phát triển.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Đóng'),
            ),
          ],
        );
      },
    );
  }

  void _deleteTransaction(BuildContext context, String category) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Xóa giao dịch'),
          content: Text(
              'Bạn có chắc muốn xóa giao dịch trong danh mục $category không?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Hủy'),
            ),
            TextButton(
              onPressed: () {
                // Xử lý xóa giao dịch tại đây
                Navigator.of(context).pop();
              },
              child: const Text('Xóa', style: TextStyle(color: Colors.red)),
            ),
          ],
        );
      },
    );
  }
}

class PieChartWidget extends StatelessWidget {
  final double totalAmount;
  final Map<String, double> categorySums;

  const PieChartWidget(
      {super.key, required this.totalAmount, required this.categorySums});

  @override
  Widget build(BuildContext context) {
    List<PieChartSectionData> sections = categorySums.entries.map((entry) {
      return PieChartSectionData(
        value: entry.value,
        title: '${((entry.value / totalAmount) * 100).toStringAsFixed(1)}%',
        color: Colors.primaries[entry.key.hashCode % Colors.primaries.length],
        radius: 60,
      );
    }).toList();

    return Card(
      margin: const EdgeInsets.all(16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: PieChart(PieChartData(
        sections: sections,
        centerSpaceRadius: 40,
        borderData: FlBorderData(show: false),
      )),
    );
  }
}
