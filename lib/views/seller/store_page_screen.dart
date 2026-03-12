// lib/views/seller/store_page_screen.dart
// Public-facing store page — buyers land here when tapping org/seller name

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../models/seller_model.dart';
import '../../providers/seller_provider.dart';

class StorePageScreen extends StatefulWidget {
  final String sellerId;
  const StorePageScreen({super.key, required this.sellerId});

  @override
  State<StorePageScreen> createState() => _StorePageScreenState();
}

class _StorePageScreenState extends State<StorePageScreen> {
  SellerStore? _store;
  List<SellerProduct> _products = [];
  bool _isLoading = true;
  String _sort = 'Rating';

  final _sortOptions = ['Rating', 'Price: Low', 'Price: High', 'Newest'];

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final store = await SellerProvider.loadStoreById(widget.sellerId);
    final products =
        await SellerProvider.loadProductsByStore(widget.sellerId);
    if (mounted) {
      setState(() {
        _store = store;
        _products = products;
        _isLoading = false;
      });
    }
  }

  List<SellerProduct> get _sorted {
    final list = List<SellerProduct>.from(_products);
    switch (_sort) {
      case 'Rating':
        list.sort((a, b) => b.rating.compareTo(a.rating));
      case 'Price: Low':
        list.sort((a, b) => a.price.compareTo(b.price));
      case 'Price: High':
        list.sort((a, b) => b.price.compareTo(a.price));
      case 'Newest':
        list.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    }
    return list;
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        backgroundColor: Color(0xFF0D0D0D),
        body: Center(
          child: CircularProgressIndicator(
              valueColor:
                  AlwaysStoppedAnimation<Color>(Color(0xFFE63946))),
        ),
      );
    }

    if (_store == null) {
      return Scaffold(
        backgroundColor: const Color(0xFF0D0D0D),
        appBar: AppBar(
          backgroundColor: const Color(0xFF161616),
          iconTheme: const IconThemeData(color: Colors.white),
        ),
        body: Center(
          child: Text('Store not found',
              style: GoogleFonts.poppins(color: Colors.grey)),
        ),
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xFF0D0D0D),
      body: CustomScrollView(
        slivers: [
          // ── Store header ──
          SliverToBoxAdapter(
            child: _StoreHeader(store: _store!),
          ),

          // ── Sort bar ──
          SliverToBoxAdapter(
            child: Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Row(
                children: [
                  Text('${_products.length} products',
                      style: GoogleFonts.poppins(
                          color: Colors.grey.shade500, fontSize: 12)),
                  const Spacer(),
                  Text('Sort: ',
                      style: GoogleFonts.poppins(
                          color: Colors.grey.shade600, fontSize: 12)),
                  DropdownButton<String>(
                    value: _sort,
                    dropdownColor: const Color(0xFF1E1E1E),
                    underline: const SizedBox(),
                    style: GoogleFonts.poppins(
                        color: const Color(0xFFE63946),
                        fontSize: 12,
                        fontWeight: FontWeight.bold),
                    icon: const Icon(Icons.keyboard_arrow_down,
                        color: Color(0xFFE63946), size: 18),
                    items: _sortOptions
                        .map((o) => DropdownMenuItem(
                              value: o,
                              child: Text(o),
                            ))
                        .toList(),
                    onChanged: (v) => setState(() => _sort = v!),
                  ),
                ],
              ),
            ),
          ),

          // ── Product grid ──
          if (_products.isEmpty)
            SliverFillRemaining(
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.inventory_2_outlined,
                        size: 56, color: Colors.grey.shade800),
                    const SizedBox(height: 12),
                    Text('No products listed yet',
                        style: GoogleFonts.poppins(
                            color: Colors.grey.shade600, fontSize: 14)),
                  ],
                ),
              ),
            )
          else
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 40),
              sliver: SliverGrid(
                gridDelegate:
                    const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  mainAxisSpacing: 12,
                  crossAxisSpacing: 12,
                  childAspectRatio: 0.72,
                ),
                delegate: SliverChildBuilderDelegate(
                  (context, i) =>
                      _StoreProductCard(product: _sorted[i]),
                  childCount: _sorted.length,
                ),
              ),
            ),
        ],
      ),
    );
  }
}

