// lib/views/seller/seller_add_product_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../providers/seller_provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/product_provider.dart';
import '../../models/seller_model.dart';

class SellerAddProductScreen extends StatefulWidget {
  final SellerProduct? editProduct;
  const SellerAddProductScreen({super.key, this.editProduct});

  @override
  State<SellerAddProductScreen> createState() =>
      _SellerAddProductScreenState();
}

class _SellerAddProductScreenState extends State<SellerAddProductScreen> {
  final _formKey = GlobalKey<FormState>();

  late final TextEditingController _nameCtrl;
  late final TextEditingController _brandCtrl;
  late final TextEditingController _descCtrl;
  late final TextEditingController _priceCtrl;
  late final TextEditingController _originalPriceCtrl;
  late final TextEditingController _stockCtrl;
  late final TextEditingController _tagCtrl;

  String _category = 'Games';
  List<String> _tags = [];
  bool _isActive = true;
  bool _isLoading = false;

  // ── These match exactly what ProductProvider._mapCategory() handles ──
  final _categories = [
    'Games',
    'PC',           // → cat1 PC Hardware
    'Consoles',     // → cat2 Games
    'Accessories',  // → cat8
    'Keyboards',    // → cat4
    'Mice',         // → cat5
    'Monitors',     // → cat6
    'Headsets',     // → cat7
    'Gaming Chairs',// → cat3
    'Merchandise',  // → cat8
  ];

  bool get _isEditing => widget.editProduct != null;

  @override
  void initState() {
    super.initState();
    final p = widget.editProduct;
    _nameCtrl = TextEditingController(text: p?.name ?? '');
    _brandCtrl = TextEditingController(text: p?.brand ?? '');
    _descCtrl = TextEditingController(text: p?.description ?? '');
    _priceCtrl = TextEditingController(
        text: p != null ? p.price.toString() : '');
    _originalPriceCtrl = TextEditingController(
        text: p?.originalPrice != null ? p!.originalPrice.toString() : '');
    _stockCtrl = TextEditingController(
        text: p != null ? p.stock.toString() : '');
    _tagCtrl = TextEditingController();
    _category = p?.category ?? 'Games';
    // If saved category isn't in current list, default to Games
    if (!_categories.contains(_category)) _category = 'Games';
    _tags = List.from(p?.tags ?? []);
    _isActive = p?.isActive ?? true;
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _brandCtrl.dispose();
    _descCtrl.dispose();
    _priceCtrl.dispose();
    _originalPriceCtrl.dispose();
    _stockCtrl.dispose();
    _tagCtrl.dispose();
    super.dispose();
  }

  void _addTag() {
    final tag = _tagCtrl.text.trim().toLowerCase().replaceAll(' ', '-');
    if (tag.isNotEmpty && !_tags.contains(tag)) {
      setState(() {
        _tags.add(tag);
        _tagCtrl.clear();
      });
    }
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);

    final seller = context.read<SellerProvider>();
    final auth = context.read<AuthProvider>();
    final productProvider = context.read<ProductProvider>();
    final store = seller.store;
    final storeName =
        store?.storeName ?? auth.currentUser?.name ?? 'Unknown Store';
    final sellerId = auth.currentUser?.id ?? '';

    final price = double.tryParse(_priceCtrl.text.trim()) ?? 0;
    final origPrice = _originalPriceCtrl.text.trim().isNotEmpty
        ? double.tryParse(_originalPriceCtrl.text.trim())
        : null;
    final stock = int.tryParse(_stockCtrl.text.trim()) ?? 0;

