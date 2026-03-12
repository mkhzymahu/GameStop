// lib/views/admin/admin_dashboard_screen.dart

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../services/user_storage_service.dart';
import '../../models/user_model.dart';
import '../../models/order_model.dart';

class AdminDashboardScreen extends StatefulWidget {
  const AdminDashboardScreen({super.key});

  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen> {
  List<UserModel> _users = [];
  List<OrderModel> _allOrders = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  void _load() {
    final users = UserStorageService.getAllUsers();
    final orders = <OrderModel>[];
    for (final u in users) {
      orders.addAll(UserStorageService.loadOrders(u.id));
    }
    setState(() {
      _users = users;
      _allOrders = orders;
      _loading = false;
    });
  }

  int get _customerCount =>
      _users.where((u) => u.role == UserRole.customer).length;
  int get _sellerCount =>
      _users.where((u) => u.role == UserRole.seller).length;
  int get _pendingOrders =>
      _allOrders.where((o) => o.status == OrderStatus.pending).length;
  double get _totalRevenue =>
      _allOrders.fold(0, (sum, o) => sum + o.total);

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
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(28),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Page title
            _PageHeader(
              title: 'Dashboard',
              subtitle: 'Platform overview and key metrics',
            ),
            const SizedBox(height: 28),

            // Stats grid
            GridView.count(
              crossAxisCount: 4,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              childAspectRatio: 1.6,
              children: [
                _StatTile(
                  label: 'Total Users',
                  value: _users.length.toString(),
                  icon: Icons.people_outline,
                  color: const Color(0xFF6C63FF),
                  sub: '$_customerCount customers · $_sellerCount sellers',
                ),
                _StatTile(
                  label: 'Total Orders',
                  value: _allOrders.length.toString(),
                  icon: Icons.receipt_long_outlined,
                  color: const Color(0xFF00BFA5),
                  sub: '$_pendingOrders pending',
                ),
                _StatTile(
                  label: 'Revenue',
                  value:
                      '\$${_totalRevenue.toStringAsFixed(0)}',
                  icon: Icons.attach_money,
                  color: const Color(0xFFFFB347),
                  sub: 'All time',
                ),
                _StatTile(
                  label: 'Open Tickets',
                  value: UserStorageService.loadAllTickets()
                      .where((t) =>
                          t.status == 'open' || t.status == 'inProgress')
                      .length
                      .toString(),
                  icon: Icons.support_agent_outlined,
                  color: const Color(0xFFE63946),
                  sub: 'Needs attention',
                ),
              ],
            ),
            const SizedBox(height: 32),

            // Two columns: recent users + recent orders
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Recent users
                Expanded(
                  child: _AdminCard(
                    title: 'RECENT USERS',
                    child: _users.isEmpty
                        ? _EmptyRow('No users yet')
                        : Column(
                            children: _users.reversed
                                .take(6)
                                .map((u) => _UserRow(user: u))
                                .toList(),
                          ),
                  ),
                ),
                const SizedBox(width: 20),
                // Recent orders
                Expanded(
                  child: _AdminCard(
                    title: 'RECENT ORDERS',
                    child: _allOrders.isEmpty
                        ? _EmptyRow('No orders yet')
                        : Column(
                            children: _allOrders
                                .take(6)
                                .map((o) => _OrderRow(order: o))
                                .toList(),
                          ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// ── Page header ──
class _PageHeader extends StatelessWidget {
  final String title;
  final String subtitle;
  const _PageHeader({required this.title, required this.subtitle});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title,
            style: GoogleFonts.poppins(
              color: Colors.white,
              fontSize: 22,
              fontWeight: FontWeight.w700,
            )),
        const SizedBox(height: 3),
        Text(subtitle,
            style: GoogleFonts.poppins(
              color: Colors.white.withOpacity(0.3),
              fontSize: 13,
            )),
      ],
    );
  }
}

// ── Stat tile ──
class _StatTile extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color color;
  final String sub;

