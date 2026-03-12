// lib/views/products/product_detail_screen.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:go_router/go_router.dart';
import '../../providers/product_provider.dart';
import '../../providers/cart_provider.dart';
import '../../models/product_model.dart';
import '../../app/theme/app_theme.dart';

class ProductDetailScreen extends StatelessWidget {
  final String productId;
  const ProductDetailScreen({super.key, required this.productId});

  static const Map<String, String> _productImages = {
    'prod1': 'https://images.unsplash.com/photo-1587202372775-e229f172b9d7?w=800&auto=format',
    'prod2': 'https://images.unsplash.com/photo-1555617778-6b8591a12c7c?w=800&auto=format',
    'prod3': 'https://images.unsplash.com/photo-1562976540-1502c2145186?w=800&auto=format',
    'prod4': 'https://images.unsplash.com/photo-1542751371-adc38448a05e?w=800&auto=format',
    'prod5': 'https://images.unsplash.com/photo-1538481199705-c710c4e965fc?w=800&auto=format',
    'prod6': 'https://images.unsplash.com/photo-1598550476439-6847785fcea6?w=800&auto=format',
    'prod7': 'https://images.unsplash.com/photo-1587202372775-e229f172b9d7?w=800&auto=format',
    'prod8': 'https://images.unsplash.com/photo-1615663245857-ac93bb7c39e7?w=800&auto=format',
    'prod9': 'https://images.unsplash.com/photo-1586210579191-33b45e38fa2c?w=800&auto=format',
    'prod10': 'https://images.unsplash.com/photo-1505740420928-5e560c06d30e?w=800&auto=format',
  };

  String _getImageUrl(ProductModel product) {
    if (product.isSellerProduct) {
      if (product.images != null && product.images!.isNotEmpty) {
        return product.images!.first;
      }
      return 'https://placehold.co/800x600/1A1A2E/6C63FF?text=${Uri.encodeComponent(product.name)}';
    }
    return _productImages[product.id] ??
        'https://placehold.co/800x600/3A3A3A/5A5A5A?text=${Uri.encodeComponent(product.name)}';
  }

  @override
  Widget build(BuildContext context) {
    final product = context.watch<ProductProvider>().getProductById(productId);

    if (product == null) {
      return Scaffold(
        backgroundColor: AppTheme.darkGrey,
        appBar: AppBar(
          backgroundColor: AppTheme.darkGrey,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
            onPressed: () => context.canPop() ? context.pop() : context.go('/products'),
          ),
        ),
        body: Center(
          child: Text('Product not found',
              style: GoogleFonts.poppins(color: Colors.white)),
        ),
      );
    }