// ── Store header ──
class _StoreHeader extends StatelessWidget {
  final SellerStore store;
  const _StoreHeader({required this.store});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xFF161616),
      child: Column(
        children: [
          // Banner / back button area
          Stack(
            children: [
              Container(
                height: 160,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      const Color(0xFFE63946).withOpacity(0.3),
                      const Color(0xFF161616),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: Center(
                  child: Icon(Icons.storefront_rounded,
                      size: 64,
                      color: Colors.white.withOpacity(0.05)),
                ),
              ),
              Positioned(
                top: 44,
                left: 16,
                child: GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.5),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(Icons.arrow_back_ios_rounded,
                        color: Colors.white, size: 16),
                  ),
                ),
              ),
            ],
          ),

          // Store info
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Store logo / initials
                Transform.translate(
                  offset: const Offset(0, -30),
                  child: Container(
                    width: 64,
                    height: 64,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFFE63946), Color(0xFFFF6B6B)],
                      ),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                          color: const Color(0xFF161616), width: 3),
                    ),
                    child: Center(
                      child: Text(
                        store.storeName.isNotEmpty
                            ? store.storeName[0].toUpperCase()
                            : 'S',
                        style: GoogleFonts.orbitron(
                            color: Colors.white,
                            fontSize: 24,
                            fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                ),
                Transform.translate(
                  offset: const Offset(0, -22),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(store.storeName,
                                style: GoogleFonts.orbitron(
                                    color: Colors.white,
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold)),
                          ),
                          if (store.isVerified)
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: Colors.green.withOpacity(0.15),
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(
                                    color: Colors.green.withOpacity(0.4)),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Icon(Icons.verified,
                                      color: Colors.green, size: 12),
                                  const SizedBox(width: 4),
                                  Text('Verified',
                                      style: GoogleFonts.poppins(
                                          color: Colors.green,
                                          fontSize: 10,
                                          fontWeight: FontWeight.w600)),
                                ],
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(
                              color: const Color(0xFFE63946)
                                  .withOpacity(0.15),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              store.type == SellerType.organization
                                  ? 'ORGANIZATION'
                                  : 'INDIVIDUAL',
                              style: GoogleFonts.poppins(
                                  color: const Color(0xFFE63946),
                                  fontSize: 9,
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 0.5),
                            ),
                          ),
                        ],
                      ),
                      if (store.storeDescription != null &&
                          store.storeDescription!.isNotEmpty) ...[
                        const SizedBox(height: 8),
                        Text(store.storeDescription!,
                            style: GoogleFonts.poppins(
                                color: Colors.grey.shade400,
                                fontSize: 12),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis),
                      ],
                      const SizedBox(height: 12),
                      // Stats row
                      Row(
                        children: [
                          _StatPill(
                            icon: Icons.star_rounded,
                            color: Colors.amber,
                            value: store.averageRating == 0
                                ? '—'
                                : store.formattedRating,
                            label: '/ 5.0',
                          ),
                          const SizedBox(width: 12),
                          _StatPill(
                            icon: Icons.rate_review_rounded,
                            color: const Color(0xFF6C63FF),
                            value: store.totalReviews.toString(),
                            label: 'reviews',
                          ),
                          const SizedBox(width: 12),
                          _StatPill(
                            icon: Icons.shopping_bag_rounded,
                            color: Colors.green,
                            value: store.totalSales.toString(),
                            label: 'sold',
                          ),
                        ],
                      ),
                      if (store.contactEmail != null ||
                          store.website != null) ...[
                        const SizedBox(height: 10),
                        Wrap(
                          spacing: 8,
                          children: [
                            if (store.contactEmail != null)
                              _ContactChip(
                                  icon: Icons.email_outlined,
                                  label: store.contactEmail!),
                            if (store.website != null)
                              _ContactChip(
                                  icon: Icons.language_rounded,
                                  label: store.website!),
                          ],
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _StatPill extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String value;
  final String label;

  const _StatPill({
    required this.icon,
    required this.color,
    required this.value,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.25)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: 13),
          const SizedBox(width: 4),
          Text(value,
              style: GoogleFonts.orbitron(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.bold)),
          const SizedBox(width: 3),
          Text(label,
              style: TextStyle(color: Colors.grey.shade500, fontSize: 10)),
        ],
      ),
    );
  }
}

class _ContactChip extends StatelessWidget {
  final IconData icon;
  final String label;
  const _ContactChip({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: const Color(0xFF222222),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: Colors.grey.shade500),
          const SizedBox(width: 5),
          Text(label,
              style: GoogleFonts.poppins(
                  color: Colors.grey.shade500, fontSize: 10),
              overflow: TextOverflow.ellipsis),
        ],
      ),
    );
  }
}

