// lib/models/seller_model.dart

enum SellerType { individual, organization }

class SellerStore {
  final String sellerId;
  final SellerType type;
  final String storeName; // org name or "{firstName}'s Store"
  final String? storeDescription;
  final String? storeLogoUrl;
  final String? storeBannerUrl;
  final String? website;
  final String? contactEmail;
  final String? contactPhone;
  final String? address;
  final List<String> productIds;
  final double totalRating; // sum of all review stars
  final int totalReviews;
  final int totalSales;
  final DateTime createdAt;
  final bool isVerified;
  final bool isActive;

  const SellerStore({
    required this.sellerId,
    required this.type,
    required this.storeName,
    this.storeDescription,
    this.storeLogoUrl,
    this.storeBannerUrl,
    this.website,
    this.contactEmail,
    this.contactPhone,
    this.address,
    this.productIds = const [],
    this.totalRating = 0,
    this.totalReviews = 0,
    this.totalSales = 0,
    required this.createdAt,
    this.isVerified = false,
    this.isActive = true,
  });

  double get averageRating =>
      totalReviews == 0 ? 0 : (totalRating / totalReviews).clamp(0, 5);

  String get formattedRating => averageRating.toStringAsFixed(1);

  SellerStore copyWith({
    SellerType? type,
    String? storeName,
    String? storeDescription,
    String? storeLogoUrl,
    String? storeBannerUrl,
    String? website,
    String? contactEmail,
    String? contactPhone,
    String? address,
    List<String>? productIds,
    double? totalRating,
    int? totalReviews,
    int? totalSales,
    bool? isVerified,
    bool? isActive,
  }) {
    return SellerStore(
      sellerId: sellerId,
      type: type ?? this.type,
      storeName: storeName ?? this.storeName,
      storeDescription: storeDescription ?? this.storeDescription,
      storeLogoUrl: storeLogoUrl ?? this.storeLogoUrl,
      storeBannerUrl: storeBannerUrl ?? this.storeBannerUrl,
      website: website ?? this.website,
      contactEmail: contactEmail ?? this.contactEmail,
      contactPhone: contactPhone ?? this.contactPhone,
      address: address ?? this.address,
      productIds: productIds ?? this.productIds,
      totalRating: totalRating ?? this.totalRating,
      totalReviews: totalReviews ?? this.totalReviews,
      totalSales: totalSales ?? this.totalSales,
      createdAt: createdAt,
      isVerified: isVerified ?? this.isVerified,
      isActive: isActive ?? this.isActive,
    );
  }

  Map<String, dynamic> toJson() => {
        'sellerId': sellerId,
        'type': type.name,
        'storeName': storeName,
        'storeDescription': storeDescription,
        'storeLogoUrl': storeLogoUrl,
        'storeBannerUrl': storeBannerUrl,
        'website': website,
        'contactEmail': contactEmail,
        'contactPhone': contactPhone,
        'address': address,
        'productIds': productIds,
        'totalRating': totalRating,
        'totalReviews': totalReviews,
        'totalSales': totalSales,
        'createdAt': createdAt.toIso8601String(),
        'isVerified': isVerified,
        'isActive': isActive,
      };

  factory SellerStore.fromJson(Map<String, dynamic> json) => SellerStore(
        sellerId: json['sellerId'],
        type: SellerType.values.firstWhere(
          (e) => e.name == json['type'],
          orElse: () => SellerType.individual,
        ),
        storeName: json['storeName'],
        storeDescription: json['storeDescription'],
        storeLogoUrl: json['storeLogoUrl'],
        storeBannerUrl: json['storeBannerUrl'],
        website: json['website'],
        contactEmail: json['contactEmail'],
        contactPhone: json['contactPhone'],
        address: json['address'],
        productIds: List<String>.from(json['productIds'] ?? []),
        totalRating: (json['totalRating'] ?? 0).toDouble(),
        totalReviews: json['totalReviews'] ?? 0,
        totalSales: json['totalSales'] ?? 0,
        createdAt: DateTime.parse(json['createdAt']),
        isVerified: json['isVerified'] ?? false,
        isActive: json['isActive'] ?? true,
      );
}

