class UserCoupon {
  final String id;
  final String userId;
  final String code;
  final String description;
  final double discountAmount;
  final bool isPercentage;
  final bool isUsed;
  final DateTime wonAt;
  final DateTime? expiresAt;
  final String source; // 'spin', 'promotion', 'admin'

  UserCoupon({
    required this.id,
    required this.userId,
    required this.code,
    required this.description,
    required this.discountAmount,
    this.isPercentage = false,
    this.isUsed = false,
    DateTime? wonAt,
    this.expiresAt,
    this.source = 'spin',
  }) : wonAt = wonAt ?? DateTime.now();

  bool get isExpired =>
      expiresAt != null && DateTime.now().isAfter(expiresAt!);
  bool get isValid => !isUsed && !isExpired;

  UserCoupon copyWith({
    String? id,
    String? userId,
    String? code,
    String? description,
    double? discountAmount,
    bool? isPercentage,
    bool? isUsed,
    DateTime? wonAt,
    DateTime? expiresAt,
    String? source,
  }) => UserCoupon(
    id: id ?? this.id,
    userId: userId ?? this.userId,
    code: code ?? this.code,
    description: description ?? this.description,
    discountAmount: discountAmount ?? this.discountAmount,
    isPercentage: isPercentage ?? this.isPercentage,
    isUsed: isUsed ?? this.isUsed,
    wonAt: wonAt ?? this.wonAt,
    expiresAt: expiresAt ?? this.expiresAt,
    source: source ?? this.source,
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'userId': userId,
    'code': code,
    'description': description,
    'discountAmount': discountAmount,
    'isPercentage': isPercentage,
    'isUsed': isUsed,
    'wonAt': wonAt.toIso8601String(),
    'expiresAt': expiresAt?.toIso8601String(),
    'source': source,
  };

  factory UserCoupon.fromJson(Map<String, dynamic> json) => UserCoupon(
    id: json['id'],
    userId: json['userId'],
    code: json['code'],
    description: json['description'],
    discountAmount: (json['discountAmount'] as num).toDouble(),
    isPercentage: json['isPercentage'] ?? false,
    isUsed: json['isUsed'] ?? false,
    wonAt: DateTime.parse(json['wonAt']),
    expiresAt: json['expiresAt'] != null
        ? DateTime.parse(json['expiresAt'])
        : null,
    source: json['source'] ?? 'spin',
  );
}