import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../app/theme/app_theme.dart';
import '../../models/payment_method_model.dart';
import '../../providers/auth_provider.dart';
import '../../providers/user_data_provider.dart';

class PaymentScreen extends StatelessWidget {
  /// When true, user is coming from checkout — selecting a method
  /// returns it via Navigator.pop(context, selectedMethod).
  final bool selectMode;

  const PaymentScreen({super.key, this.selectMode = false});

  @override
  Widget build(BuildContext context) {
    return Consumer2<UserDataProvider, AuthProvider>(
      builder: (context, data, auth, _) {
        final methods = data.paymentMethods;

        return Scaffold(
          backgroundColor: const Color(0xFF141414),
          appBar: AppBar(
            backgroundColor: const Color(0xFF141414),
            elevation: 0,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back_ios,
                  color: Colors.white, size: 18),
              onPressed: () => Navigator.canPop(context)
                  ? Navigator.pop(context)
                  : context.go('/profile'),
            ),
            title: Text(
              selectMode ? 'SELECT PAYMENT' : 'PAYMENT METHODS',
              style: GoogleFonts.orbitron(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 2),
            ),
            actions: [
              if (methods.isNotEmpty)
                TextButton.icon(
                  onPressed: () => _showAddSheet(context, data, auth),
                  icon: const Icon(Icons.add,
                      color: AppTheme.primaryRed, size: 18),
                  label: Text('Add',
                      style: GoogleFonts.poppins(
                          color: AppTheme.primaryRed,
                          fontSize: 13,
                          fontWeight: FontWeight.bold)),
                ),
            ],
          ),
          body: methods.isEmpty
              ? _EmptyPaymentState(
                  onAdd: () => _showAddSheet(context, data, auth))
              : _PaymentList(
                  methods: methods,
                  data: data,
                  selectMode: selectMode,
                  onAdd: () => _showAddSheet(context, data, auth),
                ),
        );
      },
    );
  }

  void _showAddSheet(BuildContext context, UserDataProvider data,
      AuthProvider auth) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _AddPaymentSheet(
        userId: auth.currentUser?.id ?? '',
        data: data,
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────
// EMPTY STATE
// ─────────────────────────────────────────────────────────

class _EmptyPaymentState extends StatelessWidget {
  final VoidCallback onAdd;
  const _EmptyPaymentState({required this.onAdd});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Animated card icon
            Container(
              width: 100, height: 100,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppTheme.primaryRed.withOpacity(0.08),
                border: Border.all(
                    color: AppTheme.primaryRed.withOpacity(0.2),
                    width: 2),
              ),
              child: const Icon(Icons.credit_card_outlined,
                  color: AppTheme.primaryRed, size: 48),
            ),
            const SizedBox(height: 28),
            Text('No Payment Methods',
                style: GoogleFonts.orbitron(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            Text(
              'Add a card or payment method to\ncheckout faster and securely.',
              textAlign: TextAlign.center,
              style: TextStyle(
                  color: Colors.grey.shade500,
                  fontSize: 14,
                  height: 1.5),
            ),
            const SizedBox(height: 36),
            // Payment brand logos row
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _BrandChip(label: 'VISA', color: const Color(0xFF1A1F71)),
                const SizedBox(width: 10),
                _BrandChip(
                    label: 'MC', color: const Color(0xFFEB001B)),
                const SizedBox(width: 10),
                _BrandChip(
                    label: 'AMEX',
                    color: const Color(0xFF2E77BC)),
                const SizedBox(width: 10),
                _BrandChip(
                    label: 'PP',
                    color: const Color(0xFF003087)),
              ],
            ),
            const SizedBox(height: 36),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: onAdd,
                icon: const Icon(Icons.add, size: 20),
                label: Text('Add Payment Method',
                    style: GoogleFonts.poppins(
                        fontSize: 15,
                        fontWeight: FontWeight.bold)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primaryRed,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14)),
                  elevation: 0,
                ),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.lock_outline,
                    color: Colors.grey.shade600, size: 13),
                const SizedBox(width: 5),
                Text('256-bit encrypted & secure',
                    style: TextStyle(
                        color: Colors.grey.shade600, fontSize: 12)),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _BrandChip extends StatelessWidget {
  final String label;
  final Color color;
  const _BrandChip({required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 52, height: 32,
      decoration: BoxDecoration(
        color: color.withOpacity(0.15),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Center(
        child: Text(label,
            style: TextStyle(
                color: color,
                fontSize: 10,
                fontWeight: FontWeight.bold,
                letterSpacing: 0.5)),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────
// PAYMENT LIST
// ─────────────────────────────────────────────────────────

class _PaymentList extends StatefulWidget {
  final List<PaymentMethod> methods;
  final UserDataProvider data;
  final bool selectMode;
  final VoidCallback onAdd;

  const _PaymentList({
    required this.methods,
    required this.data,
    required this.selectMode,
    required this.onAdd,
  });

  @override
  State<_PaymentList> createState() => _PaymentListState();
}

class _PaymentListState extends State<_PaymentList> {
  String? _selectedId;

  @override
  void initState() {
    super.initState();
    // Pre-select default in selectMode
    final def = widget.methods.where((m) => m.isDefault).firstOrNull;
    _selectedId = def?.id ?? widget.methods.first.id;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
            itemCount: widget.methods.length,
            itemBuilder: (context, i) {
              final m = widget.methods[i];
              final isSelected =
                  widget.selectMode && _selectedId == m.id;

              return GestureDetector(
                onTap: widget.selectMode
                    ? () => setState(() => _selectedId = m.id)
                    : null,
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  margin: const EdgeInsets.only(bottom: 12),
                  decoration: BoxDecoration(
                    color: const Color(0xFF1E1E1E),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: isSelected
                          ? AppTheme.primaryRed
                          : m.isDefault
                              ? AppTheme.primaryRed.withOpacity(0.4)
                              : Colors.grey.shade800,
                      width: isSelected ? 2 : 1,
                    ),
                    boxShadow: isSelected
                        ? [
                            BoxShadow(
                              color: AppTheme.primaryRed
                                  .withOpacity(0.15),
                              blurRadius: 12,
                              spreadRadius: 2,
                            )
                          ]
                        : null,
                  ),
                  child: Column(children: [
                    // Card visual
                    _CardVisual(method: m),
                    // Actions row
                    Padding(
                      padding: const EdgeInsets.fromLTRB(
                          16, 0, 8, 12),
                      child: Row(children: [
                        if (m.isDefault)
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(
                              color: AppTheme.primaryRed
                                  .withOpacity(0.12),
                              borderRadius:
                                  BorderRadius.circular(20),
                              border: Border.all(
                                  color: AppTheme.primaryRed
                                      .withOpacity(0.4)),
                            ),
                            child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Icon(Icons.check_circle,
                                      color: AppTheme.primaryRed,
                                      size: 11),
                                  const SizedBox(width: 4),
                                  const Text('DEFAULT',
                                      style: TextStyle(
                                          color: AppTheme.primaryRed,
                                          fontSize: 9,
                                          fontWeight:
                                              FontWeight.bold,
                                          letterSpacing: 0.5)),
                                ]),
                          )
                        else
                          TextButton(
                            onPressed: () =>
                                widget.data.setDefaultPayment(m.id),
                            style: TextButton.styleFrom(
                                padding: EdgeInsets.zero,
                                minimumSize: const Size(0, 0),
                                tapTargetSize:
                                    MaterialTapTargetSize.shrinkWrap),
                            child: Text('Set default',
                                style: TextStyle(
                                    color: Colors.grey.shade500,
                                    fontSize: 11)),
                          ),
                        const Spacer(),
                        // Delete
                        IconButton(
                          onPressed: () =>
                              _confirmDelete(context, m),
                          icon: Icon(Icons.delete_outline,
                              color: Colors.grey.shade600,
                              size: 18),
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(),
                        ),
                      ]),
                    ),
                  ]),
                ),
              );
            },
          ),
        ),

        // Add another
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
          child: OutlinedButton.icon(
            onPressed: widget.onAdd,
            icon: const Icon(Icons.add, size: 18),
            label: const Text('Add Another Method'),
            style: OutlinedButton.styleFrom(
              minimumSize: const Size(double.infinity, 48),
              foregroundColor: AppTheme.primaryRed,
              side: BorderSide(
                  color: AppTheme.primaryRed.withOpacity(0.5)),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
            ),
          ),
        ),

        // Confirm button in select mode
        if (widget.selectMode)
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
            child: ElevatedButton(
              onPressed: () {
                final chosen = widget.methods
                    .firstWhere((m) => m.id == _selectedId);
                Navigator.pop(context, chosen);
              },
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(double.infinity, 52),
                backgroundColor: AppTheme.primaryRed,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14)),
                elevation: 0,
              ),
              child: Text('Use This Card',
                  style: GoogleFonts.poppins(
                      fontSize: 15, fontWeight: FontWeight.bold)),
            ),
          )
        else
          const SizedBox(height: 24),

        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.lock_outline,
                color: Colors.grey.shade700, size: 12),
            const SizedBox(width: 5),
            Text('256-bit SSL encrypted',
                style: TextStyle(
                    color: Colors.grey.shade700, fontSize: 11)),
          ],
        ),
        const SizedBox(height: 16),
      ],
    );
  }

  void _confirmDelete(BuildContext context, PaymentMethod m) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF2A2A2A),
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16)),
        title: const Text('Remove Card',
            style: TextStyle(color: Colors.white)),
        content: Text(
            'Remove ${m.displayName} ending in ${m.last4 ?? ''}?',
            style: TextStyle(color: Colors.grey.shade400)),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Cancel',
                  style: TextStyle(color: Colors.grey))),
          TextButton(
            onPressed: () {
              widget.data.removePaymentMethod(m.id);
              Navigator.pop(ctx);
            },
            child: const Text('Remove',
                style: TextStyle(
                    color: Colors.red,
                    fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────
// CARD VISUAL — the realistic card render
// ─────────────────────────────────────────────────────────

class _CardVisual extends StatelessWidget {
  final PaymentMethod method;
  const _CardVisual({required this.method});

  Color get _cardColor {
    switch (method.cardBrand?.toLowerCase()) {
      case 'visa': return const Color(0xFF1A237E);
      case 'mastercard': return const Color(0xFF880E4F);
      case 'amex': return const Color(0xFF0D47A1);
      case 'paypal': return const Color(0xFF003087);
      default: return const Color(0xFF1B1B2F);
    }
  }

  String get _brandLabel {
    if (method.type == PaymentType.paypal) return 'PayPal';
    if (method.type == PaymentType.applePay) return 'Apple Pay';
    if (method.type == PaymentType.googlePay) return 'Google Pay';
    return method.cardBrand?.toUpperCase() ?? 'CARD';
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(12),
      height: 130,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14),
        gradient: LinearGradient(
          colors: [
            _cardColor,
            _cardColor.withOpacity(0.7),
            Colors.black.withOpacity(0.5),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: _cardColor.withOpacity(0.4),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Stack(
        children: [
          // Decorative circles
          Positioned(
            right: -20, top: -20,
            child: Container(
              width: 100, height: 100,
              decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withOpacity(0.05)),
            ),
          ),
          Positioned(
            right: 30, bottom: -30,
            child: Container(
              width: 80, height: 80,
              decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withOpacity(0.04)),
            ),
          ),
          // Content
          Padding(
            padding: const EdgeInsets.all(18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Top row: chip + brand
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // EMV chip
                    Container(
                      width: 32, height: 24,
                      decoration: BoxDecoration(
                        color: Colors.amber.shade300.withOpacity(0.7),
                        borderRadius: BorderRadius.circular(4),
                        border: Border.all(
                            color: Colors.amber.shade600.withOpacity(0.5)),
                      ),
                    ),
                    Text(_brandLabel,
                        style: GoogleFonts.orbitron(
                            color: Colors.white.withOpacity(0.9),
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1)),
                  ],
                ),
                const Spacer(),
                // Card number
                Text(
                  method.last4 != null
                      ? '•••• •••• •••• ${method.last4}'
                      : method.displayName,
                  style: GoogleFonts.orbitron(
                      color: Colors.white,
                      fontSize: 14,
                      letterSpacing: 3),
                ),
                const SizedBox(height: 10),
                // Expiry + cardholder
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('EXPIRES',
                            style: TextStyle(
                                color: Colors.white.withOpacity(0.5),
                                fontSize: 8,
                                letterSpacing: 1)),
                        Text(
                          method.expiryMonth != null
                              ? '${method.expiryMonth}/${method.expiryYear}'
                              : '—',
                          style: const TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text('CARDHOLDER',
                            style: TextStyle(
                                color: Colors.white.withOpacity(0.5),
                                fontSize: 8,
                                letterSpacing: 1)),
                        Text(
                          method.displayName.toUpperCase(),
                          style: const TextStyle(
                              color: Colors.white,
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 0.5),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────
// ADD PAYMENT SHEET
// ─────────────────────────────────────────────────────────

class _AddPaymentSheet extends StatefulWidget {
  final String userId;
  final UserDataProvider data;

  const _AddPaymentSheet({required this.userId, required this.data});

  @override
  State<_AddPaymentSheet> createState() => _AddPaymentSheetState();
}

class _AddPaymentSheetState extends State<_AddPaymentSheet>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  // Card fields
  final _nameCtrl = TextEditingController();
  final _numberCtrl = TextEditingController();
  final _expiryCtrl = TextEditingController();
  final _cvvCtrl = TextEditingController();
  String _cardBrand = 'Visa';
  bool _saveCard = true;

  // Card preview state
  String _previewNumber = '';
  String _previewName = '';
  String _previewExpiry = '';

  static const _brands = ['Visa', 'Mastercard', 'Amex', 'Other'];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _numberCtrl.addListener(() {
      setState(() => _previewNumber = _numberCtrl.text);
    });
    _nameCtrl.addListener(() {
      setState(() => _previewName = _nameCtrl.text);
    });
    _expiryCtrl.addListener(() {
      setState(() => _previewExpiry = _expiryCtrl.text);
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    _nameCtrl.dispose();
    _numberCtrl.dispose();
    _expiryCtrl.dispose();
    _cvvCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.90,
      decoration: const BoxDecoration(
        color: Color(0xFF1A1A1A),
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(children: [
        // Handle
        Center(
          child: Container(
            width: 40, height: 4,
            margin: const EdgeInsets.only(top: 14, bottom: 4),
            decoration: BoxDecoration(
                color: Colors.grey.shade700,
                borderRadius: BorderRadius.circular(2)),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(
              horizontal: 20, vertical: 12),
          child: Row(children: [
            Text('Add Payment Method',
                style: GoogleFonts.poppins(
                    color: Colors.white,
                    fontSize: 17,
                    fontWeight: FontWeight.bold)),
            const Spacer(),
            GestureDetector(
              onTap: () => Navigator.pop(context),
              child: Icon(Icons.close,
                  color: Colors.grey.shade500, size: 22),
            ),
          ]),
        ),

        // Tab bar
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 20),
          decoration: BoxDecoration(
            color: const Color(0xFF2A2A2A),
            borderRadius: BorderRadius.circular(12),
          ),
          child: TabBar(
            controller: _tabController,
            indicator: BoxDecoration(
              color: AppTheme.primaryRed,
              borderRadius: BorderRadius.circular(10),
            ),
            indicatorSize: TabBarIndicatorSize.tab,
            labelColor: Colors.white,
            unselectedLabelColor: Colors.grey.shade500,
            labelStyle: GoogleFonts.poppins(
                fontSize: 12, fontWeight: FontWeight.bold),
            unselectedLabelStyle:
                GoogleFonts.poppins(fontSize: 12),
            dividerColor: Colors.transparent,
            tabs: const [
              Tab(text: 'Card'),
              Tab(text: 'PayPal'),
              Tab(text: 'Other'),
            ],
          ),
        ),

        Expanded(
          child: TabBarView(
            controller: _tabController,
            children: [
              _buildCardTab(),
              _buildPayPalTab(),
              _buildOtherTab(),
            ],
          ),
        ),
      ]),
    );
  }

  // ── Card tab ──
  Widget _buildCardTab() {
    return SingleChildScrollView(
      padding: EdgeInsets.fromLTRB(
          20, 20, 20, MediaQuery.of(context).viewInsets.bottom + 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Live card preview
          _LiveCardPreview(
            number: _previewNumber,
            name: _previewName,
            expiry: _previewExpiry,
            brand: _cardBrand,
          ),
          const SizedBox(height: 24),

          // Card brand selector
          _label('Card Type'),
          const SizedBox(height: 8),
          Row(
            children: _brands.map((brand) {
              final selected = _cardBrand == brand;
              return GestureDetector(
                onTap: () => setState(() => _cardBrand = brand),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  margin: const EdgeInsets.only(right: 8),
                  padding: const EdgeInsets.symmetric(
                      horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: selected
                        ? AppTheme.primaryRed.withOpacity(0.15)
                        : const Color(0xFF2A2A2A),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                        color: selected
                            ? AppTheme.primaryRed
                            : Colors.grey.shade700),
                  ),
                  child: Text(brand,
                      style: TextStyle(
                          color: selected
                              ? AppTheme.primaryRed
                              : Colors.grey.shade400,
                          fontSize: 12,
                          fontWeight: selected
                              ? FontWeight.bold
                              : FontWeight.normal)),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 16),

          // Cardholder name
          _label('Cardholder Name'),
          const SizedBox(height: 8),
          _field(
            controller: _nameCtrl,
            hint: 'Name as on card',
            icon: Icons.person_outline,
            inputFormatters: [
              FilteringTextInputFormatter.allow(RegExp(r'[a-zA-Z ]'))
            ],
          ),
          const SizedBox(height: 14),

          // Card number
          _label('Card Number'),
          const SizedBox(height: 8),
          _field(
            controller: _numberCtrl,
            hint: '0000 0000 0000 0000',
            icon: Icons.credit_card_outlined,
            keyboardType: TextInputType.number,
            inputFormatters: [
              FilteringTextInputFormatter.digitsOnly,
              _CardNumberFormatter(),
            ],
            maxLength: 19,
          ),
          const SizedBox(height: 14),

          // Expiry + CVV
          Row(children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _label('Expiry Date'),
                  const SizedBox(height: 8),
                  _field(
                    controller: _expiryCtrl,
                    hint: 'MM/YY',
                    icon: Icons.calendar_today_outlined,
                    keyboardType: TextInputType.number,
                    inputFormatters: [
                      FilteringTextInputFormatter.digitsOnly,
                      _ExpiryFormatter(),
                    ],
                    maxLength: 5,
                  ),
                ],
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _label('CVV'),
                  const SizedBox(height: 8),
                  _field(
                    controller: _cvvCtrl,
                    hint: '•••',
                    icon: Icons.lock_outline,
                    keyboardType: TextInputType.number,
                    obscure: true,
                    inputFormatters: [
                      FilteringTextInputFormatter.digitsOnly,
                    ],
                    maxLength: 4,
                  ),
                ],
              ),
            ),
          ]),
          const SizedBox(height: 14),

          // Save toggle
          Row(children: [
            Switch(
                value: _saveCard,
                onChanged: (v) => setState(() => _saveCard = v),
                activeColor: AppTheme.primaryRed),
            const SizedBox(width: 8),
            Expanded(
              child: Text('Save card for future payments',
                  style: TextStyle(
                      color: Colors.grey.shade400, fontSize: 13)),
            ),
          ]),
          const SizedBox(height: 20),

          // Save button
          ElevatedButton.icon(
            onPressed: _saveCardMethod,
            icon: const Icon(Icons.lock_outline, size: 18),
            label: Text('Save Card',
                style: GoogleFonts.poppins(
                    fontSize: 15, fontWeight: FontWeight.bold)),
            style: ElevatedButton.styleFrom(
              minimumSize: const Size(double.infinity, 52),
              backgroundColor: AppTheme.primaryRed,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14)),
              elevation: 0,
            ),
          ),
          const SizedBox(height: 12),
          Center(
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.security,
                    color: Colors.grey.shade600, size: 13),
                const SizedBox(width: 5),
                Text('Your data is end-to-end encrypted',
                    style: TextStyle(
                        color: Colors.grey.shade600,
                        fontSize: 11)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ── PayPal tab ──
  Widget _buildPayPalTab() {
    final emailCtrl = TextEditingController();
    return Padding(
      padding: EdgeInsets.fromLTRB(
          20, 30, 20, MediaQuery.of(context).viewInsets.bottom + 24),
      child: Column(children: [
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: const Color(0xFF003087).withOpacity(0.1),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
                color: const Color(0xFF003087).withOpacity(0.3)),
          ),
          child: Row(children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: const Color(0xFF003087).withOpacity(0.2),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(
                  Icons.account_balance_wallet_outlined,
                  color: Color(0xFF009CDE),
                  size: 26),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('PayPal',
                      style: GoogleFonts.poppins(
                          color: Colors.white,
                          fontSize: 15,
                          fontWeight: FontWeight.bold)),
                  Text('Fast, secure checkout',
                      style: TextStyle(
                          color: Colors.grey.shade500,
                          fontSize: 12)),
                ],
              ),
            ),
          ]),
        ),
        const SizedBox(height: 24),
        _label('PayPal Email'),
        const SizedBox(height: 8),
        _field(
            controller: emailCtrl,
            hint: 'your@paypal.com',
            icon: Icons.email_outlined,
            keyboardType: TextInputType.emailAddress),
        const SizedBox(height: 20),
        ElevatedButton(
          onPressed: () {
            if (emailCtrl.text.isEmpty ||
                !emailCtrl.text.contains('@')) return;
            widget.data.addPaymentMethod(PaymentMethod(
              id: 'pm_${DateTime.now().millisecondsSinceEpoch}',
              userId: widget.userId,
              type: PaymentType.paypal,
              displayName: emailCtrl.text,
              isDefault: widget.data.paymentMethods.isEmpty,
            ));
            Navigator.pop(context);
            _successSnack(context, 'PayPal account linked!');
          },
          style: ElevatedButton.styleFrom(
            minimumSize: const Size(double.infinity, 52),
            backgroundColor: const Color(0xFF003087),
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14)),
          ),
          child: Text('Link PayPal',
              style: GoogleFonts.poppins(
                  fontSize: 15, fontWeight: FontWeight.bold)),
        ),
      ]),
    );
  }

  // ── Other tab ──
  Widget _buildOtherTab() {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          _DigitalWalletTile(
            icon: Icons.apple,
            label: 'Apple Pay',
            subtitle: 'Pay with Touch ID or Face ID',
            color: Colors.white,
            onTap: () {
              widget.data.addPaymentMethod(PaymentMethod(
                id: 'pm_${DateTime.now().millisecondsSinceEpoch}',
                userId: widget.userId,
                type: PaymentType.applePay,
                displayName: 'Apple Pay',
                isDefault: widget.data.paymentMethods.isEmpty,
              ));
              Navigator.pop(context);
              _successSnack(context, 'Apple Pay added!');
            },
          ),
          const SizedBox(height: 10),
          _DigitalWalletTile(
            icon: Icons.g_mobiledata,
            label: 'Google Pay',
            subtitle: 'Pay with your Google account',
            color: const Color(0xFF4285F4),
            onTap: () {
              widget.data.addPaymentMethod(PaymentMethod(
                id: 'pm_${DateTime.now().millisecondsSinceEpoch}',
                userId: widget.userId,
                type: PaymentType.googlePay,
                displayName: 'Google Pay',
                isDefault: widget.data.paymentMethods.isEmpty,
              ));
              Navigator.pop(context);
              _successSnack(context, 'Google Pay added!');
            },
          ),
        ],
      ),
    );
  }

  void _saveCardMethod() {
    final number = _numberCtrl.text.replaceAll(' ', '');
    if (_nameCtrl.text.trim().isEmpty) {
      _errorSnack(context, 'Enter cardholder name');
      return;
    }
    if (number.length < 13) {
      _errorSnack(context, 'Enter a valid card number');
      return;
    }
    if (_expiryCtrl.text.length < 5) {
      _errorSnack(context, 'Enter expiry date (MM/YY)');
      return;
    }
    if (_cvvCtrl.text.length < 3) {
      _errorSnack(context, 'Enter CVV');
      return;
    }

    final parts = _expiryCtrl.text.split('/');
    widget.data.addPaymentMethod(PaymentMethod(
      id: 'pm_${DateTime.now().millisecondsSinceEpoch}',
      userId: widget.userId,
      type: PaymentType.card,
      displayName: _nameCtrl.text.trim(),
      last4: number.length >= 4 ? number.substring(number.length - 4) : null,
      expiryMonth: parts.isNotEmpty ? parts[0] : null,
      expiryYear: parts.length > 1 ? parts[1] : null,
      cardBrand: _cardBrand,
      isDefault: widget.data.paymentMethods.isEmpty,
    ));
    Navigator.pop(context);
    _successSnack(context, 'Card saved successfully!');
  }

  Widget _label(String text) => Text(text,
      style: TextStyle(
          color: Colors.grey.shade400,
          fontSize: 11,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.5));

  Widget _field({
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    TextInputType? keyboardType,
    bool obscure = false,
    List<TextInputFormatter>? inputFormatters,
    int? maxLength,
  }) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      obscureText: obscure,
      inputFormatters: inputFormatters,
      maxLength: maxLength,
      style: const TextStyle(color: Colors.white, fontSize: 14),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle:
            TextStyle(color: Colors.grey.shade600, fontSize: 14),
        prefixIcon: Icon(icon,
            color: AppTheme.primaryRed, size: 18),
        filled: true,
        fillColor: const Color(0xFF2A2A2A),
        counterText: '',
        contentPadding: const EdgeInsets.symmetric(
            horizontal: 14, vertical: 14),
        border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none),
        focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(
                color: AppTheme.primaryRed.withOpacity(0.5))),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────
