// lib/views/seller/seller_analytics_screen.dart

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../providers/seller_provider.dart';

class SellerAnalyticsScreen extends StatelessWidget {
  const SellerAnalyticsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final seller = context.watch<SellerProvider>();

    return Scaffold(
      backgroundColor: const Color(0xFF0D0D0D),
      body: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 52, 20, 24),
              child: Text('ANALYTICS',
                  style: GoogleFonts.orbitron(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold)),
            ),
          ),
          // Summary grid
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: GridView.count(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisCount: 2,
                mainAxisSpacing: 12,
                crossAxisSpacing: 12,
                childAspectRatio: 1.4,
                children: [
                  _AnalyticCard(
                    label: 'Total Products',
                    value: seller.totalProducts.toString(),
                    icon: Icons.inventory_2_rounded,
                    color: const Color(0xFF6C63FF),
                  ),
                  _AnalyticCard(
                    label: 'Active Listings',
                    value: seller.activeProductCount.toString(),
                    icon: Icons.visibility_rounded,
                    color: Colors.green,
                  ),
                  _AnalyticCard(
                    label: 'Avg Rating',
                    value: seller.avgRating == 0
                        ? '—'
                        : seller.avgRating.toStringAsFixed(1),
                    icon: Icons.star_rounded,
                    color: Colors.amber,
                  ),
                  _AnalyticCard(
                    label: 'Est. Revenue',
                    value: '\$${seller.totalRevenue.toStringAsFixed(0)}',
                    icon: Icons.attach_money_rounded,
                    color: const Color(0xFFE63946),
                  ),
                ],
              ),
            ),
          ),
          const SliverToBoxAdapter(child: SizedBox(height: 32)),
          // Placeholder chart area
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Container(
                height: 200,
                decoration: BoxDecoration(
                  color: const Color(0xFF161616),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.white.withOpacity(0.06)),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.bar_chart_rounded,
                        size: 48, color: Colors.grey.shade800),
                    const SizedBox(height: 12),
                    Text('Sales Chart',
                        style: GoogleFonts.orbitron(
                            color: Colors.grey.shade600,
                            fontSize: 14,
                            fontWeight: FontWeight.bold)),
                    const SizedBox(height: 6),
                    Text('Coming soon — sell more products to unlock',
                        style: GoogleFonts.poppins(
                            color: Colors.grey.shade700, fontSize: 12)),
                  ],
                ),
              ),
            ),
          ),
          // Per-product breakdown
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 28, 20, 8),
              child: Text('PRODUCT PERFORMANCE',
                  style: GoogleFonts.poppins(
                      color: Colors.grey.shade500,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.5)),
            ),
          ),
          if (seller.products.isEmpty)
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: const Color(0xFF161616),
                    borderRadius: BorderRadius.circular(12),
                    border:
                        Border.all(color: Colors.white.withOpacity(0.05)),
                  ),
                  child: Center(
                    child: Text('Add products to see performance data',
                        style: GoogleFonts.poppins(
                            color: Colors.grey.shade700, fontSize: 12)),
                  ),
                ),
              ),
            )
          else
            SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, i) {
                  final p = seller.products[i];
                  return Padding(
                    padding:
                        const EdgeInsets.fromLTRB(20, 0, 20, 8),
                    child: Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: const Color(0xFF161616),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                            color: Colors.white.withOpacity(0.06)),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(p.name,
                                    style: GoogleFonts.poppins(
                                        color: Colors.white,
                                        fontSize: 13,
                                        fontWeight: FontWeight.w600),
                                    overflow: TextOverflow.ellipsis),
                                Text(p.category,
                                    style: TextStyle(
                                        color: Colors.grey.shade600,
                                        fontSize: 11)),
                              ],
                            ),
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text('\$${p.price.toStringAsFixed(2)}',
                                  style: GoogleFonts.orbitron(
                                      color: const Color(0xFFE63946),
                                      fontSize: 13,
                                      fontWeight: FontWeight.bold)),
                              Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Icon(Icons.star_rounded,
                                      color: Colors.amber, size: 12),
                                  const SizedBox(width: 2),
                                  Text(
                                      p.reviewCount > 0
                                          ? p.rating.toStringAsFixed(1)
                                          : '—',
                                      style: TextStyle(
                                          color: Colors.grey.shade500,
                                          fontSize: 11)),
                                ],
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  );
                },
                childCount: seller.products.length,
              ),
            ),
          const SliverToBoxAdapter(child: SizedBox(height: 40)),
        ],
      ),
    );
  }
}

class _AnalyticCard extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color color;

  const _AnalyticCard({
    required this.label,
    required this.value,
    required this.icon,
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
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Icon(icon, color: color, size: 22),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(value,
                  style: GoogleFonts.orbitron(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold)),
              Text(label,
                  style: TextStyle(
                      color: Colors.grey.shade500, fontSize: 10)),
            ],
          ),
        ],
      ),
    );
  }
}
