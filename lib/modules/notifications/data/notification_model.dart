enum NotificationType { following, liked, commented, generic }

class NotificationModel {
  final String id;
  final String? avatar;
  final String? name;
  final String? message;
  final bool isRead;
  final String? createdAt;
  final String? target;
  final NotificationType type;

  NotificationModel({
    required this.id,
    this.avatar,
    this.name,
    this.message,
    required this.isRead,
    this.createdAt,
    this.target,
    required this.type,
  });

  factory NotificationModel.fromJson(Map<String, dynamic> json) {
    return NotificationModel(
      id: json['id']?.toString() ?? '',
      avatar: json['avatar'],
      name: json['name'],
      message: json['message'] ?? json['action'],
      isRead: json['is_read'] ?? false,
      createdAt: json['created_at'] ?? json['time'],
      target: json['target']?.toString() ?? '',
      type: _parseType(json['type']?.toString()),
    );
  }

  static NotificationType _parseType(String? typeStr) {
    if (typeStr == null) return NotificationType.generic;
    return NotificationType.values.firstWhere(
      (e) => e.name == typeStr.toLowerCase(),
      orElse: () => NotificationType.generic,
    );
  }

  // Compatibility getters for the UI
  String get action => message ?? '';
  String get time => createdAt ?? '';

  NotificationModel copyWith({
    String? id,
    String? avatar,
    String? name,
    String? message,
    bool? isRead,
    String? createdAt,
    String? target,
    NotificationType? type,
  }) {
    return NotificationModel(
      id: id ?? this.id,
      avatar: avatar ?? this.avatar,
      name: name ?? this.name,
      message: message ?? this.message,
      isRead: isRead ?? this.isRead,
      createdAt: createdAt ?? this.createdAt,
      target: target ?? this.target,
      type: type ?? this.type,
    );
  }
}
