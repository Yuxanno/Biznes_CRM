class Debt {
  final String id;
  final String type; // 'owe' | 'owed'
  final String personName;
  final String? phone;
  final double amount;
  final double paidAmount;
  final String? description;
  final String? comment;
  final DateTime date;
  final DateTime? dueDate;
  final String status; // 'unpaid' | 'partial' | 'paid'
  final String? customerId;

  const Debt({
    required this.id,
    required this.type,
    required this.personName,
    this.phone,
    required this.amount,
    required this.paidAmount,
    this.description,
    this.comment,
    required this.date,
    this.dueDate,
    required this.status,
    this.customerId,
  });

  double get remaining => amount - paidAmount;
  bool get isPaid => status == 'paid';
  bool get isOverdue => dueDate != null && dueDate!.isBefore(DateTime.now()) && !isPaid;
  /// true = someone owes me
  bool get isOwedToMe => type == 'owed';

  factory Debt.fromJson(Map<String, dynamic> json) {
    return Debt(
      id: json['_id'] as String,
      type: json['type'] as String,
      personName: json['personName'] as String,
      phone: json['phone'] as String?,
      amount: (json['amount'] as num).toDouble(),
      paidAmount: (json['paidAmount'] as num? ?? 0).toDouble(),
      description: json['description'] as String?,
      comment: json['comment'] as String?,
      date: DateTime.parse(json['date'] as String),
      dueDate: json['dueDate'] != null ? DateTime.parse(json['dueDate'] as String) : null,
      status: json['status'] as String,
      customerId: json['customerId'] is Map
          ? (json['customerId'] as Map)['_id'] as String?
          : json['customerId'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
        '_id': id,
        'type': type,
        'personName': personName,
        if (phone != null) 'phone': phone,
        'amount': amount,
        'paidAmount': paidAmount,
        if (description != null) 'description': description,
        if (comment != null) 'comment': comment,
        'date': date.toIso8601String(),
        if (dueDate != null) 'dueDate': dueDate!.toIso8601String(),
        'status': status,
        if (customerId != null) 'customerId': customerId,
      };
}
