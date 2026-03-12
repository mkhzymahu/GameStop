// lib/views/admin/admin_shell.dart

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/seller_provider.dart';
import 'package:go_router/go_router.dart';
import 'admin_dashboard_screen.dart';
import 'admin_users_screen.dart';
import 'admin_orders_screen.dart';
import 'admin_tickets_screen.dart';

class AdminShell extends StatefulWidget {
  const AdminShell({super.key});

  @override
  State<AdminShell> createState() => _AdminShellState();
}

class _AdminShellState extends State<AdminShell> {
  int _selectedIndex = 0;
  bool _sidebarCollapsed = false;

  final List<_AdminNavItem> _navItems = const [
    _AdminNavItem(Icons.dashboard_outlined, Icons.dashboard, 'Dashboard', 'Overview'),
    _AdminNavItem(Icons.people_outline, Icons.people, 'Users', 'Manage accounts'),
    _AdminNavItem(Icons.receipt_long_outlined, Icons.receipt_long, 'Orders', 'All transactions'),
    _AdminNavItem(Icons.support_agent_outlined, Icons.support_agent, 'Tickets', 'Support queue'),
  ];

  Widget _buildPage(int index) {
    switch (index) {
      case 0: return const AdminDashboardScreen();
      case 1: return const AdminUsersScreen();
      case 2: return const AdminOrdersScreen();
      case 3: return const AdminTicketsScreen();
      default: return const AdminDashboardScreen();
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final adminName = auth.currentUser?.name ?? 'Admin';
    final sidebarW = _sidebarCollapsed ? 64.0 : 220.0;

    return Scaffold(
      backgroundColor: const Color(0xFF0A0A0F),
      body: Row(
        children: [
          // ── Sidebar ──
          AnimatedContainer(
            duration: const Duration(milliseconds: 220),
            curve: Curves.easeInOut,
            width: sidebarW,
            color: const Color(0xFF0F0F18),
            child: Column(
              children: [
                // Brand header
                Container(
                  height: 64,
                  padding: EdgeInsets.symmetric(
                    horizontal: _sidebarCollapsed ? 16 : 20,
                  ),
                  decoration: BoxDecoration(
                    border: Border(
                      bottom: BorderSide(color: Colors.white.withOpacity(0.06)),
                    ),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 32,
                        height: 32,
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [Color(0xFF6C63FF), Color(0xFF9C92FF)],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(Icons.shield_outlined,
                            color: Colors.white, size: 18),
                      ),
                      if (!_sidebarCollapsed) ...[
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('ADMIN',
                                  style: GoogleFonts.orbitron(
                                    color: Colors.white,
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                    letterSpacing: 2,
                                  )),
                              Text('CONSOLE',
                                  style: GoogleFonts.orbitron(
                                    color: const Color(0xFF6C63FF),
                                    fontSize: 9,
                                    letterSpacing: 3,
                                  )),
                            ],
                          ),
                        ),
                      ],
                    ],
                  ),
                ),

                const SizedBox(height: 12),

                // Nav section label
                if (!_sidebarCollapsed)
                  Padding(
                    padding: const EdgeInsets.fromLTRB(20, 4, 20, 8),
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: Text('NAVIGATION',
                          style: GoogleFonts.poppins(
                            color: Colors.white.withOpacity(0.2),
                            fontSize: 9,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 2,
                          )),
                    ),
                  ),

                // Nav items
                Expanded(
                  child: ListView.builder(
                    padding: EdgeInsets.symmetric(
                        horizontal: _sidebarCollapsed ? 8 : 12),
                    itemCount: _navItems.length,
                    itemBuilder: (context, i) {
                      final item = _navItems[i];
                      final selected = i == _selectedIndex;
                      return Tooltip(
                        message: _sidebarCollapsed ? item.label : '',
                        child: GestureDetector(
                          onTap: () => setState(() => _selectedIndex = i),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 180),
                            margin: const EdgeInsets.only(bottom: 4),
                            padding: EdgeInsets.symmetric(
                              horizontal: _sidebarCollapsed ? 0 : 12,
                              vertical: 11,
                            ),
                            decoration: BoxDecoration(
                              color: selected
                                  ? const Color(0xFF6C63FF).withOpacity(0.12)
                                  : Colors.transparent,
                              borderRadius: BorderRadius.circular(8),
                              border: selected
                                  ? Border.all(
                                      color: const Color(0xFF6C63FF)
                                          .withOpacity(0.25),
                                      width: 1)
                                  : null,
                            ),
                            child: _sidebarCollapsed
                                ? Center(
                                    child: Icon(
                                      selected ? item.selectedIcon : item.icon,
                                      color: selected
                                          ? const Color(0xFF6C63FF)
                                          : Colors.white.withOpacity(0.35),
                                      size: 20,
                                    ),
                                  )
                                : Row(
                                    children: [
                                      Icon(
                                        selected
                                            ? item.selectedIcon
                                            : item.icon,
                                        color: selected
                                            ? const Color(0xFF6C63FF)
                                            : Colors.white.withOpacity(0.35),
                                        size: 18,
                                      ),
                                      const SizedBox(width: 12),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(item.label,
                                                style: GoogleFonts.poppins(
                                                  color: selected
                                                      ? Colors.white
                                                      : Colors.white
                                                          .withOpacity(0.45),
                                                  fontSize: 13,
                                                  fontWeight: selected
                                                      ? FontWeight.w600
                                                      : FontWeight.normal,
                                                )),
                                          ],
                                        ),
                                      ),
                                      if (selected)
                                        Container(
                                          width: 4,
                                          height: 4,
                                          decoration: const BoxDecoration(
                                            color: Color(0xFF6C63FF),
                                            shape: BoxShape.circle,
                                          ),
                                        ),
                                    ],
                                  ),
                          ),
                        ),
                      );
                    },
                  ),
                ),

                // Divider + logout
                Container(
                  decoration: BoxDecoration(
                    border: Border(
                      top: BorderSide(color: Colors.white.withOpacity(0.06)),
                    ),
                  ),
                  padding: EdgeInsets.symmetric(
                    horizontal: _sidebarCollapsed ? 12 : 16,
                    vertical: 14,
                  ),
                  child: _sidebarCollapsed
                      ? GestureDetector(
                          onTap: () => _logout(context),
                          child: const Icon(Icons.logout,
                              color: Colors.redAccent, size: 18),
                        )
                      : Row(
                          children: [
                            // Avatar
                            Container(
                              width: 32,
                              height: 32,
                              decoration: BoxDecoration(
                                color: const Color(0xFF6C63FF).withOpacity(0.2),
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(
                                    color: const Color(0xFF6C63FF)
                                        .withOpacity(0.3)),
                              ),
                              child: Center(
                                child: Text(
                                  adminName.isNotEmpty
                                      ? adminName[0].toUpperCase()
                                      : 'A',
                                  style: GoogleFonts.poppins(
                                    color: const Color(0xFF6C63FF),
                                    fontWeight: FontWeight.bold,
                                    fontSize: 13,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(adminName,
                                      style: GoogleFonts.poppins(
                                        color: Colors.white,
                                        fontSize: 12,
                                        fontWeight: FontWeight.w600,
                                      ),
                                      overflow: TextOverflow.ellipsis),
                                  Text('Administrator',
                                      style: GoogleFonts.poppins(
                                        color: Colors.white.withOpacity(0.3),
                                        fontSize: 10,
                                      )),
                                ],
                              ),
                            ),
                            GestureDetector(
                              onTap: () => _logout(context),
                              child: Icon(Icons.logout,
                                  color: Colors.white.withOpacity(0.25),
                                  size: 16),
                            ),
                          ],
                        ),
                ),
              ],
            ),
          ),

          // ── Main content area ──
          Expanded(
            child: Column(
              children: [
                // Top command bar
                Container(
                  height: 64,
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  decoration: BoxDecoration(
                    color: const Color(0xFF0F0F18),
                    border: Border(
                      bottom: BorderSide(color: Colors.white.withOpacity(0.06)),
                    ),
                  ),
                  child: Row(
                    children: [
                      // Collapse toggle
                      GestureDetector(
                        onTap: () => setState(
                            () => _sidebarCollapsed = !_sidebarCollapsed),
                        child: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.05),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Icon(
                            _sidebarCollapsed
                                ? Icons.menu_open
                                : Icons.menu,
                            color: Colors.white.withOpacity(0.5),
                            size: 18,
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      // Breadcrumb
                      Text('GameStop',
                          style: GoogleFonts.poppins(
                            color: Colors.white.withOpacity(0.25),
                            fontSize: 13,
                          )),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8),
                        child: Icon(Icons.chevron_right,
                            color: Colors.white.withOpacity(0.15), size: 16),
                      ),
                      Text(_navItems[_selectedIndex].label,
                          style: GoogleFonts.poppins(
                            color: Colors.white,
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                          )),
                      const Spacer(),
                      // Status pill
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 5),
                        decoration: BoxDecoration(
                          color: Colors.green.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                              color: Colors.green.withOpacity(0.3), width: 1),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              width: 6,
                              height: 6,
                              decoration: const BoxDecoration(
                                color: Colors.green,
                                shape: BoxShape.circle,
                              ),
                            ),
                            const SizedBox(width: 6),
                            Text('System Online',
                                style: GoogleFonts.poppins(
                                  color: Colors.green,
                                  fontSize: 11,
                                  fontWeight: FontWeight.w500,
                                )),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                // Page content
                Expanded(
                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 200),
                    child: KeyedSubtree(
                      key: ValueKey(_selectedIndex),
                      child: _buildPage(_selectedIndex),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _logout(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF13131F),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        title: Text('Sign Out',
            style: GoogleFonts.poppins(
                color: Colors.white, fontWeight: FontWeight.w600)),
        content: Text('End your admin session?',
            style:
                GoogleFonts.poppins(color: Colors.white54, fontSize: 13)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text('Cancel',
                style: GoogleFonts.poppins(color: Colors.white38)),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(ctx);
              await context.read<AuthProvider>().logout();
              await context.read<SellerProvider>().clearForLogout();
              if (context.mounted) context.go('/auth');
            },
            child: Text('Sign Out',
                style: GoogleFonts.poppins(color: Colors.redAccent)),
          ),
        ],
      ),
    );
  }
}

class _AdminNavItem {
  final IconData icon;
  final IconData selectedIcon;
  final String label;
  final String subtitle;
  const _AdminNavItem(this.icon, this.selectedIcon, this.label, this.subtitle);
}
