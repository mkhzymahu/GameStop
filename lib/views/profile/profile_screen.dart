import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/notification_provider.dart';
import '../../providers/wishlist_provider.dart';
import '../../providers/cart_provider.dart';
import '../../providers/user_data_provider.dart';
import '../payment/payment_screen.dart';
import '../../models/notification_model.dart';
import '../../models/order_model.dart';
import '../../models/payment_method_model.dart';
import '../../app/theme/app_theme.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthProvider>(
      builder: (context, auth, _) {
        final user = auth.currentUser;
        final name = user?.name ?? 'Guest User';
        final email = user?.email ?? 'guest@gamestop.com';
        final phone = user?.phone ?? '';
        final address = user?.address ?? '';

        return Scaffold(
          backgroundColor: AppTheme.darkGrey,
          appBar: AppBar(
            backgroundColor: AppTheme.darkGrey,
            elevation: 0,
            title: Text('PROFILE',
                style: GoogleFonts.orbitron(
                    fontWeight: FontWeight.bold,
                    color: AppTheme.primaryRed,
                    letterSpacing: 2)),
            actions: [
              Consumer<NotificationProvider>(
                builder: (context, notifs, _) {
                  return Stack(children: [
                    IconButton(
                      icon: const Icon(Icons.notifications_outlined,
                          color: Colors.white),
                      onPressed: () {
                        // jump to notifications tab
                        _ProfileContentState._globalKey.currentState?.setTab(5);
                      },
                    ),
                    if (notifs.hasUnread)
                      Positioned(
                        right: 8,
                        top: 8,
                        child: Container(
                          width: 8,
                          height: 8,
                          decoration: const BoxDecoration(
                              color: AppTheme.primaryRed,
                              shape: BoxShape.circle),
                        ),
                      ),
                  ]);
                },
              ),
            ],
          ),
          body: Row(
            children: [
              _ProfileSidebar(name: name),
              VerticalDivider(
                  color: Colors.grey.shade800, width: 1, thickness: 1),
              Expanded(
                child: _ProfileContent(
                  key: _ProfileContentState._globalKey,
                  name: name,
                  email: email,
                  phone: phone,
                  address: address,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

// ─────────────────────────────────────────────────────────
// SIDEBAR
// ─────────────────────────────────────────────────────────

class _ProfileSidebar extends StatefulWidget {
  final String name;
  const _ProfileSidebar({required this.name});

  @override
  State<_ProfileSidebar> createState() => _ProfileSidebarState();
}

class _ProfileSidebarState extends State<_ProfileSidebar> {
  int _selectedIndex = 0;

  static const List<_SidebarItem> _items = [
    _SidebarItem(icon: Icons.person_outline, label: 'Account'),
    _SidebarItem(icon: Icons.shopping_bag_outlined, label: 'Orders'),
    _SidebarItem(icon: Icons.favorite_border, label: 'Wishlist'),
    _SidebarItem(icon: Icons.location_on_outlined, label: 'Addresses'),
    _SidebarItem(icon: Icons.payment_outlined, label: 'Payment'),
    _SidebarItem(icon: Icons.notifications_outlined, label: 'Notifications'),
    _SidebarItem(icon: Icons.security_outlined, label: 'Security'),
    _SidebarItem(icon: Icons.help_outline, label: 'Help'),
    _SidebarItem(icon: Icons.logout, label: 'Logout', isDestructive: true),
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 80,
      color: const Color(0xFF252525),
      child: Column(
        children: [
          const SizedBox(height: 16),
          CircleAvatar(
            radius: 24,
            backgroundColor: AppTheme.primaryRed,
            child: Text(
              widget.name.isNotEmpty ? widget.name[0].toUpperCase() : 'G',
              style: const TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold),
            ),
          ),
          const SizedBox(height: 20),
          Expanded(
            child: ListView.builder(
              itemCount: _items.length,
              padding: EdgeInsets.zero,
              itemBuilder: (context, index) {
                final item = _items[index];
                final isSelected = _selectedIndex == index;
                final color = item.isDestructive
                    ? Colors.red.shade400
                    : isSelected
                        ? AppTheme.primaryRed
                        : Colors.grey.shade500;

                return GestureDetector(
                  onTap: () {
                    if (item.isDestructive) {
                      _confirmLogout(context);
                      return;
                    }
                    setState(() => _selectedIndex = index);
                    _ProfileContentState._globalKey.currentState?.setTab(index);
                  },
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    margin:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? AppTheme.primaryRed.withOpacity(0.12)
                          : Colors.transparent,
                      borderRadius: BorderRadius.circular(10),
                      border: isSelected
                          ? Border.all(
                              color: AppTheme.primaryRed.withOpacity(0.3))
                          : null,
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(item.icon, color: color, size: 22),
                        const SizedBox(height: 4),
                        Text(item.label,
                            style: TextStyle(
                                color: color,
                                fontSize: 9,
                                fontWeight: isSelected
                                    ? FontWeight.bold
                                    : FontWeight.normal),
                            textAlign: TextAlign.center,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  void _confirmLogout(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF3A3A3A),
        title: const Text('Logout', style: TextStyle(color: Colors.white)),
        content: const Text('Are you sure you want to logout?',
            style: TextStyle(color: Colors.grey)),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx),
              child:
                  const Text('Cancel', style: TextStyle(color: Colors.grey))),
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              context.read<AuthProvider>().logout();
              context.go('/auth');
            },
            child: const Text('Logout', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}

class _SidebarItem {
  final IconData icon;
  final String label;
  final bool isDestructive;
  const _SidebarItem(
      {required this.icon, required this.label, this.isDestructive = false});
}

// ─────────────────────────────────────────────────────────
// CONTENT AREA
// ─────────────────────────────────────────────────────────

class _ProfileContent extends StatefulWidget {
  final String name;
  final String email;
  final String phone;
  final String address;

  const _ProfileContent({
    Key? key,
    required this.name,
    required this.email,
    required this.phone,
    required this.address,
  }) : super(key: key);

  @override
  State<_ProfileContent> createState() => _ProfileContentState();
}

class _ProfileContentState extends State<_ProfileContent> {
  static final GlobalKey<_ProfileContentState> _globalKey =
      GlobalKey<_ProfileContentState>();
  int _currentTab = 0;

  void setTab(int index) => setState(() => _currentTab = index);

  @override
  Widget build(BuildContext context) {
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 250),
      transitionBuilder: (child, animation) => FadeTransition(
        opacity: animation,
        child: SlideTransition(
          position:
              Tween<Offset>(begin: const Offset(0.04, 0), end: Offset.zero)
                  .animate(animation),
          child: child,
        ),
      ),
      child: KeyedSubtree(
        key: ValueKey(_currentTab),
        child: _buildTab(_currentTab),
      ),
    );
  }

  Widget _buildTab(int index) {
    switch (index) {
      case 0:
        return _AccountTab(
            name: widget.name,
            email: widget.email,
            phone: widget.phone,
            address: widget.address);
      case 1:
        return const _OrdersTab();
      case 2:
        return const _WishlistTab();
      case 3:
        return const _AddressesTab();
      case 4:
        return const _PaymentTab();
      case 5:
        return const _NotificationsTab();
      case 6:
        return const _SecurityTab();
      case 7:
        return const _HelpTab();
      default:
        return const SizedBox();
    }
  }
}

// ─────────────────────────────────────────────────────────
// TAB 0 — ACCOUNT
// ─────────────────────────────────────────────────────────

class _AccountTab extends StatefulWidget {
  final String name, email, phone, address;
  const _AccountTab(
      {required this.name,
      required this.email,
      required this.phone,
      required this.address});

  @override
  State<_AccountTab> createState() => _AccountTabState();
}

class _AccountTabState extends State<_AccountTab> {
  late TextEditingController _nameCtrl;
  late TextEditingController _emailCtrl;
  late TextEditingController _phoneCtrl;
  late TextEditingController _addressCtrl;
  bool _editing = false;

  @override
  void initState() {
    super.initState();
    _nameCtrl = TextEditingController(text: widget.name);
    _emailCtrl = TextEditingController(text: widget.email);
    _phoneCtrl = TextEditingController(text: widget.phone);
    _addressCtrl = TextEditingController(text: widget.address);
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _emailCtrl.dispose();
    _phoneCtrl.dispose();
    _addressCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Account Info',
                  style: GoogleFonts.poppins(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold)),
              GestureDetector(
                onTap: () async {
                  if (_editing) {
                    await context.read<AuthProvider>().updateProfile(
                          name: _nameCtrl.text,
                          phone: _phoneCtrl.text,
                          address: _addressCtrl.text,
                        );
                    if (mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                            content: Text('Profile saved'),
                            backgroundColor: Colors.green,
                            behavior: SnackBarBehavior.floating,
                            duration: Duration(seconds: 1)),
                      );
                    }
                  }
                  setState(() => _editing = !_editing);
                },
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: _editing
                        ? Colors.green.withOpacity(0.15)
                        : AppTheme.primaryRed.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                        color: _editing ? Colors.green : AppTheme.primaryRed),
                  ),
                  child: Row(mainAxisSize: MainAxisSize.min, children: [
                    Icon(_editing ? Icons.check : Icons.edit_outlined,
                        color: _editing ? Colors.green : AppTheme.primaryRed,
                        size: 14),
                    const SizedBox(width: 4),
                    Text(_editing ? 'Save' : 'Edit',
                        style: TextStyle(
                            color:
                                _editing ? Colors.green : AppTheme.primaryRed,
                            fontSize: 12,
                            fontWeight: FontWeight.bold)),
                  ]),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Center(
            child: Stack(children: [
              CircleAvatar(
                radius: 36,
                backgroundColor: AppTheme.primaryRed,
                child: Text(
                  widget.name.isNotEmpty ? widget.name[0].toUpperCase() : 'G',
                  style: const TextStyle(
                      color: Colors.white,
                      fontSize: 28,
                      fontWeight: FontWeight.bold),
                ),
              ),
              if (_editing)
                Positioned(
                  bottom: 0,
                  right: 0,
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: const BoxDecoration(
                        color: AppTheme.primaryRed, shape: BoxShape.circle),
                    child: const Icon(Icons.camera_alt,
                        color: Colors.white, size: 12),
                  ),
                ),
            ]),
          ),
          const SizedBox(height: 10),
          Center(
            child: Column(children: [
              Text(widget.name,
                  style: GoogleFonts.poppins(
                      color: Colors.white,
                      fontSize: 15,
                      fontWeight: FontWeight.bold)),
              Text(widget.email,
                  style: TextStyle(color: Colors.grey.shade500, fontSize: 12)),
            ]),
          ),
          const SizedBox(height: 24),
          Divider(color: Colors.grey.shade800),
          const SizedBox(height: 16),
          _buildField('Full Name', _nameCtrl, Icons.person_outline,
              enabled: _editing),
          _buildField('Email', _emailCtrl, Icons.email_outlined,
              enabled: false),
          _buildField('Phone', _phoneCtrl, Icons.phone_outlined,
              enabled: _editing),
          _buildField('Address', _addressCtrl, Icons.location_on_outlined,
              enabled: _editing, maxLines: 2),
        ],
      ),
    );
  }

  Widget _buildField(String label, TextEditingController ctrl, IconData icon,
      {bool enabled = false, int maxLines = 1}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label,
              style: TextStyle(
                  color: Colors.grey.shade500,
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.5)),
          const SizedBox(height: 6),
          TextField(
            controller: ctrl,
            enabled: enabled,
            maxLines: maxLines,
            style: const TextStyle(color: Colors.white, fontSize: 13),
            decoration: InputDecoration(
              prefixIcon: Icon(icon,
                  color: enabled ? AppTheme.primaryRed : Colors.grey.shade700,
                  size: 18),
              filled: true,
              fillColor: enabled
                  ? AppTheme.primaryRed.withOpacity(0.05)
                  : const Color(0xFF2A2A2A),
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
              border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide.none),
              enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide:
                      BorderSide(color: AppTheme.primaryRed.withOpacity(0.3))),
              disabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide.none),
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────
// TAB 1 — ORDERS
// ─────────────────────────────────────────────────────────

class _OrdersTab extends StatelessWidget {
  const _OrdersTab();

  Color _statusColor(OrderStatus s) {
    switch (s) {
      case OrderStatus.delivered:
        return Colors.green;
      case OrderStatus.shipped:
        return const Color(0xFF3B8EFF);
      case OrderStatus.cancelled:
        return Colors.red;
      case OrderStatus.refunded:
        return Colors.orange;
      case OrderStatus.processing:
        return Colors.amber;
      default:
        return Colors.grey;
    }
  }

  IconData _statusIcon(OrderStatus s) {
    switch (s) {
      case OrderStatus.delivered:
        return Icons.check_circle_outline;
      case OrderStatus.shipped:
        return Icons.local_shipping_outlined;
      case OrderStatus.cancelled:
        return Icons.cancel_outlined;
      case OrderStatus.refunded:
        return Icons.assignment_return_outlined;
      case OrderStatus.processing:
        return Icons.autorenew;
      case OrderStatus.confirmed:
        return Icons.thumb_up_outlined;
      default:
        return Icons.hourglass_empty;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<UserDataProvider>(
      builder: (context, data, _) {
        final orders = data.orders;
        if (orders.isEmpty) {
          return _EmptyState(
            icon: Icons.shopping_bag_outlined,
            title: 'No Orders Yet',
            subtitle: 'Your purchase history will appear here',
            actionLabel: 'Start Shopping',
            onAction: () => context.go('/products'),
          );
        }
        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: orders.length,
          itemBuilder: (context, i) {
            final order = orders[i];
            final statusColor = _statusColor(order.status);
            return Container(
              margin: const EdgeInsets.only(bottom: 12),
              decoration: BoxDecoration(
                color: const Color(0xFF2A2A2A),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: Colors.grey.shade800),
              ),
              child: Column(
                children: [
                  // Header
                  Padding(
                    padding: const EdgeInsets.all(14),
                    child: Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('#${order.id.split('_').last}',
                                  style: GoogleFonts.orbitron(
                                      color: Colors.white,
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold)),
                              const SizedBox(height: 3),
                              Text(
                                _formatDate(order.createdAt),
                                style: TextStyle(
                                    color: Colors.grey.shade500, fontSize: 11),
                              ),
                            ],
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: statusColor.withOpacity(0.12),
                            borderRadius: BorderRadius.circular(20),
                            border:
                                Border.all(color: statusColor.withOpacity(0.4)),
                          ),
                          child: Row(mainAxisSize: MainAxisSize.min, children: [
                            Icon(_statusIcon(order.status),
                                color: statusColor, size: 12),
                            const SizedBox(width: 4),
                            Text(
                              order.status.name.toUpperCase(),
                              style: TextStyle(
                                  color: statusColor,
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold),
                            ),
                          ]),
                        ),
                      ],
                    ),
                  ),
                  Divider(color: Colors.grey.shade800, height: 1),
                  // Items
                  ...order.items.take(2).map((item) => Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 14, vertical: 8),
                        child: Row(children: [
                          Container(
                            width: 36,
                            height: 36,
                            decoration: BoxDecoration(
                              color: const Color(0xFF3A3A3A),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Icon(Icons.sports_esports,
                                color: Colors.grey, size: 18),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(item.productName,
                                    style: const TextStyle(
                                        color: Colors.white, fontSize: 12),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis),
                                Text('x${item.quantity}',
                                    style: TextStyle(
                                        color: Colors.grey.shade600,
                                        fontSize: 11)),
                              ],
                            ),
                          ),
                          Text(
                            '\$${item.totalPrice.toStringAsFixed(2)}',
                            style: const TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                                fontWeight: FontWeight.bold),
                          ),
                        ]),
                      )),
                  if (order.items.length > 2)
                    Padding(
                      padding: const EdgeInsets.only(left: 14, bottom: 8),
                      child: Text(
                        '+${order.items.length - 2} more items',
                        style: TextStyle(
                            color: Colors.grey.shade600, fontSize: 11),
                      ),
                    ),
                  Divider(color: Colors.grey.shade800, height: 1),
                  // Footer
                  Padding(
                    padding: const EdgeInsets.all(14),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Total: \$${order.total.toStringAsFixed(2)}',
                          style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 13),
                        ),
                        if (order.trackingNumber != null)
                          GestureDetector(
                            onTap: () {
                              Clipboard.setData(
                                  ClipboardData(text: order.trackingNumber!));
                              ScaffoldMessenger.of(context)
                                  .showSnackBar(const SnackBar(
                                content: Text('Tracking # copied'),
                                behavior: SnackBarBehavior.floating,
                                duration: Duration(seconds: 1),
                              ));
                            },
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(Icons.local_shipping_outlined,
                                    color: Color(0xFF3B8EFF), size: 14),
                                const SizedBox(width: 4),
                                Text('Track',
                                    style: const TextStyle(
                                        color: Color(0xFF3B8EFF),
                                        fontSize: 12,
                                        fontWeight: FontWeight.bold)),
                              ],
                            ),
                          ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  String _formatDate(DateTime d) => '${d.day}/${d.month}/${d.year}';
}

