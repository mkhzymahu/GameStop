enum TicketStatus { open, inProgress, resolved, closed }
enum TicketPriority { low, medium, high, urgent }

class TicketMessage {
  final String id;
  final String senderId;
  final String senderName;
  final bool isAdmin;
  final String message;
  final DateTime sentAt;

  TicketMessage({
    required this.id,
    required this.senderId,
    required this.senderName,
    required this.isAdmin,
    required this.message,
    DateTime? sentAt,
  }) : sentAt = sentAt ?? DateTime.now();

  Map<String, dynamic> toJson() => {
    'id': id,
    'senderId': senderId,
    'senderName': senderName,
    'isAdmin': isAdmin,
    'message': message,
    'sentAt': sentAt.toIso8601String(),
  };

  factory TicketMessage.fromJson(Map<String, dynamic> json) => TicketMessage(
    id: json['id'],
    senderId: json['senderId'],
    senderName: json['senderName'],
    isAdmin: json['isAdmin'] ?? false,
    message: json['message'],
    sentAt: DateTime.parse(json['sentAt']),
  );
}

class SupportTicket {
  final String id;
  final String userId;
  final String userName;
  final String subject;
  final String category;
  final TicketStatus status;
  final TicketPriority priority;
  final List<TicketMessage> messages;
  final DateTime createdAt;
  final DateTime? resolvedAt;
  final String? assignedAdminId;
  final String? relatedOrderId;

  SupportTicket({
    required this.id,
    required this.userId,
    required this.userName,
    required this.subject,
    required this.category,
    this.status = TicketStatus.open,
    this.priority = TicketPriority.medium,
    List<TicketMessage>? messages,
    DateTime? createdAt,
    this.resolvedAt,
    this.assignedAdminId,
    this.relatedOrderId,
  }) : messages = messages ?? [],
       createdAt = createdAt ?? DateTime.now();

  SupportTicket copyWith({
    TicketStatus? status,
    TicketPriority? priority,
    List<TicketMessage>? messages,
    DateTime? resolvedAt,
    String? assignedAdminId,
  }) => SupportTicket(
    id: id,
    userId: userId,
    userName: userName,
    subject: subject,
    category: category,
    status: status ?? this.status,
    priority: priority ?? this.priority,
    messages: messages ?? this.messages,
    createdAt: createdAt,
    resolvedAt: resolvedAt ?? this.resolvedAt,
    assignedAdminId: assignedAdminId ?? this.assignedAdminId,
    relatedOrderId: relatedOrderId,
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'userId': userId,
    'userName': userName,
    'subject': subject,
    'category': category,
    'status': status.name,
    'priority': priority.name,
    'messages': messages.map((m) => m.toJson()).toList(),
    'createdAt': createdAt.toIso8601String(),
    'resolvedAt': resolvedAt?.toIso8601String(),
    'assignedAdminId': assignedAdminId,
    'relatedOrderId': relatedOrderId,
  };

  factory SupportTicket.fromJson(Map<String, dynamic> json) => SupportTicket(
    id: json['id'],
    userId: json['userId'],
    userName: json['userName'],
    subject: json['subject'],
    category: json['category'],
    status: TicketStatus.values.firstWhere(
      (s) => s.name == json['status'],
      orElse: () => TicketStatus.open,
    ),
    priority: TicketPriority.values.firstWhere(
      (p) => p.name == json['priority'],
      orElse: () => TicketPriority.medium,
    ),
    messages: (json['messages'] as List? ?? [])
        .map((m) => TicketMessage.fromJson(Map<String, dynamic>.from(m)))
        .toList(),
    createdAt: DateTime.parse(json['createdAt']),
    resolvedAt: json['resolvedAt'] != null
        ? DateTime.parse(json['resolvedAt'])
        : null,
    assignedAdminId: json['assignedAdminId'],
    relatedOrderId: json['relatedOrderId'],
  );
}