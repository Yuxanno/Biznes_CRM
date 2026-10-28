class Category {
  final String id;
  final String name;
  final String type; // 'income' | 'expense'

  const Category({
    required this.id,
    required this.name,
    required this.type,
  });

  bool get isIncome => type == 'income';

  factory Category.fromJson(Map<String, dynamic> json) {
    return Category(
      id: json['_id'] as String,
      name: json['name'] as String,
      type: json['type'] as String,
    );
  }

  Map<String, dynamic> toJson() => {
        '_id': id,
        'name': name,
        'type': type,
      };
}
