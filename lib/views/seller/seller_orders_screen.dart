// lib/views/seller/seller_orders_screen.dart

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class SellerOrdersScreen extends StatelessWidget {
  const SellerOrdersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0D0D0D),
      body: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 52, 20, 24),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('ORDERS',
                      style: GoogleFonts.orbitron(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.bold)),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.grey.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text('0 orders',
                        style: GoogleFonts.poppins(
                            color: Colors.grey.shade500, fontSize: 12)),
                  ),
                ],
              ),
            ),
          ),
          SliverFillRemaining(
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: const Color(0xFF161616),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                          color: Colors.white.withOpacity(0.06)),
                    ),
                    child: Icon(Icons.receipt_long_outlined,
                        size: 56, color: Colors.grey.shade800),
                  ),
                  const SizedBox(height: 20),
                  Text('No orders yet',
                      style: GoogleFonts.orbitron(
                          color: Colors.grey.shade600,
                          fontSize: 16,
                          fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  Text('Orders for your products\nwill appear here',
                      style: GoogleFonts.poppins(
                          color: Colors.grey.shade700, fontSize: 13),
                      textAlign: TextAlign.center),
                  const SizedBox(height: 8),
                  Text('(Coming in next update)',
                      style: GoogleFonts.poppins(
                          color: Colors.grey.shade800, fontSize: 11)),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
