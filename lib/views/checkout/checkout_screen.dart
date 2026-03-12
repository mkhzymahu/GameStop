import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../app/theme/app_theme.dart';
import '../../models/order_model.dart';
import '../../models/payment_method_model.dart';
import '../../providers/auth_provider.dart';
import '../../providers/cart_provider.dart';
import '../../providers/notification_provider.dart';
import '../../providers/user_data_provider.dart';
import '../../services/order_service.dart';

// ─────────────────────────────────────────────────────────
// CHECKOUT SCREEN — entry point
// ─────────────────────────────────────────────────────────

class CheckoutScreen extends StatefulWidget {
  const CheckoutScreen({super.key});

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  // Steps: 0 = payment method, 1 = address, 2 = review, 3 = processing, 4 = success
  int _step = 0;

  // Selections
  String _paymentType = ''; // 'cod' | 'card' | 'paypal' | 'applepay' | 'googlepay'
  PaymentMethod? _selectedCard;
  String _deliveryAddress = '';
  bool _saveAddress = true;
  OrderModel? _placedOrder;

  // Address controllers
  final _streetCtrl = TextEditingController();
  final _cityCtrl = TextEditingController();
  final _zipCtrl = TextEditingController();

  @override
  void dispose() {
    _streetCtrl.dispose();
    _cityCtrl.dispose();
    _zipCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        if (_step > 0 && _step < 3) {
          setState(() => _step--);
          return false;
        }
        return _step == 0;
      },
      child: Scaffold(
        backgroundColor: const Color(0xFF141414),
        appBar: _step < 3
            ? AppBar(
                backgroundColor: const Color(0xFF141414),
                elevation: 0,
                leading: IconButton(
                  icon: const Icon(Icons.arrow_back_ios,
                      color: Colors.white, size: 18),
                  onPressed: () {
                    if (_step > 0) {
                      setState(() => _step--);
                    } else {
                      Navigator.pop(context);
                    }
                  },
                ),
                title: Text(
                  ['PAYMENT', 'DELIVERY', 'REVIEW'][_step.clamp(0, 2)],
                  style: GoogleFonts.orbitron(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 2),
                ),
                bottom: PreferredSize(
                  preferredSize: const Size.fromHeight(4),
                  child: _StepIndicator(step: _step, total: 3),
                ),
              )
            : null,
        body: AnimatedSwitcher(
          duration: const Duration(milliseconds: 300),
          transitionBuilder: (child, anim) => FadeTransition(
            opacity: anim,
            child: SlideTransition(
              position: Tween<Offset>(
                      begin: const Offset(0.05, 0), end: Offset.zero)
                  .animate(anim),
              child: child,
            ),
          ),
          child: KeyedSubtree(
            key: ValueKey(_step),
            child: _buildStep(),
          ),
        ),
      ),
    );
  }

  Widget _buildStep() {
    switch (_step) {
      case 0:
        return _PaymentMethodStep(
          onSelectCard: (card) {
            setState(() {
              _paymentType = 'card';
              _selectedCard = card;
            });
          },
          onSelectCod: () => setState(() {
            _paymentType = 'cod';
            _selectedCard = null;
          }),
          selectedType: _paymentType,
          selectedCard: _selectedCard,
          onNext: () {
            if (_paymentType.isEmpty) {
              _snack('Please select a payment method', Colors.red);
              return;
            }
            setState(() => _step = 1);
          },
        );
      case 1:
        return _DeliveryAddressStep(
          streetCtrl: _streetCtrl,
          cityCtrl: _cityCtrl,
          zipCtrl: _zipCtrl,
          saveAddress: _saveAddress,
          onToggleSave: (v) => setState(() => _saveAddress = v),
          onNext: () {
            final street = _streetCtrl.text.trim();
            final city = _cityCtrl.text.trim();
            if (street.isEmpty || city.isEmpty) {
              _snack('Please fill in your delivery address', Colors.red);
              return;
            }
            final zip = _zipCtrl.text.trim();
            _deliveryAddress =
                '$street, $city${zip.isNotEmpty ? ' $zip' : ''}';

            // Persist address if user wants
            if (_saveAddress) {
              final auth = context.read<AuthProvider>();
              if (auth.currentUser != null &&
                  (auth.currentUser!.address.isEmpty)) {
                auth.updateProfile(address: _deliveryAddress);
              }
            }
            setState(() => _step = 2);
          },
        );
      case 2:
        return _ReviewStep(
          paymentType: _paymentType,
          selectedCard: _selectedCard,
          deliveryAddress: _deliveryAddress,
          onConfirm: _placeOrder,
          onEditPayment: () => setState(() => _step = 0),
          onEditAddress: () => setState(() => _step = 1),
        );
      case 3:
        return const _ProcessingStep();
      case 4:
        return _SuccessStep(
          order: _placedOrder,
          onDone: () {
            context.read<CartProvider>().clearCart();
            Navigator.pop(context);
            context.go('/profile');
          },
          onContinueShopping: () {
            context.read<CartProvider>().clearCart();
            Navigator.pop(context);
            context.go('/products');
          },
        );
      default:
        return const SizedBox();
    }
  }

  Future<void> _placeOrder() async {
    setState(() => _step = 3);

    final cart = context.read<CartProvider>();
    final auth = context.read<AuthProvider>();
    final userData = context.read<UserDataProvider>();
    final notifs = context.read<NotificationProvider>();

    await Future.delayed(const Duration(milliseconds: 1500));

    final order = await OrderService.placeOrder(
      context: context,
      userId: auth.currentUser!.id,
      userName: auth.currentUser!.name,
      items: cart.cartItems,
      subtotal: cart.subtotal,
      discount: cart.discount,
      tax: cart.tax,
      shipping: cart.shipping,
      total: cart.total,
      shippingAddress: _deliveryAddress,
      paymentMethod: _paymentType,
      couponCode: cart.appliedCouponCode,
      paymentMethodId: _selectedCard?.id,
      userData: userData,
      notifProvider: notifs,
    );

    if (mounted) {
      setState(() {
        _placedOrder = order;
        _step = 4;
      });
    }
  }

  void _snack(String msg, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(msg),
      backgroundColor: color,
      behavior: SnackBarBehavior.floating,
    ));
  }
}

