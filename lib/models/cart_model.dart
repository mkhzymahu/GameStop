import 'product_model.dart';

class CartItem {
  final String id;
  final ProductModel product;
  final int quantity;
  final double? selectedPrice;
  final DateTime? addedAt;

  CartItem({
    required this.product,
    required this.quantity,
    this.selectedPrice,
    this.addedAt,
    String? id,
  }) : id = id ?? product.id;

  double get totalPrice {
    final price = selectedPrice ?? product.finalPrice;
    return price * quantity;
  }

  CartItem copyWith({
    String? id,
    ProductModel? product,
    int? quantity,
    double? selectedPrice,
    DateTime? addedAt,
  }) {
    return CartItem(
      id: id ?? this.id,
      product: product ?? this.product,
      quantity: quantity ?? this.quantity,
      selectedPrice: selectedPrice ?? this.selectedPrice,
      addedAt: addedAt ?? this.addedAt,
    );
  }
}
