// lib/views/seller/seller_products_screen.dart

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../providers/seller_provider.dart';
import '../../models/seller_model.dart';
import 'seller_add_product_screen.dart';

class SellerProductsScreen extends StatefulWidget {
  const SellerProductsScreen({super.key});

  @override
  State<SellerProductsScreen> createState() => _SellerProductsScreenState();
}

class _SellerProductsScreenState extends State<SellerProductsScreen> {
  String _filter = 'All';
  String _searchQuery = '';
  final _searchCtrl = TextEditingController();
  final _filters = ['All', 'Active', 'Hidden', 'Low Stock'];

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  List<SellerProduct> _filtered(List<SellerProduct> all) {
    var list = all;
    if (_filter == 'Active') list = list.where((p) => p.isActive).toList();
    if (_filter == 'Hidden') list = list.where((p) => !p.isActive).toList();
    if (_filter == 'Low Stock') list = list.where((p) => p.stock < 5).toList();
    if (_searchQuery.isNotEmpty) {
      final q = _searchQuery.toLowerCase();
      list = list
          .where((p) =>
              p.name.toLowerCase().contains(q) ||
              p.brand.toLowerCase().contains(q) ||
              p.category.toLowerCase().contains(q))
          .toList();
    }
    return list;
  }

  @override
  Widget build(BuildContext context) {
    final seller = context.watch<SellerProvider>();
    final filtered = _filtered(seller.products);

    return Scaffold(
      backgroundColor: const Color(0xFF0D0D0D),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const SellerAddProductScreen()),
        ),
        backgroundColor: const Color(0xFFE63946),
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add),
        label: Text('Add Product', style: GoogleFonts.poppins(fontWeight: FontWeight.bold)),
      ),
      body: Column(
        children: [
          // Header
          Container(
            padding: const EdgeInsets.fromLTRB(20, 52, 20, 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('MY PRODUCTS',
                        style: GoogleFonts.orbitron(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.bold)),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: const Color(0xFFE63946).withOpacity(0.15),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                            color: const Color(0xFFE63946).withOpacity(0.3)),
                      ),
                      child: Text(
                        '${seller.totalProducts} total',
                        style: GoogleFonts.poppins(
                            color: const Color(0xFFE63946),
                            fontSize: 12,
                            fontWeight: FontWeight.w600),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                // Search
                TextField(
                  controller: _searchCtrl,
                  onChanged: (v) => setState(() => _searchQuery = v),
                  style: GoogleFonts.poppins(color: Colors.white, fontSize: 13),
                  decoration: InputDecoration(
                    hintText: 'Search products...',
                    hintStyle: GoogleFonts.poppins(
                        color: Colors.grey.shade600, fontSize: 13),
                    prefixIcon:
                        Icon(Icons.search, color: Colors.grey.shade600, size: 20),
                    filled: true,
                    fillColor: const Color(0xFF1A1A1A),
                    contentPadding:
                        const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                    suffixIcon: _searchQuery.isNotEmpty
                        ? GestureDetector(
                            onTap: () {
                              _searchCtrl.clear();
                              setState(() => _searchQuery = '');
                            },
                            child: Icon(Icons.close,
                                color: Colors.grey.shade600, size: 18),
                          )
                        : null,
                  ),
                ),
                const SizedBox(height: 12),
                // Filter chips
                SizedBox(
                  height: 32,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    separatorBuilder: (_, __) => const SizedBox(width: 8),
                    itemCount: _filters.length,
                    itemBuilder: (context, i) {
                      final active = _filters[i] == _filter;
                      return GestureDetector(
                        onTap: () => setState(() => _filter = _filters[i]),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 180),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 14, vertical: 6),
                          decoration: BoxDecoration(
                            color: active
                                ? const Color(0xFFE63946)
                                : const Color(0xFF1A1A1A),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: active
                                  ? const Color(0xFFE63946)
                                  : Colors.grey.shade800,
                            ),
                          ),
                          child: Text(_filters[i],
                              style: GoogleFonts.poppins(
                                  color:
                                      active ? Colors.white : Colors.grey.shade500,
                                  fontSize: 12,
                                  fontWeight: active
                                      ? FontWeight.bold
                                      : FontWeight.normal)),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),

          // Product list
          Expanded(
            child: filtered.isEmpty
                ? _buildEmpty()
                : ListView.builder(
                    padding: const EdgeInsets.fromLTRB(20, 0, 20, 100),
                    itemCount: filtered.length,
                    itemBuilder: (context, i) =>
                        _SellerProductCard(product: filtered[i]),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmpty() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.inventory_2_outlined,
              size: 64, color: Colors.grey.shade800),
          const SizedBox(height: 16),
          Text(
              _searchQuery.isNotEmpty || _filter != 'All'
                  ? 'No matching products'
                  : 'No products yet',
              style: GoogleFonts.orbitron(
                  color: Colors.grey.shade600, fontSize: 14)),
          const SizedBox(height: 8),
          Text(
              _searchQuery.isNotEmpty
                  ? 'Try a different search term'
                  : 'Tap + to add your first product',
              style: GoogleFonts.poppins(
                  color: Colors.grey.shade700, fontSize: 12)),
        ],
      ),
    );
  }
}

