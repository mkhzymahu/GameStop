// lib/views/auth/register_screen.dart
// Replace entire file

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../models/user_model.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  final _confirmCtrl = TextEditingController();
  final _storeNameCtrl = TextEditingController();

  UserRole _role = UserRole.customer;
  String _sellerType = 'individual'; // 'individual' or 'organization'
  bool _obscurePass = true;
  bool _obscureConfirm = true;
  bool _isLoading = false;
  String? _error;

  late AnimationController _animCtrl;
  late Animation<double> _fadeAnim;

  @override
  void initState() {
    super.initState();
    _animCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 600));
    _fadeAnim =
        CurvedAnimation(parent: _animCtrl, curve: Curves.easeOut);
    _animCtrl.forward();
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _emailCtrl.dispose();
    _phoneCtrl.dispose();
    _passwordCtrl.dispose();
    _confirmCtrl.dispose();
    _storeNameCtrl.dispose();
    _animCtrl.dispose();
    super.dispose();
  }

  Future<void> _register() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() {
      _isLoading = true;
      _error = null;
    });

    final auth = context.read<AuthProvider>();
    final result = await auth.register(
      name: _nameCtrl.text.trim(),
      email: _emailCtrl.text.trim(),
      password: _passwordCtrl.text,
      confirmPassword: _confirmCtrl.text,
      phone: _phoneCtrl.text.trim(),
      address: null,
      role: _role,
      storeName: _role == UserRole.seller
          ? (_sellerType == 'organization'
              ? _storeNameCtrl.text.trim()
              : null)
          : null,
    );

    setState(() => _isLoading = false);

    if (result.success && mounted) {
      // redirect immediately based on role using go_router
      if (_role == UserRole.seller) {
        context.go('/seller');
      } else {
        context.go('/home');
      }
    } else {
      // AuthResult provides `error` (nullable) rather than `message`.
      setState(() => _error = result.error ?? 'Registration failed');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0D0D0D),
      body: FadeTransition(
        opacity: _fadeAnim,
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 28),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SizedBox(height: 32),

                  // Back button
                  Align(
                    alignment: Alignment.centerLeft,
                    child: GestureDetector(
                      onTap: () {
                        // go_router throws if you pop the last route.  use canPop
                        if (Navigator.of(context).canPop()) {
                          Navigator.of(context).pop();
                        } else {
                          context.go('/auth/login');
                        }
                      },
                      child: Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: const Color(0xFF1A1A1A),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Icon(Icons.arrow_back_ios_rounded,
                            color: Colors.white, size: 16),
                      ),
                    ),
                  ),
                  const SizedBox(height: 28),

                  // Title
                  Text('CREATE ACCOUNT',
                      style: GoogleFonts.orbitron(
                          color: Colors.white,
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1)),
                  const SizedBox(height: 6),
                  Text('Join GameStop and start gaming',
                      style: GoogleFonts.poppins(
                          color: Colors.grey.shade500, fontSize: 14)),

                  const SizedBox(height: 28),

                  // ── Role selector ──
                  Text('I WANT TO',
                      style: GoogleFonts.poppins(
                          color: Colors.grey.shade500,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1.5)),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Expanded(
                        child: _RoleTile(
                          icon: Icons.shopping_bag_rounded,
                          title: 'Buy',
                          subtitle: 'Shop for games\n& accessories',
                          selected: _role == UserRole.customer,
                          onTap: () =>
                              setState(() => _role = UserRole.customer),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _RoleTile(
                          icon: Icons.storefront_rounded,
                          title: 'Sell',
                          subtitle: 'List products\nand earn',
                          selected: _role == UserRole.seller,
                          onTap: () =>
                              setState(() => _role = UserRole.seller),
                        ),
                      ),
                    ],
                  ),

                  // ── Seller-specific fields ──
                  if (_role == UserRole.seller) ...[
                    const SizedBox(height: 20),
                    Text('SELLER TYPE',
                        style: GoogleFonts.poppins(
                            color: Colors.grey.shade500,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1.5)),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        Expanded(
                          child: _SellerTypeTile(
                            icon: Icons.person_rounded,
                            title: 'Individual',
                            selected: _sellerType == 'individual',
                            onTap: () =>
                                setState(() => _sellerType = 'individual'),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _SellerTypeTile(
                            icon: Icons.business_rounded,
                            title: 'Organization',
                            selected: _sellerType == 'organization',
                            onTap: () =>
                                setState(() => _sellerType = 'organization'),
                          ),
                        ),
                      ],
                    ),
                    if (_sellerType == 'organization') ...[
                      const SizedBox(height: 16),
                      _buildField(
                        controller: _storeNameCtrl,
                        label: 'Organization Name *',
                        hint: 'e.g. GameTech Studios',
                        icon: Icons.business_rounded,
                        validator: (v) => v == null || v.trim().isEmpty
                            ? 'Organization name required'
                            : null,
                      ),
                    ],
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: const Color(0xFFE63946).withOpacity(0.08),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                            color: const Color(0xFFE63946).withOpacity(0.2)),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.info_outline_rounded,
                              color: Color(0xFFE63946), size: 16),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              'You\'ll set up your store after registering.',
                              style: GoogleFonts.poppins(
                                  color: Colors.grey.shade400,
                                  fontSize: 11),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],

                  const SizedBox(height: 20),

                  // ── Standard fields ──
                  _buildField(
                    controller: _nameCtrl,
                    label: 'Full Name *',
                    hint: 'Your full name',
                    icon: Icons.person_outline_rounded,
                    validator: (v) => v == null || v.trim().isEmpty
                        ? 'Name is required'
                        : null,
                  ),
                  const SizedBox(height: 14),
                  _buildField(
                    controller: _emailCtrl,
                    label: 'Email *',
                    hint: 'you@email.com',
                    icon: Icons.email_outlined,
                    keyboardType: TextInputType.emailAddress,
                    validator: (v) {
                      if (v == null || v.trim().isEmpty)
                        return 'Email is required';
                      if (!RegExp(r'^[^@]+@[^@]+\.[^@]+')
                          .hasMatch(v.trim())) return 'Enter a valid email';
                      return null;
                    },
                  ),
                  const SizedBox(height: 14),
                  _buildField(
                    controller: _phoneCtrl,
                    label: 'Phone (optional)',
                    hint: '+1 234 567 8900',
                    icon: Icons.phone_outlined,
                    keyboardType: TextInputType.phone,
                  ),
                  const SizedBox(height: 14),
                  _buildField(
                    controller: _passwordCtrl,
                    label: 'Password *',
                    hint: 'Min 6 characters',
                    icon: Icons.lock_outline_rounded,
                    obscure: _obscurePass,
                    onToggleObscure: () =>
                        setState(() => _obscurePass = !_obscurePass),
                    validator: (v) {
                      if (v == null || v.isEmpty) return 'Password required';
                      if (v.length < 6) return 'Min 6 characters';
                      return null;
                    },
                  ),
                  const SizedBox(height: 14),
                  _buildField(
                    controller: _confirmCtrl,
                    label: 'Confirm Password *',
                    hint: 'Repeat your password',
                    icon: Icons.lock_outline_rounded,
                    obscure: _obscureConfirm,
                    onToggleObscure: () =>
                        setState(() => _obscureConfirm = !_obscureConfirm),
                    validator: (v) {
                      if (v != _passwordCtrl.text)
                        return 'Passwords do not match';
                      return null;
                    },
                  ),

                  // Error
                  if (_error != null) ...[
                    const SizedBox(height: 16),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.red.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: Colors.red.withOpacity(0.3)),
                      ),
                      child: Row(children: [
                        const Icon(Icons.error_outline,
                            color: Colors.red, size: 16),
                        const SizedBox(width: 8),
                        Expanded(
                            child: Text(_error!,
                                style: GoogleFonts.poppins(
                                    color: Colors.red, fontSize: 12))),
                      ]),
                    ),
                  ],

                  const SizedBox(height: 28),

                  // Register button
                  ElevatedButton(
                    onPressed: _isLoading ? null : _register,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFE63946),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14)),
                      disabledBackgroundColor:
                          const Color(0xFFE63946).withOpacity(0.4),
                    ),
                    child: _isLoading
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                                strokeWidth: 2, color: Colors.white))
                        : Text(
                            _role == UserRole.seller
                                ? 'Create Seller Account'
                                : 'Create Account',
                            style: GoogleFonts.orbitron(
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                                letterSpacing: 1),
                          ),
                  ),

                  const SizedBox(height: 20),

                  // Login link
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text('Already have an account? ',
                          style: GoogleFonts.poppins(
                              color: Colors.grey.shade500, fontSize: 13)),
                      GestureDetector(
                        onTap: () => context.go('/auth/login'),
                        child: Text('Sign In',
                            style: GoogleFonts.poppins(
                                color: const Color(0xFFE63946),
                                fontSize: 13,
                                fontWeight: FontWeight.bold)),
                      ),
                    ],
                  ),

                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    TextInputType? keyboardType,
    bool obscure = false,
    VoidCallback? onToggleObscure,
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
          keyboardType: keyboardType,
          obscureText: obscure,
          style: GoogleFonts.poppins(color: Colors.white, fontSize: 14),
          validator: validator,
          decoration: InputDecoration(
            hintText: hint,
            hintStyle:
                GoogleFonts.poppins(color: Colors.grey.shade700, fontSize: 13),
            prefixIcon: Icon(icon, color: Colors.grey.shade600, size: 20),
            suffixIcon: onToggleObscure != null
                ? GestureDetector(
                    onTap: onToggleObscure,
                    child: Icon(
                        obscure
                            ? Icons.visibility_off_outlined
                            : Icons.visibility_outlined,
                        color: Colors.grey.shade600,
                        size: 20),
                  )
                : null,
            filled: true,
            fillColor: const Color(0xFF1A1A1A),
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide:
                  const BorderSide(color: Color(0xFFE63946), width: 1.5),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.red.shade700),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.red.shade700, width: 1.5),
            ),
          ),
        ),
      ],
    );
  }
}