// ─────────────────────────────────────────────────────────
// STEP INDICATOR
// ─────────────────────────────────────────────────────────

class _StepIndicator extends StatelessWidget {
  final int step;
  final int total;
  const _StepIndicator({required this.step, required this.total});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: List.generate(total, (i) {
        final done = i < step;
        final active = i == step;
        return Expanded(
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            height: 3,
            margin: EdgeInsets.only(right: i < total - 1 ? 2 : 0),
            color: done || active
                ? AppTheme.primaryRed
                : Colors.grey.shade800,
          ),
        );
      }),
    );
  }
}

// ─────────────────────────────────────────────────────────
// STEP 0 — PAYMENT METHOD
// ─────────────────────────────────────────────────────────

class _PaymentMethodStep extends StatelessWidget {
  final String selectedType;
  final PaymentMethod? selectedCard;
  final ValueChanged<PaymentMethod> onSelectCard;
  final VoidCallback onSelectCod;
  final VoidCallback onNext;

  const _PaymentMethodStep({
    required this.selectedType,
    required this.selectedCard,
    required this.onSelectCard,
    required this.onSelectCod,
    required this.onNext,
  });

  @override
  Widget build(BuildContext context) {
    return Consumer<UserDataProvider>(
      builder: (context, data, _) {
        final cards = data.paymentMethods;

        return Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _sectionLabel('HOW WOULD YOU LIKE TO PAY?'),
                    const SizedBox(height: 14),

                    // ── COD Option ──
                    _PaymentOptionTile(
                      selected: selectedType == 'cod',
                      icon: Icons.payments_outlined,
                      iconColor: const Color(0xFF3BFF8E),
                      title: 'Cash / Card on Delivery',
                      subtitle: 'Pay when your order arrives',
                      badge: 'NO FEES',
                      badgeColor: const Color(0xFF3BFF8E),
                      onTap: onSelectCod,
                    ),
                    const SizedBox(height: 10),

                    // ── Saved cards ──
                    if (cards.isNotEmpty) ...[
                      _sectionLabel('SAVED CARDS'),
                      const SizedBox(height: 10),
                      ...cards.map((card) => Padding(
                            padding: const EdgeInsets.only(bottom: 10),
                            child: _SavedCardTile(
                              card: card,
                              selected: selectedType == 'card' &&
                                  selectedCard?.id == card.id,
                              onTap: () => onSelectCard(card),
                            ),
                          )),
                    ],

                    // ── Add card prompt ──
                    const SizedBox(height: 4),
                    GestureDetector(
                      onTap: () {
                        // Route to payment screen to add
                        context.push('/payment');
                      },
                      child: Container(
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: const Color(0xFF1E1E1E),
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(
                              color: Colors.grey.shade800,
                              style: BorderStyle.solid),
                        ),
                        child: Row(children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: AppTheme.primaryRed.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Icon(Icons.add_card_outlined,
                                color: AppTheme.primaryRed, size: 20),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              cards.isEmpty
                                  ? 'Add a credit or debit card'
                                  : 'Add another card',
                              style: const TextStyle(
                                  color: Colors.white, fontSize: 13),
                            ),
                          ),
                          Icon(Icons.chevron_right,
                              color: Colors.grey.shade600, size: 18),
                        ]),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Next button
            _BottomAction(
              label: 'Continue to Delivery',
              icon: Icons.local_shipping_outlined,
              onTap: onNext,
              enabled: selectedType.isNotEmpty,
            ),
          ],
        );
      },
    );
  }
}

