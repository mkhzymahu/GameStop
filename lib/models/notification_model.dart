enum NotificationType {
  orderUpdate,
  couponWon,
  supportReply,
  promotion,
  system,
  adminAlert,
}

class AppNotification {
  final String id;
  final String userId;
  final String title;
  final String body;
  final NotificationType type;
  final bool isRead;
  final DateTime createdAt;
  final Map<String, dynamic>? metadata;

  AppNotification({
    required this.id,
    required this.userId,
    required this.title,
    required this.body,
    required this.type,
    this.isRead = false,
    DateTime? createdAt,
    this.metadata,
  }) : createdAt = createdAt ?? DateTime.now();

  AppNotification copyWith({
    String? id,
    String? userId,
    String? title,
    String? body,
    NotificationType? type,
    bool? isRead,
    DateTime? createdAt,
    Map<String, dynamic>? metadata,
  }) => AppNotification(
    id: id ?? this.id,
    userId: userId ?? this.userId,
    title: title ?? this.title,
    body: body ?? this.body,
    type: type ?? this.type,
    isRead: isRead ?? this.isRead,
    createdAt: createdAt ?? this.createdAt,
    metadata: metadata ?? this.metadata,
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'userId': userId,
    'title': title,
    'body': body,
    'type': type.name,
    'isRead': isRead,
    'createdAt': createdAt.toIso8601String(),
    'metadata': metadata,
  };

  factory AppNotification.fromJson(Map<String, dynamic> json) =>
      AppNotification(
        id: json['id'],
        userId: json['userId'],
        title: json['title'],
        body: json['body'],
        type: NotificationType.values.firstWhere(
          (t) => t.name == json['type'],
          orElse: () => NotificationType.system,
        ),
        isRead: json['isRead'] ?? false,
        createdAt: DateTime.parse(json['createdAt']),
        metadata: json['metadata'] != null
            ? Map<String, dynamic>.from(json['metadata'])
            : null,
      );
}