// ─────────────────────────────────────────────────────────
// TAB 2 — WISHLIST
// ─────────────────────────────────────────────────────────

class _WishlistTab extends StatelessWidget {
  const _WishlistTab();

  @override
  Widget build(BuildContext context) {
    return Consumer<WishlistProvider>(
      builder: (context, wishlist, _) {
        final items = wishlist.items;

        if (items.isEmpty) {
          return _EmptyState(
            icon: Icons.favorite_border,
            title: 'Wishlist is Empty',
            subtitle: 'Heart items in the shop to save them here',
            actionLabel: 'Browse Products',
            onAction: () => context.go('/products'),
          );
        }

        return Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                      '${items.length} saved item${items.length == 1 ? '' : 's'}',
                      style:
                          TextStyle(color: Colors.grey.shade400, fontSize: 13)),
                  GestureDetector(
                    onTap: () {
                      for (final p in items) {
                        context.read<CartProvider>().addToCart(p);
                      }
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('${items.length} items added to cart'),
                          backgroundColor: Colors.green,
                          behavior: SnackBarBehavior.floating,
                          duration: const Duration(seconds: 1),
                        ),
                      );
                    },
                    child: const Text('Add all to cart',
                        style: TextStyle(
                            color: AppTheme.primaryRed,
                            fontSize: 12,
                            fontWeight: FontWeight.bold)),
                  ),
                ],
              ),
            ),
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: items.length,
                itemBuilder: (context, i) {
                  final product = items[i];
                  return Container(
                    margin: const EdgeInsets.only(bottom: 10),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: const Color(0xFF2A2A2A),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.grey.shade800),
                    ),
                    child: Row(children: [
                      // Product image
                      ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: product.image != null
                            ? Image.network(
                                product.image!,
                                width: 56,
                                height: 56,
                                fit: BoxFit.cover,
                                errorBuilder: (_, __, ___) => _imageFallback(),
                              )
                            : _imageFallback(),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(product.brand.toUpperCase(),
                                style: const TextStyle(
                                    color: AppTheme.primaryRed,
                                    fontSize: 9,
                                    fontWeight: FontWeight.bold,
                                    letterSpacing: 0.5)),
                            Text(product.name,
                                style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 13,
                                    fontWeight: FontWeight.w600),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis),
                            Text(
                              '\$${product.finalPrice.toStringAsFixed(2)}',
                              style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                      ),
                      Column(children: [
                        GestureDetector(
                          onTap: () {
                            context.read<CartProvider>().addToCart(product);
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('${product.name} added to cart'),
                                backgroundColor: Colors.green,
                                behavior: SnackBarBehavior.floating,
                                duration: const Duration(seconds: 1),
                              ),
                            );
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 10, vertical: 6),
                            decoration: BoxDecoration(
                              color: AppTheme.primaryRed,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Text('Add',
                                style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 11,
                                    fontWeight: FontWeight.bold)),
                          ),
                        ),
                        const SizedBox(height: 6),
                        GestureDetector(
                          onTap: () => wishlist.remove(product.id),
                          child: Icon(Icons.delete_outline,
                              color: Colors.grey.shade600, size: 18),
                        ),
                      ]),
                    ]),
                  );
                },
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _imageFallback() => Container(
        width: 56,
        height: 56,
        decoration: BoxDecoration(
          color: const Color(0xFF3A3A3A),
          borderRadius: BorderRadius.circular(8),
        ),
        child: const Icon(Icons.sports_esports, color: Colors.grey, size: 24),
      );
}

