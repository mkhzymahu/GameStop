import 'package:flutter/material.dart';
import '../models/order_model.dart';
import '../models/notification_model.dart';
import '../models/cart_model.dart';
import '../providers/user_data_provider.dart';
import '../providers/notification_provider.dart';

class OrderService {
  /// Generates a human-readable unique order number
  /// Format: GS-YYYYMMDD-XXXX  e.g. GS-20260228-7K3M
  static String generateOrderNumber() {
    final now = DateTime.now();
    final date =
        '${now.year}${now.month.toString().padLeft(2, '0')}${now.day.toString().padLeft(2, '0')}';
    const chars = 'ABCDEFGHJKLMNPQRSTUVWXYZ23456789';
    final rand = now.millisecondsSinceEpoch;
    final suffix = String.fromCharCodes(
      List.generate(4, (i) => chars.codeUnitAt((rand >> (i * 4)) % chars.length)),
    );
    return 'GS-$date-$suffix';
  }

  /// Places an order, saves it, fires notifications, then simulates
  /// status progression with timed delays.
  static Future<OrderModel> placeOrder({
    required BuildContext context,
    required String userId,
    required String userName,
    required List<CartItem> items,
    required double subtotal,
    required double discount,
    required double tax,
    required double shipping,
    required double total,
    required String shippingAddress,
    required String paymentMethod, // 'cod' | 'card' | 'paypal' etc.
    String? couponCode,
    String? paymentMethodId,
    required UserDataProvider userData,
    required NotificationProvider notifProvider,
  }) async {
    final orderId = generateOrderNumber();

    final order = OrderModel(
      id: orderId,
      userId: userId,
      items: items.map((i) => OrderItem.fromCartItem(i)).toList(),
      subtotal: subtotal,
      discount: discount,
      tax: tax,
      shipping: shipping,
      total: total,
      couponCode: couponCode,
      shippingAddress: shippingAddress,
      paymentMethodId: paymentMethod,
      status: OrderStatus.pending,
    );

    // Save order immediately
    await userData.addOrder(order);

    // --- Notification: Order Received ---
    await _pushNotif(
      notifProvider: notifProvider,
      userId: userId,
      title: '🛍️ Order Received — $orderId',
      body: 'Your order has been received. Total: \$${total.toStringAsFixed(2)}',
      type: NotificationType.orderUpdate,
      metadata: {'orderId': orderId},
    );

    // --- Simulate status pipeline ---
    _simulateOrderPipeline(
      orderId: orderId,
      userId: userId,
      paymentMethod: paymentMethod,
      userData: userData,
      notifProvider: notifProvider,
    );

    return order;
  }

  static Future<void> _simulateOrderPipeline({
    required String orderId,
    required String userId,
    required String paymentMethod,
    required UserDataProvider userData,
    required NotificationProvider notifProvider,
  }) async {
    // Step 1 — Confirmed (2 seconds)
    await Future.delayed(const Duration(seconds: 2));
    await userData.updateOrderStatus(orderId, OrderStatus.confirmed);
    await _pushNotif(
      notifProvider: notifProvider,
      userId: userId,
      title: '✅ Order Confirmed — $orderId',
      body: paymentMethod == 'cod'
          ? 'Your order is confirmed. Payment will be collected on delivery.'
          : 'Payment successful! Your order is confirmed.',
      type: NotificationType.orderUpdate,
      metadata: {'orderId': orderId},
    );

    // Step 2 — Processing (5 seconds)
    await Future.delayed(const Duration(seconds: 5));
    await userData.updateOrderStatus(orderId, OrderStatus.processing);
    await _pushNotif(
      notifProvider: notifProvider,
      userId: userId,
      title: '⚙️ Order Processing — $orderId',
      body: 'We\'re preparing your items for shipment.',
      type: NotificationType.orderUpdate,
      metadata: {'orderId': orderId},
    );

    // Step 3 — Shipped (10 seconds) — assign fake tracking number
    await Future.delayed(const Duration(seconds: 10));
    final tracking = 'TRK${DateTime.now().millisecondsSinceEpoch % 1000000}';
    await userData.updateOrderStatus(
      orderId,
      OrderStatus.shipped,
      trackingNumber: tracking,
    );
    await _pushNotif(
      notifProvider: notifProvider,
      userId: userId,
      title: '🚚 Order Shipped — $orderId',
      body: 'Your order is on its way! Tracking: $tracking',
      type: NotificationType.orderUpdate,
      metadata: {'orderId': orderId, 'tracking': tracking},
    );

    // Step 4 — Delivered (20 seconds)
    await Future.delayed(const Duration(seconds: 20));
    await userData.updateOrderStatus(orderId, OrderStatus.delivered);
    await _pushNotif(
      notifProvider: notifProvider,
      userId: userId,
      title: '🎉 Order Delivered — $orderId',
      body: 'Your order has been delivered. Enjoy your gear!',
      type: NotificationType.orderUpdate,
      metadata: {'orderId': orderId},
    );
  }

  static Future<void> _pushNotif({
    required NotificationProvider notifProvider,
    required String userId,
    required String title,
    required String body,
    required NotificationType type,
    Map<String, dynamic>? metadata,
  }) async {
    final notif = AppNotification(
      id: 'notif_${DateTime.now().millisecondsSinceEpoch}',
      userId: userId,
      title: title,
      body: body,
      type: type,
      metadata: metadata,
    );
    await notifProvider.addNotification(notif);
  }
}
