// lib/views/admin/admin_users_screen.dart

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../services/user_storage_service.dart';
import '../../models/user_model.dart';

class AdminUsersScreen extends StatefulWidget {
  const AdminUsersScreen({super.key});

  @override
  State<AdminUsersScreen> createState() => _AdminUsersScreenState();
}

class _AdminUsersScreenState extends State<AdminUsersScreen> {
  List<UserModel> _users = [];
  List<UserModel> _filtered = [];
  String _search = '';
  String _roleFilter = 'All';
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  void _load() {
    final users = UserStorageService.getAllUsers();
    setState(() {
      _users = users;
      _applyFilter();
      _loading = false;
    });
  }

  void _applyFilter() {
    _filtered = _users.where((u) {
      final matchSearch = _search.isEmpty ||
          u.name.toLowerCase().contains(_search.toLowerCase()) ||
          u.email.toLowerCase().contains(_search.toLowerCase());
      final matchRole = _roleFilter == 'All' ||
          u.role.name.toLowerCase() == _roleFilter.toLowerCase();
      return matchSearch && matchRole;
    }).toList();
  }

  Future<void> _changeRole(UserModel user, UserRole newRole) async {
    final updated = user.copyWith(role: newRole);
    await UserStorageService.saveUser(updated);
    _load();
  }

