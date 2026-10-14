class NotificationModel {
  final String id;
  final String eventType;
  final String title;
  final String message;
  final String? relatedRequestId;
  final String? relatedEquipmentId;
  final bool isRead;
  final DateTime? createdAt;

  NotificationModel({
    required this.id,
    required this.eventType,
    required this.title,
    required this.message,
    this.relatedRequestId,
    this.relatedEquipmentId,
    this.isRead = false,
    this.createdAt,
  });

  NotificationModel copyWith({bool? isRead}) {
    return NotificationModel(
      id: id,
      eventType: eventType,
      title: title,
      message: message,
      relatedRequestId: relatedRequestId,
      relatedEquipmentId: relatedEquipmentId,
      isRead: isRead ?? this.isRead,
      createdAt: createdAt,
    );
  }

  factory NotificationModel.fromJson(Map<String, dynamic> json) {
    return NotificationModel(
      id: json['_id'] ?? json['id'] ?? '',
      eventType: json['eventType'] ?? 'system',
      title: json['title'] ?? '',
      message: json['message'] ?? '',
      relatedRequestId: json['relatedRequest'] is Map
          ? json['relatedRequest']['_id']
          : json['relatedRequest'],
      relatedEquipmentId: json['relatedEquipment'] is Map
          ? json['relatedEquipment']['_id']
          : json['relatedEquipment'],
      isRead: json['isRead'] ?? false,
      createdAt: json['createdAt'] != null ? DateTime.tryParse(json['createdAt']) : null,
    );
  }
}