// ── Store product card ──
class _StoreProductCard extends StatelessWidget {
  final SellerProduct product;
  const _StoreProductCard({required this.product});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => _showProductSheet(context),
      child: Container(
        decoration: BoxDecoration(
          color: const Color(0xFF161616),
          borderRadius: BorderRadius.circular(14),
          border:
              Border.all(color: Colors.white.withOpacity(0.06)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image / icon area
            Expanded(
              child: Container(
                decoration: const BoxDecoration(
                  color: Color(0xFF1A1A1A),
                  borderRadius:
                      BorderRadius.vertical(top: Radius.circular(14)),
                ),
                child: Center(
                  child: Icon(
                    _categoryIcon(product.category),
                    color: const Color(0xFFE63946).withOpacity(0.6),
                    size: 48,
                  ),
                ),
              ),
            ),
            // Info
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(product.brand,
                      style: TextStyle(
                          color: const Color(0xFFE63946),
                          fontSize: 9,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 0.5)),
                  const SizedBox(height: 2),
                  Text(product.name,
                      style: GoogleFonts.poppins(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.w600),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis),
                  const SizedBox(height: 6),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '\$${product.price.toStringAsFixed(2)}',
                        style: GoogleFonts.orbitron(
                            color: const Color(0xFFE63946),
                            fontSize: 13,
                            fontWeight: FontWeight.bold),
                      ),
                      if (product.reviewCount > 0)
                        Row(
                          children: [
                            const Icon(Icons.star_rounded,
                                color: Colors.amber, size: 12),
                            const SizedBox(width: 2),
                            Text(product.rating.toStringAsFixed(1),
                                style: TextStyle(
                                    color: Colors.grey.shade500,
                                    fontSize: 10)),
                          ],
                        ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showProductSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) => _ProductDetailSheet(product: product),
    );
  }

  IconData _categoryIcon(String category) {
    switch (category.toLowerCase()) {
      case 'consoles':
        return Icons.videogame_asset_rounded;
      case 'games':
        return Icons.sports_esports_rounded;
      case 'accessories':
        return Icons.headset_rounded;
      case 'pc':
        return Icons.computer_rounded;
      default:
        return Icons.inventory_2_rounded;
    }
  }
}

// ── Product detail sheet (quick view from store page) ──
class _ProductDetailSheet extends StatelessWidget {
  final SellerProduct product;
  const _ProductDetailSheet({required this.product});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Color(0xFF1A1A1A),
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: const EdgeInsets.fromLTRB(24, 12, 24, 32),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                  color: Colors.grey.shade700,
                  borderRadius: BorderRadius.circular(2)),
            ),
          ),
          const SizedBox(height: 20),

          // Product icon
          Center(
            child: Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: const Color(0xFF222222),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Icon(Icons.videogame_asset_rounded,
                  color: const Color(0xFFE63946), size: 36),
            ),
          ),
          const SizedBox(height: 16),

          Text(product.brand,
              style: TextStyle(
                  color: const Color(0xFFE63946),
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1)),
          const SizedBox(height: 4),
          Text(product.name,
              style: GoogleFonts.orbitron(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Row(
            children: [
              Text('\$${product.price.toStringAsFixed(2)}',
                  style: GoogleFonts.orbitron(
                      color: const Color(0xFFE63946),
                      fontSize: 22,
                      fontWeight: FontWeight.bold)),
              if (product.hasDiscount) ...[
                const SizedBox(width: 10),
                Text('\$${product.originalPrice!.toStringAsFixed(2)}',
                    style: TextStyle(
                        color: Colors.grey.shade600,
                        fontSize: 14,
                        decoration: TextDecoration.lineThrough)),
                const SizedBox(width: 6),
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: Colors.green.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text('-${product.discountPercent}%',
                      style: const TextStyle(
                          color: Colors.green,
                          fontSize: 11,
                          fontWeight: FontWeight.bold)),
                ),
              ],
            ],
          ),
          const SizedBox(height: 14),
          Text(product.description,
              style: GoogleFonts.poppins(
                  color: Colors.grey.shade400, fontSize: 13),
              maxLines: 3,
              overflow: TextOverflow.ellipsis),
          const SizedBox(height: 8),

          // From store
          Row(
            children: [
              const Icon(Icons.store_rounded,
                  size: 13, color: Colors.grey),
              const SizedBox(width: 5),
              Text('Sold by ',
                  style: TextStyle(
                      color: Colors.grey.shade600, fontSize: 11)),
              Text(product.storeName,
                  style: GoogleFonts.poppins(
                      color: const Color(0xFFE63946),
                      fontSize: 11,
                      fontWeight: FontWeight.bold)),
            ],
          ),

          const SizedBox(height: 20),

          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () => Navigator.pop(context),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.grey,
                    side: const BorderSide(color: Colors.grey),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                  ),
                  child: Text('Close',
                      style: GoogleFonts.poppins(
                          fontWeight: FontWeight.w600)),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                flex: 2,
                child: ElevatedButton.icon(
                  onPressed: () {
                    // Add to cart (convert SellerProduct to something cart understands)
                    // For now show snackbar
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                      content: Text('${product.name} added to cart!'),
                      backgroundColor: Colors.green,
                      behavior: SnackBarBehavior.floating,
                    ));
                  },
                  icon: const Icon(Icons.add_shopping_cart_rounded,
                      size: 16),
                  label: Text('Add to Cart',
                      style: GoogleFonts.poppins(
                          fontWeight: FontWeight.bold)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFE63946),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
