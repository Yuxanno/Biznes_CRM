class Order {
  final String id;
  final String title;
  final String clientName;
  final String? clientPhone;
  final String? description;
  final double? amount;
  final String status; // 'new' | 'in_progress' | 'waiting' | 'completed' | 'cancelled'
  final List<String> photos;
  final String? audioId;
  final DateTime? deadline;
  final String? customerId;
  final String periodId;
  final DateTime createdDate;

  const Order({
    required this.id,
    required this.title,
    required this.clientName,
    this.clientPhone,
    this.description,
    this.amount,
    required this.status,
    required this.photos,
    this.audioId,
    this.deadline,
    this.customerId,
    required this.periodId,
    required this.createdDate,
  });

  bool get isActive => ['new', 'in_progress', 'waiting'].contains(status);
  bool get isOverdue => deadline != null && deadline!.isBefore(DateTime.now()) && isActive;

  factory Order.fromJson(Map<String, dynamic> json) {
    return Order(
      id: json['_id'] as String,
      title: json['title'] as String,
      clientName: json['clientName'] as String,
      clientPhone: json['clientPhone'] as String?,
      description: json['description'] as String?,
      amount: (json['amount'] as num?)?.toDouble(),
      status: json['status'] as String,
      photos: List<String>.from(json['photos'] as List? ?? []),
      audioId: json['audioId'] as String?,
      deadline: json['deadline'] != null ? DateTime.parse(json['deadline'] as String) : null,
      customerId: json['customerId'] is Map
          ? (json['customerId'] as Map)['_id'] as String?
          : json['customerId'] as String?,
      periodId: json['periodId'] is Map
          ? (json['periodId'] as Map)['_id'] as String
          : json['periodId'] as String,
      createdDate: DateTime.parse(json['createdDate'] as String),
    );
  }

  Map<String, dynamic> toJson() => {
        '_id': id,
        'title': title,
        'clientName': clientName,
        if (clientPhone != null) 'clientPhone': clientPhone,
        if (description != null) 'description': description,
        if (amount != null) 'amount': amount,
        'status': status,
        'photos': photos,
        if (audioId != null) 'audioId': audioId,
        if (deadline != null) 'deadline': deadline!.toIso8601String(),
        if (customerId != null) 'customerId': customerId,
        'periodId': periodId,
        'createdDate': createdDate.toIso8601String(),
      };
}