// ─────────────────────────────────────────────────────────
// TAB 3 — ADDRESSES
// ─────────────────────────────────────────────────────────

class _AddressesTab extends StatefulWidget {
  const _AddressesTab();

  @override
  State<_AddressesTab> createState() => _AddressesTabState();
}

class _AddressesTabState extends State<_AddressesTab> {
  final List<Map<String, dynamic>> _addresses = [
    {
      'id': '1',
      'label': 'Home',
      'line1': '123 Game Street',
      'line2': 'Gaming City, GC 12345',
      'isDefault': true,
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Saved Addresses',
                  style: GoogleFonts.poppins(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.bold)),
              GestureDetector(
                onTap: () => _showAddAddressSheet(context),
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: AppTheme.primaryRed.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(8),
                    border:
                        Border.all(color: AppTheme.primaryRed.withOpacity(0.4)),
                  ),
                  child: Row(mainAxisSize: MainAxisSize.min, children: [
                    const Icon(Icons.add, color: AppTheme.primaryRed, size: 14),
                    const SizedBox(width: 4),
                    const Text('Add New',
                        style: TextStyle(
                            color: AppTheme.primaryRed,
                            fontSize: 11,
                            fontWeight: FontWeight.bold)),
                  ]),
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: _addresses.isEmpty
              ? _EmptyState(
                  icon: Icons.location_on_outlined,
                  title: 'No Addresses',
                  subtitle: 'Add a delivery address',
                  actionLabel: 'Add Address',
                  onAction: () => _showAddAddressSheet(context),
                )
              : ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: _addresses.length,
                  itemBuilder: (context, i) {
                    final addr = _addresses[i];
                    final isDefault = addr['isDefault'] as bool;
                    return Container(
                      margin: const EdgeInsets.only(bottom: 10),
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: const Color(0xFF2A2A2A),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                            color: isDefault
                                ? AppTheme.primaryRed.withOpacity(0.4)
                                : Colors.grey.shade800),
                      ),
                      child: Row(children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: isDefault
                                ? AppTheme.primaryRed.withOpacity(0.15)
                                : Colors.grey.shade800,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Icon(Icons.location_on_outlined,
                              color:
                                  isDefault ? AppTheme.primaryRed : Colors.grey,
                              size: 20),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(children: [
                                Text(addr['label'] as String,
                                    style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 13,
                                        fontWeight: FontWeight.bold)),
                                if (isDefault) ...[
                                  const SizedBox(width: 6),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 6, vertical: 2),
                                    decoration: BoxDecoration(
                                      color:
                                          AppTheme.primaryRed.withOpacity(0.15),
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                    child: const Text('DEFAULT',
                                        style: TextStyle(
                                            color: AppTheme.primaryRed,
                                            fontSize: 8,
                                            fontWeight: FontWeight.bold)),
                                  ),
                                ],
                              ]),
                              const SizedBox(height: 2),
                              Text(addr['line1'] as String,
                                  style: TextStyle(
                                      color: Colors.grey.shade400,
                                      fontSize: 12)),
                              Text(addr['line2'] as String,
                                  style: TextStyle(
                                      color: Colors.grey.shade500,
                                      fontSize: 11)),
                            ],
                          ),
                        ),
                        PopupMenuButton<String>(
                          color: const Color(0xFF3A3A3A),
                          icon: Icon(Icons.more_vert,
                              color: Colors.grey.shade600, size: 18),
                          onSelected: (val) {
                            if (val == 'default') {
                              setState(() {
                                for (var a in _addresses) {
                                  a['isDefault'] = a['id'] == addr['id'];
                                }
                              });
                            } else if (val == 'delete') {
                              setState(() => _addresses
                                  .removeWhere((a) => a['id'] == addr['id']));
                            }
                          },
                          itemBuilder: (_) => [
                            const PopupMenuItem(
                                value: 'default',
                                child: Text('Set as default',
                                    style: TextStyle(
                                        color: Colors.white, fontSize: 13))),
                            const PopupMenuItem(
                                value: 'delete',
                                child: Text('Delete',
                                    style: TextStyle(
                                        color: Colors.red, fontSize: 13))),
                          ],
                        ),
                      ]),
                    );
                  },
                ),
        ),
      ],
    );
  }

  void _showAddAddressSheet(BuildContext context) {
    final labelCtrl = TextEditingController();
    final line1Ctrl = TextEditingController();
    final line2Ctrl = TextEditingController();

    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF2A2A2A),
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (ctx) => Padding(
        padding: EdgeInsets.fromLTRB(
            20, 20, 20, MediaQuery.of(ctx).viewInsets.bottom + 28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _sheetHandle(),
            Text('Add New Address',
                style: GoogleFonts.poppins(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            _sheetField(
                'Label (e.g. Home, Work)', labelCtrl, Icons.label_outline),
            const SizedBox(height: 12),
            _sheetField(
                'Street Address', line1Ctrl, Icons.location_on_outlined),
            const SizedBox(height: 12),
            _sheetField('City, State ZIP', line2Ctrl, Icons.map_outlined),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                if (labelCtrl.text.isEmpty || line1Ctrl.text.isEmpty) {
                  return;
                }
                setState(() {
                  _addresses.add({
                    'id': DateTime.now().millisecondsSinceEpoch.toString(),
                    'label': labelCtrl.text,
                    'line1': line1Ctrl.text,
                    'line2': line2Ctrl.text,
                    'isDefault': _addresses.isEmpty,
                  });
                });
                Navigator.pop(ctx);
              },
              style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primaryRed,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10))),
              child: const Text('Save Address',
                  style: TextStyle(fontWeight: FontWeight.bold)),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────