class _PaymentOptionTile extends StatelessWidget {
  final bool selected;
  final IconData icon;
  final Color iconColor;
  final String title;
  final String subtitle;
  final String? badge;
  final Color? badgeColor;
  final VoidCallback onTap;

  const _PaymentOptionTile({
    required this.selected,
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.subtitle,
    this.badge,
    this.badgeColor,
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
              ? iconColor.withOpacity(0.07)
              : const Color(0xFF1E1E1E),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: selected ? iconColor : Colors.grey.shade800,
            width: selected ? 2 : 1,
          ),
        ),
        child: Row(children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: iconColor.withOpacity(0.12),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: iconColor, size: 22),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(children: [
                  Text(title,
                      style: const TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.bold)),
                  if (badge != null) ...[
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: badgeColor!.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(badge!,
                          style: TextStyle(
                              color: badgeColor,
                              fontSize: 9,
                              fontWeight: FontWeight.bold)),
                    ),
                  ],
                ]),
                const SizedBox(height: 2),
                Text(subtitle,
                    style: TextStyle(
                        color: Colors.grey.shade500, fontSize: 12)),
              ],
            ),
          ),
          AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            width: 20, height: 20,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: selected ? iconColor : Colors.transparent,
              border: Border.all(
                  color: selected ? iconColor : Colors.grey.shade600,
                  width: 2),
            ),
            child: selected
                ? const Icon(Icons.check, color: Colors.black, size: 13)
                : null,
          ),
        ]),
      ),
    );
  }
}

class _SavedCardTile extends StatelessWidget {
  final PaymentMethod card;
  final bool selected;
  final VoidCallback onTap;

  const _SavedCardTile(
      {required this.card, required this.selected, required this.onTap});

