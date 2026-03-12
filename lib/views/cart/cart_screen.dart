import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../checkout/checkout_screen.dart';
import '../../providers/cart_provider.dart';
import '../../models/cart_model.dart';
import '../../app/theme/app_theme.dart';

class CartScreen extends StatelessWidget {
  const CartScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.darkGrey,
      appBar: AppBar(
        backgroundColor: AppTheme.darkGrey,
        elevation: 0,
        title: Text('MY CART',
            style: GoogleFonts.orbitron(
                fontWeight: FontWeight.bold,
                color: AppTheme.primaryRed,
                letterSpacing: 2)),
        actions: [
          Consumer<CartProvider>(
            builder: (context, cart, _) {
              if (cart.cartItems.isEmpty) return const SizedBox();
              return TextButton.icon(
                onPressed: () => _showClearCartDialog(context, cart),
                icon: const Icon(Icons.delete_outline,
                    color: Colors.grey, size: 18),
                label: const Text('Clear',
                    style: TextStyle(color: Colors.grey, fontSize: 13)),
              );
            },
          ),
        ],
      ),
      body: Consumer<CartProvider>(
        builder: (context, cart, _) {
          if (cart.isLoading) {
            return const Center(
                child: CircularProgressIndicator(
                    valueColor:
                        AlwaysStoppedAnimation<Color>(AppTheme.primaryRed)));
          }
          if (cart.cartItems.isEmpty) return _buildEmptyCart(context);
          return Column(
            children: [
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.all(15),
                  itemCount: cart.cartItems.length,
                  itemBuilder: (context, index) => _CartItemTile(
                    key: ValueKey(cart.cartItems[index].product.id),
                    item: cart.cartItems[index],
                  ),
                ),
              ),
              _BottomBar(cart: cart),
            ],
          );
        },
      ),
    );
  }

  Widget _buildEmptyCart(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.shopping_cart_outlined,
              size: 100, color: Colors.grey.shade800),
          const SizedBox(height: 20),
          Text('Your cart is empty',
              style: GoogleFonts.poppins(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.white)),
          const SizedBox(height: 8),
          Text('Add some products to get started',
              style: GoogleFonts.poppins(
                  fontSize: 14, color: Colors.grey.shade500)),
          const SizedBox(height: 30),
          ElevatedButton.icon(
            onPressed: () => context.go('/products'),
            icon: const Icon(Icons.sports_esports),
            label: const Text('Browse Products'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primaryRed,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 14),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
            ),
          ),
        ],
      ),
    );
  }

  void _showClearCartDialog(BuildContext context, CartProvider cart) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF3A3A3A),
        title: const Text('Clear Cart', style: TextStyle(color: Colors.white)),
        content: const Text('Remove all items from your cart?',
            style: TextStyle(color: Colors.grey)),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx),
              child:
                  const Text('Cancel', style: TextStyle(color: Colors.grey))),
          TextButton(
            onPressed: () {
              cart.clearCart();
              Navigator.pop(ctx);
            },
            child: const Text('Clear',
                style: TextStyle(color: AppTheme.primaryRed)),
          ),
        ],
      ),
    );
  }
}

