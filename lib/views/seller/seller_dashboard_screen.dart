// lib/views/seller/seller_dashboard_screen.dart

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../providers/seller_provider.dart';
import '../../providers/auth_provider.dart';
import '../../models/seller_model.dart';
import 'seller_products_screen.dart';
import 'seller_add_product_screen.dart';
import 'seller_profile_screen.dart';
import 'seller_orders_screen.dart';
import 'seller_analytics_screen.dart';
import 'store_page_screen.dart';

class SellerDashboardScreen extends StatefulWidget {
  const SellerDashboardScreen({super.key});

  @override
  State<SellerDashboardScreen> createState() => _SellerDashboardScreenState();
}

class _SellerDashboardScreenState extends State<SellerDashboardScreen> {
  int _selectedIndex = 0;

  static const _navItems = [
    _NavItem(Icons.dashboard_rounded, 'Dashboard'),
    _NavItem(Icons.inventory_2_rounded, 'Products'),
    _NavItem(Icons.bar_chart_rounded, 'Analytics'),
    _NavItem(Icons.receipt_long_rounded, 'Orders'),
    _NavItem(Icons.store_rounded, 'Store'),
  ];

  Widget _buildPage(int index) {
    switch (index) {
      case 0:
        return const _DashboardHome();
      case 1:
        return const SellerProductsScreen();
      case 2:
        return const SellerAnalyticsScreen();
      case 3:
        return const SellerOrdersScreen();
      case 4:
        return const SellerProfileScreen();
      default:
        return const _DashboardHome();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0D0D0D),
      body: Row(
        children: [
          // ── Left rail nav ──
          _SellerRailNav(
            selectedIndex: _selectedIndex,
            items: _navItems,
            onTap: (i) => setState(() => _selectedIndex = i),
          ),
          // ── Main content ──
          Expanded(
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 250),
              transitionBuilder: (child, anim) => FadeTransition(
                opacity: anim,
                child: SlideTransition(
                  position: Tween<Offset>(
                          begin: const Offset(0.03, 0), end: Offset.zero)
                      .animate(anim),
                  child: child,
                ),
              ),
              child: KeyedSubtree(
                key: ValueKey(_selectedIndex),
                child: _buildPage(_selectedIndex),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Side rail nav ──
class _SellerRailNav extends StatelessWidget {
  final int selectedIndex;
  final List<_NavItem> items;
  final ValueChanged<int> onTap;

  const _SellerRailNav({
    required this.selectedIndex,
    required this.items,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final seller = context.watch<SellerProvider>();
    final storeName =
        seller.store?.storeName ?? auth.currentUser?.name ?? 'Seller';
    final initials = storeName.isNotEmpty
        ? storeName
            .trim()
            .split(' ')
            .take(2)
            .map((w) => w[0].toUpperCase())
            .join()
        : 'S';

    return Container(
      width: 72,
      color: const Color(0xFF161616),
      child: Column(
        children: [
          const SizedBox(height: 20),
          // Logo
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 12),
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFFE63946), Color(0xFFFF6B6B)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(14),
            ),
      child: const Icon(
  Icons.sports_esports_rounded,
  color: Colors.white,
  size: 36,
),
          ),
          const SizedBox(height: 28),
          Divider(color: Colors.white.withOpacity(0.07), height: 1),
          const SizedBox(height: 12),
          // Nav items
          Expanded(
            child: ListView.builder(
              padding: EdgeInsets.zero,
              itemCount: items.length,
              itemBuilder: (context, i) {
                final selected = i == selectedIndex;
                return GestureDetector(
                  onTap: () => onTap(i),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    margin: const EdgeInsets.symmetric(
                        horizontal: 8, vertical: 4),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    decoration: BoxDecoration(
                      color: selected
                          ? const Color(0xFFE63946).withOpacity(0.15)
                          : Colors.transparent,
                      borderRadius: BorderRadius.circular(12),
                      border: selected
                          ? Border.all(
                              color: const Color(0xFFE63946).withOpacity(0.4),
                              width: 1)
                          : null,
                    ),
                    child: Column(
                      children: [
                        Icon(
                          items[i].icon,
                          color: selected
                              ? const Color(0xFFE63946)
                              : Colors.grey.shade600,
                          size: 22,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          items[i].label,
                          style: TextStyle(
                            color: selected
                                ? const Color(0xFFE63946)
                                : Colors.grey.shade600,
                            fontSize: 9,
                            fontWeight: selected
                                ? FontWeight.bold
                                : FontWeight.normal,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          Divider(color: Colors.white.withOpacity(0.07), height: 1),
          const SizedBox(height: 12),
          // Avatar / logout
          GestureDetector(
            onTap: () => _showLogoutDialog(context),
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 12),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFF222222),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                initials,
                style: GoogleFonts.orbitron(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 13),
                textAlign: TextAlign.center,
              ),
            ),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF1E1E1E),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text('Sign Out',
            style: GoogleFonts.orbitron(
                color: Colors.white, fontWeight: FontWeight.bold)),
        content: Text(
            'Are you sure you want to sign out of your seller account?',
            style: GoogleFonts.poppins(color: Colors.grey.shade400)),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: Text('Cancel',
                  style: GoogleFonts.poppins(color: Colors.grey))),
          TextButton(
            onPressed: () async {
              // Close the dialog first
              Navigator.pop(ctx);

              // Clear all provider state
              await context.read<AuthProvider>().logout();
              await context.read<SellerProvider>().clearForLogout();

              // Use GoRouter to navigate — works correctly unlike pushNamedAndRemoveUntil
              if (context.mounted) {
                context.go('/auth');
              }
            },
            child: Text('Sign Out',
                style:
                    GoogleFonts.poppins(color: const Color(0xFFE63946))),
          ),
        ],
      ),
    );
  }
}

// ── Dashboard home page ──
class _DashboardHome extends StatelessWidget {
  const _DashboardHome();

  @override
  Widget build(BuildContext context) {
    final seller = context.watch<SellerProvider>();
    final auth = context.watch<AuthProvider>();
    final store = seller.store;
    final name = store?.storeName ?? auth.currentUser?.name ?? 'Seller';
    final now = DateTime.now();
    final greeting = now.hour < 12
        ? 'Good morning'
        : now.hour < 17
            ? 'Good afternoon'
            : 'Good evening';

    return Scaffold(
      backgroundColor: const Color(0xFF0D0D0D),
      body: CustomScrollView(
        slivers: [
          // ── Header ──
          SliverToBoxAdapter(
            child: Container(
              padding: const EdgeInsets.fromLTRB(28, 52, 28, 24),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '$greeting,',
                          style: GoogleFonts.poppins(
                              color: Colors.grey.shade500, fontSize: 14),
                        ),
                        Text(
                          name,
                          style: GoogleFonts.orbitron(
                              color: Colors.white,
                              fontSize: 22,
                              fontWeight: FontWeight.bold),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  if (store != null && store.isVerified)
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 5),
                      decoration: BoxDecoration(
                        color: Colors.green.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                            color: Colors.green.withOpacity(0.4), width: 1),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.verified,
                              color: Colors.green, size: 14),
                          const SizedBox(width: 4),
                          Text('Verified',
                              style: GoogleFonts.poppins(
                                  color: Colors.green,
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600)),
                        ],
                      ),
                    ),
                ],
              ),
            ),
          ),

          // ── Store setup prompt if no store ──
          if (!seller.hasStore)
            SliverToBoxAdapter(
              child: _StoreSetupBanner(),
            ),

          // ── Stats cards ──
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                children: [
                  Row(
                    children: [
                      Expanded(
                          child: _StatCard(
                        icon: Icons.inventory_2_rounded,
                        label: 'Products',
                        value: seller.totalProducts.toString(),
                        sub: '${seller.activeProductCount} active',
                        color: const Color(0xFF6C63FF),
                      )),
                      const SizedBox(width: 12),
                      Expanded(
                          child: _StatCard(
                        icon: Icons.star_rounded,
                        label: 'Avg Rating',
                        value: seller.avgRating == 0
                            ? '—'
                            : seller.avgRating.toStringAsFixed(1),
                        sub: store != null
                            ? '${store.totalReviews} reviews'
                            : '0 reviews',
                        color: const Color(0xFFFFB347),
                      )),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                          child: _StatCard(
                        icon: Icons.shopping_bag_rounded,
                        label: 'Total Sales',
                        value: store?.totalSales.toString() ?? '0',
                        sub: 'units sold',
                        color: const Color(0xFF4CAF50),
                      )),
                      const SizedBox(width: 12),
                      Expanded(
                          child: _StatCard(
                        icon: Icons.attach_money_rounded,
                        label: 'Revenue',
                        value: '\$${seller.totalRevenue.toStringAsFixed(0)}',
                        sub: 'estimated',
                        color: const Color(0xFFE63946),
                      )),
                    ],
                  ),
                ],
              ),
            ),
          ),

          const SliverToBoxAdapter(child: SizedBox(height: 28)),

          // ── Quick actions ──
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _sectionLabel('QUICK ACTIONS'),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: _QuickAction(
                          icon: Icons.add_box_rounded,
                          label: 'Add Product',
                          color: const Color(0xFFE63946),
                          onTap: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (_) =>
                                    const SellerAddProductScreen()),
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: _QuickAction(
                          icon: Icons.bar_chart_rounded,
                          label: 'Analytics',
                          color: const Color(0xFF6C63FF),
                          onTap: () {},
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: _QuickAction(
                          icon: Icons.storefront_rounded,
                          label: 'View Store',
                          color: const Color(0xFF4CAF50),
                          onTap: () {
                            if (seller.store != null) {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => StorePageScreen(
                                      sellerId: seller.store!.sellerId),
                                ),
                              );
                            }
                          },
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),

          const SliverToBoxAdapter(child: SizedBox(height: 28)),

          // ── Recent products ──
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _sectionLabel('RECENT PRODUCTS'),
                      TextButton(
                        onPressed: () {},
                        child: Text('See all',
                            style: GoogleFonts.poppins(
                                color: const Color(0xFFE63946),
                                fontSize: 12)),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                ],
              ),
            ),
          ),

          if (seller.products.isEmpty)
            SliverToBoxAdapter(
              child: _EmptyProducts(
                onAdd: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (_) => const SellerAddProductScreen()),
                ),
              ),
            )
          else
            SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, i) {
                  if (i >= seller.products.length.clamp(0, 5)) return null;
                  return Padding(
                    padding: const EdgeInsets.fromLTRB(20, 0, 20, 8),
                    child: _ProductMiniTile(product: seller.products[i]),
                  );
                },
                childCount: seller.products.length.clamp(0, 5),
              ),
            ),

          const SliverToBoxAdapter(child: SizedBox(height: 40)),
        ],
      ),
    );
  }
}