  Color get _brandColor {
    switch (card.cardBrand?.toLowerCase()) {
      case 'visa': return const Color(0xFF4169E1);
      case 'mastercard': return const Color(0xFFEB001B);
      case 'amex': return const Color(0xFF2E77BC);
      default: return AppTheme.primaryRed;
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: selected
              ? _brandColor.withOpacity(0.07)
              : const Color(0xFF1E1E1E),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
              color: selected ? _brandColor : Colors.grey.shade800,
              width: selected ? 2 : 1),
        ),
        child: Row(children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: _brandColor.withOpacity(0.12),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(Icons.credit_card_outlined,
                color: _brandColor, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(card.displayName,
                    style: const TextStyle(
                        color: Colors.white,
                        fontSize: 13,
                        fontWeight: FontWeight.bold)),
                if (card.last4 != null)
                  Text('•••• ${card.last4}   ${card.expiryMonth}/${card.expiryYear}',
                      style: TextStyle(
                          color: Colors.grey.shade500,
                          fontSize: 12,
                          letterSpacing: 0.5)),
              ],
            ),
          ),
          if (card.isDefault)
            Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: AppTheme.primaryRed.withOpacity(0.12),
                borderRadius: BorderRadius.circular(4),
              ),
              child: const Text('DEFAULT',
                  style: TextStyle(
                      color: AppTheme.primaryRed,
                      fontSize: 9,
                      fontWeight: FontWeight.bold)),
            ),
          const SizedBox(width: 8),
          AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            width: 20, height: 20,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: selected ? _brandColor : Colors.transparent,
              border: Border.all(
                  color: selected ? _brandColor : Colors.grey.shade600,
                  width: 2),
            ),
            child: selected
                ? const Icon(Icons.check, color: Colors.white, size: 13)
                : null,
          ),
        ]),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────
// STEP 1 — DELIVERY ADDRESS
// ─────────────────────────────────────────────────────────

class _DeliveryAddressStep extends StatelessWidget {
  final TextEditingController streetCtrl;
  final TextEditingController cityCtrl;
  final TextEditingController zipCtrl;
  final bool saveAddress;
  final ValueChanged<bool> onToggleSave;
  final VoidCallback onNext;

  const _DeliveryAddressStep({
    required this.streetCtrl,
    required this.cityCtrl,
    required this.zipCtrl,
    required this.saveAddress,
    required this.onToggleSave,
    required this.onNext,
  });

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final savedAddress = auth.currentUser?.address ?? '';

    return Column(
      children: [
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _sectionLabel('DELIVER TO'),
                const SizedBox(height: 14),

                // Pre-fill from saved address if available
                if (savedAddress.isNotEmpty && streetCtrl.text.isEmpty) ...[
                  GestureDetector(
                    onTap: () {
                      // Parse saved address into fields
                      final parts = savedAddress.split(',');
                      if (parts.isNotEmpty) {
                        streetCtrl.text = parts[0].trim();
                        if (parts.length > 1) {
                          final rest = parts[1].trim().split(' ');
                          cityCtrl.text = rest.take(rest.length - 1).join(' ');
                          zipCtrl.text = rest.last;
                        }
                      }
                    },
                    child: Container(
                      padding: const EdgeInsets.all(14),
                      margin: const EdgeInsets.only(bottom: 16),
                      decoration: BoxDecoration(
                        color: AppTheme.primaryRed.withOpacity(0.06),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                            color: AppTheme.primaryRed.withOpacity(0.3)),
                      ),
                      child: Row(children: [
                        const Icon(Icons.history,
                            color: AppTheme.primaryRed, size: 18),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('USE SAVED ADDRESS',
                                  style: TextStyle(
                                      color: AppTheme.primaryRed,
                                      fontSize: 10,
                                      fontWeight: FontWeight.bold,
                                      letterSpacing: 0.5)),
                              const SizedBox(height: 2),
                              Text(savedAddress,
                                  style: TextStyle(
                                      color: Colors.grey.shade400,
                                      fontSize: 12)),
                            ],
                          ),
                        ),
                        const Icon(Icons.arrow_forward_ios,
                            color: AppTheme.primaryRed, size: 14),
                      ]),
                    ),
                  ),
                ],

                _AddressField(
                  controller: streetCtrl,
                  label: 'Street Address',
                  hint: 'House #, Street name',
                  icon: Icons.home_outlined,
                ),
                const SizedBox(height: 12),
                Row(children: [
                  Expanded(
                    flex: 2,
                    child: _AddressField(
                      controller: cityCtrl,
                      label: 'City',
                      hint: 'City name',
                      icon: Icons.location_city_outlined,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _AddressField(
                      controller: zipCtrl,
                      label: 'ZIP',
                      hint: '12345',
                      icon: Icons.pin_outlined,
                      keyboardType: TextInputType.number,
                    ),
                  ),
                ]),
                const SizedBox(height: 16),

                // Save address toggle
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 14, vertical: 10),
                  decoration: BoxDecoration(
                    color: const Color(0xFF1E1E1E),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.grey.shade800),
                  ),
                  child: Row(children: [
                    const Icon(Icons.bookmark_outline,
                        color: Colors.grey, size: 18),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text('Save address for future orders',
                          style: TextStyle(
                              color: Colors.grey.shade400, fontSize: 13)),
                    ),
                    Switch(
                        value: saveAddress,
                        onChanged: onToggleSave,
                        activeColor: AppTheme.primaryRed),
                  ]),
                ),
              ],
            ),
          ),
        ),

        _BottomAction(
          label: 'Review Order',
          icon: Icons.receipt_long_outlined,
          onTap: onNext,
          enabled: true,
        ),
      ],
    );
  }
}

