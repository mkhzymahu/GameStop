// lib/views/seller/seller_profile_screen.dart

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../providers/seller_provider.dart';
import '../../providers/auth_provider.dart';
import '../../models/seller_model.dart';

class SellerProfileScreen extends StatefulWidget {
  const SellerProfileScreen({super.key});

  @override
  State<SellerProfileScreen> createState() => _SellerProfileScreenState();
}

class _SellerProfileScreenState extends State<SellerProfileScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabCtrl;

  @override
  void initState() {
    super.initState();
    _tabCtrl = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final seller = context.watch<SellerProvider>();
    final auth = context.watch<AuthProvider>();

    return Scaffold(
      backgroundColor: const Color(0xFF0D0D0D),
      body: Column(
        children: [
          // Header
          Container(
            padding: const EdgeInsets.fromLTRB(20, 52, 20, 0),
            color: const Color(0xFF161616),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('STORE SETTINGS',
                    style: GoogleFonts.orbitron(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold)),
                const SizedBox(height: 4),
                Text(auth.currentUser?.email ?? '',
                    style: TextStyle(
                        color: Colors.grey.shade600, fontSize: 12)),
                const SizedBox(height: 16),
                TabBar(
                  controller: _tabCtrl,
                  indicatorColor: const Color(0xFFE63946),
                  labelColor: Colors.white,
                  unselectedLabelColor: Colors.grey.shade600,
                  labelStyle: GoogleFonts.poppins(
                      fontWeight: FontWeight.bold, fontSize: 13),
                  unselectedLabelStyle: GoogleFonts.poppins(fontSize: 13),
                  tabs: const [
                    Tab(text: 'Store Info'),
                    Tab(text: 'Account'),
                  ],
                ),
              ],
            ),
          ),
          Expanded(
            child: TabBarView(
              controller: _tabCtrl,
              children: [
                _StoreInfoTab(seller: seller, auth: auth),
                _AccountTab(auth: auth),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ── Store info tab ──
class _StoreInfoTab extends StatefulWidget {
  final SellerProvider seller;
  final AuthProvider auth;
  const _StoreInfoTab({required this.seller, required this.auth});

  @override
  State<_StoreInfoTab> createState() => _StoreInfoTabState();
}

class _StoreInfoTabState extends State<_StoreInfoTab> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _storeNameCtrl;
  late TextEditingController _descCtrl;
  late TextEditingController _emailCtrl;
  late TextEditingController _phoneCtrl;
  late TextEditingController _addressCtrl;
  late TextEditingController _websiteCtrl;
  late SellerType _type;
  bool _isLoading = false;
  bool _isEditing = false;

  @override
  void initState() {
    super.initState();
    _initFromStore(widget.seller.store);
  }

  void _initFromStore(SellerStore? store) {
    _storeNameCtrl = TextEditingController(text: store?.storeName ?? '');
    _descCtrl = TextEditingController(text: store?.storeDescription ?? '');
    _emailCtrl = TextEditingController(text: store?.contactEmail ?? '');
    _phoneCtrl = TextEditingController(text: store?.contactPhone ?? '');
    _addressCtrl = TextEditingController(text: store?.address ?? '');
    _websiteCtrl = TextEditingController(text: store?.website ?? '');
    _type = store?.type ?? SellerType.individual;
  }

  @override
  void dispose() {
    _storeNameCtrl.dispose();
    _descCtrl.dispose();
    _emailCtrl.dispose();
    _phoneCtrl.dispose();
    _addressCtrl.dispose();
    _websiteCtrl.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);

    final seller = context.read<SellerProvider>();
    final auth = context.read<AuthProvider>();
    final userId = auth.currentUser?.id ?? '';

    bool success;
    if (seller.store == null) {
      success = await seller.createStore(
        sellerId: userId,
        type: _type,
        storeName: _storeNameCtrl.text.trim(),
        description: _descCtrl.text.trim(),
        contactEmail: _emailCtrl.text.trim(),
        contactPhone: _phoneCtrl.text.trim(),
        address: _addressCtrl.text.trim(),
      );
    } else {
      final updated = seller.store!.copyWith(
        type: _type,
        storeName: _storeNameCtrl.text.trim(),
        storeDescription: _descCtrl.text.trim(),
        contactEmail: _emailCtrl.text.trim(),
        contactPhone: _phoneCtrl.text.trim(),
        address: _addressCtrl.text.trim(),
        website: _websiteCtrl.text.trim(),
      );
      success = await seller.updateStore(updated);
    }

    setState(() {
      _isLoading = false;
      if (success) _isEditing = false;
    });

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(success ? 'Store updated!' : 'Failed to save.'),
        backgroundColor: success ? Colors.green : Colors.red,
        behavior: SnackBarBehavior.floating,
      ));
    }
  }

  @override
  Widget build(BuildContext context) {
    final store = widget.seller.store;

    return Form(
      key: _formKey,
      child: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          // Store type banner
          Container(
            padding: const EdgeInsets.all(16),
            margin: const EdgeInsets.only(bottom: 20),
            decoration: BoxDecoration(
              color: const Color(0xFF161616),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: Colors.white.withOpacity(0.06)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('SELLER TYPE',
                    style: GoogleFonts.poppins(
                        color: Colors.grey.shade500,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.5)),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: _TypeTile(
                        icon: Icons.person_rounded,
                        title: 'Individual',
                        subtitle: 'Sell as a person',
                        selected: _type == SellerType.individual,
                        onTap: _isEditing
                            ? () => setState(
                                () => _type = SellerType.individual)
                            : null,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: _TypeTile(
                        icon: Icons.business_rounded,
                        title: 'Organization',
                        subtitle: 'Sell as a business',
                        selected: _type == SellerType.organization,
                        onTap: _isEditing
                            ? () => setState(
                                () => _type = SellerType.organization)
                            : null,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Store status
          if (store != null)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              margin: const EdgeInsets.only(bottom: 20),
              decoration: BoxDecoration(
                color: store.isVerified
                    ? Colors.green.withOpacity(0.1)
                    : Colors.orange.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                    color: store.isVerified
                        ? Colors.green.withOpacity(0.3)
                        : Colors.orange.withOpacity(0.3)),
              ),
              child: Row(
                children: [
                  Icon(
                    store.isVerified
                        ? Icons.verified_rounded
                        : Icons.pending_rounded,
                    color:
                        store.isVerified ? Colors.green : Colors.orange,
                    size: 18,
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      store.isVerified
                          ? 'Verified seller — your store is trusted by buyers'
                          : 'Verification pending — keep adding products to get verified',
                      style: GoogleFonts.poppins(
                          color: store.isVerified
                              ? Colors.green
                              : Colors.orange,
                          fontSize: 12),
                    ),
                  ),
                ],
              ),
            ),

          // Fields
          _field(
            label: _type == SellerType.organization
                ? 'Organization Name *'
                : 'Store Name *',
            controller: _storeNameCtrl,
            hint: _type == SellerType.organization
                ? 'e.g. GameTech Studios'
                : 'e.g. Alex\'s Game Shop',
            enabled: _isEditing,
            validator: (v) =>
                v == null || v.trim().isEmpty ? 'Required' : null,
          ),
          const SizedBox(height: 14),
          _field(
            label: 'Store Description',
            controller: _descCtrl,
            hint: 'Tell buyers about your store...',
            enabled: _isEditing,
            maxLines: 3,
          ),
          const SizedBox(height: 14),
          _field(
            label: 'Contact Email',
            controller: _emailCtrl,
            hint: 'store@email.com',
            enabled: _isEditing,
            keyboardType: TextInputType.emailAddress,
          ),
          const SizedBox(height: 14),
          _field(
            label: 'Phone',
            controller: _phoneCtrl,
            hint: '+1 234 567 8900',
            enabled: _isEditing,
            keyboardType: TextInputType.phone,
          ),
          const SizedBox(height: 14),
          _field(
            label: 'Address',
            controller: _addressCtrl,
            hint: 'Store or business address',
            enabled: _isEditing,
          ),
          const SizedBox(height: 14),
          _field(
            label: 'Website',
            controller: _websiteCtrl,
            hint: 'https://yourstore.com',
            enabled: _isEditing,
            keyboardType: TextInputType.url,
          ),

          const SizedBox(height: 24),

          if (_isEditing)
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () {
                      _initFromStore(widget.seller.store);
                      setState(() => _isEditing = false);
                    },
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.grey,
                      side: const BorderSide(color: Colors.grey),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                    ),
                    child: Text('Cancel',
                        style: GoogleFonts.poppins(
                            fontWeight: FontWeight.w600)),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  flex: 2,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _save,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFE63946),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                    ),
                    child: _isLoading
                        ? const SizedBox(
                            height: 18,
                            width: 18,
                            child: CircularProgressIndicator(
                                strokeWidth: 2, color: Colors.white))
                        : Text(
                            store == null ? 'Create Store' : 'Save Changes',
                            style: GoogleFonts.poppins(
                                fontWeight: FontWeight.bold)),
                  ),
                ),
              ],
            )
          else
            ElevatedButton.icon(
              onPressed: () => setState(() => _isEditing = true),
              icon: const Icon(Icons.edit_rounded, size: 16),
              label: Text('Edit Store Info',
                  style: GoogleFonts.poppins(fontWeight: FontWeight.bold)),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF222222),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
              ),
            ),

          const SizedBox(height: 40),
        ],
      ),
    );
  }

  Widget _field({
    required String label,
    required TextEditingController controller,
    String? hint,
    int maxLines = 1,
    bool enabled = true,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: GoogleFonts.poppins(
                color: Colors.grey.shade500,
                fontSize: 11,
                fontWeight: FontWeight.w500)),
        const SizedBox(height: 6),
        TextFormField(
          controller: controller,
          enabled: enabled,
          maxLines: maxLines,
          keyboardType: keyboardType,
          validator: validator,
          style: GoogleFonts.poppins(color: Colors.white, fontSize: 13),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle:
                GoogleFonts.poppins(color: Colors.grey.shade700, fontSize: 12),
            filled: true,
            fillColor:
                enabled ? const Color(0xFF1A1A1A) : const Color(0xFF161616),
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide.none,
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(
                  color: Color(0xFFE63946), width: 1.5),
            ),
            disabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide:
                  BorderSide(color: Colors.white.withOpacity(0.05)),
            ),
          ),
        ),
      ],
    );
  }
}