  const _StatTile({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
    required this.sub,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF0F0F18),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.white.withOpacity(0.06)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(label,
                  style: GoogleFonts.poppins(
                    color: Colors.white.withOpacity(0.4),
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                  )),
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Icon(icon, color: color, size: 14),
              ),
            ],
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(value,
                  style: GoogleFonts.poppins(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.w700,
                  )),
              Text(sub,
                  style: GoogleFonts.poppins(
                    color: color.withOpacity(0.7),
                    fontSize: 10,
                  )),
            ],
          ),
        ],
      ),
    );
  }
}

// ── Admin card wrapper ──
class _AdminCard extends StatelessWidget {
  final String title;
  final Widget child;
  const _AdminCard({required this.title, required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF0F0F18),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.white.withOpacity(0.06)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 12),
            child: Text(title,
                style: GoogleFonts.poppins(
                  color: Colors.white.withOpacity(0.25),
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1.5,
                )),
          ),
          Divider(height: 1, color: Colors.white.withOpacity(0.05)),
          child,
        ],
      ),
    );
  }
}

// ── User row ──
class _UserRow extends StatelessWidget {
  final UserModel user;
  const _UserRow({required this.user});

  @override
  Widget build(BuildContext context) {
    Color roleColor;
    String roleLabel;
    switch (user.role) {
      case UserRole.admin:
        roleColor = const Color(0xFF6C63FF);
        roleLabel = 'Admin';
        break;
      case UserRole.seller:
        roleColor = const Color(0xFFFFB347);
        roleLabel = 'Seller';
        break;
      default:
        roleColor = const Color(0xFF00BFA5);
        roleLabel = 'Customer';
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(color: Colors.white.withOpacity(0.04)),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 30,
            height: 30,
            decoration: BoxDecoration(
              color: roleColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Center(
              child: Text(
                user.name.isNotEmpty ? user.name[0].toUpperCase() : '?',
                style: GoogleFonts.poppins(
                    color: roleColor,
                    fontSize: 12,
                    fontWeight: FontWeight.bold),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(user.name,
                    style: GoogleFonts.poppins(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.w500),
                    overflow: TextOverflow.ellipsis),
                Text(user.email,
                    style: GoogleFonts.poppins(
                        color: Colors.white.withOpacity(0.3), fontSize: 10),
                    overflow: TextOverflow.ellipsis),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Flexible(
            child: Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: roleColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(roleLabel,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.poppins(
                      color: roleColor,
                      fontSize: 10,
                      fontWeight: FontWeight.w600)),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Order row ──
class _OrderRow extends StatelessWidget {
  final OrderModel order;
  const _OrderRow({required this.order});

  Color _statusColor(OrderStatus s) {
    switch (s) {
      case OrderStatus.delivered: return const Color(0xFF00BFA5);
      case OrderStatus.shipped: return const Color(0xFF6C63FF);
      case OrderStatus.processing: return const Color(0xFFFFB347);
      case OrderStatus.cancelled: return const Color(0xFFE63946);
      default: return Colors.white38;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(color: Colors.white.withOpacity(0.04)),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(order.id,
                    style: GoogleFonts.poppins(
                        color: Colors.white,
                        fontSize: 11,
                        fontWeight: FontWeight.w600),
                    overflow: TextOverflow.ellipsis),
                Text('${order.items.length} item(s)',
                    style: GoogleFonts.poppins(
                        color: Colors.white.withOpacity(0.3),
                        fontSize: 10)),
              ],
            ),
          ),
          Flexible(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: Text('\$${order.total.toStringAsFixed(2)}',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.poppins(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.w600)),
            ),
          ),
          Flexible(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: _statusColor(order.status).withOpacity(0.1),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                order.status.name.toUpperCase(),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: GoogleFonts.poppins(
                    color: _statusColor(order.status),
                    fontSize: 9,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.5),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _EmptyRow extends StatelessWidget {
  final String message;
  const _EmptyRow(this.message);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Center(
        child: Text(message,
            style: GoogleFonts.poppins(
                color: Colors.white.withOpacity(0.2), fontSize: 13)),
      ),
    );
  }
}
