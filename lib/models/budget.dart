class Budget {
  final String date; // Ngày giao dịch
  final String category; // Danh mục giao dịch
  final double amount; // Số tiền giao dịch
  final String note; // Ghi chú
  final String type; // Loại giao dịch: 'expense' hoặc 'income'

  Budget({
    required this.date,
    required this.category,
    required this.amount,
    required this.note,
    required this.type,
  });

  // Phương thức để chuyển từ JSON thành đối tượng Budget
  factory Budget.fromJson(Map<String, dynamic> json) {
    return Budget(
      date: json['date'] as String,
      category: json['category'] as String,
      amount: (json['amount'] as num).toDouble(), // Đảm bảo chuyển đổi sang double
      note: json['note'] as String,
      type: json['type'] as String,
    );
  }

  // Phương thức để chuyển đối tượng Budget thành JSON
  Map<String, dynamic> toJson() {
    return {
      'date': date,
      'category': category,
      'amount': amount,
      'note': note,
      'type': type,
    };
  }
}