class _AddressField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final String hint;
  final IconData icon;
  final TextInputType? keyboardType;

  const _AddressField({
    required this.controller,
    required this.label,
    required this.hint,
    required this.icon,
    this.keyboardType,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
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
          controller: controller,
          keyboardType: keyboardType,
          style: const TextStyle(color: Colors.white, fontSize: 14),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle:
                TextStyle(color: Colors.grey.shade700, fontSize: 13),
            prefixIcon:
                Icon(icon, color: AppTheme.primaryRed, size: 18),
            filled: true,
            fillColor: const Color(0xFF1E1E1E),
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
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────
// STEP 2 — REVIEW ORDER
// ─────────────────────────────────────────────────────────

class _ReviewStep extends StatelessWidget {
  final String paymentType;
  final PaymentMethod? selectedCard;
  final String deliveryAddress;
  final VoidCallback onConfirm;
  final VoidCallback onEditPayment;
  final VoidCallback onEditAddress;

  const _ReviewStep({
    required this.paymentType,
    required this.selectedCard,
    required this.deliveryAddress,
    required this.onConfirm,
    required this.onEditPayment,
    required this.onEditAddress,
  });

  String get _paymentLabel {
    if (paymentType == 'cod') return 'Cash / Card on Delivery';
    if (selectedCard != null) {
      return '${selectedCard!.displayName} ••••${selectedCard!.last4 ?? ''}';
    }
    return paymentType;
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<CartProvider>(
      builder: (context, cart, _) {
        return Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _sectionLabel('ORDER ITEMS'),
                    const SizedBox(height: 10),

                    // Items list
                    ...cart.cartItems.map((item) => Container(
                          margin: const EdgeInsets.only(bottom: 8),
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: const Color(0xFF1E1E1E),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(children: [
                            Container(
                              width: 44, height: 44,
                              decoration: BoxDecoration(
                                color: const Color(0xFF2A2A2A),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: const Icon(Icons.sports_esports,
                                  color: Colors.grey, size: 20),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment:
                                    CrossAxisAlignment.start,
                                children: [
                                  Text(item.product.name,
                                      style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 12,
                                          fontWeight: FontWeight.w600),
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
                                  fontWeight: FontWeight.bold,
                                  fontSize: 13),
                            ),
                          ]),
                        )),

                    const SizedBox(height: 16),
                    _sectionLabel('PAYMENT'),
                    const SizedBox(height: 8),
                    _ReviewRow(
                      icon: paymentType == 'cod'
                          ? Icons.payments_outlined
                          : Icons.credit_card_outlined,
                      iconColor: paymentType == 'cod'
                          ? const Color(0xFF3BFF8E)
                          : const Color(0xFF3B8EFF),
                      label: _paymentLabel,
                      onEdit: onEditPayment,
                    ),

                    const SizedBox(height: 10),
                    _sectionLabel('DELIVERY'),
                    const SizedBox(height: 8),
                    _ReviewRow(
                      icon: Icons.location_on_outlined,
                      iconColor: const Color(0xFFFFB83B),
                      label: deliveryAddress,
                      onEdit: onEditAddress,
                    ),

                    const SizedBox(height: 16),
                    _sectionLabel('PRICE SUMMARY'),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: const Color(0xFF1E1E1E),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Column(children: [
                        _PriceRow('Subtotal',
                            '\$${cart.subtotal.toStringAsFixed(2)}'),
                        if (cart.discount > 0) ...[
                          const SizedBox(height: 6),
                          _PriceRow('Discount',
                              '-\$${cart.discount.toStringAsFixed(2)}',
                              color: Colors.green),
                        ],
                        const SizedBox(height: 6),
                        _PriceRow(
                            cart.shipping == 0 ? 'Shipping (Free)' : 'Shipping',
                            cart.shipping == 0
                                ? 'FREE'
                                : '\$${cart.shipping.toStringAsFixed(2)}',
                            color: cart.shipping == 0
                                ? Colors.green
                                : null),
                        const SizedBox(height: 6),
                        _PriceRow('Tax', '\$${cart.tax.toStringAsFixed(2)}'),
                        Divider(
                            color: Colors.grey.shade800,
                            height: 16),
                        _PriceRow(
                            'Total',
                            '\$${cart.total.toStringAsFixed(2)}',
                            bold: true,
                            fontSize: 16),
                      ]),
                    ),

                    if (paymentType == 'cod') ...[
                      const SizedBox(height: 14),
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: const Color(0xFF3BFF8E).withOpacity(0.06),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                              color: const Color(0xFF3BFF8E)
                                  .withOpacity(0.3)),
                        ),
                        child: Row(children: [
                          const Icon(Icons.info_outline,
                              color: Color(0xFF3BFF8E), size: 16),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              'Payment will be collected upon delivery. Please have exact cash or a card ready.',
                              style: TextStyle(
                                  color: Colors.grey.shade400,
                                  fontSize: 12,
                                  height: 1.4),
                            ),
                          ),
                        ]),
                      ),
                    ],
                  ],
                ),
              ),
            ),

            _BottomAction(
              label: paymentType == 'cod'
                  ? 'Place Order (COD)'
                  : 'Confirm & Pay  \$${cart.total.toStringAsFixed(2)}',
              icon: paymentType == 'cod'
                  ? Icons.local_shipping_outlined
                  : Icons.lock_outline,
              onTap: onConfirm,
              enabled: true,
            ),
          ],
        );
      },
    );
  }
}

