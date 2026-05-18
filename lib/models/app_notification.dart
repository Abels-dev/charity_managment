enum NotificationTargetType {
  campaign,
  donation;

  String get value => switch (this) {
        NotificationTargetType.campaign => 'campaign',
        NotificationTargetType.donation => 'donation',
      };

  static NotificationTargetType? fromJson(String? value) {
    if (value == null) return null;
    return NotificationTargetType.values.firstWhere(
      (type) => type.value == value,
      orElse: () => NotificationTargetType.campaign,
    );
  }
}

class AppNotification {
  const AppNotification({
    required this.id,
    required this.userId,
    required this.title,
    required this.message,
    required this.isRead,
    required this.createdAt,
    this.targetType,
    this.targetId,
  });

  final String id;
  final String userId;
  final String title;
  final String message;
  final bool isRead;
  final DateTime createdAt;
  final NotificationTargetType? targetType;
  final String? targetId;

  AppNotification copyWith({
    String? id,
    String? userId,
    String? title,
    String? message,
    bool? isRead,
    DateTime? createdAt,
    NotificationTargetType? targetType,
    String? targetId,
  }) {
    return AppNotification(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      title: title ?? this.title,
      message: message ?? this.message,
      isRead: isRead ?? this.isRead,
      createdAt: createdAt ?? this.createdAt,
      targetType: targetType ?? this.targetType,
      targetId: targetId ?? this.targetId,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'title': title,
      'message': message,
      'isRead': isRead,
      'createdAt': createdAt.toIso8601String(),
      'targetType': targetType?.value,
      'targetId': targetId,
    };
  }

  factory AppNotification.fromJson(Map<String, dynamic> json) {
    return AppNotification(
      id: json['id'] as String,
      userId: json['userId'] as String,
      title: json['title'] as String,
      message: json['message'] as String,
      isRead: json['isRead'] as bool? ?? false,
      createdAt: DateTime.parse(json['createdAt'] as String),
      targetType: NotificationTargetType.fromJson(json['targetType'] as String?),
      targetId: json['targetId'] as String?,
    );
  }
}
