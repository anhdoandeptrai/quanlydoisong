import 'package:hive/hive.dart';

part 'transaction_model.g.dart';

@HiveType(typeId: 3)
class TransactionModel extends HiveObject {
  @HiveField(0)
  String category;

  @HiveField(1)
  double amount;

  @HiveField(2)
  String note;

  @HiveField(3)
  DateTime date;

  @HiveField(4)
  String type; // "expense" hoặc "income"

  TransactionModel({
    required this.category,
    required this.amount,
    required this.note,
    required this.date,
    required this.type,
  });
}
