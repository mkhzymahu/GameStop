import 'package:flutter/material.dart';

class OrderProvider extends ChangeNotifier {
  final List<Order> _orders = [];
  bool _isLoading = false;
  String? _errorMessage;

  List<Order> get orders => _orders;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  OrderProvider() {
    // Load mock orders or from storage
  }

  void placeOrder(Order order) {
    _orders.add(order);
    notifyListeners();
  }

  void cancelOrder(String orderId) {
    _orders.removeWhere((order) => order.id == orderId);
    notifyListeners();
  }

  Order? getOrderById(String orderId) {
    try {
      return _orders.firstWhere((order) => order.id == orderId);
    } catch (e) {
      return null;
    }
  }

  List<Order> getUserOrders(String userId) {
    return _orders.where((order) => order.userId == userId).toList();
  }

  double getTotalOrderAmount() {
    return _orders.fold(0, (sum, order) => sum + order.totalAmount);
  }
}

class Order {
  final String id;
  final String userId;
  final DateTime orderDate;
  final DateTime? deliveryDate;
  final List<OrderItem> items;
  final double totalAmount;
  final double tax;
  final double shippingCost;
  final double discount;
  final String status;
  final String shippingAddress;
  final String? trackingNumber;
  final String paymentMethod;

  Order({
    required this.id,
    required this.userId,
    required this.orderDate,
    this.deliveryDate,
    required this.items,
    required this.totalAmount,
    required this.tax,
    required this.shippingCost,
    this.discount = 0,
    required this.status,
    required this.shippingAddress,
    this.trackingNumber,
    required this.paymentMethod,
  });
}

class OrderItem {
  final String productId;
  final String productName;
  final double price;
  final int quantity;
  final String? image;

  OrderItem({
    required this.productId,
    required this.productName,
    required this.price,
    required this.quantity,
    this.image,
  });

  double get totalPrice => price * quantity;
}