    return Scaffold(
      backgroundColor: AppTheme.darkGrey,
      body: CustomScrollView(
        slivers: [
          // Hero image
          SliverAppBar(
            expandedHeight: 300,
            pinned: true,
            backgroundColor: AppTheme.darkGrey,
            leading: Padding(
              padding: const EdgeInsets.all(8),
              child: CircleAvatar(
                backgroundColor: Colors.black54,
                child: IconButton(
                  icon: const Icon(Icons.arrow_back_ios,
                      color: Colors.white, size: 18),
                  onPressed: () =>
                      context.canPop() ? context.pop() : context.go('/products'),
                ),
              ),
            ),
            flexibleSpace: FlexibleSpaceBar(
              background: product.isSellerProduct &&
                      (product.images == null || product.images!.isEmpty)
                  ? Container(
                      color: const Color(0xFF1A1A2E),
                      child: Center(
                        child: Icon(Icons.videogame_asset_rounded,
                            color: const Color(0xFF6C63FF).withOpacity(0.3),
                            size: 80),
                      ),
                    )
                  : CachedNetworkImage(
                      imageUrl: _getImageUrl(product),
                      fit: BoxFit.cover,
                      placeholder: (_, __) =>
                          Container(color: Colors.grey.shade900),
                      errorWidget: (_, __, ___) => Container(
                        color: Colors.grey.shade900,
                        child: Center(
                          child: Icon(Icons.image_not_supported,
                              color: Colors.grey.shade600, size: 60),
                        ),
                      ),
                    ),
            ),
          ),

          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ── Seller / GameStop attribution ──
                  _AttributionBanner(product: product),
                  const SizedBox(height: 14),

                  // Brand
                  Text(
                    product.brand.toUpperCase(),
                    style: const TextStyle(
                      color: AppTheme.primaryRed,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.5,
                    ),
                  ),
                  const SizedBox(height: 8),

                  // Name
                  Text(
                    product.name,
                    style: GoogleFonts.poppins(
                        color: Colors.white,
                        fontSize: 22,
                        fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 10),

                  // Rating
                  Row(
                    children: [
                      const Icon(Icons.star, color: Colors.amber, size: 16),
                      const SizedBox(width: 4),
                      Text(product.rating.toString(),
                          style: TextStyle(
                              color: Colors.grey.shade300, fontSize: 14)),
                      const SizedBox(width: 6),
                      Text('(${product.reviewCount ?? 0} reviews)',
                          style: TextStyle(
                              color: Colors.grey.shade600, fontSize: 13)),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Price
                  Row(
                    children: [
                      Text(
                        '\$${product.finalPrice.toStringAsFixed(2)}',
                        style: const TextStyle(
                            color: Colors.white,
                            fontSize: 26,
                            fontWeight: FontWeight.bold),
                      ),
                      if (product.discountPrice != null) ...[
                        const SizedBox(width: 10),
                        Text(
                          '\$${product.price.toStringAsFixed(2)}',
                          style: TextStyle(
                            color: Colors.grey.shade600,
                            fontSize: 16,
                            decoration: TextDecoration.lineThrough,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: AppTheme.primaryRed,
                            borderRadius: BorderRadius.circular(5),
                          ),
                          child: Text(
                            '-${product.discountPercentage.toInt()}%',
                            style: const TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                                fontWeight: FontWeight.bold),
                          ),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Stock
                  Row(
                    children: [
                      Container(
                        width: 8, height: 8,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: product.inStock == false
                              ? Colors.red
                              : Colors.green,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        product.inStock == false ? 'Out of Stock' : 'In Stock',
                        style: TextStyle(
                          color: product.inStock == false
                              ? Colors.red
                              : Colors.green,
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      if (product.stockQuantity != null &&
                          product.stockQuantity! > 0 &&
                          product.stockQuantity! <= 10) ...[
                        const SizedBox(width: 10),
                        Text(
                          'Only ${product.stockQuantity} left',
                          style: TextStyle(
                              color: Colors.orange.shade400,
                              fontSize: 11,
                              fontWeight: FontWeight.w500),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 20),

                  Divider(color: Colors.grey.shade800),
                  const SizedBox(height: 16),

                  // Description
                  Text('Description',
                      style: GoogleFonts.poppins(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  Text(
                    product.description,
                    style: TextStyle(
                        color: Colors.grey.shade400, fontSize: 14, height: 1.6),
                  ),

                  // Tags
                  if (product.tags != null && product.tags!.isNotEmpty) ...[
                    const SizedBox(height: 20),
                    Divider(color: Colors.grey.shade800),
                    const SizedBox(height: 16),
                    Text('Tags',
                        style: GoogleFonts.poppins(
                            color: Colors.white,
                            fontSize: 14,
                            fontWeight: FontWeight.bold)),
                    const SizedBox(height: 10),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: product.tags!
                          .map((tag) => Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 10, vertical: 5),
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.05),
                                  borderRadius: BorderRadius.circular(20),
                                  border: Border.all(
                                      color: Colors.white.withOpacity(0.1)),
                                ),
                                child: Text('#$tag',
                                    style: TextStyle(
                                        color: Colors.grey.shade400,
                                        fontSize: 11)),
                              ))
                          .toList(),
                    ),
                  ],

                  // Specs (hardcoded products)
                  if (product.specifications != null &&
                      product.specifications!.isNotEmpty) ...[
                    const SizedBox(height: 20),
                    Divider(color: Colors.grey.shade800),
                    const SizedBox(height: 16),
                    Text('Specifications',
                        style: GoogleFonts.poppins(
                            color: Colors.white,
                            fontSize: 14,
                            fontWeight: FontWeight.bold)),
                    const SizedBox(height: 10),
                    ...product.specifications!.entries.map((e) => Padding(
                          padding: const EdgeInsets.only(bottom: 8),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              SizedBox(
                                width: 130,
                                child: Text(e.key,
                                    style: TextStyle(
                                        color: Colors.grey.shade600,
                                        fontSize: 13)),
                              ),
                              Expanded(
                                child: Text(e.value,
                                    style: const TextStyle(
                                        color: Colors.white, fontSize: 13)),
                              ),
                            ],
                          ),
                        )),
                  ],

                  // ── Seller store info card ──
                  if (product.isSellerProduct) ...[
                    const SizedBox(height: 24),
                    Divider(color: Colors.grey.shade800),
                    const SizedBox(height: 16),
                    _SellerInfoCard(product: product),
                  ],

                  const SizedBox(height: 100),
                ],
              ),
            ),
          ),
        ],
      ),

      // Add to cart
      bottomNavigationBar: Container(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 28),
        decoration: BoxDecoration(
          color: AppTheme.darkGrey,
          border: Border(top: BorderSide(color: Colors.grey.shade800)),
        ),
        child: ElevatedButton.icon(
          onPressed: product.inStock == false
              ? null
              : () {
                  context.read<CartProvider>().addToCart(product);
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                    content: Text('${product.name} added to cart'),
                    backgroundColor: AppTheme.primaryRed,
                    duration: const Duration(seconds: 1),
                  ));
                },
          icon: const Icon(Icons.add_shopping_cart),
          label: Text(
            product.inStock == false ? 'Out of Stock' : 'Add to Cart',
            style: GoogleFonts.poppins(
                fontSize: 16, fontWeight: FontWeight.bold),
          ),
          style: ElevatedButton.styleFrom(
            backgroundColor: AppTheme.primaryRed,
            foregroundColor: Colors.white,
            disabledBackgroundColor: Colors.grey.shade800,
            disabledForegroundColor: Colors.grey.shade600,
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12)),
          ),
        ),
      ),
    );
  }
}