// TAB 4 — PAYMENT METHODS
// ─────────────────────────────────────────────────────────

class _PaymentTab extends StatelessWidget {
  const _PaymentTab();

  @override
  Widget build(BuildContext context) {
    return Consumer<UserDataProvider>(
      builder: (context, data, _) {
        final methods = data.paymentMethods;

        if (methods.isEmpty) {
          return _EmptyState(
            icon: Icons.credit_card_outlined,
            title: 'No Payment Methods',
            subtitle: 'Add a card to checkout faster',
            actionLabel: 'Add Payment Method',
            onAction: () => Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (_) => const PaymentScreen()),
            ),
          );
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
              child: Row(
                mainAxisAlignment:
                    MainAxisAlignment.spaceBetween,
                children: [
                  Text('Payment Methods',
                      style: GoogleFonts.poppins(
                          color: Colors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.bold)),
                  GestureDetector(
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (_) =>
                              const PaymentScreen()),
                    ),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 6),
                      decoration: BoxDecoration(
                        color: AppTheme.primaryRed
                            .withOpacity(0.15),
                        borderRadius:
                            BorderRadius.circular(8),
                        border: Border.all(
                            color: AppTheme.primaryRed
                                .withOpacity(0.4)),
                      ),
                      child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.open_in_new,
                                color: AppTheme.primaryRed,
                                size: 13),
                            const SizedBox(width: 5),
                            const Text('Manage',
                                style: TextStyle(
                                    color: AppTheme.primaryRed,
                                    fontSize: 11,
                                    fontWeight:
                                        FontWeight.bold)),
                          ]),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: ListView.builder(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16),
                itemCount: methods.length,
                itemBuilder: (context, i) {
                  final m = methods[i];
                  return Container(
                    margin: const EdgeInsets.only(bottom: 10),
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: const Color(0xFF2A2A2A),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                          color: m.isDefault
                              ? AppTheme.primaryRed
                                  .withOpacity(0.4)
                              : Colors.grey.shade800),
                    ),
                    child: Row(children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: m.isDefault
                              ? AppTheme.primaryRed
                                  .withOpacity(0.15)
                              : Colors.grey.shade800,
                          borderRadius:
                              BorderRadius.circular(8),
                        ),
                        child: Icon(_typeIcon(m.type),
                            color: m.isDefault
                                ? AppTheme.primaryRed
                                : Colors.grey,
                            size: 22),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment:
                              CrossAxisAlignment.start,
                          children: [
                            Row(children: [
                              Text(m.displayName,
                                  style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 13,
                                      fontWeight:
                                          FontWeight.bold)),
                              if (m.isDefault) ...[
                                const SizedBox(width: 6),
                                Container(
                                  padding:
                                      const EdgeInsets
                                          .symmetric(
                                          horizontal: 6,
                                          vertical: 2),
                                  decoration: BoxDecoration(
                                    color: AppTheme.primaryRed
                                        .withOpacity(0.15),
                                    borderRadius:
                                        BorderRadius.circular(
                                            4),
                                  ),
                                  child: const Text('DEFAULT',
                                      style: TextStyle(
                                          color: AppTheme
                                              .primaryRed,
                                          fontSize: 8,
                                          fontWeight:
                                              FontWeight.bold)),
                                ),
                              ],
                            ]),
                            if (m.last4 != null)
                              Text(m.maskedDisplay,
                                  style: TextStyle(
                                      color: Colors
                                          .grey.shade500,
                                      fontSize: 12,
                                      letterSpacing: 1)),
                            if (m.expiryMonth != null)
                              Text(
                                  'Expires ${m.expiryMonth}/${m.expiryYear}',
                                  style: TextStyle(
                                      color:
                                          Colors.grey.shade600,
                                      fontSize: 11)),
                          ],
                        ),
                      ),
                    ]),
                  );
                },
              ),
            ),
          ],
        );
      },
    );
  }

  IconData _typeIcon(PaymentType t) {
    switch (t) {
      case PaymentType.paypal:
        return Icons.account_balance_wallet_outlined;
      case PaymentType.applePay:
        return Icons.apple;
      case PaymentType.googlePay:
        return Icons.g_mobiledata;
      default:
        return Icons.credit_card_outlined;
    }
  }
}

