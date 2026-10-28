class AppNotification {
  final String? id;
  final String type; // 'order_deadline' | 'debt_due' | 'debt_overdue' | 'general'
  final String title;
  final String message;
  final bool read;
  final String? relatedId;
  final String? relatedType; // 'order' | 'debt'
  final DateTime createdAt;

  const AppNotification({
    this.id,
    required this.type,
    required this.title,
    required this.message,
    required this.read,
    this.relatedId,
    this.relatedType,
    required this.createdAt,
  });

  factory AppNotification.fromJson(Map<String, dynamic> json) {
    return AppNotification(
      id: json['_id'] as String?,
      type: json['type'] as String,
      title: json['title'] as String,
      message: json['message'] as String,
      read: json['read'] as bool? ?? false,
      relatedId: json['relatedId'] as String?,
      relatedType: json['relatedType'] as String?,
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'] as String)
          : DateTime.now(),
    );
  }
}
