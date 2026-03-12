// lib/views/admin/admin_orders_screen.dart

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../services/user_storage_service.dart';
import '../../models/order_model.dart';
import '../../models/user_model.dart';

class AdminOrdersScreen extends StatefulWidget {
  const AdminOrdersScreen({super.key});

  @override
  State<AdminOrdersScreen> createState() => _AdminOrdersScreenState();
}

class _AdminOrdersScreenState extends State<AdminOrdersScreen> {
  List<_OrderWithUser> _orders = [];
  List<_OrderWithUser> _filtered = [];
  String _search = '';
  String _statusFilter = 'All';
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  void _load() {
    final users = UserStorageService.getAllUsers();
    final result = <_OrderWithUser>[];
    for (final u in users) {
      final orders = UserStorageService.loadOrders(u.id);
      for (final o in orders) {
        result.add(_OrderWithUser(order: o, user: u));
      }
    }
    result.sort((a, b) => b.order.createdAt.compareTo(a.order.createdAt));
    setState(() {
      _orders = result;
      _applyFilter();
      _loading = false;
    });
  }

  void _applyFilter() {
    _filtered = _orders.where((o) {
      final matchSearch = _search.isEmpty ||
          o.order.id.toLowerCase().contains(_search.toLowerCase()) ||
          o.user.name.toLowerCase().contains(_search.toLowerCase());
      final matchStatus = _statusFilter == 'All' ||
          o.order.status.name.toLowerCase() ==
              _statusFilter.toLowerCase();
      return matchSearch && matchStatus;
    }).toList();
  }

  Future<void> _updateStatus(
      _OrderWithUser item, OrderStatus newStatus) async {
    final orders = UserStorageService.loadOrders(item.user.id);
    final updated = orders.map((o) {
      if (o.id == item.order.id) {
        return o.copyWith(status: newStatus, updatedAt: DateTime.now());
      }
      return o;
    }).toList();
    await UserStorageService.saveOrders(item.user.id, updated);
    _load();
  }

