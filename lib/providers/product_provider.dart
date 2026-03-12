// lib/providers/product_provider.dart

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../models/product_model.dart';
import '../models/category_model.dart';
import '../models/seller_model.dart';
import '../services/user_storage_service.dart';

class ProductProvider extends ChangeNotifier {
  List<ProductModel> _hardcodedProducts = [];
  List<ProductModel> _sellerProducts = [];
  List<CategoryModel> _categories = [];

  bool _isLoading = false;
  String? _errorMessage;
  String? _selectedCategory;
  String _searchQuery = '';

  List<ProductModel> get products =>
      [..._hardcodedProducts, ..._sellerProducts];
  List<CategoryModel> get categories => _categories;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  String? get selectedCategory => _selectedCategory;

  List<ProductModel> get featuredProducts =>
      products.where((p) => p.isFeatured).toList();
  List<ProductModel> get trendingProducts =>
      products.where((p) => p.isTrending).toList();
  List<ProductModel> get newArrivals =>
      products.where((p) => p.isNew == true).toList();

  List<ProductModel> get filteredProducts {
    return products.where((p) {
      if (_selectedCategory != null && _selectedCategory!.isNotEmpty) {
        if (p.categoryId != _selectedCategory) return false;
      }
      if (_searchQuery.isNotEmpty) {
        final q = _searchQuery.toLowerCase();
        return p.name.toLowerCase().contains(q) ||
            p.brand.toLowerCase().contains(q) ||
            p.description.toLowerCase().contains(q) ||
            (p.categoryName?.toLowerCase().contains(q) ?? false) ||
            (p.tags?.any((t) => t.toLowerCase().contains(q)) ?? false);
      }
      return true;
    }).toList();
  }

  ProductProvider() {
    _loadHardcodedData();
    Future.microtask(() => loadSellerProducts());
  }

  /// Scans the Hive box directly for any key matching 'seller_products_*'
  /// This avoids depending on getAllUsers() and is guaranteed to find
  /// all seller product entries regardless of user model parsing.
  Future<void> loadSellerProducts() async {
    try {
      // Access the Hive box directly — same box UserStorageService uses
      const boxName = 'users_v1';
      final box = Hive.box(boxName);

      final List<ProductModel> collected = [];

      for (final key in box.keys) {
        final keyStr = key.toString();

        // Only look at seller product keys
        if (!keyStr.startsWith('seller_products_')) continue;

        // Extract sellerId from key: 'seller_products_user_1234' → 'user_1234'
        final sellerId = keyStr.replaceFirst('seller_products_', '');

        // Try to load the matching store for attribution
        SellerStore? store;
        try {
          final storeRaw = box.get('seller_store_$sellerId') as String?;
          if (storeRaw != null) {
            store = SellerStore.fromJson(jsonDecode(storeRaw));
          }
        } catch (_) {}

        // Parse the products list
        final productsRaw = box.get(keyStr) as String?;
        if (productsRaw == null) continue;

        try {
          final list = jsonDecode(productsRaw) as List;
          for (final e in list) {
            try {
              final sp = SellerProduct.fromJson(Map<String, dynamic>.from(e));
              if (!sp.isActive) continue;
              collected.add(_toProductModel(sp, store));
            } catch (e) {
              debugPrint('ProductProvider: failed to parse seller product: $e');
            }
          }
        } catch (e) {
          debugPrint('ProductProvider: failed to parse products for $sellerId: $e');
        }
      }

      debugPrint('ProductProvider: loaded ${collected.length} seller products');
      _sellerProducts = collected;
      notifyListeners();
    } catch (e) {
      debugPrint('ProductProvider.loadSellerProducts error: $e');
    }
  }

  ProductModel _toProductModel(SellerProduct sp, SellerStore? store) {
    return ProductModel(
      id: sp.id,
      name: sp.name,
      brand: sp.brand,
      description: sp.description,
      price: sp.originalPrice ?? sp.price,
      discountPrice: sp.hasDiscount ? sp.price : null,
      categoryId: _mapCategory(sp.category),
      categoryName: sp.category,
      rating: sp.rating,
      reviewCount: sp.reviewCount,
      inStock: sp.stock > 0,
      stockQuantity: sp.stock,
      tags: sp.tags,
      isFeatured: sp.isFeatured,
      isTrending: false,
      isNew: DateTime.now().difference(sp.createdAt).inDays < 14,
      sellerId: sp.sellerId,
      sellerName: store?.storeName ?? sp.storeName,
      isSellerProduct: true,
    );
  }

