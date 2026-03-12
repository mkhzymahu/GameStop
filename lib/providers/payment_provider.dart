import 'package:flutter/material.dart';
import '../models/payment_model.dart';

class PaymentProvider extends ChangeNotifier {
  List<PaymentMethod> _savedPaymentMethods = [];
  PaymentMethod? _defaultPaymentMethod;
  
  bool _isLoading = false;
  bool _isProcessing = false;
  String? _errorMessage;
  String? _transactionId;

  // Getters
  List<PaymentMethod> get savedPaymentMethods => _savedPaymentMethods;
  PaymentMethod? get defaultPaymentMethod => _defaultPaymentMethod;
  bool get isLoading => _isLoading;
  bool get isProcessing => _isProcessing;
  String? get errorMessage => _errorMessage;
  String? get transactionId => _transactionId;

  PaymentProvider() {
    loadMockPaymentMethods();
  }

  void loadMockPaymentMethods() {
    _savedPaymentMethods = [
      PaymentMethod(
        id: 'pm1',
        type: PaymentType.creditCard,
        cardNumber: '**** **** **** 4242',
        cardHolderName: 'John Doe',
        expiryDate: '12/25',
        cardBrand: 'Visa',
        isDefault: true,
      ),
      PaymentMethod(
        id: 'pm2',
        type: PaymentType.creditCard,
        cardNumber: '**** **** **** 8888',
        cardHolderName: 'John Doe',
        expiryDate: '09/24',
        cardBrand: 'Mastercard',
        isDefault: false,
      ),
      PaymentMethod(
        id: 'pm3',
        type: PaymentType.paypal,
        email: 'john.doe@example.com',
        isDefault: false,
      ),
    ];

    _defaultPaymentMethod = _savedPaymentMethods.firstWhere(
      (pm) => pm.isDefault,
      orElse: () => _savedPaymentMethods.first,
    );

    notifyListeners();
  }

  Future<bool> addCreditCard({
    required String cardNumber,
    required String cardHolderName,
    required String expiryDate,
    required String cvv,
    required String cardBrand,
    bool setAsDefault = false,
  }) async {
    _isLoading = true;
    notifyListeners();

    try {
      // Simulate API call
      await Future.delayed(const Duration(seconds: 2));

      // Validate card (simplified)
      if (cardNumber.length < 16) {
        throw Exception('Invalid card number');
      }

      // Create masked card number
      String maskedNumber = '**** **** **** ${cardNumber.substring(cardNumber.length - 4)}';

      final newMethod = PaymentMethod(
        id: 'pm${DateTime.now().millisecondsSinceEpoch}',
        type: PaymentType.creditCard,
        cardNumber: maskedNumber,
        cardHolderName: cardHolderName,
        expiryDate: expiryDate,
        cardBrand: cardBrand,
        isDefault: setAsDefault,
      );

      if (setAsDefault) {
        // Remove default from others
        _savedPaymentMethods = _savedPaymentMethods
            .map((method) => method.copyWith(isDefault: false))
            .toList();
        _defaultPaymentMethod = newMethod;
      }

      _savedPaymentMethods.add(newMethod);

      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> addPayPal({required String email, bool setAsDefault = false}) async {
    _isLoading = true;
    notifyListeners();

    try {
      // Simulate API call
      await Future.delayed(const Duration(seconds: 1));

      final newMethod = PaymentMethod(
        id: 'pm${DateTime.now().millisecondsSinceEpoch}',
        type: PaymentType.paypal,
        email: email,
        isDefault: setAsDefault,
      );

      if (setAsDefault) {
        // Remove default from others
        _savedPaymentMethods = _savedPaymentMethods
            .map((method) => method.copyWith(isDefault: false))
            .toList();
        _defaultPaymentMethod = newMethod;
      }

      _savedPaymentMethods.add(newMethod);

      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> processPayment({
    required double amount,
    required String paymentMethodId,
    Map<String, dynamic>? paymentDetails,
  }) async {
    _isProcessing = true;
    notifyListeners();

    try {
      // Simulate payment processing
      await Future.delayed(const Duration(seconds: 3));

      // Generate transaction ID
      _transactionId = 'TXN${DateTime.now().millisecondsSinceEpoch}';

      // Log payment
      print('Payment processed: $amount, Transaction ID: $_transactionId');

      _isProcessing = false;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = 'Payment failed: ${e.toString()}';
      _isProcessing = false;
      notifyListeners();
      return false;
    }
  }

  Future<void> setDefaultPaymentMethod(String methodId) async {
    _savedPaymentMethods = _savedPaymentMethods
        .map((method) => method.copyWith(isDefault: method.id == methodId))
        .toList();
    
    _defaultPaymentMethod = _savedPaymentMethods.firstWhere(
      (method) => method.id == methodId,
      orElse: () => _savedPaymentMethods.first,
    );
    notifyListeners();
  }

  Future<void> removePaymentMethod(String methodId) async {
    _savedPaymentMethods.removeWhere((method) => method.id == methodId);
    
    // Update default if removed
    if (_defaultPaymentMethod?.id == methodId) {
      _defaultPaymentMethod = _savedPaymentMethods.isNotEmpty ? _savedPaymentMethods.first : null;
    }
    
    notifyListeners();
  }

  PaymentMethod? getPaymentMethod(String methodId) {
    try {
      return _savedPaymentMethods.firstWhere((method) => method.id == methodId);
    } catch (e) {
      return null;
    }
  }

  String getPaymentMethodIcon(PaymentType type, {String? cardBrand}) {
    switch (type) {
      case PaymentType.creditCard:
        if (cardBrand != null) {
          switch (cardBrand.toLowerCase()) {
            case 'visa':
              return 'assets/icons/visa.png';
            case 'mastercard':
              return 'assets/icons/mastercard.png';
            case 'amex':
              return 'assets/icons/amex.png';
            default:
              return 'assets/icons/credit_card.png';
          }
        }
        return 'assets/icons/credit_card.png';
      case PaymentType.paypal:
        return 'assets/icons/paypal.png';
      case PaymentType.applePay:
        return 'assets/icons/apple_pay.png';
      case PaymentType.googlePay:
        return 'assets/icons/google_pay.png';
      default:
        return 'assets/icons/payment.png';
    }
  }
}