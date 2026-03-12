import 'package:flutter/material.dart';
import '../models/cart_model.dart';
import '../models/product_model.dart';
import '../services/user_storage_service.dart';

class CartProvider extends ChangeNotifier {
  List<CartItem> _cartItems = [];
  bool _isLoading = false;
  String? _appliedCouponCode;
  double _couponDiscount = 0.0;
  String? _currentUserId;

  List<CartItem> get cartItems => _cartItems;
  bool get isLoading => _isLoading;
  String? get appliedCouponCode => _appliedCouponCode;
  double get couponDiscount => _couponDiscount;

  int get itemCount => _cartItems.fold(0, (s, i) => s + i.quantity);
  int get uniqueItemCount => _cartItems.length;

  double get subtotal =>
      _cartItems.fold(0.0, (s, i) => s + (i.product.price * i.quantity));

  double get discount {
    double productDiscounts = _cartItems.fold(0.0, (s, i) {
      if (i.product.discountPrice != null) {
        return s + ((i.product.price - i.product.discountPrice!) * i.quantity);
      }
      return s;
    });
    return productDiscounts + _couponDiscount;
  }

  double get tax => (subtotal - discount) * 0.10;
  double get shipping => (subtotal - discount) >= 100 ? 0.0 : 9.99;
  double get total => subtotal - discount + tax + shipping;

  // ── Load cart for a specific user ──
  Future<void> loadForUser(String userId) async {
    _currentUserId = userId;
    _isLoading = true;
    notifyListeners();
    _cartItems = UserStorageService.loadCart(userId);
    _appliedCouponCode = null;
    _couponDiscount = 0.0;
    _isLoading = false;
    notifyListeners();
  }

  // ── Clear cart from memory when user logs out ──
  void clearForLogout() {
    _cartItems = [];
    _appliedCouponCode = null;
    _couponDiscount = 0.0;
    _currentUserId = null;
    notifyListeners();
  }

  Future<void> _persist() async {
    if (_currentUserId == null) return;
    await UserStorageService.saveCart(_currentUserId!, _cartItems);
  }

  Future<void> addToCart(ProductModel product, {int quantity = 1}) async {
    final idx = _cartItems.indexWhere((i) => i.product.id == product.id);
    if (idx >= 0) {
      _cartItems[idx] = _cartItems[idx].copyWith(
          quantity: _cartItems[idx].quantity + quantity);
    } else {
      _cartItems.add(CartItem(
          product: product, quantity: quantity, addedAt: DateTime.now()));
    }
    await _persist();
    notifyListeners();
  }

  Future<void> updateQuantity(String productId, int newQuantity) async {
    if (newQuantity <= 0) {
      await removeFromCart(productId);
      return;
    }
    final idx = _cartItems.indexWhere((i) => i.product.id == productId);
    if (idx >= 0) {
      _cartItems[idx] = _cartItems[idx].copyWith(quantity: newQuantity);
      await _persist();
      notifyListeners();
    }
  }

  Future<void> removeFromCart(String productId) async {
    _cartItems.removeWhere((i) => i.product.id == productId);
    await _persist();
    notifyListeners();
  }

  Future<void> clearCart() async {
    _cartItems.clear();
    _appliedCouponCode = null;
    _couponDiscount = 0.0;
    if (_currentUserId != null) {
      await UserStorageService.clearCart(_currentUserId!);
    }
    notifyListeners();
  }

  bool applyCoupon(String couponCode) {
    final validCoupons = {
      'SAVE10': 10.0,
      'SAVE20': 20.0,
      'GAMER15': 15.0,
      'WELCOME5': 5.0,
      'FREESHIP': 9.99,
    };
    final code = couponCode.toUpperCase();
    if (validCoupons.containsKey(code)) {
      _appliedCouponCode = code;
      _couponDiscount = validCoupons[code]!;
      if (_couponDiscount > subtotal) _couponDiscount = subtotal;
      notifyListeners();
      return true;
    }
    return false;
  }

  void removeCoupon() {
    _appliedCouponCode = null;
    _couponDiscount = 0.0;
    notifyListeners();
  }

  bool isInCart(String productId) =>
      _cartItems.any((i) => i.product.id == productId);

  int getQuantity(String productId) {
    final idx = _cartItems.indexWhere((i) => i.product.id == productId);
    return idx >= 0 ? _cartItems[idx].quantity : 0;
  }
}