class _ReviewRow extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String label;
  final VoidCallback onEdit;

  const _ReviewRow({
    required this.icon,
    required this.iconColor,
    required this.label,
    required this.onEdit,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFF1E1E1E),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade800),
      ),
      child: Row(children: [
        Icon(icon, color: iconColor, size: 20),
        const SizedBox(width: 12),
        Expanded(
            child: Text(label,
                style: const TextStyle(color: Colors.white, fontSize: 13),
                maxLines: 2,
                overflow: TextOverflow.ellipsis)),
        GestureDetector(
          onTap: onEdit,
          child: const Text('Edit',
              style: TextStyle(
                  color: AppTheme.primaryRed,
                  fontSize: 12,
                  fontWeight: FontWeight.bold)),
        ),
      ]),
    );
  }
}

class _PriceRow extends StatelessWidget {
  final String label;
  final String value;
  final Color? color;
  final bool bold;
  final double fontSize;

  const _PriceRow(this.label, this.value,
      {this.color, this.bold = false, this.fontSize = 13});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label,
            style: TextStyle(
                color: bold ? Colors.white : Colors.grey.shade500,
                fontSize: fontSize,
                fontWeight:
                    bold ? FontWeight.bold : FontWeight.normal)),
        Text(value,
            style: TextStyle(
                color: color ?? Colors.white,
                fontSize: fontSize,
                fontWeight:
                    bold ? FontWeight.bold : FontWeight.normal)),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────
