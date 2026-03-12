import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'dart:convert';
import '../models/product_model.dart';

class WishlistProvider extends ChangeNotifier {
  final List<ProductModel> _items = [];
  String? _currentUserId;

  List<ProductModel> get items => List.unmodifiable(_items);
  int get count => _items.length;

  bool isInWishlist(String productId) =>
      _items.any((p) => p.id == productId);

  // ── Called when user logs in ──
  Future<void> loadForUser(String userId) async {
    _currentUserId = userId;
    _items.clear();
    final box = Hive.box('users_v1');
    final raw = box.get('wishlist_$userId') as String?;
    if (raw != null) {
      try {
        final list = jsonDecode(raw) as List;
        _items.addAll(
          list.map((e) => ProductModel.fromJson(
              Map<String, dynamic>.from(e))),
        );
      } catch (_) {}
    }
    notifyListeners();
  }

  // ── Called on logout ──
  void clearForLogout() {
    _items.clear();
    _currentUserId = null;
    notifyListeners();
  }

  Future<void> toggle(ProductModel product) async {
    final idx = _items.indexWhere((p) => p.id == product.id);
    if (idx >= 0) {
      _items.removeAt(idx);
    } else {
      _items.add(product);
    }
    await _persist();
    notifyListeners();
  }

  Future<void> remove(String productId) async {
    _items.removeWhere((p) => p.id == productId);
    await _persist();
    notifyListeners();
  }

  Future<void> _persist() async {
    if (_currentUserId == null) return;
    final box = Hive.box('users_v1');
    await box.put(
      'wishlist_$_currentUserId',
      jsonEncode(_items.map((p) => p.toJson()).toList()),
    );
  }
}