    bool success;
    if (_isEditing) {
      final updated = widget.editProduct!.copyWith(
        name: _nameCtrl.text.trim(),
        brand: _brandCtrl.text.trim(),
        category: _category,
        description: _descCtrl.text.trim(),
        price: price,
        originalPrice: origPrice,
        stock: stock,
        tags: _tags,
        isActive: _isActive,
      );
      success = await seller.updateProduct(updated);
    } else {
      final product = SellerProduct(
        id: seller.generateProductId(),
        sellerId: sellerId,
        storeName: storeName,
        name: _nameCtrl.text.trim(),
        brand: _brandCtrl.text.trim(),
        category: _category,
        description: _descCtrl.text.trim(),
        price: price,
        originalPrice: origPrice,
        stock: stock,
        tags: _tags,
        isActive: _isActive,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
      success = await seller.addProduct(product);
    }

    if (success) {
      // ── Refresh buyer feed immediately so product shows up ──
      await productProvider.loadSellerProducts();
    }

    setState(() => _isLoading = false);

    if (success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(_isEditing
            ? 'Product updated successfully!'
            : 'Product listed in the store!'),
        backgroundColor: Colors.green,
        behavior: SnackBarBehavior.floating,
      ));
      Navigator.pop(context);
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('Something went wrong. Please try again.'),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
      ));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0D0D0D),
      appBar: AppBar(
        backgroundColor: const Color(0xFF161616),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_rounded,
              color: Colors.white, size: 18),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          _isEditing ? 'EDIT PRODUCT' : 'ADD PRODUCT',
          style: GoogleFonts.orbitron(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 16,
              letterSpacing: 1.5),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: Row(
              children: [
                Text('Active',
                    style: TextStyle(
                        color: Colors.grey.shade500, fontSize: 12)),
                const SizedBox(width: 6),
                Switch(
                  value: _isActive,
                  onChanged: (v) => setState(() => _isActive = v),
                  activeColor: const Color(0xFFE63946),
                  materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
              ],
            ),
          ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            // ── Basic Info ──
            _sectionHeader('BASIC INFORMATION'),
            const SizedBox(height: 12),
            _field(
              label: 'Product Name *',
              controller: _nameCtrl,
              hint: 'e.g. PlayStation 5 Controller',
              validator: (v) =>
                  v == null || v.trim().isEmpty ? 'Required' : null,
            ),
            const SizedBox(height: 12),
            _field(
              label: 'Brand *',
              controller: _brandCtrl,
              hint: 'e.g. Sony, Microsoft, Nintendo',
              validator: (v) =>
                  v == null || v.trim().isEmpty ? 'Required' : null,
            ),
            const SizedBox(height: 12),

            // Category selector
            _sectionLabel('Category *'),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _categories.map((cat) {
                final sel = cat == _category;
                return GestureDetector(
                  onTap: () => setState(() => _category = cat),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 180),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 14, vertical: 8),
                    decoration: BoxDecoration(
                      color: sel
                          ? const Color(0xFFE63946)
                          : const Color(0xFF1A1A1A),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: sel
                            ? const Color(0xFFE63946)
                            : Colors.grey.shade800,
                      ),
                    ),
                    child: Text(cat,
                        style: GoogleFonts.poppins(
                            color: sel ? Colors.white : Colors.grey.shade500,
                            fontSize: 12,
                            fontWeight:
                                sel ? FontWeight.bold : FontWeight.normal)),
                  ),
                );
              }).toList(),
            ),

            const SizedBox(height: 20),

            // ── Pricing ──
            _sectionHeader('PRICING & INVENTORY'),
            const SizedBox(height: 12),
            // Hint about original price
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.04),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.white.withOpacity(0.06)),
              ),
              child: Row(
                children: [
                  Icon(Icons.info_outline,
                      color: Colors.grey.shade600, size: 14),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Set "Original Price" higher than "Price" to show a discount badge on your listing.',
                      style: GoogleFonts.poppins(
                          color: Colors.grey.shade600, fontSize: 11),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _field(
                    label: 'Selling Price (USD) *',
                    controller: _priceCtrl,
                    hint: '0.00',
                    prefixText: '\$',
                    keyboardType:
                        const TextInputType.numberWithOptions(decimal: true),
                    inputFormatters: [
                      FilteringTextInputFormatter.allow(
                          RegExp(r'^\d+\.?\d{0,2}')),
                    ],
                    validator: (v) {
                      if (v == null || v.trim().isEmpty) return 'Required';
                      if (double.tryParse(v.trim()) == null) return 'Invalid';
                      if (double.parse(v.trim()) <= 0) return 'Must be > 0';
                      return null;
                    },
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _field(
                    label: 'Original Price (optional)',
                    controller: _originalPriceCtrl,
                    hint: '0.00',
                    prefixText: '\$',
                    keyboardType:
                        const TextInputType.numberWithOptions(decimal: true),
                    inputFormatters: [
                      FilteringTextInputFormatter.allow(
                          RegExp(r'^\d+\.?\d{0,2}')),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            _field(
              label: 'Stock Quantity *',
              controller: _stockCtrl,
              hint: 'e.g. 50',
              keyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              validator: (v) {
                if (v == null || v.trim().isEmpty) return 'Required';
                if (int.tryParse(v.trim()) == null) return 'Invalid';
                return null;
              },
            ),

            const SizedBox(height: 20),

            // ── Description ──
            _sectionHeader('DESCRIPTION'),
            const SizedBox(height: 12),
            _field(
              label: 'Product Description *',
              controller: _descCtrl,
              hint: 'Describe your product — features, compatibility, what\'s included...',
              maxLines: 5,
              validator: (v) =>
                  v == null || v.trim().length < 10 ? 'Min 10 characters' : null,
            ),

            const SizedBox(height: 20),

            // ── Tags ──
            _sectionHeader('TAGS'),
            const SizedBox(height: 8),
            Text(
              'Tags help buyers find your product when searching. Press + or Enter to add.',
              style: GoogleFonts.poppins(
                  color: Colors.grey.shade600, fontSize: 11),
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _tagCtrl,
                    style: GoogleFonts.poppins(
                        color: Colors.white, fontSize: 13),
                    decoration: InputDecoration(
                      hintText: 'e.g. fps, multiplayer, rpg',
                      hintStyle: GoogleFonts.poppins(
                          color: Colors.grey.shade600, fontSize: 12),
                      filled: true,
                      fillColor: const Color(0xFF1A1A1A),
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 14, vertical: 12),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide.none,
                      ),
                    ),
                    onSubmitted: (_) => _addTag(),
                  ),
                ),
                const SizedBox(width: 10),
                GestureDetector(
                  onTap: _addTag,
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: const Color(0xFFE63946),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child:
                        const Icon(Icons.add, color: Colors.white, size: 20),
                  ),
                ),
              ],
            ),
            if (_tags.isNotEmpty) ...[
              const SizedBox(height: 10),
              Wrap(
                spacing: 8,
                runSpacing: 6,
                children: _tags
                    .map((tag) => Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 5),
                          decoration: BoxDecoration(
                            color: const Color(0xFF1A1A1A),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                                color: const Color(0xFFE63946)
                                    .withOpacity(0.4)),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text('#$tag',
                                  style: GoogleFonts.poppins(
                                      color: const Color(0xFFE63946),
                                      fontSize: 12)),
                              const SizedBox(width: 6),
                              GestureDetector(
                                onTap: () =>
                                    setState(() => _tags.remove(tag)),
                                child: Icon(Icons.close,
                                    size: 14,
                                    color: const Color(0xFFE63946)
                                        .withOpacity(0.7)),
                              ),
                            ],
                          ),
                        ))
                    .toList(),
              ),
            ],

            const SizedBox(height: 32),

            ElevatedButton(
              onPressed: _isLoading ? null : _save,
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
                      _isEditing ? 'Save Changes' : 'List Product',
                      style: GoogleFonts.orbitron(
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                          letterSpacing: 1),
                    ),
            ),

            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _field({
    required String label,
    required TextEditingController controller,
    String? hint,
    String? prefixText,
    int maxLines = 1,
    TextInputType? keyboardType,
    List<TextInputFormatter>? inputFormatters,
    String? Function(String?)? validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _sectionLabel(label),
        const SizedBox(height: 6),
        TextFormField(
          controller: controller,
          style: GoogleFonts.poppins(color: Colors.white, fontSize: 13),
          maxLines: maxLines,
          keyboardType: keyboardType,
          inputFormatters: inputFormatters,
          validator: validator,
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: GoogleFonts.poppins(
                color: Colors.grey.shade700, fontSize: 12),
            prefixText: prefixText,
            prefixStyle: GoogleFonts.poppins(
                color: Colors.grey.shade400, fontSize: 13),
            filled: true,
            fillColor: const Color(0xFF1A1A1A),
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
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(color: Colors.red.shade700, width: 1),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide:
                  BorderSide(color: Colors.red.shade700, width: 1.5),
            ),
          ),
        ),
      ],
    );
  }

  Widget _sectionHeader(String text) {
    return Row(
      children: [
        Container(
          width: 3, height: 16,
          decoration: BoxDecoration(
            color: const Color(0xFFE63946),
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 8),
        Text(text,
            style: GoogleFonts.orbitron(
                color: Colors.white,
                fontSize: 11,
                fontWeight: FontWeight.bold,
                letterSpacing: 2)),
      ],
    );
  }

  Widget _sectionLabel(String text) {
    return Text(text,
        style: GoogleFonts.poppins(
            color: Colors.grey.shade500,
            fontSize: 11,
            fontWeight: FontWeight.w500));
  }
}
