enum PaymentType { creditCard, debitCard, paypal, applePay, googlePay }

class PaymentMethod {
  final String id;
  final String? name;
  final PaymentType type;
  final String? cardNumber;
  final String? cardHolderName;
  final String? expiryDate;
  final String? cvv;
  final String? cardBrand;
  final String? email;
  final bool isDefault;
  final DateTime? createdAt;

  PaymentMethod({
    required this.id,
    this.name,
    required this.type,
    this.cardNumber,
    this.cardHolderName,
    this.expiryDate,
    this.cvv,
    this.cardBrand,
    this.email,
    this.isDefault = false,
    this.createdAt,
  });

  String get maskedCardNumber {
    if (cardNumber != null && cardNumber!.length >= 4) {
      return '**** **** **** ${cardNumber!.substring(cardNumber!.length - 4)}';
    }
    return cardNumber ?? 'N/A';
  }

  PaymentMethod copyWith({
    String? id,
    String? name,
    PaymentType? type,
    String? cardNumber,
    String? cardHolderName,
    String? expiryDate,
    String? cvv,
    String? cardBrand,
    String? email,
    bool? isDefault,
    DateTime? createdAt,
  }) {
    return PaymentMethod(
      id: id ?? this.id,
      name: name ?? this.name,
      type: type ?? this.type,
      cardNumber: cardNumber ?? this.cardNumber,
      cardHolderName: cardHolderName ?? this.cardHolderName,
      expiryDate: expiryDate ?? this.expiryDate,
      cvv: cvv ?? this.cvv,
      cardBrand: cardBrand ?? this.cardBrand,
      email: email ?? this.email,
      isDefault: isDefault ?? this.isDefault,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}

