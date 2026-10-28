class BusinessPeriod {
  final String id;
  final String name;
  final DateTime startDate;
  final DateTime? endDate;
  final String status; // 'active' | 'closed'
  final double? totalIncome;
  final double? totalExpense;
  final double? profit;

  const BusinessPeriod({
    required this.id,
    required this.name,
    required this.startDate,
    this.endDate,
    required this.status,
    this.totalIncome,
    this.totalExpense,
    this.profit,
  });

  bool get isActive => status == 'active';

  factory BusinessPeriod.fromJson(Map<String, dynamic> json) {
    return BusinessPeriod(
      id: json['_id'] as String,
      name: json['name'] as String,
      startDate: DateTime.parse(json['startDate'] as String),
      endDate: json['endDate'] != null ? DateTime.parse(json['endDate'] as String) : null,
      status: json['status'] as String,
      // backend returns 'income'/'expense'/'profit' from aggregate
      totalIncome: (json['totalIncome'] as num? ?? json['income'] as num? ?? 0).toDouble(),
      totalExpense: (json['totalExpense'] as num? ?? json['expense'] as num? ?? 0).toDouble(),
      profit: (json['profit'] as num?)?.toDouble(),
    );
  }

  Map<String, dynamic> toJson() => {
        '_id': id,
        'name': name,
        'startDate': startDate.toIso8601String(),
        if (endDate != null) 'endDate': endDate!.toIso8601String(),
        'status': status,
      };
}