// ── Role tile (buy vs sell) ──
class _RoleTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final bool selected;
  final VoidCallback onTap;

  const _RoleTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: selected
              ? const Color(0xFFE63946).withOpacity(0.1)
              : const Color(0xFF1A1A1A),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: selected
                ? const Color(0xFFE63946)
                : Colors.grey.shade800,
            width: selected ? 1.5 : 1,
          ),
        ),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: selected
                    ? const Color(0xFFE63946).withOpacity(0.2)
                    : const Color(0xFF222222),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon,
                  color:
                      selected ? const Color(0xFFE63946) : Colors.grey.shade600,
                  size: 24),
            ),
            const SizedBox(height: 8),
            Text(title,
                style: GoogleFonts.orbitron(
                    color: selected ? Colors.white : Colors.grey.shade600,
                    fontSize: 13,
                    fontWeight: FontWeight.bold)),
            const SizedBox(height: 4),
            Text(subtitle,
                style: GoogleFonts.poppins(
                    color: Colors.grey.shade600, fontSize: 10),
                textAlign: TextAlign.center),
          ],
        ),
      ),
    );
  }
}

// ── Seller type mini tile ──
class _SellerTypeTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final bool selected;
  final VoidCallback onTap;

  const _SellerTypeTile({
    required this.icon,
    required this.title,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        decoration: BoxDecoration(
          color: selected
              ? const Color(0xFFE63946).withOpacity(0.1)
              : const Color(0xFF1A1A1A),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: selected
                ? const Color(0xFFE63946).withOpacity(0.6)
                : Colors.grey.shade800,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon,
                color: selected
                    ? const Color(0xFFE63946)
                    : Colors.grey.shade600,
                size: 18),
            const SizedBox(width: 8),
            Text(title,
                style: GoogleFonts.poppins(
                    color:
                        selected ? Colors.white : Colors.grey.shade600,
                    fontSize: 12,
                    fontWeight: selected
                        ? FontWeight.bold
                        : FontWeight.normal)),
          ],
        ),
      ),
    );
  }
}