// LIVE CARD PREVIEW
// ─────────────────────────────────────────────────────────

class _LiveCardPreview extends StatelessWidget {
  final String number;
  final String name;
  final String expiry;
  final String brand;

  const _LiveCardPreview({
    required this.number,
    required this.name,
    required this.expiry,
    required this.brand,
  });

  Color get _color {
    switch (brand.toLowerCase()) {
      case 'visa': return const Color(0xFF1A237E);
      case 'mastercard': return const Color(0xFF880E4F);
      case 'amex': return const Color(0xFF0D47A1);
      default: return const Color(0xFF1B1B2F);
    }
  }

  String get _formattedNumber {
    final raw = number.replaceAll(' ', '');
    if (raw.isEmpty) return '•••• •••• •••• ••••';
    final padded = raw.padRight(16, '•');
    final parts = <String>[];
    for (var i = 0; i < 16; i += 4) {
      parts.add(padded.substring(i, i + 4));
    }
    return parts.join(' ');
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      height: 150,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        gradient: LinearGradient(
          colors: [_color, _color.withOpacity(0.6), Colors.black45],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
              color: _color.withOpacity(0.4),
              blurRadius: 20,
              offset: const Offset(0, 8)),
        ],
      ),
      child: Stack(children: [
        // Circles
        Positioned(
          right: -30, top: -30,
          child: Container(
            width: 120, height: 120,
            decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withOpacity(0.05)),
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    width: 32, height: 22,
                    decoration: BoxDecoration(
                      color: Colors.amber.shade300.withOpacity(0.7),
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                  Text(brand.toUpperCase(),
                      style: GoogleFonts.orbitron(
                          color: Colors.white.withOpacity(0.8),
                          fontSize: 11,
                          fontWeight: FontWeight.bold)),
                ],
              ),
              const Spacer(),
              Text(
                _formattedNumber,
                style: GoogleFonts.orbitron(
                    color: Colors.white,
                    fontSize: 15,
                    letterSpacing: 3),
              ),
              const SizedBox(height: 10),
              Row(
                mainAxisAlignment:
                    MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    name.isEmpty ? 'CARDHOLDER NAME' : name.toUpperCase(),
                    style: TextStyle(
                        color: name.isEmpty
                            ? Colors.white38
                            : Colors.white,
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1),
                  ),
                  Text(
                    expiry.isEmpty ? 'MM/YY' : expiry,
                    style: TextStyle(
                        color: expiry.isEmpty
                            ? Colors.white38
                            : Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ],
          ),
        ),
      ]),
    );
  }
}