// ─────────────────────────────────────────────────────────
// TAB 5 — NOTIFICATIONS
// ─────────────────────────────────────────────────────────

class _NotificationsTab extends StatelessWidget {
  const _NotificationsTab();

  IconData _typeIcon(NotificationType t) {
    switch (t) {
      case NotificationType.orderUpdate:
        return Icons.local_shipping_outlined;
      case NotificationType.couponWon:
        return Icons.local_offer_outlined;
      case NotificationType.supportReply:
        return Icons.support_agent_outlined;
      case NotificationType.promotion:
        return Icons.campaign_outlined;
      case NotificationType.adminAlert:
        return Icons.admin_panel_settings_outlined;
      default:
        return Icons.notifications_outlined;
    }
  }

  Color _typeColor(NotificationType t) {
    switch (t) {
      case NotificationType.orderUpdate:
        return const Color(0xFF3B8EFF);
      case NotificationType.couponWon:
        return const Color(0xFF3BFF8E);
      case NotificationType.supportReply:
        return const Color(0xFFFFB83B);
      case NotificationType.promotion:
        return AppTheme.primaryRed;
      case NotificationType.adminAlert:
        return const Color(0xFFB83BFF);
      default:
        return Colors.grey;
    }
  }

  String _timeAgo(DateTime dt) {
    final diff = DateTime.now().difference(dt);
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    return '${diff.inDays}d ago';
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<NotificationProvider>(
      builder: (context, notifs, _) {
        final list = notifs.notifications;
        return Column(
          children: [
            // Header with mark all read
            if (list.isNotEmpty)
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '${notifs.unreadCount} unread',
                      style:
                          TextStyle(color: Colors.grey.shade400, fontSize: 13),
                    ),
                    GestureDetector(
                      onTap: notifs.markAllRead,
                      child: const Text('Mark all read',
                          style: TextStyle(
                              color: AppTheme.primaryRed,
                              fontSize: 12,
                              fontWeight: FontWeight.bold)),
                    ),
                  ],
                ),
              ),
            Expanded(
              child: list.isEmpty
                  ? const _EmptyState(
                      icon: Icons.notifications_none_outlined,
                      title: 'No Notifications',
                      subtitle: 'You\'re all caught up!')
                  : ListView.builder(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 8),
                      itemCount: list.length,
                      itemBuilder: (context, i) {
                        final n = list[i];
                        final color = _typeColor(n.type);
                        return Dismissible(
                          key: Key(n.id),
                          direction: DismissDirection.endToStart,
                          background: Container(
                            alignment: Alignment.centerRight,
                            padding: const EdgeInsets.only(right: 20),
                            margin: const EdgeInsets.only(bottom: 8),
                            decoration: BoxDecoration(
                                color: Colors.red.shade900,
                                borderRadius: BorderRadius.circular(12)),
                            child:
                                const Icon(Icons.delete, color: Colors.white),
                          ),
                          onDismissed: (_) => notifs.deleteNotification(n.id),
                          child: GestureDetector(
                            onTap: () => notifs.markRead(n.id),
                            child: Container(
                              margin: const EdgeInsets.only(bottom: 8),
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: n.isRead
                                    ? const Color(0xFF2A2A2A)
                                    : color.withOpacity(0.06),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                    color: n.isRead
                                        ? Colors.grey.shade800
                                        : color.withOpacity(0.3)),
                              ),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(8),
                                    decoration: BoxDecoration(
                                      color: color.withOpacity(0.15),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Icon(_typeIcon(n.type),
                                        color: color, size: 18),
                                  ),
                                  const SizedBox(width: 10),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Row(children: [
                                          Expanded(
                                            child: Text(n.title,
                                                style: TextStyle(
                                                    color: Colors.white,
                                                    fontSize: 12,
                                                    fontWeight: n.isRead
                                                        ? FontWeight.normal
                                                        : FontWeight.bold)),
                                          ),
                                          if (!n.isRead)
                                            Container(
                                              width: 7,
                                              height: 7,
                                              decoration: BoxDecoration(
                                                  color: color,
                                                  shape: BoxShape.circle),
                                            ),
                                        ]),
                                        const SizedBox(height: 3),
                                        Text(n.body,
                                            style: TextStyle(
                                                color: Colors.grey.shade500,
                                                fontSize: 11,
                                                height: 1.3),
                                            maxLines: 2,
                                            overflow: TextOverflow.ellipsis),
                                        const SizedBox(height: 4),
                                        Text(_timeAgo(n.createdAt),
                                            style: TextStyle(
                                                color: Colors.grey.shade600,
                                                fontSize: 10)),
                                      ],
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
          ],
        );
      },
    );
  }
}