  String _mapCategory(String sellerCategory) {
    switch (sellerCategory.toLowerCase().trim()) {
      case 'games':
        return 'cat2';
      case 'pc':
      case 'pc hardware':
      case 'hardware':
        return 'cat1';
      case 'consoles':
      case 'console':
        return 'cat2';
      case 'accessories':
        return 'cat8';
      case 'keyboards':
      case 'keyboard':
        return 'cat4';
      case 'mice':
      case 'mouse':
        return 'cat5';
      case 'monitors':
      case 'monitor':
        return 'cat6';
      case 'headsets':
      case 'headset':
        return 'cat7';
      case 'gaming chairs':
      case 'chair':
        return 'cat3';
      default:
        return 'cat8';
    }
  }

  ProductModel? getProductById(String id) {
    try {
      return products.firstWhere((p) => p.id == id);
    } catch (_) {
      return null;
    }
  }

  List<ProductModel> getProductsByCategory(String categoryId) =>
      products.where((p) => p.categoryId == categoryId).toList();

  void setSelectedCategory(String? categoryId) {
    _selectedCategory = categoryId;
    notifyListeners();
  }

  void setSearchQuery(String query) {
    _searchQuery = query;
    notifyListeners();
  }

  void clearFilters() {
    _selectedCategory = null;
    _searchQuery = '';
    notifyListeners();
  }

  Future<void> refreshProducts() async {
    _isLoading = true;
    notifyListeners();
    await loadSellerProducts();
    _isLoading = false;
    notifyListeners();
  }

