// lib/providers/seller_provider.dart

import 'dart:convert';
import 'dart:math';
import 'package:flutter/foundation.dart';
import '../models/seller_model.dart';
import '../services/user_storage_service.dart';

class SellerProvider extends ChangeNotifier {
  SellerStore? _store;
  List<SellerProduct> _products = [];
  String? _currentSellerId;
  bool _isLoading = false;
  String? _error;

  SellerStore? get store => _store;
  List<SellerProduct> get products => List.unmodifiable(_products);
  List<SellerProduct> get activeProducts =>
      _products.where((p) => p.isActive).toList();
  int get totalProducts => _products.length;
  int get activeProductCount => activeProducts.length;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get hasStore => _store != null;

  double get totalRevenue =>
      _products.fold(0, (sum, p) => sum + (p.price * p.reviewCount * 0.3));
  int get totalOrders =>
      _products.fold(0, (sum, p) => sum + (p.reviewCount ~/ 3));
  double get avgRating {
    if (_products.isEmpty) return 0;
    final rated = _products.where((p) => p.reviewCount > 0).toList();
    if (rated.isEmpty) return 0;
    return rated.fold(0.0, (sum, p) => sum + p.rating) / rated.length;
  }

  Future<void> loadForSeller(String sellerId) async {
    _currentSellerId = sellerId;
    _isLoading = true;
    notifyListeners();

    try {
      // loadRaw is now synchronous
      final storeJson = UserStorageService.loadRaw('seller_store_$sellerId');
      if (storeJson != null) {
        _store = SellerStore.fromJson(jsonDecode(storeJson));
      }
      final productsJson =
          UserStorageService.loadRaw('seller_products_$sellerId');
      if (productsJson != null) {
        final list = jsonDecode(productsJson) as List;
        _products = list
            .map((e) => SellerProduct.fromJson(Map<String, dynamic>.from(e)))
            .toList();
      }
    } catch (e) {
      _error = e.toString();
      debugPrint('SellerProvider.loadForSeller error: $e');
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<void> clearForLogout() async {
    _store = null;
    _products = [];
    _currentSellerId = null;
    _error = null;
    notifyListeners();
  }

  Future<bool> createStore({
    required String sellerId,
    required SellerType type,
    required String storeName,
    String? description,
    String? contactEmail,
    String? contactPhone,
    String? address,
  }) async {
    try {
      _store = SellerStore(
        sellerId: sellerId,
        type: type,
        storeName: storeName,
        storeDescription: description,
        contactEmail: contactEmail,
        contactPhone: contactPhone,
        address: address,
        createdAt: DateTime.now(),
      );
      await _persistStore();
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }

  Future<bool> updateStore(SellerStore updated) async {
    try {
      _store = updated;
      await _persistStore();
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }

  Future<bool> addProduct(SellerProduct product) async {
    try {
      _products.insert(0, product);
      if (_store != null) {
        _store = _store!.copyWith(
          productIds: [..._store!.productIds, product.id],
        );
        await _persistStore();
      }
      await _persistProducts();
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      debugPrint('SellerProvider.addProduct error: $e');
      notifyListeners();
      return false;
    }
  }

  Future<bool> updateProduct(SellerProduct updated) async {
    try {
      final idx = _products.indexWhere((p) => p.id == updated.id);
      if (idx == -1) return false;
      _products[idx] = updated;
      await _persistProducts();
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }

  Future<bool> deleteProduct(String productId) async {
    try {
      _products.removeWhere((p) => p.id == productId);
      if (_store != null) {
        _store = _store!.copyWith(
          productIds:
              _store!.productIds.where((id) => id != productId).toList(),
        );
        await _persistStore();
      }
      await _persistProducts();
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }

  Future<bool> toggleProductActive(String productId) async {
    final idx = _products.indexWhere((p) => p.id == productId);
    if (idx == -1) return false;
    _products[idx] =
        _products[idx].copyWith(isActive: !_products[idx].isActive);
    await _persistProducts();
    notifyListeners();
    return true;
  }

  String generateProductId() {
    const chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
    final rng = Random();
    final suffix =
        List.generate(8, (_) => chars[rng.nextInt(chars.length)]).join();
    return 'SP-$suffix';
  }

  Future<void> _persistStore() async {
    if (_store == null || _currentSellerId == null) return;
    await UserStorageService.saveRaw(
      'seller_store_$_currentSellerId',
      jsonEncode(_store!.toJson()),
    );
  }

  Future<void> _persistProducts() async {
    if (_currentSellerId == null) return;
    await UserStorageService.saveRaw(
      'seller_products_$_currentSellerId',
      jsonEncode(_products.map((p) => p.toJson()).toList()),
    );
    debugPrint(
        'SellerProvider: persisted ${_products.length} products for $_currentSellerId');
  }

  // ── Public static loaders (for buyer store page) ──
  static Future<SellerStore?> loadStoreById(String sellerId) async {
    try {
      final json = UserStorageService.loadRaw('seller_store_$sellerId');
      if (json == null) return null;
      return SellerStore.fromJson(jsonDecode(json));
    } catch (_) {
      return null;
    }
  }

  static Future<List<SellerProduct>> loadProductsByStore(
      String sellerId) async {
    try {
      final json =
          UserStorageService.loadRaw('seller_products_$sellerId');
      if (json == null) return [];
      final list = jsonDecode(json) as List;
      return list
          .map((e) => SellerProduct.fromJson(Map<String, dynamic>.from(e)))
          .where((p) => p.isActive)
          .toList();
    } catch (_) {
      return [];
    }
  }
}