// ── Store setup banner ──
class _StoreSetupBanner extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(20, 0, 20, 20),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            const Color(0xFFE63946).withOpacity(0.15),
            const Color(0xFF6C63FF).withOpacity(0.15),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
            color: const Color(0xFFE63946).withOpacity(0.3), width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFFE63946).withOpacity(0.2),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.store_rounded,
                    color: Color(0xFFE63946), size: 20),
              ),
              const SizedBox(width: 12),
              Text('Complete Your Store Setup',
                  style: GoogleFonts.orbitron(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 13)),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            'Add your store details, logo, and description to start selling and attract buyers.',
            style:
                GoogleFonts.poppins(color: Colors.grey.shade400, fontSize: 12),
          ),
          const SizedBox(height: 14),
          ElevatedButton(
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const SellerProfileScreen()),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFE63946),
              foregroundColor: Colors.white,
              padding:
                  const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
            ),
            child: Text('Setup Store',
                style: GoogleFonts.poppins(
                    fontWeight: FontWeight.bold, fontSize: 13)),
          ),
        ],
      ),
    );
  }
}

// ── Stat card ──
class _StatCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final String sub;
  final Color color;

  const _StatCard({
    required this.icon,
    required this.label,
    required this.value,
    required this.sub,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF161616),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.white.withOpacity(0.06)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withOpacity(0.15),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: color, size: 18),
          ),
          const SizedBox(height: 12),
          Text(value,
              style: GoogleFonts.orbitron(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold)),
          const SizedBox(height: 2),
          Text(label,
              style: TextStyle(color: Colors.grey.shade500, fontSize: 11)),
          const SizedBox(height: 2),
          Text(sub,
              style: TextStyle(color: color.withOpacity(0.8), fontSize: 10)),
        ],
      ),
    );
  }
}