// ── Account tab (personal details) ──
class _AccountTab extends StatefulWidget {
  final AuthProvider auth;
  const _AccountTab({required this.auth});

  @override
  State<_AccountTab> createState() => _AccountTabState();
}

class _AccountTabState extends State<_AccountTab> {
  late TextEditingController _nameCtrl;
  late TextEditingController _phoneCtrl;
  bool _isEditing = false;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _nameCtrl =
        TextEditingController(text: widget.auth.currentUser?.name ?? '');
    _phoneCtrl =
        TextEditingController(text: widget.auth.currentUser?.phone ?? '');
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _phoneCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final user = widget.auth.currentUser;
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        // Avatar
        Center(
          child: Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFFE63946), Color(0xFFFF6B6B)],
              ),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Center(
              child: Text(
                (user?.name ?? 'S').isNotEmpty
                    ? user!.name[0].toUpperCase()
                    : 'S',
                style: GoogleFonts.orbitron(
                    color: Colors.white,
                    fontSize: 32,
                    fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ),
        const SizedBox(height: 8),
        Center(
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            decoration: BoxDecoration(
              color: const Color(0xFFE63946).withOpacity(0.15),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                  color: const Color(0xFFE63946).withOpacity(0.3)),
            ),
            child: Text('SELLER ACCOUNT',
                style: GoogleFonts.poppins(
                    color: const Color(0xFFE63946),
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.5)),
          ),
        ),
        const SizedBox(height: 24),

        // Read-only email
        _InfoTile(label: 'Email', value: user?.email ?? '—'),
        const SizedBox(height: 10),

        // Editable name
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Full Name',
                style: GoogleFonts.poppins(
                    color: Colors.grey.shade500,
                    fontSize: 11,
                    fontWeight: FontWeight.w500)),
            const SizedBox(height: 6),
            TextField(
              controller: _nameCtrl,
              enabled: _isEditing,
              style: GoogleFonts.poppins(color: Colors.white, fontSize: 13),
              decoration: InputDecoration(
                filled: true,
                fillColor: _isEditing
                    ? const Color(0xFF1A1A1A)
                    : const Color(0xFF161616),
                contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16, vertical: 14),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide.none,
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: const BorderSide(
                      color: Color(0xFFE63946), width: 1.5),
                ),
                disabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide:
                      BorderSide(color: Colors.white.withOpacity(0.05)),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 14),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Phone',
                style: GoogleFonts.poppins(
                    color: Colors.grey.shade500,
                    fontSize: 11,
                    fontWeight: FontWeight.w500)),
            const SizedBox(height: 6),
            TextField(
              controller: _phoneCtrl,
              enabled: _isEditing,
              keyboardType: TextInputType.phone,
              style: GoogleFonts.poppins(color: Colors.white, fontSize: 13),
              decoration: InputDecoration(
                filled: true,
                fillColor: _isEditing
                    ? const Color(0xFF1A1A1A)
                    : const Color(0xFF161616),
                contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16, vertical: 14),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide.none,
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: const BorderSide(
                      color: Color(0xFFE63946), width: 1.5),
                ),
                disabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide:
                      BorderSide(color: Colors.white.withOpacity(0.05)),
                ),
              ),
            ),
          ],
        ),

        const SizedBox(height: 24),

        if (_isEditing)
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () => setState(() => _isEditing = false),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.grey,
                    side: const BorderSide(color: Colors.grey),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                  ),
                  child: Text('Cancel',
                      style: GoogleFonts.poppins(fontWeight: FontWeight.w600)),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                flex: 2,
                child: ElevatedButton(
                  onPressed: _isLoading
                      ? null
                      : () async {
                          setState(() => _isLoading = true);
                          await widget.auth.updateProfile(
                            name: _nameCtrl.text.trim(),
                            phone: _phoneCtrl.text.trim(),
                            address: null,
                          );
                          setState(() {
                            _isLoading = false;
                            _isEditing = false;
                          });
                          if (context.mounted) {
                            ScaffoldMessenger.of(context)
                                .showSnackBar(const SnackBar(
                              content: Text('Profile updated!'),
                              backgroundColor: Colors.green,
                              behavior: SnackBarBehavior.floating,
                            ));
                          }
                        },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFE63946),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                  ),
                  child: Text('Save',
                      style: GoogleFonts.poppins(fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          )
        else
          ElevatedButton.icon(
            onPressed: () => setState(() => _isEditing = true),
            icon: const Icon(Icons.edit_rounded, size: 16),
            label: Text('Edit Profile',
                style: GoogleFonts.poppins(fontWeight: FontWeight.bold)),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF222222),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
            ),
          ),

        const SizedBox(height: 40),
      ],
    );
  }
}