  void _showUserDetail(UserModel user) {
    final orders = UserStorageService.loadOrders(user.id);
    showDialog(
      context: context,
      builder: (ctx) => Dialog(
        backgroundColor: const Color(0xFF13131F),
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: SizedBox(
          width: 480,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Header
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  border: Border(
                    bottom: BorderSide(color: Colors.white.withOpacity(0.07)),
                  ),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 42,
                      height: 42,
                      decoration: BoxDecoration(
                        color: const Color(0xFF6C63FF).withOpacity(0.15),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Center(
                        child: Text(
                          user.name.isNotEmpty
                              ? user.name[0].toUpperCase()
                              : '?',
                          style: GoogleFonts.poppins(
                              color: const Color(0xFF6C63FF),
                              fontSize: 18,
                              fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(user.name,
                              style: GoogleFonts.poppins(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w600,
                                  fontSize: 15)),
                          Text(user.email,
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
              // Details
              Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    _DetailRow('User ID', user.id),
                    _DetailRow('Phone', user.phone.isEmpty ? '—' : user.phone),
                    _DetailRow(
                        'Address', user.address.isEmpty ? '—' : user.address),
                    _DetailRow('Role', user.role.name.toUpperCase()),
                    _DetailRow('Orders', orders.length.toString()),
                    _DetailRow(
                      'Total Spent',
                      '\$${orders.fold<double>(0, (s, o) => s + o.total).toStringAsFixed(2)}',
                    ),
                    _DetailRow(
                        'Joined',
                        _formatDate(user.createdAt)),
                  ],
                ),
              ),
              // Role change actions
              Container(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('CHANGE ROLE',
                        style: GoogleFonts.poppins(
                            color: Colors.white24,
                            fontSize: 9,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1.5)),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        if (user.role != UserRole.customer)
                          _RoleButton(
                            label: 'Set Customer',
                            color: const Color(0xFF00BFA5),
                            onTap: () {
                              Navigator.pop(ctx);
                              _changeRole(user, UserRole.customer);
                            },
                          ),
                        if (user.role != UserRole.seller) ...[
                          const SizedBox(width: 8),
                          _RoleButton(
                            label: 'Set Seller',
                            color: const Color(0xFFFFB347),
                            onTap: () {
                              Navigator.pop(ctx);
                              _changeRole(user, UserRole.seller);
                            },
                          ),
                        ],
                        if (user.role != UserRole.admin) ...[
                          const SizedBox(width: 8),
                          _RoleButton(
                            label: 'Set Admin',
                            color: const Color(0xFF6C63FF),
                            onTap: () {
                              Navigator.pop(ctx);
                              _changeRole(user, UserRole.admin);
                            },
                          ),
                        ],
                      ],
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
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Users',
                        style: GoogleFonts.poppins(
                            color: Colors.white,
                            fontSize: 22,
                            fontWeight: FontWeight.w700)),
                    Text('${_users.length} registered accounts',
                        style: GoogleFonts.poppins(
                            color: Colors.white30, fontSize: 13)),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // Search + filter row
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
                      hintText: 'Search by name or email...',
                      hintStyle: GoogleFonts.poppins(
                          color: Colors.white24, fontSize: 13),
                      prefixIcon: Icon(Icons.search,
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
              // Role filter chips
              ...[
                'All', 'Customer', 'Seller', 'Admin'
              ].map((role) => Padding(
                    padding: const EdgeInsets.only(left: 6),
                    child: _FilterChip(
                      label: role,
                      selected: _roleFilter == role,
                      onTap: () => setState(() {
                        _roleFilter = role;
                        _applyFilter();
                      }),
                    ),
                  )),
            ],
          ),
          const SizedBox(height: 16),

          // Table header
          Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
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
                _TableHeader('USER', flex: 3),
                _TableHeader('ROLE', flex: 1),
                _TableHeader('PHONE', flex: 2),
                _TableHeader('ORDERS', flex: 1),
                _TableHeader('ACTIONS', flex: 1),
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
                      child: Text('No users found',
                          style: GoogleFonts.poppins(
                              color: Colors.white24, fontSize: 13)))
                  : ListView.builder(
                      itemCount: _filtered.length,
                      itemBuilder: (context, i) {
                        final user = _filtered[i];
                        final orders =
                            UserStorageService.loadOrders(user.id);
                        return _UserTableRow(
                          user: user,
                          orderCount: orders.length,
                          onTap: () => _showUserDetail(user),
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

class _UserTableRow extends StatelessWidget {
  final UserModel user;
  final int orderCount;
  final VoidCallback onTap;

  const _UserTableRow({
    required this.user,
    required this.orderCount,
    required this.onTap,
  });

  Color get _roleColor {
    switch (user.role) {
      case UserRole.admin: return const Color(0xFF6C63FF);
      case UserRole.seller: return const Color(0xFFFFB347);
      default: return const Color(0xFF00BFA5);
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(color: Colors.white.withOpacity(0.04)),
          ),
        ),
        child: Row(
          children: [
            // User info
            Expanded(
              flex: 3,
              child: Row(
                children: [
                  Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      color: _roleColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Center(
                      child: Text(
                        user.name.isNotEmpty
                            ? user.name[0].toUpperCase()
                            : '?',
                        style: GoogleFonts.poppins(
                            color: _roleColor,
                            fontSize: 13,
                            fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
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
                                color: Colors.white30, fontSize: 10),
                            overflow: TextOverflow.ellipsis),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            // Role
            Expanded(
              flex: 1,
              child: Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: _roleColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  user.role.name.toUpperCase(),
                  style: GoogleFonts.poppins(
                      color: _roleColor,
                      fontSize: 9,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.5),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
            // Phone
            Expanded(
              flex: 2,
              child: Text(
                user.phone.isEmpty ? '—' : user.phone,
                style: GoogleFonts.poppins(
                    color: Colors.white38, fontSize: 12),
              ),
            ),
            // Orders
            Expanded(
              flex: 1,
              child: Text(
                orderCount.toString(),
                style: GoogleFonts.poppins(
                    color: Colors.white, fontSize: 12),
              ),
            ),
            // Actions
            Expanded(
              flex: 1,
              child: Row(
                children: [
                  _IconAction(
                    icon: Icons.open_in_new,
                    tooltip: 'View details',
                    onTap: onTap,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  final String label;
  final String value;
  const _DetailRow(this.label, this.value);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(label,
                style: GoogleFonts.poppins(
                    color: Colors.white30,
                    fontSize: 12)),
          ),
          Expanded(
            child: Text(value,
                style: GoogleFonts.poppins(
                    color: Colors.white, fontSize: 12)),
          ),
        ],
      ),
    );
  }
}

class _RoleButton extends StatelessWidget {
  final String label;
  final Color color;
  final VoidCallback onTap;
  const _RoleButton(
      {required this.label, required this.color, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding:
            const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(6),
          border: Border.all(color: color.withOpacity(0.3)),
        ),
        child: Text(label,
            style: GoogleFonts.poppins(
                color: color,
                fontSize: 11,
                fontWeight: FontWeight.w600)),
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;
  const _FilterChip(
      {required this.label, required this.selected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding:
            const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: selected
              ? const Color(0xFF6C63FF).withOpacity(0.15)
              : const Color(0xFF0F0F18),
          borderRadius: BorderRadius.circular(6),
          border: Border.all(
            color: selected
                ? const Color(0xFF6C63FF).withOpacity(0.4)
                : Colors.white.withOpacity(0.07),
          ),
        ),
        child: Text(label,
            style: GoogleFonts.poppins(
              color: selected ? const Color(0xFF6C63FF) : Colors.white38,
              fontSize: 12,
              fontWeight:
                  selected ? FontWeight.w600 : FontWeight.normal,
            )),
      ),
    );
  }
}

class _TableHeader extends StatelessWidget {
  final String text;
  final int flex;
  const _TableHeader(this.text, {required this.flex});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      flex: flex,
      child: Text(text,
          style: GoogleFonts.poppins(
            color: Colors.white24,
            fontSize: 10,
            fontWeight: FontWeight.w700,
            letterSpacing: 1,
          )),
    );
  }
}

class _IconAction extends StatelessWidget {
  final IconData icon;
  final String tooltip;
  final VoidCallback onTap;
  const _IconAction(
      {required this.icon, required this.tooltip, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip,
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.05),
            borderRadius: BorderRadius.circular(6),
          ),
          child: Icon(icon, color: Colors.white38, size: 14),
        ),
      ),
    );
  }
}