  void _showOrderDetail(_OrderWithUser item) {
    showDialog(
      context: context,
      builder: (ctx) => Dialog(
        backgroundColor: const Color(0xFF13131F),
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: SizedBox(
          width: 520,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Header
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  border: Border(
                    bottom:
                        BorderSide(color: Colors.white.withOpacity(0.07)),
                  ),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(item.order.id,
                              style: GoogleFonts.poppins(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w600,
                                  fontSize: 14)),
                          Text('Customer: ${item.user.name}',
                              style: GoogleFonts.poppins(
                                  color: Colors.white38, fontSize: 12)),
                        ],
                      ),
                    ),
                    IconButton(
                      onPressed: () => Navigator.pop(ctx),
                      icon: const Icon(Icons.close,
                          color: Colors.white38, size: 18),
                    ),
                  ],
                ),
              ),
              // Content
              Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Order items
                    Text('ORDER ITEMS',
                        style: GoogleFonts.poppins(
                            color: Colors.white24,
                            fontSize: 9,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1.5)),
                    const SizedBox(height: 10),
                    ...item.order.items.map((oi) => Padding(
                          padding: const EdgeInsets.only(bottom: 8),
                          child: Row(
                            children: [
                              Container(
                                width: 8,
                                height: 8,
                                decoration: const BoxDecoration(
                                  color: Color(0xFF6C63FF),
                                  shape: BoxShape.circle,
                                ),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Text(oi.productName,
                                    style: GoogleFonts.poppins(
                                        color: Colors.white,
                                        fontSize: 12)),
                              ),
                              Text('x${oi.quantity}',
                                  style: GoogleFonts.poppins(
                                      color: Colors.white38,
                                      fontSize: 12)),
                              const SizedBox(width: 12),
                              Text(
                                  '\$${oi.totalPrice.toStringAsFixed(2)}',
                                  style: GoogleFonts.poppins(
                                      color: Colors.white,
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600)),
                            ],
                          ),
                        )),
                    const Divider(color: Colors.white12, height: 24),
                    // Summary
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Total',
                            style: GoogleFonts.poppins(
                                color: Colors.white,
                                fontWeight: FontWeight.w600)),
                        Text(
                            '\$${item.order.total.toStringAsFixed(2)}',
                            style: GoogleFonts.poppins(
                                color: Colors.white,
                                fontWeight: FontWeight.w700,
                                fontSize: 15)),
                      ],
                    ),
                    const SizedBox(height: 20),
                    // Status update
                    Text('UPDATE STATUS',
                        style: GoogleFonts.poppins(
                            color: Colors.white24,
                            fontSize: 9,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1.5)),
                    const SizedBox(height: 10),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: OrderStatus.values.map((s) {
                        final isCurrent = item.order.status == s;
                        final color = _statusColor(s);
                        return GestureDetector(
                          onTap: isCurrent
                              ? null
                              : () {
                                  Navigator.pop(ctx);
                                  _updateStatus(item, s);
                                },
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 12, vertical: 7),
                            decoration: BoxDecoration(
                              color: isCurrent
                                  ? color.withOpacity(0.2)
                                  : color.withOpacity(0.07),
                              borderRadius: BorderRadius.circular(6),
                              border: Border.all(
                                  color: isCurrent
                                      ? color.withOpacity(0.6)
                                      : color.withOpacity(0.2)),
                            ),
                            child: Text(
                              s.name.toUpperCase(),
                              style: GoogleFonts.poppins(
                                  color: color,
                                  fontSize: 10,
                                  fontWeight: isCurrent
                                      ? FontWeight.w700
                                      : FontWeight.normal),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Color _statusColor(OrderStatus s) {
    switch (s) {
      case OrderStatus.delivered: return const Color(0xFF00BFA5);
      case OrderStatus.shipped: return const Color(0xFF6C63FF);
      case OrderStatus.processing: return const Color(0xFFFFB347);
      case OrderStatus.confirmed: return const Color(0xFF4FC3F7);
      case OrderStatus.cancelled: return const Color(0xFFE63946);
      case OrderStatus.refunded: return const Color(0xFFFF7043);
      default: return Colors.white38;
    }
  }

  String _formatDate(DateTime d) =>
      '${d.day}/${d.month}/${d.year}';

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Center(
        child: CircularProgressIndicator(
            color: Color(0xFF6C63FF), strokeWidth: 2),
      );
    }

    return Container(
      color: const Color(0xFF0A0A0F),
      padding: const EdgeInsets.all(28),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Orders',
                      style: GoogleFonts.poppins(
                          color: Colors.white,
                          fontSize: 22,
                          fontWeight: FontWeight.w700)),
                  Text('${_orders.length} total transactions',
                      style: GoogleFonts.poppins(
                          color: Colors.white30, fontSize: 13)),
                ],
              ),
            ],
          ),
          const SizedBox(height: 20),

          // Search + filters
          Row(
            children: [
              Expanded(
                child: Container(
                  height: 40,
                  decoration: BoxDecoration(
                    color: const Color(0xFF0F0F18),
                    borderRadius: BorderRadius.circular(8),
                    border:
                        Border.all(color: Colors.white.withOpacity(0.07)),
                  ),
                  child: TextField(
                    style: GoogleFonts.poppins(
                        color: Colors.white, fontSize: 13),
                    decoration: InputDecoration(
                      hintText: 'Search by order ID or customer...',
                      hintStyle: GoogleFonts.poppins(
                          color: Colors.white24, fontSize: 13),
                      prefixIcon: const Icon(Icons.search,
                          color: Colors.white24, size: 18),
                      border: InputBorder.none,
                      contentPadding:
                          const EdgeInsets.symmetric(vertical: 10),
                    ),
                    onChanged: (v) => setState(() {
                      _search = v;
                      _applyFilter();
                    }),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              ...['All', 'Pending', 'Processing', 'Shipped', 'Delivered',
                      'Cancelled']
                  .map((s) => Padding(
                        padding: const EdgeInsets.only(left: 6),
                        child: _StatusChip(
                          label: s,
                          selected: _statusFilter == s,
                          color: s == 'All'
                              ? const Color(0xFF6C63FF)
                              : _statusColor(OrderStatus.values.firstWhere(
                                  (e) =>
                                      e.name.toLowerCase() ==
                                      s.toLowerCase(),
                                  orElse: () => OrderStatus.pending)),
                          onTap: () => setState(() {
                            _statusFilter = s;
                            _applyFilter();
                          }),
                        ),
                      )),
            ],
          ),
          const SizedBox(height: 16),

          // Table header
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            decoration: BoxDecoration(
              color: const Color(0xFF0F0F18),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(10),
                topRight: Radius.circular(10),
              ),
              border: Border.all(color: Colors.white.withOpacity(0.06)),
            ),
            child: Row(
              children: [
                _TH('ORDER ID', flex: 3),
                _TH('CUSTOMER', flex: 2),
                _TH('DATE', flex: 2),
                _TH('ITEMS', flex: 1),
                _TH('TOTAL', flex: 1),
                _TH('STATUS', flex: 2),
                _TH('', flex: 1),
              ],
            ),
          ),

          // Table rows
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: const Color(0xFF0F0F18),
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(10),
                  bottomRight: Radius.circular(10),
                ),
                border: Border(
                  left: BorderSide(color: Colors.white.withOpacity(0.06)),
                  right: BorderSide(color: Colors.white.withOpacity(0.06)),
                  bottom: BorderSide(color: Colors.white.withOpacity(0.06)),
                ),
              ),
              child: _filtered.isEmpty
                  ? Center(
                      child: Text('No orders found',
                          style: GoogleFonts.poppins(
                              color: Colors.white24, fontSize: 13)))
                  : ListView.builder(
                      itemCount: _filtered.length,
                      itemBuilder: (context, i) {
                        final item = _filtered[i];
                        return GestureDetector(
                          onTap: () => _showOrderDetail(item),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 16, vertical: 13),
                            decoration: BoxDecoration(
                              border: Border(
                                bottom: BorderSide(
                                    color:
                                        Colors.white.withOpacity(0.04)),
                              ),
                            ),
                            child: Row(
                              children: [
                                Expanded(
                                  flex: 3,
                                  child: Text(item.order.id,
                                      style: GoogleFonts.poppins(
                                          color: Colors.white,
                                          fontSize: 12,
                                          fontWeight: FontWeight.w500),
                                      overflow: TextOverflow.ellipsis),
                                ),
                                Expanded(
                                  flex: 2,
                                  child: Text(item.user.name,
                                      style: GoogleFonts.poppins(
                                          color: Colors.white54,
                                          fontSize: 12),
                                      overflow: TextOverflow.ellipsis),
                                ),
                                Expanded(
                                  flex: 2,
                                  child: Text(
                                      _formatDate(item.order.createdAt),
                                      style: GoogleFonts.poppins(
                                          color: Colors.white38,
                                          fontSize: 12)),
                                ),
                                Expanded(
                                  flex: 1,
                                  child: Text(
                                      item.order.items.length.toString(),
                                      style: GoogleFonts.poppins(
                                          color: Colors.white,
                                          fontSize: 12)),
                                ),
                                Expanded(
                                  flex: 1,
                                  child: Text(
                                      '\$${item.order.total.toStringAsFixed(2)}',
                                      style: GoogleFonts.poppins(
                                          color: Colors.white,
                                          fontSize: 12,
                                          fontWeight: FontWeight.w600)),
                                ),
                                Expanded(
                                  flex: 2,
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 8, vertical: 3),
                                    decoration: BoxDecoration(
                                      color: _statusColor(item.order.status)
                                          .withOpacity(0.1),
                                      borderRadius:
                                          BorderRadius.circular(4),
                                    ),
                                    child: Text(
                                      item.order.status.name.toUpperCase(),
                                      style: GoogleFonts.poppins(
                                          color: _statusColor(
                                              item.order.status),
                                          fontSize: 9,
                                          fontWeight: FontWeight.w700,
                                          letterSpacing: 0.5),
                                      textAlign: TextAlign.center,
                                    ),
                                  ),
                                ),
                                Expanded(
                                  flex: 1,
                                  child: Icon(Icons.chevron_right,
                                      color: Colors.white24, size: 16),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
            ),
          ),
        ],
      ),
    );
  }
}

