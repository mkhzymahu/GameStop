import 'cart_model.dart';

enum OrderStatus {
  pending,
  confirmed,
  processing,
  shipped,
  delivered,
  cancelled,
  refunded,
}

class OrderItem {
  final String productId;
  final String productName;
  final String productBrand;
  final String? productImage;
  final int quantity;
  final double unitPrice;

  OrderItem({
    required this.productId,
    required this.productName,
    required this.productBrand,
    this.productImage,
    required this.quantity,
    required this.unitPrice,
  });

  double get totalPrice => unitPrice * quantity;

  factory OrderItem.fromCartItem(CartItem item) => OrderItem(
    productId: item.product.id,
    productName: item.product.name,
    productBrand: item.product.brand,
    productImage: item.product.image,
    quantity: item.quantity,
    unitPrice: item.product.finalPrice,
  );

  Map<String, dynamic> toJson() => {
    'productId': productId,
    'productName': productName,
    'productBrand': productBrand,
    'productImage': productImage,
    'quantity': quantity,
    'unitPrice': unitPrice,
  };

  factory OrderItem.fromJson(Map<String, dynamic> json) => OrderItem(
    productId: json['productId'],
    productName: json['productName'],
    productBrand: json['productBrand'],
    productImage: json['productImage'],
    quantity: json['quantity'],
    unitPrice: (json['unitPrice'] as num).toDouble(),
  );
}

class OrderModel {
  final String id;
  final String userId;
  final List<OrderItem> items;
  final double subtotal;
  final double discount;
  final double tax;
  final double shipping;
  final double total;
  final String? couponCode;
  final String shippingAddress;
  final String? paymentMethodId;
  final OrderStatus status;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final String? trackingNumber;
  final String? adminNote;

  OrderModel({
    required this.id,
    required this.userId,
    required this.items,
    required this.subtotal,
    required this.discount,
    required this.tax,
    required this.shipping,
    required this.total,
    this.couponCode,
    required this.shippingAddress,
    this.paymentMethodId,
    this.status = OrderStatus.pending,
    DateTime? createdAt,
    this.updatedAt,
    this.trackingNumber,
    this.adminNote,
  }) : createdAt = createdAt ?? DateTime.now();

  OrderModel copyWith({
    OrderStatus? status,
    String? trackingNumber,
    String? adminNote,
    DateTime? updatedAt,
  }) => OrderModel(
    id: id,
    userId: userId,
    items: items,
    subtotal: subtotal,
    discount: discount,
    tax: tax,
    shipping: shipping,
    total: total,
    couponCode: couponCode,
    shippingAddress: shippingAddress,
    paymentMethodId: paymentMethodId,
    status: status ?? this.status,
    createdAt: createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
    trackingNumber: trackingNumber ?? this.trackingNumber,
    adminNote: adminNote ?? this.adminNote,
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'userId': userId,
    'items': items.map((i) => i.toJson()).toList(),
    'subtotal': subtotal,
    'discount': discount,
    'tax': tax,
    'shipping': shipping,
    'total': total,
    'couponCode': couponCode,
    'shippingAddress': shippingAddress,
    'paymentMethodId': paymentMethodId,
    'status': status.name,
    'createdAt': createdAt.toIso8601String(),
    'updatedAt': updatedAt?.toIso8601String(),
    'trackingNumber': trackingNumber,
    'adminNote': adminNote,
  };

  factory OrderModel.fromJson(Map<String, dynamic> json) => OrderModel(
    id: json['id'],
    userId: json['userId'],
    items: (json['items'] as List)
        .map((i) => OrderItem.fromJson(Map<String, dynamic>.from(i)))
        .toList(),
    subtotal: (json['subtotal'] as num).toDouble(),
    discount: (json['discount'] as num).toDouble(),
    tax: (json['tax'] as num).toDouble(),
    shipping: (json['shipping'] as num).toDouble(),
    total: (json['total'] as num).toDouble(),
    couponCode: json['couponCode'],
    shippingAddress: json['shippingAddress'],
    paymentMethodId: json['paymentMethodId'],
    status: OrderStatus.values.firstWhere(
      (s) => s.name == json['status'],
      orElse: () => OrderStatus.pending,
    ),
    createdAt: DateTime.parse(json['createdAt']),
    updatedAt: json['updatedAt'] != null
        ? DateTime.parse(json['updatedAt'])
        : null,
    trackingNumber: json['trackingNumber'],
    adminNote: json['adminNote'],
  );
}