class _SellerProductCard extends StatelessWidget {
  final SellerProduct product;
  const _SellerProductCard({required this.product});

  @override
  Widget build(BuildContext context) {
    final seller = context.read<SellerProvider>();

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: const Color(0xFF161616),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: product.isActive
              ? Colors.white.withOpacity(0.07)
              : Colors.grey.withOpacity(0.15),
        ),
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(14),
            child: Row(
              children: [
                // Product icon/image
                Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    color: const Color(0xFF222222),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    _categoryIcon(product.category),
                    color: const Color(0xFFE63946),
                    size: 26,
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(product.name,
                                style: GoogleFonts.poppins(
                                    color: Colors.white,
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600),
                                overflow: TextOverflow.ellipsis),
                          ),
                          const SizedBox(width: 8),
                          _statusBadge(product),
                        ],
                      ),
                      const SizedBox(height: 3),
                      Text('${product.brand}  ·  ${product.category}',
                          style: TextStyle(
                              color: Colors.grey.shade500, fontSize: 11)),
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          Text(
                            '\$${product.price.toStringAsFixed(2)}',
                            style: GoogleFonts.orbitron(
                                color: const Color(0xFFE63946),
                                fontSize: 14,
                                fontWeight: FontWeight.bold),
                          ),
                          if (product.hasDiscount) ...[
                            const SizedBox(width: 6),
                            Text(
                              '\$${product.originalPrice!.toStringAsFixed(2)}',
                              style: TextStyle(
                                  color: Colors.grey.shade600,
                                  fontSize: 11,
                                  decoration: TextDecoration.lineThrough),
                            ),
                          ],
                          const Spacer(),
                          _stockIndicator(product.stock),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          // Actions row
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.03),
              borderRadius: const BorderRadius.vertical(
                  bottom: Radius.circular(14)),
            ),
            child: Row(
              children: [
                if (product.reviewCount > 0) ...[
                  const Icon(Icons.star_rounded,
                      color: Colors.amber, size: 14),
                  const SizedBox(width: 3),
                  Text(
                    '${product.rating.toStringAsFixed(1)} (${product.reviewCount})',
                    style: TextStyle(
                        color: Colors.grey.shade500, fontSize: 11),
                  ),
                ] else
                  Text('No reviews yet',
                      style: TextStyle(
                          color: Colors.grey.shade700, fontSize: 11)),
                const Spacer(),
                // Edit
                _ActionBtn(
                  icon: Icons.edit_rounded,
                  color: const Color(0xFF6C63FF),
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) =>
                          SellerAddProductScreen(editProduct: product),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                // Toggle active
                _ActionBtn(
                  icon: product.isActive
                      ? Icons.visibility_off_rounded
                      : Icons.visibility_rounded,
                  color: product.isActive ? Colors.amber : Colors.green,
                  onTap: () => seller.toggleProductActive(product.id),
                ),
                const SizedBox(width: 8),
                // Delete
                _ActionBtn(
                  icon: Icons.delete_rounded,
                  color: Colors.red.shade700,
                  onTap: () => _confirmDelete(context, seller),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _statusBadge(SellerProduct p) {
    final isActive = p.isActive;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
      decoration: BoxDecoration(
        color: isActive
            ? Colors.green.withOpacity(0.15)
            : Colors.grey.withOpacity(0.15),
        borderRadius: BorderRadius.circular(4),
        border: Border.all(
            color: isActive
                ? Colors.green.withOpacity(0.4)
                : Colors.grey.withOpacity(0.3)),
      ),
      child: Text(
        isActive ? 'LIVE' : 'HIDDEN',
        style: TextStyle(
            color: isActive ? Colors.green : Colors.grey,
            fontSize: 9,
            fontWeight: FontWeight.bold,
            letterSpacing: 0.5),
      ),
    );
  }

  Widget _stockIndicator(int stock) {
    final color = stock == 0
        ? Colors.red
        : stock < 5
            ? Colors.orange
            : Colors.green;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
            width: 6,
            height: 6,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
        const SizedBox(width: 4),
        Text('$stock in stock',
            style: TextStyle(color: color, fontSize: 10)),
      ],
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
      case 'merchandise':
        return Icons.shopping_bag_rounded;
      default:
        return Icons.inventory_2_rounded;
    }
  }

  void _confirmDelete(BuildContext context, SellerProvider seller) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF1E1E1E),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text('Delete Product',
            style: GoogleFonts.orbitron(
                color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
        content: Text(
            'Remove "${product.name}" from your store? This cannot be undone.',
            style: GoogleFonts.poppins(color: Colors.grey.shade400)),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: Text('Cancel',
                  style: GoogleFonts.poppins(color: Colors.grey))),
          TextButton(
            onPressed: () {
              seller.deleteProduct(product.id);
              Navigator.pop(ctx);
            },
            child: Text('Delete',
                style: GoogleFonts.poppins(
                    color: Colors.red, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }
}

class _ActionBtn extends StatelessWidget {
  final IconData icon;
  final Color color;
  final VoidCallback onTap;
  const _ActionBtn(
      {required this.icon, required this.color, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(7),
        decoration: BoxDecoration(
          color: color.withOpacity(0.12),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: color.withOpacity(0.25)),
        ),
        child: Icon(icon, color: color, size: 16),
      ),
    );
  }
}