  void _loadHardcodedData() {
    _categories = [
      CategoryModel(id: 'cat1', name: 'PC Hardware', icon: 'computer', color: 0xFFE31C23, productCount: 45),
      CategoryModel(id: 'cat2', name: 'Games', icon: 'sports_esports', color: 0xFF0066CC, productCount: 120),
      CategoryModel(id: 'cat3', name: 'Gaming Chairs', icon: 'chair', color: 0xFF00AA00, productCount: 15),
      CategoryModel(id: 'cat4', name: 'Keyboards', icon: 'keyboard', color: 0xFFFF6B00, productCount: 28),
      CategoryModel(id: 'cat5', name: 'Mice', icon: 'mouse', color: 0xFF9C27B0, productCount: 32),
      CategoryModel(id: 'cat6', name: 'Monitors', icon: 'monitor', color: 0xFF607D8B, productCount: 23),
      CategoryModel(id: 'cat7', name: 'Headsets', icon: 'headset', color: 0xFF795548, productCount: 19),
      CategoryModel(id: 'cat8', name: 'Accessories', icon: 'usb', color: 0xFF009688, productCount: 56),
    ];

    _hardcodedProducts = [
      ProductModel(
        id: 'prod1', name: 'NVIDIA GeForce RTX 4090',
        description: 'The ultimate GeForce GPU. Enormous leap in performance, efficiency, and AI-powered graphics.',
        price: 1599.99, discountPrice: 1499.99,
        categoryId: 'cat1', categoryName: 'PC Hardware', brand: 'NVIDIA',
        images: ['https://images.unsplash.com/photo-1587202372775-e229f172b9d7?w=400&auto=format'],
        rating: 4.9, reviewCount: 342, inStock: true, stockQuantity: 15,
        specifications: {'CUDA Cores': '16384', 'Memory': '24GB GDDR6X'},
        isFeatured: true, isTrending: true, isNew: false,
        tags: ['graphics-card', 'gaming', '4k', 'gpu'],
      ),
      ProductModel(
        id: 'prod2', name: 'AMD Ryzen 9 7950X',
        description: '16-core, 32-thread desktop processor for ultimate gaming and creative performance.',
        price: 699.99, categoryId: 'cat1', categoryName: 'PC Hardware', brand: 'AMD',
        images: ['https://images.unsplash.com/photo-1555617778-6b8591a12c7c?w=400&auto=format'],
        rating: 4.8, reviewCount: 256, inStock: true, stockQuantity: 28,
        specifications: {'Cores': '16', 'Threads': '32', 'Max Boost': '5.7GHz'},
        isFeatured: true, isTrending: false, isNew: false,
        tags: ['cpu', 'processor', 'amd'],
      ),
      ProductModel(
        id: 'prod3', name: 'Samsung 990 Pro 2TB',
        description: 'Ultra-fast PCIe 4.0 NVMe SSD for gaming and content creation.',
        price: 159.99, discountPrice: 139.99,
        categoryId: 'cat1', categoryName: 'PC Hardware', brand: 'Samsung',
        images: ['https://images.unsplash.com/photo-1562976540-1502c2145186?w=400&auto=format'],
        rating: 4.7, reviewCount: 189, inStock: true, stockQuantity: 42,
        specifications: {'Capacity': '2TB', 'Interface': 'PCIe 4.0 x4', 'Read Speed': '7450 MB/s'},
        isFeatured: false, isTrending: true, isNew: true,
        tags: ['ssd', 'storage', 'nvme'],
      ),
      ProductModel(
        id: 'prod4', name: 'Cyberpunk 2077',
        description: 'An open-world, action-adventure story set in Night City.',
        price: 59.99, discountPrice: 39.99,
        categoryId: 'cat2', categoryName: 'Games', brand: 'CD Projekt Red',
        images: ['https://images.unsplash.com/photo-1542751371-adc38448a05e?w=400&auto=format'],
        rating: 4.2, reviewCount: 1245, inStock: true, stockQuantity: 100,
        specifications: {'Platform': 'PC', 'Genre': 'Action RPG'},
        isFeatured: true, isTrending: true, isNew: false,
        tags: ['rpg', 'open-world', 'sci-fi', 'game'],
      ),
      ProductModel(
        id: 'prod5', name: 'Elden Ring',
        description: 'Rise, Tarnished, and be guided by grace to brandish the power of the Elden Ring.',
        price: 59.99, categoryId: 'cat2', categoryName: 'Games', brand: 'FromSoftware',
        images: ['https://images.unsplash.com/photo-1538481199705-c710c4e965fc?w=400&auto=format'],
        rating: 4.9, reviewCount: 2134, inStock: true, stockQuantity: 75,
        specifications: {'Platform': 'PC', 'Genre': 'Action RPG'},
        isFeatured: true, isTrending: true, isNew: false,
        tags: ['souls-like', 'open-world', 'fantasy', 'game'],
      ),
      ProductModel(
        id: 'prod6', name: 'Secretlab Titan Evo 2022',
        description: 'The award-winning TITAN Evo 2022 Series with advanced technology.',
        price: 549.99, categoryId: 'cat3', categoryName: 'Gaming Chairs', brand: 'Secretlab',
        images: ['https://images.unsplash.com/photo-1598550476439-6847785fcea6?w=400&auto=format'],
        rating: 4.8, reviewCount: 567, inStock: true, stockQuantity: 12,
        specifications: {'Material': 'NEO Hybrid Leatherette', 'Warranty': '5 years'},
        isFeatured: true, isTrending: false, isNew: true,
        tags: ['chair', 'ergonomic', 'premium'],
      ),
      ProductModel(
        id: 'prod7', name: 'Razer Huntsman V2',
        description: 'Optical gaming keyboard with Razer Linear Optical Switches.',
        price: 199.99, discountPrice: 169.99,
        categoryId: 'cat4', categoryName: 'Keyboards', brand: 'Razer',
        images: ['https://images.unsplash.com/photo-1587202372775-e229f172b9d7?w=400&auto=format'],
        rating: 4.6, reviewCount: 342, inStock: true, stockQuantity: 34,
        specifications: {'Switch Type': 'Razer Optical', 'Layout': 'Full-size', 'Backlight': 'RGB'},
        isFeatured: false, isTrending: true, isNew: false,
        tags: ['keyboard', 'mechanical', 'gaming'],
      ),
      ProductModel(
        id: 'prod8', name: 'Logitech G Pro X Superlight',
        description: 'The lightest and fastest PRO mouse yet, designed for pro gamers.',
        price: 149.99, categoryId: 'cat5', categoryName: 'Mice', brand: 'Logitech',
        images: ['https://images.unsplash.com/photo-1615663245857-ac93bb7c39e7?w=400&auto=format'],
        rating: 4.9, reviewCount: 892, inStock: true, stockQuantity: 45,
        specifications: {'Sensor': 'HERO 25K', 'Weight': '63g', 'Connectivity': 'Wireless'},
        isFeatured: true, isTrending: true, isNew: true,
        tags: ['mouse', 'wireless', 'esports'],
      ),
      ProductModel(
        id: 'prod9', name: 'LG 27GP950-B',
        description: '27" 4K UHD Nano IPS gaming monitor with 144Hz refresh rate.',
        price: 799.99, discountPrice: 749.99,
        categoryId: 'cat6', categoryName: 'Monitors', brand: 'LG',
        images: ['https://images.unsplash.com/photo-1586210579191-33b45e38fa2c?w=400&auto=format'],
        rating: 4.7, reviewCount: 234, inStock: true, stockQuantity: 8,
        specifications: {'Size': '27"', 'Resolution': '3840x2160', 'Refresh Rate': '144Hz'},
        isFeatured: true, isTrending: false, isNew: false,
        tags: ['monitor', '4k', 'gaming'],
      ),
      ProductModel(
        id: 'prod10', name: 'SteelSeries Arctis Nova Pro',
        description: 'Premium gaming headset with active noise cancellation.',
        price: 349.99, categoryId: 'cat7', categoryName: 'Headsets', brand: 'SteelSeries',
        images: ['https://images.unsplash.com/photo-1505740420928-5e560c06d30e?w=400&auto=format'],
        rating: 4.8, reviewCount: 456, inStock: true, stockQuantity: 23,
        specifications: {'Driver': '40mm Neodymium', 'Connectivity': 'USB-C'},
        isFeatured: false, isTrending: true, isNew: true,
        tags: ['headset', 'wireless', 'noise-cancelling'],
      ),
    ];

    notifyListeners();
  }
}