// ── Seller-listed product ──
class SellerProduct {
  final String id;
  final String sellerId;
  final String storeName;
  final String name;
  final String brand;
  final String category;
  final String description;
  final double price;
  final double? originalPrice;
  final int stock;
  final List<String> imageUrls;
  final List<String> tags;
  final double rating;
  final int reviewCount;
  final bool isActive;
  final bool isFeatured;
  final DateTime createdAt;
  final DateTime updatedAt;

  const SellerProduct({
    required this.id,
    required this.sellerId,
    required this.storeName,
    required this.name,
    required this.brand,
    required this.category,
    required this.description,
    required this.price,
    this.originalPrice,
    required this.stock,
    this.imageUrls = const [],
    this.tags = const [],
    this.rating = 0,
    this.reviewCount = 0,
    this.isActive = true,
    this.isFeatured = false,
    required this.createdAt,
    required this.updatedAt,
  });

  bool get hasDiscount => originalPrice != null && originalPrice! > price;
  int get discountPercent => hasDiscount
      ? ((1 - price / originalPrice!) * 100).round()
      : 0;

  SellerProduct copyWith({
    String? name,
    String? brand,
    String? category,
    String? description,
    double? price,
    double? originalPrice,
    int? stock,
    List<String>? imageUrls,
    List<String>? tags,
    double? rating,
    int? reviewCount,
    bool? isActive,
    bool? isFeatured,
  }) {
    return SellerProduct(
      id: id,
      sellerId: sellerId,
      storeName: storeName,
      name: name ?? this.name,
      brand: brand ?? this.brand,
      category: category ?? this.category,
      description: description ?? this.description,
      price: price ?? this.price,
      originalPrice: originalPrice ?? this.originalPrice,
      stock: stock ?? this.stock,
      imageUrls: imageUrls ?? this.imageUrls,
      tags: tags ?? this.tags,
      rating: rating ?? this.rating,
      reviewCount: reviewCount ?? this.reviewCount,
      isActive: isActive ?? this.isActive,
      isFeatured: isFeatured ?? this.isFeatured,
      createdAt: createdAt,
      updatedAt: DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'sellerId': sellerId,
        'storeName': storeName,
        'name': name,
        'brand': brand,
        'category': category,
        'description': description,
        'price': price,
        'originalPrice': originalPrice,
        'stock': stock,
        'imageUrls': imageUrls,
        'tags': tags,
        'rating': rating,
        'reviewCount': reviewCount,
        'isActive': isActive,
        'isFeatured': isFeatured,
        'createdAt': createdAt.toIso8601String(),
        'updatedAt': updatedAt.toIso8601String(),
      };

  factory SellerProduct.fromJson(Map<String, dynamic> json) => SellerProduct(
        id: json['id'],
        sellerId: json['sellerId'],
        storeName: json['storeName'] ?? 'Unknown Store',
        name: json['name'],
        brand: json['brand'],
        category: json['category'],
        description: json['description'],
        price: (json['price'] ?? 0).toDouble(),
        originalPrice: json['originalPrice'] != null
            ? (json['originalPrice']).toDouble()
            : null,
        stock: json['stock'] ?? 0,
        imageUrls: List<String>.from(json['imageUrls'] ?? []),
        tags: List<String>.from(json['tags'] ?? []),
        rating: (json['rating'] ?? 0).toDouble(),
        reviewCount: json['reviewCount'] ?? 0,
        isActive: json['isActive'] ?? true,
        isFeatured: json['isFeatured'] ?? false,
        createdAt: DateTime.parse(json['createdAt']),
        updatedAt: DateTime.parse(json['updatedAt']),
      );
}