// ─────────────────────────────────────────────────────────
// TAB 6 — SECURITY
// ─────────────────────────────────────────────────────────

class _SecurityTab extends StatefulWidget {
  const _SecurityTab();

  @override
  State<_SecurityTab> createState() => _SecurityTabState();
}

class _SecurityTabState extends State<_SecurityTab> {
  bool _twoFactor = false;
  bool _biometric = false;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Security',
              style: GoogleFonts.poppins(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          Container(
            decoration: BoxDecoration(
                color: const Color(0xFF2A2A2A),
                borderRadius: BorderRadius.circular(12)),
            child: Column(children: [
              _buildTile(Icons.lock_outline, 'Change Password',
                  'Update your account password',
                  onTap: () => _showChangePasswordSheet(context)),
              Divider(color: Colors.grey.shade800, height: 1),
              _buildToggle(
                  Icons.security,
                  'Two-Factor Auth',
                  'Extra layer of security',
                  _twoFactor,
                  (v) => setState(() => _twoFactor = v)),
              Divider(color: Colors.grey.shade800, height: 1),
              _buildToggle(
                  Icons.fingerprint,
                  'Biometric Login',
                  'Use fingerprint or face ID',
                  _biometric,
                  (v) => setState(() => _biometric = v)),
            ]),
          ),
          const SizedBox(height: 20),
          _sectionLabel('Danger Zone'),
          const SizedBox(height: 8),
          Container(
            decoration: BoxDecoration(
                color: const Color(0xFF2A2A2A),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.red.shade900)),
            child: _buildTile(
              Icons.delete_forever_outlined,
              'Delete Account',
              'Permanently remove your account',
              iconColor: Colors.red.shade400,
              titleColor: Colors.red.shade400,
              onTap: () => _confirmDelete(context),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTile(IconData icon, String title, String subtitle,
      {Color? iconColor, Color? titleColor, VoidCallback? onTap}) {
    return ListTile(
      onTap: onTap,
      leading: Icon(icon, color: iconColor ?? AppTheme.primaryRed, size: 22),
      title: Text(title,
          style: TextStyle(color: titleColor ?? Colors.white, fontSize: 13)),
      subtitle: Text(subtitle,
          style: TextStyle(color: Colors.grey.shade600, fontSize: 11)),
      trailing: const Icon(Icons.chevron_right, color: Colors.grey, size: 18),
    );
  }

  Widget _buildToggle(IconData icon, String title, String subtitle, bool value,
      Function(bool) onChanged) {
    return ListTile(
      leading: Icon(icon, color: AppTheme.primaryRed, size: 22),
      title: Text(title,
          style: const TextStyle(color: Colors.white, fontSize: 13)),
      subtitle: Text(subtitle,
          style: TextStyle(color: Colors.grey.shade600, fontSize: 11)),
      trailing: Switch(
          value: value,
          onChanged: onChanged,
          activeThumbColor: AppTheme.primaryRed),
    );
  }

  void _showChangePasswordSheet(BuildContext context) {
    final currentCtrl = TextEditingController();
    final newCtrl = TextEditingController();
    final confirmCtrl = TextEditingController();

    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF2A2A2A),
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (ctx) => Padding(
        padding: EdgeInsets.fromLTRB(
            20, 20, 20, MediaQuery.of(ctx).viewInsets.bottom + 28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _sheetHandle(),
            Text('Change Password',
                style: GoogleFonts.poppins(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            _sheetField('Current Password', currentCtrl, Icons.lock_outline,
                obscure: true),
            const SizedBox(height: 12),
            _sheetField('New Password', newCtrl, Icons.lock_reset_outlined,
                obscure: true),
            const SizedBox(height: 12),
            _sheetField('Confirm New Password', confirmCtrl, Icons.lock_outline,
                obscure: true),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () async {
                if (newCtrl.text != confirmCtrl.text) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                        content: Text('Passwords do not match'),
                        backgroundColor: Colors.red,
                        behavior: SnackBarBehavior.floating),
                  );
                  return;
                }
                final success = await context
                    .read<AuthProvider>()
                    .changePassword(currentCtrl.text, newCtrl.text);
                if (!ctx.mounted) return;
                Navigator.pop(ctx);
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                  content: Text(success
                      ? 'Password updated successfully'
                      : 'Current password is incorrect'),
                  backgroundColor: success ? Colors.green : Colors.red,
                  behavior: SnackBarBehavior.floating,
                  duration: const Duration(seconds: 2),
                ));
              },
              style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primaryRed,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10))),
              child: const Text('Update Password',
                  style: TextStyle(fontWeight: FontWeight.bold)),
            ),
          ],
        ),
      ),
    );
  }

  void _confirmDelete(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF3A3A3A),
        title: Text('Delete Account',
            style: TextStyle(
                color: Colors.red.shade400, fontWeight: FontWeight.bold)),
        content: const Text(
            'This action is permanent and cannot be undone. All your data will be deleted.',
            style: TextStyle(color: Colors.grey)),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx),
              child:
                  const Text('Cancel', style: TextStyle(color: Colors.grey))),
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              context.read<AuthProvider>().logout();
              context.go('/auth');
            },
            child: Text('Delete',
                style: TextStyle(
                    color: Colors.red.shade400, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────
// TAB 7 — HELP & SUPPORT
// ─────────────────────────────────────────────────────────

class _HelpTab extends StatefulWidget {
  const _HelpTab();

  @override
  State<_HelpTab> createState() => _HelpTabState();
}

class _HelpTabState extends State<_HelpTab> {
  static const List<Map<String, String>> _faqs = [
    {
      'q': 'How do I track my order?',
      'a':
          'Go to Profile → Orders and tap "Track" next to your order. You\'ll get a tracking number once your order ships.'
    },
    {
      'q': 'What is the return policy?',
      'a':
          'Items can be returned within 30 days of purchase in original condition. Visit Orders to initiate a return.'
    },
    {
      'q': 'How do I apply a coupon?',
      'a':
          'In your cart, tap "View Summary" and enter your coupon code. You can also win coupons from the daily spin!'
    },
    {
      'q': 'Is my payment info secure?',
      'a':
          'Yes. All payment data is encrypted. We never store full card numbers on our servers.'
    },
    {
      'q': 'How does the daily spin work?',
      'a':
          'Every 24 hours you get one free spin. Prizes range from \$5 to \$20 off, and free shipping coupons!'
    },
  ];

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Help & Support',
              style: GoogleFonts.poppins(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold)),
          const SizedBox(height: 14),

          // Contact options
          Container(
            decoration: BoxDecoration(
                color: const Color(0xFF2A2A2A),
                borderRadius: BorderRadius.circular(12)),
            child: Column(children: [
              _contactTile(context, Icons.chat_bubble_outline, 'Live Chat',
                  'Avg. reply < 2 min', const Color(0xFF3BFF8E),
                  onTap: () => _showChat(context)),
              Divider(color: Colors.grey.shade800, height: 1),
              _contactTile(
                  context,
                  Icons.support_agent_outlined,
                  'Submit Ticket',
                  'Create a support request',
                  const Color(0xFF3B8EFF),
                  onTap: () => _showTicketSheet(context)),
              Divider(color: Colors.grey.shade800, height: 1),
              _contactTile(context, Icons.email_outlined, 'Email Us',
                  'support@gamestop.com', const Color(0xFFFFB83B),
                  onTap: () {}),
              Divider(color: Colors.grey.shade800, height: 1),
              _contactTile(context, Icons.phone_outlined, 'Call Us',
                  '1-800-GAMESTOP', Colors.grey,
                  onTap: () {}),
            ]),
          ),

          const SizedBox(height: 20),
          _sectionLabel('MY TICKETS'),
          const SizedBox(height: 8),
          Consumer<UserDataProvider>(
            builder: (context, data, _) {
              final tickets = data.tickets;
              if (tickets.isEmpty) {
                return Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                      color: const Color(0xFF2A2A2A),
                      borderRadius: BorderRadius.circular(12)),
                  child: Center(
                    child: Text('No support tickets yet',
                        style: TextStyle(
                            color: Colors.grey.shade500, fontSize: 13)),
                  ),
                );
              }
              return Column(
                children:
                    tickets.take(3).map((t) => _ticketPreview(t)).toList(),
              );
            },
          ),

          const SizedBox(height: 20),
          _sectionLabel('FAQS'),
          const SizedBox(height: 8),
          ..._faqs.map((faq) => _FaqTile(q: faq['q']!, a: faq['a']!)),
        ],
      ),
    );
  }

  Widget _contactTile(BuildContext context, IconData icon, String title,
      String subtitle, Color color,
      {VoidCallback? onTap}) {
    return ListTile(
      onTap: onTap,
      leading: Container(
        padding: const EdgeInsets.all(6),
        decoration: BoxDecoration(
            color: color.withOpacity(0.15),
            borderRadius: BorderRadius.circular(8)),
        child: Icon(icon, color: color, size: 18),
      ),
      title: Text(title,
          style: const TextStyle(color: Colors.white, fontSize: 13)),
      subtitle: Text(subtitle,
          style: TextStyle(color: Colors.grey.shade500, fontSize: 11)),
      trailing: const Icon(Icons.chevron_right, color: Colors.grey, size: 18),
    );
  }

  Widget _ticketPreview(ticket) {
    final statusColors = {
      'open': Colors.green,
      'inProgress': const Color(0xFF3B8EFF),
      'resolved': Colors.grey,
      'closed': Colors.grey,
    };
    final color = statusColors[ticket.status.name] ?? Colors.grey;
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
          color: const Color(0xFF2A2A2A),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: Colors.grey.shade800)),
      child: Row(children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(ticket.subject,
                  style: const TextStyle(color: Colors.white, fontSize: 12),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis),
              Text(ticket.category,
                  style: TextStyle(color: Colors.grey.shade500, fontSize: 11)),
            ],
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
          decoration: BoxDecoration(
              color: color.withOpacity(0.15),
              borderRadius: BorderRadius.circular(10)),
          child: Text(ticket.status.name.toUpperCase(),
              style: TextStyle(
                  color: color, fontSize: 9, fontWeight: FontWeight.bold)),
        ),
      ]),
    );
  }

  void _showChat(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF2A2A2A),
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (ctx) {
        final msgCtrl = TextEditingController();
        final messages = <Map<String, dynamic>>[
          {
            'text':
                'Hi! Welcome to GameStop support. How can I help you today?',
            'isMe': false,
            'time': DateTime.now().subtract(const Duration(minutes: 1)),
          }
        ];
        return StatefulBuilder(
          builder: (ctx, setS) => SizedBox(
            height: MediaQuery.of(ctx).size.height * 0.75,
            child: Column(children: [
              Padding(
                padding: const EdgeInsets.all(16),
                child: Row(children: [
                  _sheetHandle(),
                  const Spacer(),
                  Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                        color: const Color(0xFF3BFF8E).withOpacity(0.15),
                        shape: BoxShape.circle),
                    child: const Icon(Icons.support_agent,
                        color: Color(0xFF3BFF8E), size: 18),
                  ),
                  const SizedBox(width: 8),
                  Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Support Agent',
                            style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 13)),
                        Row(children: [
                          Container(
                              width: 6,
                              height: 6,
                              decoration: const BoxDecoration(
                                  color: Color(0xFF3BFF8E),
                                  shape: BoxShape.circle)),
                          const SizedBox(width: 4),
                          Text('Online',
                              style: TextStyle(
                                  color: Colors.grey.shade500, fontSize: 11)),
                        ]),
                      ]),
                  const Spacer(),
                ]),
              ),
              Divider(color: Colors.grey.shade800, height: 1),
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.all(12),
                  itemCount: messages.length,
                  itemBuilder: (_, i) {
                    final m = messages[i];
                    final isMe = m['isMe'] as bool;
                    return Align(
                      alignment:
                          isMe ? Alignment.centerRight : Alignment.centerLeft,
                      child: Container(
                        margin: const EdgeInsets.only(bottom: 8),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 8),
                        constraints: BoxConstraints(
                            maxWidth: MediaQuery.of(ctx).size.width * 0.65),
                        decoration: BoxDecoration(
                          color: isMe
                              ? AppTheme.primaryRed.withOpacity(0.8)
                              : const Color(0xFF3A3A3A),
                          borderRadius: BorderRadius.only(
                            topLeft: const Radius.circular(12),
                            topRight: const Radius.circular(12),
                            bottomLeft:
                                isMe ? const Radius.circular(12) : Radius.zero,
                            bottomRight:
                                isMe ? Radius.zero : const Radius.circular(12),
                          ),
                        ),
                        child: Text(m['text'] as String,
                            style: const TextStyle(
                                color: Colors.white, fontSize: 13)),
                      ),
                    );
                  },
                ),
              ),
              Padding(
                padding: EdgeInsets.fromLTRB(
                    12, 8, 12, MediaQuery.of(ctx).viewInsets.bottom + 16),
                child: Row(children: [
                  Expanded(
                    child: TextField(
                      controller: msgCtrl,
                      style: const TextStyle(color: Colors.white, fontSize: 13),
                      decoration: InputDecoration(
                        hintText: 'Type a message...',
                        hintStyle: TextStyle(
                            color: Colors.grey.shade600, fontSize: 13),
                        filled: true,
                        fillColor: const Color(0xFF3A3A3A),
                        contentPadding: const EdgeInsets.symmetric(
                            horizontal: 14, vertical: 10),
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(20),
                            borderSide: BorderSide.none),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  GestureDetector(
                    onTap: () {
                      if (msgCtrl.text.trim().isEmpty) return;
                      setS(() {
                        messages.add({
                          'text': msgCtrl.text.trim(),
                          'isMe': true,
                          'time': DateTime.now(),
                        });
                        msgCtrl.clear();
                        // Simulate bot reply
                        Future.delayed(const Duration(seconds: 1), () {
                          if (ctx.mounted) {
                            setS(() => messages.add({
                                  'text':
                                      'Thanks for reaching out! An agent will follow up shortly. Is there anything else I can help with?',
                                  'isMe': false,
                                  'time': DateTime.now(),
                                }));
                          }
                        });
                      });
                    },
                    child: Container(
                      padding: const EdgeInsets.all(10),
                      decoration: const BoxDecoration(
                          color: AppTheme.primaryRed, shape: BoxShape.circle),
                      child:
                          const Icon(Icons.send, color: Colors.white, size: 18),
                    ),
                  ),
                ]),
              ),
            ]),
          ),
        );
      },
    );
  }

  void _showTicketSheet(BuildContext context) {
    final subjectCtrl = TextEditingController();
    final messageCtrl = TextEditingController();
    String selectedCategory = 'Order Issue';

    const categories = [
      'Order Issue',
      'Payment Problem',
      'Product Question',
      'Return/Refund',
      'Account Issue',
      'Other'
    ];

    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF2A2A2A),
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setS) => Padding(
          padding: EdgeInsets.fromLTRB(
              20, 20, 20, MediaQuery.of(ctx).viewInsets.bottom + 28),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _sheetHandle(),
              Text('Submit Support Ticket',
                  style: GoogleFonts.poppins(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold)),
              const SizedBox(height: 16),
              // Category picker
              Text('Category',
                  style: TextStyle(
                      color: Colors.grey.shade500,
                      fontSize: 11,
                      fontWeight: FontWeight.w600)),
              const SizedBox(height: 6),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                decoration: BoxDecoration(
                    color: const Color(0xFF3A3A3A),
                    borderRadius: BorderRadius.circular(10)),
                child: DropdownButton<String>(
                  value: selectedCategory,
                  dropdownColor: const Color(0xFF3A3A3A),
                  isExpanded: true,
                  underline: const SizedBox(),
                  style: const TextStyle(color: Colors.white, fontSize: 13),
                  items: categories
                      .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                      .toList(),
                  onChanged: (v) => setS(() => selectedCategory = v!),
                ),
              ),
              const SizedBox(height: 12),
              _sheetField('Subject', subjectCtrl, Icons.subject_outlined),
              const SizedBox(height: 12),
              TextField(
                controller: messageCtrl,
                maxLines: 4,
                style: const TextStyle(color: Colors.white, fontSize: 13),
                decoration: InputDecoration(
                  hintText: 'Describe your issue...',
                  hintStyle:
                      TextStyle(color: Colors.grey.shade600, fontSize: 13),
                  filled: true,
                  fillColor: const Color(0xFF3A3A3A),
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide.none),
                ),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () async {
                  if (subjectCtrl.text.isEmpty || messageCtrl.text.isEmpty)
                    return;
                  final auth = context.read<AuthProvider>();
                  final data = context.read<UserDataProvider>();
                  await data.createTicket(
                    userId: auth.currentUser?.id ?? '',
                    userName: auth.currentUser?.name ?? 'User',
                    subject: subjectCtrl.text,
                    category: selectedCategory,
                    firstMessage: messageCtrl.text,
                  );
                  if (!ctx.mounted) return;
                  Navigator.pop(ctx);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                        content:
                            Text('Ticket submitted! We\'ll respond shortly.'),
                        backgroundColor: Colors.green,
                        behavior: SnackBarBehavior.floating,
                        duration: Duration(seconds: 2)),
                  );
                },
                style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primaryRed,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10))),
                child: const Text('Submit Ticket',
                    style: TextStyle(fontWeight: FontWeight.bold)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────
// SHARED HELPERS
// ─────────────────────────────────────────────────────────

Widget _sheetHandle() => Center(
      child: Container(
        width: 40,
        height: 4,
        margin: const EdgeInsets.only(bottom: 16),
        decoration: BoxDecoration(
            color: Colors.grey.shade600,
            borderRadius: BorderRadius.circular(2)),
      ),
    );

Widget _sheetField(String label, TextEditingController ctrl, IconData icon,
    {bool obscure = false, TextInputType? keyboardType}) {
  return TextField(
    controller: ctrl,
    obscureText: obscure,
    keyboardType: keyboardType,
    style: const TextStyle(color: Colors.white, fontSize: 13),
    decoration: InputDecoration(
      labelText: label,
      labelStyle: TextStyle(color: Colors.grey.shade500, fontSize: 12),
      prefixIcon: Icon(icon, color: AppTheme.primaryRed, size: 18),
      filled: true,
      fillColor: const Color(0xFF3A3A3A),
      border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none),
    ),
  );
}

