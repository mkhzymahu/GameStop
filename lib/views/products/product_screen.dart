// lib/views/products/product_screen.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../providers/product_provider.dart';
import '../../providers/cart_provider.dart';
import '../../providers/wishlist_provider.dart';
import '../../models/product_model.dart';
import '../../app/theme/app_theme.dart';

class ProductsScreen extends StatefulWidget {
  const ProductsScreen({super.key});

  @override
  State<ProductsScreen> createState() => _ProductsScreenState();
}

class _ProductsScreenState extends State<ProductsScreen>
    with TickerProviderStateMixin {
  final TextEditingController _searchController = TextEditingController();
  final ScrollController _gridScrollController = ScrollController();
  final ScrollController _categoryScrollController = ScrollController();
  bool _isSearching = false;
  String? _activeFilter;
  late AnimationController _cartAnimationController;

  // Image map for hardcoded products
  static const Map<String, String> _productImages = {
    'prod1': 'https://images.unsplash.com/photo-1587202372775-e229f172b9d7?w=400&auto=format',
    'prod2': 'https://images.unsplash.com/photo-1555617778-6b8591a12c7c?w=400&auto=format',
    'prod3': 'https://images.unsplash.com/photo-1562976540-1502c2145186?w=400&auto=format',
    'prod4': 'https://images.unsplash.com/photo-1542751371-adc38448a05e?w=400&auto=format',
    'prod5': 'https://images.unsplash.com/photo-1538481199705-c710c4e965fc?w=400&auto=format',
    'prod6': 'https://images.unsplash.com/photo-1598550476439-6847785fcea6?w=400&auto=format',
    'prod7': 'https://images.unsplash.com/photo-1587202372775-e229f172b9d7?w=400&auto=format',
    'prod8': 'https://images.unsplash.com/photo-1615663245857-ac93bb7c39e7?w=400&auto=format',
    'prod9': 'https://images.unsplash.com/photo-1586210579191-33b45e38fa2c?w=400&auto=format',
    'prod10': 'https://images.unsplash.com/photo-1505740420928-5e560c06d30e?w=400&auto=format',
  };

  @override
  void initState() {
    super.initState();
    _cartAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ProductProvider>().refreshProducts();
    });
  }

  @override
  void dispose() {
    _cartAnimationController.dispose();
    _searchController.dispose();
    _gridScrollController.dispose();
    _categoryScrollController.dispose();
    super.dispose();
  }

  String _getImageUrl(ProductModel product) {
    // Seller products — use their first imageUrl if available
    if (product.isSellerProduct) {
      if (product.images != null && product.images!.isNotEmpty) {
        return product.images!.first;
      }
      return 'https://placehold.co/400x400/1A1A2E/6C63FF?text=${Uri.encodeComponent(product.name)}';
    }
    // Hardcoded products use the local map
    return _productImages[product.id] ??
        'https://placehold.co/400x400/3A3A3A/5A5A5A?text=Loading';
  }

  List<ProductModel> _applyLocalFilter(List<ProductModel> products) {
    if (_activeFilter == null) return products;
    switch (_activeFilter) {
      case 'inStock':
        return products.where((p) => p.inStock != false).toList();
      case 'onSale':
        return products.where((p) => p.discountPrice != null).toList();
      case 'new':
        return products.where((p) => p.isNew == true).toList();
      case 'topRated':
        final sorted = [...products]..sort((a, b) => b.rating.compareTo(a.rating));
        return sorted;
      default:
        return products;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.darkGrey,
      appBar: AppBar(
        backgroundColor: AppTheme.darkGrey,
        elevation: 0,
        leading: _isSearching
            ? null
            : IconButton(
                icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
                onPressed: () => context.go('/home'),
              ),
        title: _isSearching
            ? TextField(
                controller: _searchController,
                autofocus: true,
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  hintText: 'Search products, brands, tags...',
                  hintStyle: TextStyle(color: Colors.grey.shade600),
                  border: InputBorder.none,
                  prefixIcon: const Icon(Icons.search, color: AppTheme.primaryRed),
                  suffixIcon: IconButton(
                    icon: const Icon(Icons.clear, color: Colors.grey),
                    onPressed: () {
                      setState(() {
                        _searchController.clear();
                        context.read<ProductProvider>().setSearchQuery('');
                        _isSearching = false;
                      });
                    },
                  ),
                ),
                onChanged: (value) =>
                    context.read<ProductProvider>().setSearchQuery(value),
              )
            : Text(
                'GAMESTOP',
                style: GoogleFonts.orbitron(
                  fontWeight: FontWeight.bold,
                  color: AppTheme.primaryRed,
                  letterSpacing: 2,
                ),
              ),
        actions: [
          if (!_isSearching)
            IconButton(
              icon: const Icon(Icons.search, color: AppTheme.primaryRed),
              onPressed: () => setState(() => _isSearching = true),
            ),
          Stack(
            children: [
              IconButton(
                icon: const Icon(Icons.shopping_cart, color: AppTheme.primaryRed),
                onPressed: () {
                  _cartAnimationController.forward().then((_) {
                    _cartAnimationController.reverse();
                    context.go('/cart');
                  });
                },
              ),
              Positioned(
                right: 8, top: 8,
                child: Consumer<CartProvider>(
                  builder: (context, cart, _) {
                    if (cart.itemCount == 0) return const SizedBox();
                    return Container(
                      padding: const EdgeInsets.all(2),
                      decoration: const BoxDecoration(
                          color: AppTheme.primaryRed, shape: BoxShape.circle),
                      constraints: const BoxConstraints(minWidth: 18, minHeight: 18),
                      child: Text('${cart.itemCount}',
                          style: const TextStyle(
                              color: Colors.white, fontSize: 10,
                              fontWeight: FontWeight.bold),
                          textAlign: TextAlign.center),
                    );
                  },
                ),
              ),
            ],
          ),
        ],
      ),
      body: Column(
        children: [
          // Category chips
          Container(
            height: 100,
            margin: const EdgeInsets.only(top: 10),
            child: Consumer<ProductProvider>(
              builder: (context, pp, _) => ListView.builder(
                controller: _categoryScrollController,
                scrollDirection: Axis.horizontal,
                itemCount: pp.categories.length,
                padding: const EdgeInsets.symmetric(horizontal: 15),
                itemBuilder: (context, index) {
                  final cat = pp.categories[index];
                  final isSelected = pp.selectedCategory == cat.id;
                  return GestureDetector(
                    onTap: () {
                      pp.setSelectedCategory(isSelected ? null : cat.id);
                      _gridScrollController.animateTo(0,
                          duration: const Duration(milliseconds: 500),
                          curve: Curves.easeInOut);
                    },
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      width: 90,
                      margin: const EdgeInsets.only(right: 10),
                      decoration: BoxDecoration(
                        color: isSelected ? AppTheme.primaryRed : AppTheme.darkGrey,
                        borderRadius: BorderRadius.circular(15),
                        border: Border.all(
                          color: isSelected ? Colors.transparent : Colors.grey.shade800,
                        ),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(_getCategoryIcon(cat.icon),
                              color: isSelected ? Colors.white : AppTheme.primaryRed,
                              size: 30),
                          const SizedBox(height: 5),
                          Text(cat.name,
                              style: TextStyle(
                                color: isSelected ? Colors.white : Colors.grey.shade400,
                                fontSize: 11,
                                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                              ),
                              textAlign: TextAlign.center,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ),

          // Filter chips
          SizedBox(
            height: 40,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 15),
              physics: const BouncingScrollPhysics(),
              children: [
                _buildFilterChip('All', null),
                _buildFilterChip('In Stock', 'inStock'),
                _buildFilterChip('On Sale', 'onSale'),
                _buildFilterChip('New', 'new'),
                _buildFilterChip('Top Rated', 'topRated'),
              ],
            ),
          ),
          const SizedBox(height: 10),

          // Product count
          Consumer<ProductProvider>(
            builder: (context, pp, _) {
              final count = _applyLocalFilter(pp.filteredProducts).length;
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  children: [
                    Text('$count products',
                        style: GoogleFonts.poppins(
                            color: Colors.grey.shade600, fontSize: 11)),
                    const Spacer(),
                    // Show how many are from sellers
                    Builder(builder: (_) {
                      final sellerCount = _applyLocalFilter(pp.filteredProducts)
                          .where((p) => p.isSellerProduct)
                          .length;
                      if (sellerCount == 0) return const SizedBox();
                      return Text('$sellerCount from sellers',
                          style: GoogleFonts.poppins(
                              color: Colors.grey.shade700, fontSize: 10));
                    }),
                  ],
                ),
              );
            },
          ),
          const SizedBox(height: 6),

          // Grid
          Expanded(
            child: Consumer<ProductProvider>(
              builder: (context, pp, _) {
                if (pp.isLoading) {
                  return const Center(
                    child: CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(AppTheme.primaryRed)),
                  );
                }

                final products = _applyLocalFilter(pp.filteredProducts);

                if (products.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.search_off, size: 80, color: Colors.grey.shade800),
                        const SizedBox(height: 20),
                        Text('No products found',
                            style: GoogleFonts.poppins(
                                fontSize: 18, color: Colors.grey.shade600)),
                        const SizedBox(height: 10),
                        ElevatedButton(
                          onPressed: () {
                            pp.clearFilters();
                            _searchController.clear();
                            setState(() {
                              _isSearching = false;
                              _activeFilter = null;
                            });
                          },
                          style: ElevatedButton.styleFrom(
                              backgroundColor: AppTheme.primaryRed,
                              foregroundColor: Colors.white),
                          child: const Text('Clear filters'),
                        ),
                      ],
                    ),
                  );
                }

                return GridView.builder(
                  controller: _gridScrollController,
                  padding: const EdgeInsets.all(15),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    childAspectRatio: 0.68,
                    crossAxisSpacing: 15,
                    mainAxisSpacing: 15,
                  ),
                  itemCount: products.length,
                  itemBuilder: (context, index) => ProductCard(
                    product: products[index],
                    imageUrl: _getImageUrl(products[index]),
                    index: index,
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String label, String? filter) {
    final isSelected = _activeFilter == filter;
    return Container(
      margin: const EdgeInsets.only(right: 8),
      child: FilterChip(
        label: Text(label),
        selected: isSelected,
        onSelected: (selected) =>
            setState(() => _activeFilter = selected ? filter : null),
        backgroundColor: AppTheme.darkGrey,
        selectedColor: AppTheme.primaryRed,
        checkmarkColor: Colors.white,
        labelStyle: TextStyle(
          color: Colors.white,
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: BorderSide(
            color: isSelected ? AppTheme.primaryRed : Colors.grey.shade800,
          ),
        ),
      ),
    );
  }

  IconData _getCategoryIcon(String iconName) {
    switch (iconName) {
      case 'computer': return Icons.computer;
      case 'sports_esports': return Icons.sports_esports;
      case 'chair': return Icons.chair;
      case 'keyboard': return Icons.keyboard;
      case 'mouse': return Icons.mouse;
      case 'monitor': return Icons.monitor;
      case 'headset': return Icons.headset;
      case 'usb': return Icons.usb;
      default: return Icons.category;
    }
  }
}

// ── Product card ──
class ProductCard extends StatelessWidget {
  final ProductModel product;
  final String imageUrl;
  final int index;

  const ProductCard({
    super.key,
    required this.product,
    required this.imageUrl,
    required this.index,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () =>
          context.pushNamed('productDetail', pathParameters: {'id': product.id}),
      child: TweenAnimationBuilder(
        tween: Tween<double>(begin: 0.0, end: 1.0),
        duration: Duration(milliseconds: 300 + (index * 50)),
        curve: Curves.easeOut,
        builder: (context, double value, child) =>
            Transform.scale(scale: value, child: Opacity(opacity: value, child: child)),
        child: Container(
          decoration: BoxDecoration(
            color: const Color(0xFF161616),
            borderRadius: BorderRadius.circular(15),
            border: Border.all(color: Colors.grey.shade800),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Image + badges
              Stack(
                children: [
                  AspectRatio(
                    aspectRatio: 16 / 9,
                    child: ClipRRect(
                      borderRadius:
                          const BorderRadius.vertical(top: Radius.circular(15)),
                      child: product.isSellerProduct &&
                              (product.images == null || product.images!.isEmpty)
                          ? Container(
                              color: const Color(0xFF1A1A2E),
                              child: Center(
                                child: Icon(Icons.videogame_asset_rounded,
                                    color: const Color(0xFF6C63FF).withOpacity(0.4),
                                    size: 40),
                              ),
                            )
                          : CachedNetworkImage(
                              imageUrl: imageUrl,
                              fit: BoxFit.cover,
                              placeholder: (_, __) =>
                                  Container(color: Colors.grey.shade900),
                              errorWidget: (_, __, ___) => Container(
                                color: Colors.grey.shade900,
                                child: Center(
                                  child: Icon(Icons.image_not_supported,
                                      color: Colors.grey.shade600, size: 40),
                                ),
                              ),
                            ),
                    ),
                  ),
                  // Discount badge
                  if (product.discountPrice != null)
                    Positioned(
                      top: 8, left: 8,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                        decoration: BoxDecoration(
                          color: AppTheme.primaryRed,
                          borderRadius: BorderRadius.circular(5),
                        ),
                        child: Text('-${product.discountPercentage.toInt()}%',
                            style: const TextStyle(
                                color: Colors.white, fontSize: 9,
                                fontWeight: FontWeight.bold)),
                      ),
                    ),
                  // NEW badge
                  if (product.isNew == true)
                    Positioned(
                      top: 8,
                      left: product.discountPrice != null ? 50 : 8,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                        decoration: BoxDecoration(
                          color: AppTheme.primaryBlue,
                          borderRadius: BorderRadius.circular(5),
                        ),
                        child: const Text('NEW',
                            style: TextStyle(
                                color: Colors.white, fontSize: 9,
                                fontWeight: FontWeight.bold)),
                      ),
                    ),
                  // Wishlist
                  Positioned(
                    top: 8, right: 8,
                    child: Consumer<WishlistProvider>(
                      builder: (context, wishlist, _) {
                        final inWishlist = wishlist.isInWishlist(product.id);
                        return GestureDetector(
                          onTap: () {
                            wishlist.toggle(product);
                            final isNow = wishlist.isInWishlist(product.id);
                            ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                              content: Text(isNow
                                  ? '${product.name} added to wishlist'
                                  : '${product.name} removed from wishlist'),
                              backgroundColor:
                                  isNow ? AppTheme.primaryRed : Colors.grey,
                              behavior: SnackBarBehavior.floating,
                              duration: const Duration(seconds: 1),
                            ));
                          },
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            padding: const EdgeInsets.all(5),
                            decoration: BoxDecoration(
                              color: Colors.black.withOpacity(0.5),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              inWishlist ? Icons.favorite : Icons.favorite_border,
                              color: inWishlist ? AppTheme.primaryRed : Colors.white,
                              size: 15,
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),

              // Info
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(10, 8, 10, 8),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // ── Attribution badge ──
                      Row(
                        children: [
                          Expanded(
                            child: product.isSellerProduct
                                ? Row(
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 5, vertical: 2),
                                        decoration: BoxDecoration(
                                          color: const Color(0xFF6C63FF)
                                              .withOpacity(0.15),
                                          borderRadius: BorderRadius.circular(4),
                                          border: Border.all(
                                              color: const Color(0xFF6C63FF)
                                                  .withOpacity(0.3)),
                                        ),
                                        child: Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            const Icon(Icons.storefront,
                                                color: Color(0xFF6C63FF),
                                                size: 8),
                                            const SizedBox(width: 3),
                                            Flexible(
                                              child: Text(
                                                product.sellerName ?? 'Seller',
                                                style: const TextStyle(
                                                  color: Color(0xFF6C63FF),
                                                  fontSize: 8,
                                                  fontWeight: FontWeight.w600,
                                                ),
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  )
                                : Row(
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 5, vertical: 2),
                                        decoration: BoxDecoration(
                                          color: AppTheme.primaryRed
                                              .withOpacity(0.12),
                                          borderRadius: BorderRadius.circular(4),
                                          border: Border.all(
                                              color: AppTheme.primaryRed
                                                  .withOpacity(0.3)),
                                        ),
                                        child: const Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Icon(Icons.verified,
                                                color: AppTheme.primaryRed,
                                                size: 8),
                                            SizedBox(width: 3),
                                            Text(
                                              'GAMESTOP',
                                              style: TextStyle(
                                                color: AppTheme.primaryRed,
                                                fontSize: 8,
                                                fontWeight: FontWeight.bold,
                                                letterSpacing: 0.5,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),

                      // Brand
                      Text(
                        product.brand.toUpperCase(),
                        style: const TextStyle(
                            color: AppTheme.primaryRed,
                            fontSize: 8,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 0.5),
                      ),
                      const SizedBox(height: 3),

                      // Name
                      Text(
                        product.name,
                        style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.w600),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 3),

                      // Rating
                      Row(
                        children: [
                          const Icon(Icons.star, color: Colors.amber, size: 10),
                          const SizedBox(width: 2),
                          Text(product.rating.toString(),
                              style: TextStyle(
                                  color: Colors.grey.shade400, fontSize: 9)),
                          const SizedBox(width: 4),
                          Text('(${product.reviewCount ?? 0})',
                              style: TextStyle(
                                  color: Colors.grey.shade600, fontSize: 9)),
                        ],
                      ),

                      const Spacer(),

                      // Price + cart button
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              if (product.discountPrice != null)
                                Text(
                                  '\$${product.price.toStringAsFixed(2)}',
                                  style: TextStyle(
                                      color: Colors.grey.shade600,
                                      fontSize: 9,
                                      decoration: TextDecoration.lineThrough),
                                ),
                              Text(
                                '\$${product.finalPrice.toStringAsFixed(2)}',
                                style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 13,
                                    fontWeight: FontWeight.bold),
                              ),
                            ],
                          ),
                          GestureDetector(
                            onTap: () {
                              context.read<CartProvider>().addToCart(product);
                              ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                                content: Text('${product.name} added to cart'),
                                backgroundColor: AppTheme.primaryRed,
                                duration: const Duration(seconds: 1),
                                behavior: SnackBarBehavior.floating,
                                action: SnackBarAction(
                                  label: 'VIEW',
                                  textColor: Colors.white,
                                  onPressed: () => context.go('/cart'),
                                ),
                              ));
                            },
                            child: Container(
                              decoration: BoxDecoration(
                                color: AppTheme.primaryRed,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              padding: const EdgeInsets.all(7),
                              child: const Icon(Icons.add_shopping_cart,
                                  color: Colors.white, size: 15),
                            ),
                          ),
                        ],
                      ),

                      if (product.inStock == false)
                        Padding(
                          padding: const EdgeInsets.only(top: 4),
                          child: Text('Out of stock',
                              style: TextStyle(
                                  color: Colors.red.shade700,
                                  fontSize: 9,
                                  fontWeight: FontWeight.bold)),
                        ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