class _InfoTile extends StatelessWidget {
  final String label;
  final String value;
  const _InfoTile({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: const Color(0xFF161616),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.white.withOpacity(0.05)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label,
              style: GoogleFonts.poppins(
                  color: Colors.grey.shade500, fontSize: 12)),
          Text(value,
              style: GoogleFonts.poppins(color: Colors.white, fontSize: 13)),
        ],
      ),
    );
  }
}

class _TypeTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final bool selected;
  final VoidCallback? onTap;

  const _TypeTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.selected,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: selected
              ? const Color(0xFFE63946).withOpacity(0.12)
              : const Color(0xFF222222),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: selected
                ? const Color(0xFFE63946).withOpacity(0.5)
                : Colors.white.withOpacity(0.08),
            width: selected ? 1.5 : 1,
          ),
        ),
        child: Column(
          children: [
            Icon(icon,
                color: selected ? const Color(0xFFE63946) : Colors.grey.shade600,
                size: 22),
            const SizedBox(height: 6),
            Text(title,
                style: GoogleFonts.poppins(
                    color: selected ? Colors.white : Colors.grey.shade600,
                    fontSize: 12,
                    fontWeight:
                        selected ? FontWeight.bold : FontWeight.normal)),
            Text(subtitle,
                style: GoogleFonts.poppins(
                    color: Colors.grey.shade700, fontSize: 9),
                textAlign: TextAlign.center),
          ],
        ),
      ),
    );
  }
}