// ── Bottom bar ──
class _BottomBar extends StatelessWidget {
  final CartProvider cart;
  const _BottomBar({required this.cart});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 14, 20, 24),
      decoration: BoxDecoration(
        color: const Color(0xFF3A3A3A),
        border: Border(top: BorderSide(color: Colors.grey.shade800)),
      ),
      child: Row(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                '${cart.itemCount} item${cart.itemCount == 1 ? '' : 's'}',
                style: TextStyle(color: Colors.grey.shade500, fontSize: 12),
              ),
              const SizedBox(height: 2),
              Text('\$${cart.total.toStringAsFixed(2)}',
                  style: const TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.bold)),
            ],
          ),
          const SizedBox(width: 16),
          Expanded(
            child: ElevatedButton.icon(
              onPressed: () => showModalBottomSheet(
                context: context,
                backgroundColor: Colors.transparent,
                isScrollControlled: true,
                builder: (_) => _OrderSummarySheet(cart: cart),
              ),
              icon: const Icon(Icons.receipt_long, size: 18),
              label: const Text('View Summary'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primaryRed,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Order summary bottom sheet ──
class _OrderSummarySheet extends StatefulWidget {
  final CartProvider cart;
  const _OrderSummarySheet({required this.cart});

  @override
  State<_OrderSummarySheet> createState() => _OrderSummarySheetState();
}

class _OrderSummarySheetState extends State<_OrderSummarySheet> {
  final TextEditingController _couponController = TextEditingController();
  bool _showCouponField = false;

  @override
  void dispose() {
    _couponController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<CartProvider>(
      builder: (context, cart, _) {
        return Container(
          decoration: const BoxDecoration(
            color: Color(0xFF3A3A3A),
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          padding: EdgeInsets.fromLTRB(
              20, 16, 20, MediaQuery.of(context).viewInsets.bottom + 28),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  margin: const EdgeInsets.only(bottom: 16),
                  decoration: BoxDecoration(
                      color: Colors.grey.shade600,
                      borderRadius: BorderRadius.circular(2)),
                ),
              ),
              Text('Order Summary',
                  style: GoogleFonts.poppins(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold)),
              const SizedBox(height: 16),

              // Coupon
              if (cart.appliedCouponCode != null)
                Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.green.shade900.withOpacity(0.4),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.green.shade800),
                  ),
                  child: Row(children: [
                    const Icon(Icons.local_offer,
                        color: Colors.green, size: 16),
                    const SizedBox(width: 8),
                    Expanded(
                        child: Text(
                            '"${cart.appliedCouponCode}" applied  -\$${cart.couponDiscount.toStringAsFixed(2)}',
                            style: const TextStyle(
                                color: Colors.green, fontSize: 13))),
                    GestureDetector(
                      onTap: () {
                        cart.removeCoupon();
                        _couponController.clear();
                      },
                      child: const Icon(Icons.close,
                          color: Colors.green, size: 16),
                    ),
                  ]),
                )
              else if (_showCouponField)
                Row(children: [
                  Expanded(
                    child: TextField(
                      controller: _couponController,
                      style: const TextStyle(color: Colors.white),
                      textCapitalization: TextCapitalization.characters,
                      decoration: InputDecoration(
                        hintText: 'Enter coupon code',
                        hintStyle: TextStyle(color: Colors.grey.shade600),
                        filled: true,
                        fillColor: AppTheme.darkGrey,
                        contentPadding: const EdgeInsets.symmetric(
                            horizontal: 14, vertical: 10),
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: BorderSide.none),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  SizedBox(
                    width: 80,
                    height: 44,
                    child: ElevatedButton(
                      onPressed: () {
                        final code = _couponController.text.trim();
                        if (code.isEmpty) return;
                        final success = cart.applyCoupon(code);
                        if (success) {
                          setState(() => _showCouponField = false);
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                                content: Text('Invalid coupon code'),
                                backgroundColor: Colors.red,
                                duration: Duration(seconds: 1),
                                behavior: SnackBarBehavior.floating),
                          );
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.primaryRed,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(horizontal: 8),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8)),
                      ),
                      child:
                          const Text('Apply', style: TextStyle(fontSize: 12)),
                    ),
                  ),
                  const SizedBox(width: 6),
                  GestureDetector(
                    onTap: () => setState(() => _showCouponField = false),
                    child: const Icon(Icons.close, color: Colors.grey),
                  ),
                ])
              else
                GestureDetector(
                  onTap: () => setState(() => _showCouponField = true),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(mainAxisSize: MainAxisSize.min, children: [
                          const Icon(Icons.local_offer,
                              color: AppTheme.primaryRed, size: 16),
                          const SizedBox(width: 6),
                          Text('Have a coupon code?',
                              style: TextStyle(
                                  color: Colors.grey.shade400, fontSize: 13)),
                        ]),
                        const Icon(Icons.chevron_right,
                            color: Colors.grey, size: 18),
                      ],
                    ),
                  ),
                ),

              const SizedBox(height: 14),
              Divider(color: Colors.grey.shade700),
              const SizedBox(height: 10),
              _SummaryRow(
                  label: 'Subtotal (${cart.itemCount} items)',
                  value: '\$${cart.subtotal.toStringAsFixed(2)}'),
              if (cart.discount > 0) ...[
                const SizedBox(height: 6),
                _SummaryRow(
                    label: 'Discount',
                    value: '-\$${cart.discount.toStringAsFixed(2)}',
                    valueColor: Colors.green),
              ],
              const SizedBox(height: 6),
              _SummaryRow(
                label: cart.shipping == 0 ? 'Shipping (Free!)' : 'Shipping',
                value: cart.shipping == 0
                    ? 'FREE'
                    : '\$${cart.shipping.toStringAsFixed(2)}',
                valueColor: cart.shipping == 0 ? Colors.green : Colors.white,
              ),
              const SizedBox(height: 6),
              _SummaryRow(
                  label: 'Tax (10%)',
                  value: '\$${cart.tax.toStringAsFixed(2)}'),
              const SizedBox(height: 10),
              Divider(color: Colors.grey.shade700),
              const SizedBox(height: 8),
              _SummaryRow(
                  label: 'Total',
                  value: '\$${cart.total.toStringAsFixed(2)}',
                  isBold: true,
                  fontSize: 16),
              const SizedBox(height: 20),
              ElevatedButton.icon(
                onPressed: () {
                  Navigator.pop(context); // close summary sheet
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const CheckoutScreen()),
                  );
                },
                icon: const Icon(Icons.lock_outline, size: 18),
                label: Text(
                  'Proceed to Checkout  •  \$${cart.total.toStringAsFixed(2)}',
                  style: GoogleFonts.poppins(
                      fontSize: 15, fontWeight: FontWeight.bold),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primaryRed,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

// ── Cart item tile ──
class _CartItemTile extends StatefulWidget {
  final CartItem item;
  const _CartItemTile({Key? key, required this.item}) : super(key: key);

  @override
  State<_CartItemTile> createState() => _CartItemTileState();
}

class _CartItemTileState extends State<_CartItemTile>
    with TickerProviderStateMixin {
  static const Map<String, String> _productImages = {
    'prod1':
        'https://images.unsplash.com/photo-1587202372775-e229f172b9d7?w=200&auto=format',
    'prod2':
        'https://images.unsplash.com/photo-1555617778-6b8591a12c7c?w=200&auto=format',
    'prod3':
        'https://images.unsplash.com/photo-1562976540-1502c2145186?w=200&auto=format',
    'prod4':
        'https://images.unsplash.com/photo-1542751371-adc38448a05e?w=200&auto=format',
    'prod5':
        'https://images.unsplash.com/photo-1538481199705-c710c4e965fc?w=200&auto=format',
    'prod6':
        'https://images.unsplash.com/photo-1598550476439-6847785fcea6?w=200&auto=format',
    'prod7':
        'https://images.unsplash.com/photo-1587202372775-e229f172b9d7?w=200&auto=format',
    'prod8':
        'https://images.unsplash.com/photo-1615663245857-ac93bb7c39e7?w=200&auto=format',
    'prod9':
        'https://images.unsplash.com/photo-1586210579191-33b45e38fa2c?w=200&auto=format',
    'prod10':
        'https://images.unsplash.com/photo-1505740420928-5e560c06d30e?w=200&auto=format',
  };

  final GlobalKey _minusKey = GlobalKey();
  final GlobalKey _plusKey = GlobalKey();
  OverlayEntry? _overlayEntry;

  void _showFloatingLabel(GlobalKey buttonKey, bool isAdd) {
    final renderBox =
        buttonKey.currentContext?.findRenderObject() as RenderBox?;
    if (renderBox == null) return;
    final position = renderBox.localToGlobal(Offset.zero);
    final size = renderBox.size;
    _overlayEntry?.remove();
    _overlayEntry = null;
    final entry = OverlayEntry(
      builder: (context) => _FloatingLabel(
        isAdd: isAdd,
        startX: position.dx + size.width / 2,
        startY: position.dy,
        onDone: () {
          _overlayEntry?.remove();
          _overlayEntry = null;
        },
      ),
    );
    _overlayEntry = entry;
    Overlay.of(context).insert(entry);
  }

  @override
  void dispose() {
    _overlayEntry?.remove();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cart = context.read<CartProvider>();
    final imageUrl = _productImages[widget.item.product.id] ??
        'https://placehold.co/200x200/3A3A3A/5A5A5A?text=?';

    return Dismissible(
      key: Key(widget.item.product.id),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
            color: Colors.red.shade900,
            borderRadius: BorderRadius.circular(12)),
        child: const Icon(Icons.delete, color: Colors.white, size: 28),
      ),
      onDismissed: (_) => cart.removeFromCart(widget.item.product.id),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: const Color(0xFF3A3A3A),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey.shade800),
        ),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: CachedNetworkImage(
                imageUrl: imageUrl,
                width: 70,
                height: 70,
                fit: BoxFit.cover,
                placeholder: (_, __) => Container(
                    color: Colors.grey.shade900, width: 70, height: 70),
                errorWidget: (_, __, ___) => Container(
                  color: Colors.grey.shade900,
                  width: 70,
                  height: 70,
                  child:
                      const Icon(Icons.image_not_supported, color: Colors.grey),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(widget.item.product.brand.toUpperCase(),
                      style: const TextStyle(
                          color: AppTheme.primaryRed,
                          fontSize: 9,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 0.5)),
                  const SizedBox(height: 3),
                  Text(widget.item.product.name,
                      style: const TextStyle(
                          color: Colors.white,
                          fontSize: 13,
                          fontWeight: FontWeight.w600),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis),
                  const SizedBox(height: 6),
                  Text('\$${widget.item.product.finalPrice.toStringAsFixed(2)}',
                      style: const TextStyle(
                          color: AppTheme.primaryRed,
                          fontSize: 14,
                          fontWeight: FontWeight.bold)),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                GestureDetector(
                  onTap: () => cart.removeFromCart(widget.item.product.id),
                  child:
                      Icon(Icons.close, color: Colors.grey.shade600, size: 18),
                ),
                const SizedBox(height: 8),
                Container(
                  decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey.shade700),
                      borderRadius: BorderRadius.circular(8)),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      GestureDetector(
                        key: _minusKey,
                        onTap: () {
                          _showFloatingLabel(_minusKey, false);
                          cart.updateQuantity(
                              widget.item.product.id, widget.item.quantity - 1);
                        },
                        child: Container(
                          padding: const EdgeInsets.all(6),
                          child: const Icon(Icons.remove,
                              color: AppTheme.primaryRed, size: 16),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        child: AnimatedSwitcher(
                          duration: const Duration(milliseconds: 200),
                          transitionBuilder: (child, animation) =>
                              ScaleTransition(scale: animation, child: child),
                          child: Text(
                            '${widget.item.quantity}',
                            key: ValueKey(widget.item.quantity),
                            style: const TextStyle(
                                color: Colors.white,
                                fontSize: 14,
                                fontWeight: FontWeight.bold),
                          ),
                        ),
                      ),
                      GestureDetector(
                        key: _plusKey,
                        onTap: () {
                          _showFloatingLabel(_plusKey, true);
                          cart.updateQuantity(
                              widget.item.product.id, widget.item.quantity + 1);
                        },
                        child: Container(
                          padding: const EdgeInsets.all(6),
                          child: const Icon(Icons.add,
                              color: Colors.green, size: 16),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 6),
                Text('\$${widget.item.totalPrice.toStringAsFixed(2)}',
                    style:
                        TextStyle(color: Colors.grey.shade400, fontSize: 11)),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// ── Floating label ──
class _FloatingLabel extends StatefulWidget {
  final bool isAdd;
  final double startX;
  final double startY;
  final VoidCallback onDone;

  const _FloatingLabel(
      {required this.isAdd,
      required this.startX,
      required this.startY,
      required this.onDone});

  @override
  State<_FloatingLabel> createState() => _FloatingLabelState();
}

class _FloatingLabelState extends State<_FloatingLabel>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _yAnimation;
  late Animation<double> _opacityAnimation;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 700));
    _yAnimation = Tween<double>(begin: 0, end: -50)
        .animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));
    _opacityAnimation = Tween<double>(begin: 1.0, end: 0.0).animate(
        CurvedAnimation(
            parent: _controller,
            curve: const Interval(0.4, 1.0, curve: Curves.easeIn)));
    _scaleAnimation = Tween<double>(begin: 0.5, end: 1.1).animate(
        CurvedAnimation(
            parent: _controller,
            curve: const Interval(0.0, 0.3, curve: Curves.elasticOut)));
    _controller.forward().then((_) => widget.onDone());
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final color = widget.isAdd ? Colors.green : AppTheme.primaryRed;
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, _) => Positioned(
        left: widget.startX - 16,
        top: widget.startY + _yAnimation.value,
        child: IgnorePointer(
          child: Opacity(
            opacity: _opacityAnimation.value,
            child: Transform.scale(
              scale: _scaleAnimation.value,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(color: color, width: 1.2),
                ),
                child: Text(widget.isAdd ? '+1' : '-1',
                    style: TextStyle(
                        color: color,
                        fontSize: 13,
                        fontWeight: FontWeight.bold)),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ── Summary row ──
class _SummaryRow extends StatelessWidget {
  final String label;
  final String value;
  final Color? valueColor;
  final bool isBold;
  final double fontSize;

  const _SummaryRow(
      {required this.label,
      required this.value,
      this.valueColor,
      this.isBold = false,
      this.fontSize = 13});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label,
            style: TextStyle(
                color: isBold ? Colors.white : Colors.grey.shade400,
                fontSize: fontSize,
                fontWeight: isBold ? FontWeight.bold : FontWeight.normal)),
        Text(value,
            style: TextStyle(
                color: valueColor ?? Colors.white,
                fontSize: fontSize,
                fontWeight: isBold ? FontWeight.bold : FontWeight.normal)),
      ],
    );
  }
}