// STEP 3 — PROCESSING
// ─────────────────────────────────────────────────────────

class _ProcessingStep extends StatelessWidget {
  const _ProcessingStep();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 80, height: 80,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppTheme.primaryRed.withOpacity(0.1),
            ),
            child: const CircularProgressIndicator(
              color: AppTheme.primaryRed,
              strokeWidth: 3,
            ),
          ),
          const SizedBox(height: 28),
          Text('Processing Order...',
              style: GoogleFonts.orbitron(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold)),
          const SizedBox(height: 10),
          Text('Please wait while we confirm your order',
              style: TextStyle(
                  color: Colors.grey.shade500, fontSize: 13)),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────
// STEP 4 — SUCCESS
// ─────────────────────────────────────────────────────────

class _SuccessStep extends StatefulWidget {
  final OrderModel? order;
  final VoidCallback onDone;
  final VoidCallback onContinueShopping;

  const _SuccessStep({
    required this.order,
    required this.onDone,
    required this.onContinueShopping,
  });

  @override
  State<_SuccessStep> createState() => _SuccessStepState();
}

class _SuccessStepState extends State<_SuccessStep>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _scaleAnim;
  late Animation<double> _fadeAnim;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 700));
    _scaleAnim = CurvedAnimation(parent: _ctrl, curve: Curves.elasticOut);
    _fadeAnim = CurvedAnimation(parent: _ctrl, curve: Curves.easeIn);
    _ctrl.forward();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final order = widget.order;

    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(24, 60, 24, 32),
        child: Column(
          children: [
            // Success icon
            ScaleTransition(
              scale: _scaleAnim,
              child: Container(
                width: 100, height: 100,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.green.withOpacity(0.12),
                  border: Border.all(
                      color: Colors.green.withOpacity(0.4), width: 2),
                ),
                child: const Icon(Icons.check_circle_outline,
                    color: Colors.green, size: 56),
              ),
            ),
            const SizedBox(height: 24),

            FadeTransition(
              opacity: _fadeAnim,
              child: Column(children: [
                Text('Order Placed!',
                    style: GoogleFonts.orbitron(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                Text('Your order has been received',
                    style: TextStyle(
                        color: Colors.grey.shade500, fontSize: 14)),

                if (order != null) ...[
                  const SizedBox(height: 24),
                  // Order number badge
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 20, vertical: 14),
                    decoration: BoxDecoration(
                      color: const Color(0xFF1E1E1E),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                          color: AppTheme.primaryRed.withOpacity(0.3)),
                    ),
                    child: Column(children: [
                      Text('ORDER NUMBER',
                          style: TextStyle(
                              color: Colors.grey.shade600,
                              fontSize: 10,
                              letterSpacing: 1.5,
                              fontWeight: FontWeight.bold)),
                      const SizedBox(height: 6),
                      Text(order.id,
                          style: GoogleFonts.orbitron(
                              color: AppTheme.primaryRed,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 2)),
                    ]),
                  ),
                  const SizedBox(height: 16),

                  // Order info grid
                  Row(children: [
                    Expanded(
                        child: _InfoTile(
                            icon: Icons.payments_outlined,
                            label: 'PAYMENT',
                            value: order.paymentMethodId == 'cod'
                                ? 'Cash on Delivery'
                                : 'Card Payment')),
                    const SizedBox(width: 10),
                    Expanded(
                        child: _InfoTile(
                            icon: Icons.inventory_2_outlined,
                            label: 'ITEMS',
                            value:
                                '${order.items.fold(0, (s, i) => s + i.quantity)} item(s)')),
                  ]),
                  const SizedBox(height: 10),
                  Row(children: [
                    Expanded(
                        child: _InfoTile(
                            icon: Icons.attach_money,
                            label: 'TOTAL',
                            value:
                                '\$${order.total.toStringAsFixed(2)}')),
                    const SizedBox(width: 10),
                    Expanded(
                        child: _InfoTile(
                            icon: Icons.local_shipping_outlined,
                            label: 'STATUS',
                            value: 'Processing...',
                            valueColor: const Color(0xFFFFB83B))),
                  ]),
                ],

                const SizedBox(height: 20),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFF1E1E1E),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Row(children: [
                    const Icon(Icons.notifications_outlined,
                        color: Color(0xFF3B8EFF), size: 16),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'You\'ll receive notifications as your order progresses through shipping.',
                        style: TextStyle(
                            color: Colors.grey.shade500,
                            fontSize: 12,
                            height: 1.4),
                      ),
                    ),
                  ]),
                ),

                const SizedBox(height: 32),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: widget.onDone,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.primaryRed,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14)),
                    ),
                    child: Text('Track My Order',
                        style: GoogleFonts.poppins(
                            fontSize: 15,
                            fontWeight: FontWeight.bold)),
                  ),
                ),
                const SizedBox(height: 10),
                TextButton(
                  onPressed: widget.onContinueShopping,
                  child: Text('Continue Shopping',
                      style: TextStyle(
                          color: Colors.grey.shade400, fontSize: 14)),
                ),
              ]),
            ),
          ],
        ),
      ),
    );
  }
}