class _OrderWithUser {
  final OrderModel order;
  final UserModel user;
  const _OrderWithUser({required this.order, required this.user});
}

class _TH extends StatelessWidget {
  final String text;
  final int flex;
  const _TH(this.text, {required this.flex});

  @override
  Widget build(BuildContext context) => Expanded(
        flex: flex,
        child: Text(text,
            style: GoogleFonts.poppins(
                color: Colors.white24,
                fontSize: 10,
                fontWeight: FontWeight.w700,
                letterSpacing: 1)),
      );
}

class _StatusChip extends StatelessWidget {
  final String label;
  final bool selected;
  final Color color;
  final VoidCallback onTap;
  const _StatusChip(
      {required this.label,
      required this.selected,
      required this.color,
      required this.onTap});

  @override
  Widget build(BuildContext context) => GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          padding:
              const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: selected ? color.withOpacity(0.15) : const Color(0xFF0F0F18),
            borderRadius: BorderRadius.circular(6),
            border: Border.all(
              color: selected
                  ? color.withOpacity(0.4)
                  : Colors.white.withOpacity(0.07),
            ),
          ),
          child: Text(label,
              style: GoogleFonts.poppins(
                  color: selected ? color : Colors.white38,
                  fontSize: 11,
                  fontWeight:
                      selected ? FontWeight.w600 : FontWeight.normal)),
        ),
      );
}
