import 'package:flutter/material.dart';
import '../models/coupon_model.dart';
import '../models/order_model.dart';
import '../models/payment_method_model.dart';
import '../models/support_ticket_model.dart';
import '../services/user_storage_service.dart';

class UserDataProvider extends ChangeNotifier {
  List<UserCoupon> _coupons = [];
  List<OrderModel> _orders = [];
  List<PaymentMethod> _paymentMethods = [];
  List<SupportTicket> _tickets = [];
  String? _userId;

  List<UserCoupon> get coupons => _coupons;
  List<UserCoupon> get validCoupons => _coupons.where((c) => c.isValid).toList();
  List<OrderModel> get orders => _orders;
  List<PaymentMethod> get paymentMethods => _paymentMethods;
  PaymentMethod? get defaultPayment =>
      _paymentMethods.where((m) => m.isDefault).firstOrNull ??
      _paymentMethods.firstOrNull;
  List<SupportTicket> get tickets => _tickets;

  Future<void> loadForUser(String userId) async {
    _userId = userId;
    _coupons = UserStorageService.loadCoupons(userId);
    _orders = UserStorageService.loadOrders(userId);
    _paymentMethods = UserStorageService.loadPaymentMethods(userId);
    _tickets = UserStorageService.loadTickets(userId);
    notifyListeners();
  }

  void clearForLogout() {
    _coupons = [];
    _orders = [];
    _paymentMethods = [];
    _tickets = [];
    _userId = null;
    notifyListeners();
  }

  // ────────────────────────────────────────────────────
  // COUPONS
  // ────────────────────────────────────────────────────

  Future<void> addCoupon(UserCoupon coupon) async {
    if (_userId == null) return;
    _coupons.insert(0, coupon);
    await UserStorageService.saveCoupons(_userId!, _coupons);
    notifyListeners();
  }

  Future<void> markCouponUsed(String couponId) async {
    if (_userId == null) return;
    _coupons = _coupons
        .map((c) => c.id == couponId ? c.copyWith(isUsed: true) : c)
        .toList();
    await UserStorageService.saveCoupons(_userId!, _coupons);
    notifyListeners();
  }

  // ────────────────────────────────────────────────────
  // ORDERS
  // ────────────────────────────────────────────────────

  Future<void> addOrder(OrderModel order) async {
    if (_userId == null) return;
    _orders.insert(0, order);
    await UserStorageService.saveOrders(_userId!, _orders);
    notifyListeners();
  }

  Future<void> updateOrderStatus(String orderId, OrderStatus status,
      {String? trackingNumber, String? adminNote}) async {
    if (_userId == null) return;
    _orders = _orders.map((o) {
      if (o.id == orderId) {
        return o.copyWith(
          status: status,
          trackingNumber: trackingNumber,
          adminNote: adminNote,
          updatedAt: DateTime.now(),
        );
      }
      return o;
    }).toList();
    await UserStorageService.saveOrders(_userId!, _orders);
    notifyListeners();
  }

  // ────────────────────────────────────────────────────
  // PAYMENT METHODS
  // ────────────────────────────────────────────────────

  Future<void> addPaymentMethod(PaymentMethod method) async {
    if (_userId == null) return;
    // If first card, make it default
    if (_paymentMethods.isEmpty) {
      method = method.copyWith(isDefault: true);
    }
    _paymentMethods.add(method);
    await UserStorageService.savePaymentMethods(_userId!, _paymentMethods);
    notifyListeners();
  }

  Future<void> removePaymentMethod(String methodId) async {
    if (_userId == null) return;
    _paymentMethods.removeWhere((m) => m.id == methodId);
    await UserStorageService.savePaymentMethods(_userId!, _paymentMethods);
    notifyListeners();
  }

  Future<void> setDefaultPayment(String methodId) async {
    if (_userId == null) return;
    _paymentMethods = _paymentMethods
        .map((m) => m.copyWith(isDefault: m.id == methodId))
        .toList();
    await UserStorageService.savePaymentMethods(_userId!, _paymentMethods);
    notifyListeners();
  }

  // ────────────────────────────────────────────────────
  // SUPPORT TICKETS
  // ────────────────────────────────────────────────────

  Future<SupportTicket> createTicket({
    required String userId,
    required String userName,
    required String subject,
    required String category,
    required String firstMessage,
    String? relatedOrderId,
  }) async {
    final ticket = SupportTicket(
      id: 'ticket_${DateTime.now().millisecondsSinceEpoch}',
      userId: userId,
      userName: userName,
      subject: subject,
      category: category,
      relatedOrderId: relatedOrderId,
      messages: [
        TicketMessage(
          id: 'msg_${DateTime.now().millisecondsSinceEpoch}',
          senderId: userId,
          senderName: userName,
          isAdmin: false,
          message: firstMessage,
        ),
      ],
    );
    _tickets.insert(0, ticket);
    if (_userId != null) {
      await UserStorageService.saveTickets(_userId!, _tickets);
    }
    notifyListeners();
    return ticket;
  }

  Future<void> addMessageToTicket(
      String ticketId, TicketMessage message) async {
    if (_userId == null) return;
    _tickets = _tickets.map((t) {
      if (t.id == ticketId) {
        return t.copyWith(messages: [...t.messages, message]);
      }
      return t;
    }).toList();
    await UserStorageService.saveTickets(_userId!, _tickets);
    notifyListeners();
  }
}