// ── Attribution banner shown just below hero ──
class _AttributionBanner extends StatelessWidget {
  final ProductModel product;
  const _AttributionBanner({required this.product});

  @override
  Widget build(BuildContext context) {
    if (!product.isSellerProduct) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: AppTheme.primaryRed.withOpacity(0.08),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: AppTheme.primaryRed.withOpacity(0.2)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.verified, color: AppTheme.primaryRed, size: 14),
            const SizedBox(width: 8),
            Text('Sold by ',
                style: GoogleFonts.poppins(
                    color: Colors.grey.shade400, fontSize: 12)),
            Text('GAMESTOP',
                style: GoogleFonts.orbitron(
                  color: AppTheme.primaryRed,
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                )),
          ],
        ),
      );
    }

    return GestureDetector(
      onTap: () {
        if (product.sellerId != null) {
          context.push('/store/${product.sellerId}');
        }
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: const Color(0xFF6C63FF).withOpacity(0.08),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: const Color(0xFF6C63FF).withOpacity(0.2)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.storefront, color: Color(0xFF6C63FF), size: 14),
            const SizedBox(width: 8),
            Text('Sold by ',
                style: GoogleFonts.poppins(
                    color: Colors.grey.shade400, fontSize: 12)),
            Text(
              product.sellerName ?? 'Seller',
              style: GoogleFonts.poppins(
                color: const Color(0xFF6C63FF),
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(width: 4),
            const Icon(Icons.arrow_forward_ios,
                color: Color(0xFF6C63FF), size: 10),
          ],
        ),
      ),
    );
  }
}

// ── Seller store card at bottom of detail ──
class _SellerInfoCard extends StatelessWidget {
  final ProductModel product;
  const _SellerInfoCard({required this.product});

  @override
  Widget build(BuildContext context) {
    final initials = (product.sellerName ?? 'S')
        .trim()
        .split(' ')
        .take(2)
        .map((w) => w.isNotEmpty ? w[0].toUpperCase() : '')
        .join();

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF161616),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.white.withOpacity(0.07)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('ABOUT THE SELLER',
              style: GoogleFonts.poppins(
                color: Colors.grey.shade600,
                fontSize: 10,
                fontWeight: FontWeight.bold,
                letterSpacing: 1.5,
              )),
          const SizedBox(height: 12),
          Row(
            children: [
              Container(
                width: 44, height: 44,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF6C63FF), Color(0xFF9C92FF)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Center(
                  child: Text(initials,
                      style: GoogleFonts.orbitron(
                          color: Colors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.bold)),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      product.sellerName ?? 'Seller',
                      style: GoogleFonts.poppins(
                          color: Colors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.w600),
                    ),
                    Text('Independent Seller',
                        style: GoogleFonts.poppins(
                            color: Colors.grey.shade600, fontSize: 11)),
                  ],
                ),
              ),
              // Visit store button
              if (product.sellerId != null)
                GestureDetector(
                  onTap: () => context.push('/store/${product.sellerId}'),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 7),
                    decoration: BoxDecoration(
                      color: const Color(0xFF6C63FF).withOpacity(0.15),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                          color: const Color(0xFF6C63FF).withOpacity(0.3)),
                    ),
                    child: Text('Visit Store',
                        style: GoogleFonts.poppins(
                          color: const Color(0xFF6C63FF),
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                        )),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}
