class Customer {
  final String id;
  final String name;
  final String? phone;
  final String? notes;
  final int? orderCount;
  final int? debtCount;

  const Customer({
    required this.id,
    required this.name,
    this.phone,
    this.notes,
    this.orderCount,
    this.debtCount,
  });

  factory Customer.fromJson(Map<String, dynamic> json) {
    return Customer(
      id: json['_id'] as String,
      name: json['name'] as String,
      phone: json['phone'] as String?,
      notes: json['notes'] as String?,
      orderCount: json['orderCount'] as int?,
      debtCount: json['debtCount'] as int?,
    );
  }

  Map<String, dynamic> toJson() => {
        '_id': id,
        'name': name,
        if (phone != null) 'phone': phone,
        if (notes != null) 'notes': notes,
      };
}
