class Transaction {
  final String id;
  final String type; // 'income' | 'expense'
  final double amount;
  final String category;
  final String? description;
  final DateTime date;
  final String periodId;

  const Transaction({
    required this.id,
    required this.type,
    required this.amount,
    required this.category,
    this.description,
    required this.date,
    required this.periodId,
  });

  bool get isIncome => type == 'income';

  factory Transaction.fromJson(Map<String, dynamic> json) {
    return Transaction(
      id: json['_id'] as String,
      type: json['type'] as String,
      amount: (json['amount'] as num).toDouble(),
      category: json['category'] as String,
      description: json['description'] as String?,
      date: DateTime.parse(json['date'] as String),
      periodId: json['periodId'] is Map
          ? (json['periodId'] as Map)['_id'] as String
          : json['periodId'] as String,
    );
  }

  Map<String, dynamic> toJson() => {
        '_id': id,
        'type': type,
        'amount': amount,
        'category': category,
        if (description != null) 'description': description,
        'date': date.toIso8601String(),
        'periodId': periodId,
      };
}
