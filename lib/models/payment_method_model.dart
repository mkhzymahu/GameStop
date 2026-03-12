enum PaymentType { card, paypal, applePay, googlePay }

class PaymentMethod {
  final String id;
  final String userId;
  final PaymentType type;
  final String displayName;
  final String? last4;
  final String? expiryMonth;
  final String? expiryYear;
  final String? cardBrand;
  final bool isDefault;
  final DateTime addedAt;

  PaymentMethod({
    required this.id,
    required this.userId,
    required this.type,
    required this.displayName,
    this.last4,
    this.expiryMonth,
    this.expiryYear,
    this.cardBrand,
    this.isDefault = false,
    DateTime? addedAt,
  }) : addedAt = addedAt ?? DateTime.now();

  String get maskedDisplay => last4 != null ? '•••• •••• •••• $last4' : displayName;

  PaymentMethod copyWith({
    String? id,
    String? userId,
    PaymentType? type,
    String? displayName,
    String? last4,
    String? expiryMonth,
    String? expiryYear,
    String? cardBrand,
    bool? isDefault,
    DateTime? addedAt,
  }) => PaymentMethod(
    id: id ?? this.id,
    userId: userId ?? this.userId,
    type: type ?? this.type,
    displayName: displayName ?? this.displayName,
    last4: last4 ?? this.last4,
    expiryMonth: expiryMonth ?? this.expiryMonth,
    expiryYear: expiryYear ?? this.expiryYear,
    cardBrand: cardBrand ?? this.cardBrand,
    isDefault: isDefault ?? this.isDefault,
    addedAt: addedAt ?? this.addedAt,
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'userId': userId,
    'type': type.name,
    'displayName': displayName,
    'last4': last4,
    'expiryMonth': expiryMonth,
    'expiryYear': expiryYear,
    'cardBrand': cardBrand,
    'isDefault': isDefault,
    'addedAt': addedAt.toIso8601String(),
  };

  factory PaymentMethod.fromJson(Map<String, dynamic> json) => PaymentMethod(
    id: json['id'],
    userId: json['userId'],
    type: PaymentType.values.firstWhere(
      (t) => t.name == json['type'],
      orElse: () => PaymentType.card,
    ),
    displayName: json['displayName'],
    last4: json['last4'],
    expiryMonth: json['expiryMonth'],
    expiryYear: json['expiryYear'],
    cardBrand: json['cardBrand'],
    isDefault: json['isDefault'] ?? false,
    addedAt: DateTime.parse(json['addedAt']),
  );
}