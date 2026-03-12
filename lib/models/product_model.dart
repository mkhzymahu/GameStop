// lib/models/product_model.dart

class ProductModel {
  final String id;
  final String name;
  final String description;
  final double price;
  final double? discountPrice;
  final String brand;
  final String categoryId;
  final String? categoryName;
  final String? image;
  final List<String>? images;
  final double rating;
  final int? reviewCount;
  final int? reviews;
  final int? stock;
  final bool? inStock;
  final int? stockQuantity;
  final bool isFeatured;
  final bool isTrending;
  final bool? isNew;
  final List<String>? specs;
  final List<String>? tags;
  final Map<String, String>? specifications;

  // ── Seller attribution fields ──
  /// null = GameStop native product, non-null = seller listed
  final String? sellerId;
  final String? sellerName;     // store name or individual name
  final bool isSellerProduct;   // convenience flag

  ProductModel({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    this.discountPrice,
    required this.brand,
    required this.categoryId,
    this.categoryName,
    this.image,
    this.images,
    required this.rating,
    this.reviewCount,
    this.reviews,
    this.stock,
    this.inStock,
    this.stockQuantity,
    this.isFeatured = false,
    this.isTrending = false,
    this.isNew = false,
    this.specs,
    this.tags,
    this.specifications,
    this.sellerId,
    this.sellerName,
    this.isSellerProduct = false,
  });

  double get finalPrice => discountPrice ?? price;

  double get discountPercentage {
    if (discountPrice == null) return 0;
    return ((price - discountPrice!) / price * 100).roundToDouble();
  }

  /// Display label shown on cards and detail screen
  String get attributionLabel =>
      isSellerProduct ? (sellerName ?? 'Seller') : 'GAMESTOP';

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'brand': brand,
        'price': price,
        'discountPrice': discountPrice,
        'image': image,
        'rating': rating,
        'categoryId': categoryId,
        'description': description,
        'inStock': inStock,
        'sellerId': sellerId,
        'sellerName': sellerName,
        'isSellerProduct': isSellerProduct,
      };

  factory ProductModel.fromJson(Map<String, dynamic> json) => ProductModel(
        id: json['id'],
        name: json['name'],
        brand: json['brand'],
        price: (json['price'] as num).toDouble(),
        discountPrice: json['discountPrice'] != null
            ? (json['discountPrice'] as num).toDouble()
            : null,
        image: json['image'],
        rating: (json['rating'] as num).toDouble(),
        categoryId: json['categoryId'] ?? '',
        description: json['description'] ?? '',
        inStock: json['inStock'] ?? true,
        sellerId: json['sellerId'],
        sellerName: json['sellerName'],
        isSellerProduct: json['isSellerProduct'] ?? false,
      );
}
