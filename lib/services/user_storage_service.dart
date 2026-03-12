// lib/services/user_storage_service.dart

import 'dart:convert';
import 'package:hive_flutter/hive_flutter.dart';
import '../models/user_model.dart';
import '../models/notification_model.dart';
import '../models/coupon_model.dart';
import '../models/payment_method_model.dart';
import '../models/order_model.dart';
import '../models/support_ticket_model.dart';
import '../models/cart_model.dart';
import '../models/product_model.dart';

class UserStorageService {
  static const String _usersBox = 'users_v1';
  static const String _sessionBox = 'session_v1';

  static String _cartKey(String uid) => 'cart_$uid';
  static String _couponsKey(String uid) => 'coupons_$uid';
  static String _ordersKey(String uid) => 'orders_$uid';
  static String _notificationsKey(String uid) => 'notifs_$uid';
  static String _paymentMethodsKey(String uid) => 'payments_$uid';
  static String _ticketsKey(String uid) => 'tickets_$uid';
  static String _spinKey(String uid) => 'spin_$uid';

  static Future<void> init() async {
    await Hive.openBox(_usersBox);
    await Hive.openBox(_sessionBox);
  }

  // ────────────────────────────────────────────────────
  // SESSION
  // ────────────────────────────────────────────────────

  static Future<void> saveSession(String userId) async {
    final box = Hive.box(_sessionBox);
    await box.put('currentUserId', userId);
  }

  static Future<void> clearSession() async {
    final box = Hive.box(_sessionBox);
    await box.delete('currentUserId');
  }

  static String? getSessionUserId() {
    final box = Hive.box(_sessionBox);
    return box.get('currentUserId') as String?;
  }

  // ────────────────────────────────────────────────────
  // USERS
  // ────────────────────────────────────────────────────

  static Future<void> saveUser(UserModel user) async {
    final box = Hive.box(_usersBox);
    await box.put(user.id, jsonEncode(user.toJson()));
  }

  static UserModel? getUserById(String id) {
    final box = Hive.box(_usersBox);
    final raw = box.get(id) as String?;
    if (raw == null) return null;
    return UserModel.fromJson(jsonDecode(raw));
  }

  static UserModel? getUserByEmail(String email) {
    final box = Hive.box(_usersBox);
    for (final key in box.keys) {
      final keyStr = key.toString();
      // Skip non-user keys
      if (keyStr.startsWith('pwd_') ||
          keyStr.startsWith('cart_') ||
          keyStr.startsWith('coupons_') ||
          keyStr.startsWith('orders_') ||
          keyStr.startsWith('notifs_') ||
          keyStr.startsWith('payments_') ||
          keyStr.startsWith('tickets_') ||
          keyStr.startsWith('spin_') ||
          keyStr.startsWith('seller_') ||
          keyStr.startsWith('wishlist_')) continue;

      final raw = box.get(key) as String?;
      if (raw == null) continue;
      try {
        final user = UserModel.fromJson(jsonDecode(raw));
        if (user.email.toLowerCase() == email.toLowerCase()) return user;
      } catch (_) {
        continue;
      }
    }
    return null;
  }

  static Future<void> saveUserPassword(String userId, String password) async {
    final box = Hive.box(_usersBox);
    await box.put('pwd_$userId', _simpleHash(password));
  }

  static bool verifyPassword(String userId, String password) {
    final box = Hive.box(_usersBox);
    final stored = box.get('pwd_$userId') as String?;
    return stored == _simpleHash(password);
  }

  static String _simpleHash(String input) {
    var hash = 0;
    for (var i = 0; i < input.length; i++) {
      hash = ((hash << 5) - hash) + input.codeUnitAt(i);
      hash = hash & 0xFFFFFFFF;
    }
    return hash.toRadixString(16);
  }