Widget _sectionLabel(String label) => Text(label,
    style: TextStyle(
        color: Colors.grey.shade500,
        fontSize: 11,
        fontWeight: FontWeight.bold,
        letterSpacing: 0.5));

class _EmptyState extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final String? actionLabel;
  final VoidCallback? onAction;

  const _EmptyState({
    required this.icon,
    required this.title,
    required this.subtitle,
    this.actionLabel,
    this.onAction,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 56, color: Colors.grey.shade800),
            const SizedBox(height: 14),
            Text(title,
                style: GoogleFonts.poppins(
                    color: Colors.white,
                    fontSize: 15,
                    fontWeight: FontWeight.bold)),
            const SizedBox(height: 6),
            Text(subtitle,
                style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
                textAlign: TextAlign.center),
            if (actionLabel != null && onAction != null) ...[
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: onAction,
                style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primaryRed,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 24, vertical: 12),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10))),
                child: Text(actionLabel!,
                    style: const TextStyle(fontWeight: FontWeight.bold)),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _FaqTile extends StatefulWidget {
  final String q, a;
  const _FaqTile({required this.q, required this.a});

  @override
  State<_FaqTile> createState() => _FaqTileState();
}

class _FaqTileState extends State<_FaqTile> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
          color: const Color(0xFF2A2A2A),
          borderRadius: BorderRadius.circular(10)),
      child: Column(children: [
        GestureDetector(
          onTap: () => setState(() => _expanded = !_expanded),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Row(children: [
              Expanded(
                  child: Text(widget.q,
                      style:
                          const TextStyle(color: Colors.white, fontSize: 12))),
              Icon(
                  _expanded
                      ? Icons.keyboard_arrow_up
                      : Icons.keyboard_arrow_down,
                  color: AppTheme.primaryRed,
                  size: 18),
            ]),
          ),
        ),
        if (_expanded)
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
            child: Text(widget.a,
                style: TextStyle(
                    color: Colors.grey.shade500, fontSize: 11, height: 1.4)),
          ),
      ]),
    );
  }
}