// ─────────────────────────────────────────────────────────
// DIGITAL WALLET TILE
// ─────────────────────────────────────────────────────────

class _DigitalWalletTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final String subtitle;
  final Color color;
  final VoidCallback onTap;

  const _DigitalWalletTile({
    required this.icon,
    required this.label,
    required this.subtitle,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: color.withOpacity(0.07),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: color.withOpacity(0.25)),
        ),
        child: Row(children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: color.withOpacity(0.15),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: color, size: 24),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label,
                    style: const TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.bold)),
                Text(subtitle,
                    style: TextStyle(
                        color: Colors.grey.shade500,
                        fontSize: 12)),
              ],
            ),
          ),
          Icon(Icons.arrow_forward_ios,
              color: Colors.grey.shade600, size: 15),
        ]),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────
// INPUT FORMATTERS
// ─────────────────────────────────────────────────────────

class _CardNumberFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue old, TextEditingValue next) {
    final digits = next.text.replaceAll(' ', '');
    final buffer = StringBuffer();
    for (var i = 0; i < digits.length; i++) {
      if (i > 0 && i % 4 == 0) buffer.write(' ');
      buffer.write(digits[i]);
    }
    final str = buffer.toString();
    return next.copyWith(
      text: str,
      selection: TextSelection.collapsed(offset: str.length),
    );
  }
}

class _ExpiryFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue old, TextEditingValue next) {
    var text = next.text.replaceAll('/', '');
    if (text.length >= 2) {
      text = '${text.substring(0, 2)}/${text.substring(2)}';
    }
    return next.copyWith(
      text: text,
      selection: TextSelection.collapsed(offset: text.length),
    );
  }
}

// ─────────────────────────────────────────────────────────
// SNACK HELPERS
// ─────────────────────────────────────────────────────────

void _successSnack(BuildContext context, String msg) {
  ScaffoldMessenger.of(context).showSnackBar(SnackBar(
    content: Text(msg),
    backgroundColor: Colors.green,
    behavior: SnackBarBehavior.floating,
    duration: const Duration(seconds: 2),
  ));
}

void _errorSnack(BuildContext context, String msg) {
  ScaffoldMessenger.of(context).showSnackBar(SnackBar(
    content: Text(msg),
    backgroundColor: Colors.red,
    behavior: SnackBarBehavior.floating,
    duration: const Duration(seconds: 2),
  ));
}