  static List<UserModel> getAllUsers() {
    final box = Hive.box(_usersBox);
    final users = <UserModel>[];
    for (final key in box.keys) {
      final keyStr = key.toString();
      // Only try to parse entries that look like user IDs
      if (keyStr.startsWith('pwd_') ||
          keyStr.startsWith('cart_') ||
          keyStr.startsWith('coupons_') ||
          keyStr.startsWith('orders_') ||
          keyStr.startsWith('notifs_') ||
          keyStr.startsWith('payments_') ||
          keyStr.startsWith('tickets_') ||
          keyStr.startsWith('spin_') ||
          keyStr.startsWith('seller_') ||
          keyStr.startsWith('wishlist_')) continue;

      final raw = box.get(key) as String?;
      if (raw == null) continue;
      try {
        users.add(UserModel.fromJson(jsonDecode(raw)));
      } catch (_) {}
    }
    return users;
  }

  // ────────────────────────────────────────────────────
  // CART
  // ────────────────────────────────────────────────────

  static Future<void> saveCart(String userId, List<CartItem> items) async {
    final box = Hive.box(_usersBox);
    final data = items.map((item) => {
      'productId': item.product.id,
      'productName': item.product.name,
      'productBrand': item.product.brand,
      'productPrice': item.product.price,
      'productDiscountPrice': item.product.discountPrice,
      'productImage': item.product.image,
      'productRating': item.product.rating,
      'productCategoryId': item.product.categoryId,
      'productDescription': item.product.description,
      'productInStock': item.product.inStock,
      'quantity': item.quantity,
      'addedAt': item.addedAt?.toIso8601String(),
    }).toList();
    await box.put(_cartKey(userId), jsonEncode(data));
  }

  static List<CartItem> loadCart(String userId) {
    final box = Hive.box(_usersBox);
    final raw = box.get(_cartKey(userId)) as String?;
    if (raw == null) return [];
    try {
      final list = jsonDecode(raw) as List;
      return list.map((item) {
        final product = ProductModel(
          id: item['productId'],
          name: item['productName'],
          brand: item['productBrand'],
          price: (item['productPrice'] as num).toDouble(),
          discountPrice: item['productDiscountPrice'] != null
              ? (item['productDiscountPrice'] as num).toDouble()
              : null,
          image: item['productImage'],
          rating: (item['productRating'] as num).toDouble(),
          categoryId: item['productCategoryId'] ?? '',
          description: item['productDescription'] ?? '',
          inStock: item['productInStock'],
        );
        return CartItem(
          product: product,
          quantity: item['quantity'],
          addedAt: item['addedAt'] != null
              ? DateTime.parse(item['addedAt'])
              : null,
        );
      }).toList();
    } catch (_) {
      return [];
    }
  }

  static Future<void> clearCart(String userId) async {
    final box = Hive.box(_usersBox);
    await box.delete(_cartKey(userId));
  }

  // ────────────────────────────────────────────────────
  // COUPONS
  // ────────────────────────────────────────────────────

  static Future<void> saveCoupons(
      String userId, List<UserCoupon> coupons) async {
    final box = Hive.box(_usersBox);
    await box.put(_couponsKey(userId),
        jsonEncode(coupons.map((c) => c.toJson()).toList()));
  }

  static List<UserCoupon> loadCoupons(String userId) {
    final box = Hive.box(_usersBox);
    final raw = box.get(_couponsKey(userId)) as String?;
    if (raw == null) return [];
    try {
      return (jsonDecode(raw) as List)
          .map((c) => UserCoupon.fromJson(Map<String, dynamic>.from(c)))
          .toList();
    } catch (_) {
      return [];
    }
  }

  // ────────────────────────────────────────────────────
  // ORDERS
  // ────────────────────────────────────────────────────

  static Future<void> saveOrders(
      String userId, List<OrderModel> orders) async {
    final box = Hive.box(_usersBox);
    await box.put(
        _ordersKey(userId),
        jsonEncode(orders.map((o) => o.toJson()).toList()));
  }

  static List<OrderModel> loadOrders(String userId) {
    final box = Hive.box(_usersBox);
    final raw = box.get(_ordersKey(userId)) as String?;
    if (raw == null) return [];
    try {
      return (jsonDecode(raw) as List)
          .map((o) => OrderModel.fromJson(Map<String, dynamic>.from(o)))
          .toList();
    } catch (_) {
      return [];
    }
  }

  // ────────────────────────────────────────────────────
  // NOTIFICATIONS
  // ────────────────────────────────────────────────────

