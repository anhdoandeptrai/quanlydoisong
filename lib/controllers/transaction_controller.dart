import 'package:get/get.dart';
import 'package:quanlydoisong/models/transaction_model.dart';
import 'package:hive/hive.dart';
import 'package:quanlydoisong/services/data_service.dart';

class TransactionController extends GetxController {
  late Box<TransactionModel> transactionBox;
  var transactions = <TransactionModel>[].obs;
  final DataService dataService = DataService();

  @override
  void onInit() {
    super.onInit();
    _openBox();
  }

  Future<void> _openBox() async {
    transactionBox = await Hive.openBox<TransactionModel>('transactions');
    _loadTransactions();
  }

  void _loadTransactions() {
    transactions.assignAll(transactionBox.values);
  }

  void addTransaction(TransactionModel transaction) {
    transactionBox.add(transaction);
    transactions.add(transaction);
  }

  void updateTransaction(int index, TransactionModel transaction) {
    transactionBox.putAt(index, transaction);
    transactions[index] = transaction;
  }

  void removeTransaction(TransactionModel transaction) {
    int index = transactions.indexOf(transaction);
    transactions.removeAt(index);
    transactionBox.deleteAt(index);
  }

  @override
  void onClose() {
    transactionBox.close();
    super.onClose();
  }
}
