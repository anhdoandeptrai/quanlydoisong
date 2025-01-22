import 'package:get/get.dart';
import 'package:quanlydoisong/models/transaction_model.dart';
import 'package:hive/hive.dart';
import 'package:quanlydoisong/services/data_service.dart';

class ReportController extends GetxController {
  final String reportType;
  late Box<TransactionModel> transactionBox;
    final DataService dataService = DataService();

  ReportController({required this.reportType});

  @override
  void onInit() {
    super.onInit();
    _openBox();
  }

  Future<void> _openBox() async {
    transactionBox = await Hive.openBox<TransactionModel>('transactions');
  }

  double getTotalAmount() {
    double total = 0;
    for (var transaction in transactionBox.values) {
      if (transaction.type == reportType) {
        total += transaction.amount;
      }
    }
    return total;
  }

  Map<String, double> getCategorySummary() {
    final Map<String, double> summary = {};
    for (var transaction in transactionBox.values) {
      if (transaction.type == reportType) {
        summary[transaction.category] = (summary[transaction.category] ?? 0) + transaction.amount;
      }
    }
    return summary;
  }
}