// ── Quick action ──
class _QuickAction extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _QuickAction({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: color.withOpacity(0.25)),
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 24),
            const SizedBox(height: 6),
            Text(label,
                style: GoogleFonts.poppins(
                    color: color,
                    fontSize: 10,
                    fontWeight: FontWeight.w600),
                textAlign: TextAlign.center),
          ],
        ),
      ),
    );
  }
}

// ── Product mini tile ──
class _ProductMiniTile extends StatelessWidget {
  final SellerProduct product;
  const _ProductMiniTile({required this.product});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFF161616),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withOpacity(0.06)),
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: const Color(0xFF222222),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(Icons.videogame_asset_rounded,
                color: Color(0xFFE63946), size: 22),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(product.name,
                    style: GoogleFonts.poppins(
                        color: Colors.white,
                        fontSize: 13,
                        fontWeight: FontWeight.w600),
                    overflow: TextOverflow.ellipsis),
                Text(product.category,
                    style:
                        TextStyle(color: Colors.grey.shade500, fontSize: 11)),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text('\$${product.price.toStringAsFixed(2)}',
                  style: GoogleFonts.orbitron(
                      color: const Color(0xFFE63946),
                      fontSize: 13,
                      fontWeight: FontWeight.bold)),
              const SizedBox(height: 3),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: product.isActive
                      ? Colors.green.withOpacity(0.15)
                      : Colors.grey.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  product.isActive ? 'ACTIVE' : 'HIDDEN',
                  style: TextStyle(
                      color: product.isActive ? Colors.green : Colors.grey,
                      fontSize: 9,
                      fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ── Empty products ──
class _EmptyProducts extends StatelessWidget {
  final VoidCallback onAdd;
  const _EmptyProducts({required this.onAdd});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: const Color(0xFF161616),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.06)),
      ),
      child: Column(
        children: [
          Icon(Icons.inventory_2_outlined,
              size: 48, color: Colors.grey.shade800),
          const SizedBox(height: 12),
          Text('No products yet',
              style: GoogleFonts.orbitron(
                  color: Colors.grey.shade600,
                  fontSize: 14,
                  fontWeight: FontWeight.bold)),
          const SizedBox(height: 6),
          Text('Add your first product to start selling',
              style: GoogleFonts.poppins(
                  color: Colors.grey.shade700, fontSize: 12),
              textAlign: TextAlign.center),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            onPressed: onAdd,
            icon: const Icon(Icons.add, size: 16),
            label: Text('Add Product',
                style: GoogleFonts.poppins(fontWeight: FontWeight.bold)),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFE63946),
              foregroundColor: Colors.white,
              padding:
                  const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
            ),
          ),
        ],
      ),
    );
  }
}

Widget _sectionLabel(String text) {
  return Text(
    text,
    style: GoogleFonts.poppins(
      color: Colors.grey.shade500,
      fontSize: 10,
      fontWeight: FontWeight.bold,
      letterSpacing: 1.5,
    ),
  );
}

class _NavItem {
  final IconData icon;
  final String label;
  const _NavItem(this.icon, this.label);
}