  static Future<void> saveNotifications(
      String userId, List<AppNotification> notifs) async {
    final box = Hive.box(_usersBox);
    await box.put(_notificationsKey(userId),
        jsonEncode(notifs.map((n) => n.toJson()).toList()));
  }

  static List<AppNotification> loadNotifications(String userId) {
    final box = Hive.box(_usersBox);
    final raw = box.get(_notificationsKey(userId)) as String?;
    if (raw == null) return [];
    try {
      return (jsonDecode(raw) as List)
          .map((n) => AppNotification.fromJson(Map<String, dynamic>.from(n)))
          .toList()
        ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
    } catch (_) {
      return [];
    }
  }

  // ────────────────────────────────────────────────────
  // PAYMENT METHODS
  // ────────────────────────────────────────────────────

  static Future<void> savePaymentMethods(
      String userId, List<PaymentMethod> methods) async {
    final box = Hive.box(_usersBox);
    await box.put(_paymentMethodsKey(userId),
        jsonEncode(methods.map((m) => m.toJson()).toList()));
  }

  static List<PaymentMethod> loadPaymentMethods(String userId) {
    final box = Hive.box(_usersBox);
    final raw = box.get(_paymentMethodsKey(userId)) as String?;
    if (raw == null) return [];
    try {
      return (jsonDecode(raw) as List)
          .map((m) => PaymentMethod.fromJson(Map<String, dynamic>.from(m)))
          .toList();
    } catch (_) {
      return [];
    }
  }

  // ────────────────────────────────────────────────────
  // SUPPORT TICKETS
  // ────────────────────────────────────────────────────

  static Future<void> saveTickets(
      String userId, List<SupportTicket> tickets) async {
    final box = Hive.box(_usersBox);
    await box.put(_ticketsKey(userId),
        jsonEncode(tickets.map((t) => t.toJson()).toList()));
  }

  static List<SupportTicket> loadTickets(String userId) {
    final box = Hive.box(_usersBox);
    final raw = box.get(_ticketsKey(userId)) as String?;
    if (raw == null) return [];
    try {
      return (jsonDecode(raw) as List)
          .map((t) => SupportTicket.fromJson(Map<String, dynamic>.from(t)))
          .toList();
    } catch (_) {
      return [];
    }
  }

  static List<SupportTicket> loadAllTickets() {
    final box = Hive.box(_usersBox);
    final allTickets = <SupportTicket>[];
    for (final key in box.keys) {
      if (!key.toString().startsWith('tickets_')) continue;
      final raw = box.get(key) as String?;
      if (raw == null) continue;
      try {
        final tickets = (jsonDecode(raw) as List)
            .map((t) =>
                SupportTicket.fromJson(Map<String, dynamic>.from(t)))
            .toList();
        allTickets.addAll(tickets);
      } catch (_) {}
    }
    allTickets.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return allTickets;
  }

  // ────────────────────────────────────────────────────
  // DAILY SPIN
  // ────────────────────────────────────────────────────

  static Future<void> recordSpin(String userId) async {
    final box = Hive.box(_usersBox);
    await box.put(_spinKey(userId), DateTime.now().toIso8601String());
  }

  static bool hasSpunToday(String userId) {
    final box = Hive.box(_usersBox);
    final raw = box.get(_spinKey(userId)) as String?;
    if (raw == null) return false;
    final lastSpin = DateTime.parse(raw);
    final now = DateTime.now();
    return lastSpin.year == now.year &&
        lastSpin.month == now.month &&
        lastSpin.day == now.day;
  }

  // ────────────────────────────────────────────────────
  // RAW ACCESS
  // Synchronous — the box is always open after init().
  // Used by SellerProvider and ProductProvider for seller data.
  // ────────────────────────────────────────────────────

  static Future<void> saveRaw(String key, String value) async {
    final box = Hive.box(_usersBox);
    await box.put(key, value);
  }

  /// Synchronous read — returns immediately since box is open.
  static String? loadRaw(String key) {
    final box = Hive.box(_usersBox);
    return box.get(key) as String?;
  }

  static Future<void> deleteRaw(String key) async {
    final box = Hive.box(_usersBox);
    await box.delete(key);
  }
}