class _InfoTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color? valueColor;

  const _InfoTile({
    required this.icon,
    required this.label,
    required this.value,
    this.valueColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFF1E1E1E),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(children: [
        Icon(icon, color: Colors.grey.shade600, size: 16),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label,
                  style: TextStyle(
                      color: Colors.grey.shade600,
                      fontSize: 9,
                      letterSpacing: 0.5,
                      fontWeight: FontWeight.bold)),
              Text(value,
                  style: TextStyle(
                      color: valueColor ?? Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.bold),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis),
            ],
          ),
        ),
      ]),
    );
  }
}

// ─────────────────────────────────────────────────────────
// SHARED HELPERS
// ─────────────────────────────────────────────────────────

Widget _sectionLabel(String text) => Text(text,
    style: TextStyle(
        color: Colors.grey.shade600,
        fontSize: 10,
        fontWeight: FontWeight.bold,
        letterSpacing: 1.5));

class _BottomAction extends StatelessWidget {
  final String label;
  final IconData icon;
  final VoidCallback onTap;
  final bool enabled;

  const _BottomAction({
    required this.label,
    required this.icon,
    required this.onTap,
    required this.enabled,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 28),
      decoration: BoxDecoration(
        color: const Color(0xFF141414),
        border:
            Border(top: BorderSide(color: Colors.grey.shade900)),
      ),
      child: SizedBox(
        width: double.infinity,
        child: ElevatedButton.icon(
          onPressed: enabled ? onTap : null,
          icon: Icon(icon, size: 18),
          label: Text(label,
              style: GoogleFonts.poppins(
                  fontSize: 15, fontWeight: FontWeight.bold)),
          style: ElevatedButton.styleFrom(
            backgroundColor: AppTheme.primaryRed,
            foregroundColor: Colors.white,
            disabledBackgroundColor: Colors.grey.shade800,
            disabledForegroundColor: Colors.grey.shade600,
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14)),
            elevation: 0,
          ),
        ),
      ),
    );
  }
}
