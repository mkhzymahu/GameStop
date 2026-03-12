import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../app/theme/app_theme.dart';
import '../../providers/cart_provider.dart';
import 'package:provider/provider.dart';

// ── Prize definition ──
class _Prize {
  final String label;
  final String sublabel;
  final Color color;
  final Color textColor;
  final double probability; // 0.0 - 1.0, all must sum to 1.0
  final String couponCode;

  const _Prize({
    required this.label,
    required this.sublabel,
    required this.color,
    required this.textColor,
    required this.probability,
    required this.couponCode,
  });
}

// ── Prize table: probabilities sum to 1.0 ──
const List<_Prize> _prizes = [
  _Prize(
    label: 'SAVE \$5',
    sublabel: 'WELCOME5',
    color: Color(0xFF3B8EFF),
    textColor: Colors.white,
    probability: 0.30,
    couponCode: 'WELCOME5',
  ),
  _Prize(
    label: '10% OFF',
    sublabel: 'SAVE10',
    color: Color(0xFF3BFF8E),
    textColor: Color(0xFF1A1A1A),
    probability: 0.25,
    couponCode: 'SAVE10',
  ),
  _Prize(
    label: 'TRY AGAIN',
    sublabel: 'No prize',
    color: Color(0xFF3A3A3A),
    textColor: Colors.grey,
    probability: 0.20,
    couponCode: '',
  ),
  _Prize(
    label: '15% OFF',
    sublabel: 'GAMER15',
    color: Color(0xFFFFB83B),
    textColor: Color(0xFF1A1A1A),
    probability: 0.12,
    couponCode: 'GAMER15',
  ),
  _Prize(
    label: 'SAVE \$20',
    sublabel: 'SAVE20',
    color: Color(0xFFFF3B3B),
    textColor: Colors.white,
    probability: 0.08,
    couponCode: 'SAVE20',
  ),
  _Prize(
    label: 'FREE SHIP',
    sublabel: 'FREESHIP',
    color: Color(0xFFB83BFF),
    textColor: Colors.white,
    probability: 0.05,
    couponCode: 'FREESHIP',
  ),
];

class SpinWheelScreen extends StatefulWidget {
  const SpinWheelScreen({super.key});

  @override
  State<SpinWheelScreen> createState() => _SpinWheelScreenState();
}

class _SpinWheelScreenState extends State<SpinWheelScreen>
    with TickerProviderStateMixin {

  late AnimationController _spinController;
  late AnimationController _pulseController;
  late AnimationController _resultController;

  late Animation<double> _spinAnimation;
  late Animation<double> _pulseAnimation;
  late Animation<double> _resultScaleAnimation;
  late Animation<double> _resultOpacityAnimation;

  double _currentAngle = 0.0;
  bool _isSpinning = false;
  bool _hasSpunToday = false;
  _Prize? _wonPrize;
  bool _showResult = false;

  // Each segment is equally sized visually (360 / prizes.length degrees)
  static final double _segmentAngle = (2 * pi) / _prizes.length;

  @override
  void initState() {
    super.initState();

    _spinController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 4500),
    );

    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat(reverse: true);

    _resultController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );

    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.08).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    _resultScaleAnimation = Tween<double>(begin: 0.3, end: 1.0).animate(
      CurvedAnimation(parent: _resultController,
          curve: Curves.elasticOut),
    );

    _resultOpacityAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _resultController,
          curve: const Interval(0.0, 0.4)),
    );
  }

  @override
  void dispose() {
    _spinController.dispose();
    _pulseController.dispose();
    _resultController.dispose();
    super.dispose();
  }

  // ── Weighted random prize selection ──
  _Prize _selectPrize() {
    final rand = Random().nextDouble(); // 0.0 to 1.0
    double cumulative = 0.0;
    for (final prize in _prizes) {
      cumulative += prize.probability;
      if (rand <= cumulative) return prize;
    }
    return _prizes.last;
  }

  // ── Index of prize in list ──
  int _prizeIndex(_Prize prize) => _prizes.indexOf(prize);

  void _spin() {
    if (_isSpinning || _hasSpunToday) return;

    HapticFeedback.mediumImpact();
    setState(() {
      _isSpinning = true;
      _showResult = false;
      _wonPrize = null;
    });

    final prize = _selectPrize();
    final prizeIdx = _prizeIndex(prize);

    // Target angle: land pointer (top = 0) on the winning segment
    // Segment centre for prizeIdx:
    final segmentCenter = prizeIdx * _segmentAngle + _segmentAngle / 2;
    // Pointer is at top (0 rad). Wheel needs to rotate so segment center
    // aligns with top. Add multiple full rotations for drama.
    final fullRotations = (6 + Random().nextInt(4)) * 2 * pi;
    final targetAngle = fullRotations + (2 * pi - segmentCenter);

    _spinAnimation = Tween<double>(
      begin: _currentAngle,
      end: _currentAngle + targetAngle,
    ).animate(CurvedAnimation(
      parent: _spinController,
      curve: Curves.decelerate,
    ));

    _spinController.reset();
    _spinController.forward().then((_) {
      _currentAngle = _spinAnimation.value % (2 * pi);
      HapticFeedback.heavyImpact();
      setState(() {
        _wonPrize = prize;
        _isSpinning = false;
        _hasSpunToday = true;
        _showResult = true;
      });
      _resultController.reset();
      _resultController.forward();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF141414),
      body: Stack(
        children: [
          // ── Background glow effect ──
          Positioned.fill(
            child: CustomPaint(painter: _GlowPainter()),
          ),

          SafeArea(
            child: Column(
              children: [
                // ── Header ──
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
                  child: Row(
                    children: [
                      GestureDetector(
                        onTap: () => Navigator.pop(context),
                        child: Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: Colors.white.withAlpha(18),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Icon(Icons.arrow_back_ios,
                              color: Colors.white, size: 16),
                        ),
                      ),
                      const Spacer(),
                      Column(
                        children: [
                          Text('DAILY SPIN',
                              style: GoogleFonts.orbitron(
                                  color: Colors.white,
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 3)),
                          Text('One spin per day',
                              style: TextStyle(
                                  color: Colors.grey.shade500, fontSize: 11)),
                        ],
                      ),
                      const Spacer(),
                      // Status badge
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 6),
                        decoration: BoxDecoration(
                          color: _hasSpunToday
                              ? Colors.grey.shade800
                              : AppTheme.primaryRed.withAlpha(51),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                              color: _hasSpunToday
                                  ? Colors.grey.shade700
                                  : AppTheme.primaryRed.withAlpha(128)),
                        ),
                        child: Text(
                          _hasSpunToday ? 'USED' : 'READY',
                          style: TextStyle(
                              color: _hasSpunToday
                                  ? Colors.grey : AppTheme.primaryRed,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 1),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 8),

                // ── Prize legend ──
                _buildPrizeLegend(),

                const SizedBox(height: 16),

                // ── Wheel area ──
                Expanded(
                  child: Center(
                    child: _buildWheelArea(),
                  ),
                ),

                // ── Spin button ──
                Padding(
                  padding: const EdgeInsets.fromLTRB(32, 0, 32, 16),
                  child: _buildSpinButton(),
                ),

                const SizedBox(height: 8),
              ],
            ),
          ),

          // ── Result overlay ──
          if (_showResult && _wonPrize != null)
            _buildResultOverlay(),
        ],
      ),
    );
  }

  Widget _buildPrizeLegend() {
    return SizedBox(
      height: 32,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: _prizes.length,
        itemBuilder: (context, i) {
          final p = _prizes[i];
          final pct = (p.probability * 100).toStringAsFixed(0);
          return Container(
            margin: const EdgeInsets.only(right: 8),
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: p.color.withAlpha(38),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: p.color.withAlpha(102)),
            ),
            child: Row(mainAxisSize: MainAxisSize.min, children: [
              Container(
                width: 7, height: 7,
                decoration: BoxDecoration(
                    color: p.color, shape: BoxShape.circle),
              ),
              const SizedBox(width: 5),
              Text('${p.label} · $pct%',
                  style: TextStyle(
                      color: p.color,
                      fontSize: 10,
                      fontWeight: FontWeight.bold)),
            ]),
          );
        },
      ),
    );
  }

  Widget _buildWheelArea() {
    return LayoutBuilder(builder: (context, constraints) {
      final size = min(constraints.maxWidth, constraints.maxHeight) * 0.88;
      return SizedBox(
        width: size,
        height: size,
        child: Stack(
          alignment: Alignment.center,
          children: [
            // Outer glow ring
            Container(
              width: size,
              height: size,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: AppTheme.primaryRed.withAlpha(
                        _isSpinning ? 102 : 38),
                    blurRadius: _isSpinning ? 40 : 20,
                    spreadRadius: _isSpinning ? 8 : 2,
                  ),
                ],
              ),
            ),

            // Wheel
            AnimatedBuilder(
              animation: _spinController,
              builder: (context, _) {
                final angle = _isSpinning
                    ? _spinAnimation.value
                    : _currentAngle;
                return Transform.rotate(
                  angle: angle,
                  child: CustomPaint(
                    size: Size(size * 0.92, size * 0.92),
                    painter: _WheelPainter(prizes: _prizes),
                  ),
                );
              },
            ),

            // Center hub
            AnimatedBuilder(
              animation: _pulseAnimation,
              builder: (context, _) {
                return Transform.scale(
                  scale: _isSpinning ? 1.0 : _pulseAnimation.value,
                  child: Container(
                    width: size * 0.16,
                    height: size * 0.16,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: const Color(0xFF141414),
                      border: Border.all(
                          color: AppTheme.primaryRed, width: 3),
                      boxShadow: [
                        BoxShadow(
                          color: AppTheme.primaryRed.withAlpha(153),
                          blurRadius: 12,
                          spreadRadius: 2,
                        ),
                      ],
                    ),
                    child: Center(
                      child: Icon(Icons.sports_esports,
                          color: AppTheme.primaryRed,
                          size: size * 0.07),
                    ),
                  ),
                );
              },
            ),

            // Pointer (top)
            Positioned(
              top: 0,
              child: CustomPaint(
                size: Size(size * 0.1, size * 0.1),
                painter: _PointerPainter(),
              ),
            ),
          ],
        ),
      );
    });
  }

  Widget _buildSpinButton() {
    final canSpin = !_isSpinning && !_hasSpunToday;
    return GestureDetector(
      onTap: _spin,
      child: AnimatedBuilder(
        animation: _pulseAnimation,
        builder: (context, _) {
          return Transform.scale(
            scale: canSpin ? _pulseAnimation.value : 1.0,
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 18),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                gradient: canSpin
                    ? const LinearGradient(
                  colors: [Color(0xFF8B0000), AppTheme.primaryRed,
                    Color(0xFFFF6B3B)],
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                )
                    : null,
                color: canSpin ? null : Colors.grey.shade800,
                boxShadow: canSpin ? [
                  BoxShadow(
                    color: AppTheme.primaryRed.withAlpha(102),
                    blurRadius: 20,
                    spreadRadius: 2,
                    offset: const Offset(0, 4),
                  ),
                ] : null,
              ),
              child: Center(
                child: Text(
                  _hasSpunToday
                      ? 'COME BACK TOMORROW'
                      : _isSpinning
                      ? 'SPINNING...'
                      : 'SPIN THE WHEEL',
                  style: GoogleFonts.orbitron(
                    color: canSpin ? Colors.white : Colors.grey,
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 2,
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildResultOverlay() {
    final prize = _wonPrize!;
    final won = prize.couponCode.isNotEmpty;

    return GestureDetector(
      onTap: () => setState(() => _showResult = false),
      child: Container(
        color: Colors.black.withAlpha(191),
        child: Center(
          child: AnimatedBuilder(
            animation: _resultController,
            builder: (context, _) {
              return Opacity(
                opacity: _resultOpacityAnimation.value,
                child: Transform.scale(
                  scale: _resultScaleAnimation.value,
                  child: Container(
                    margin: const EdgeInsets.symmetric(horizontal: 32),
                    padding: const EdgeInsets.all(32),
                    decoration: BoxDecoration(
                      color: const Color(0xFF1E1E1E),
                      borderRadius: BorderRadius.circular(28),
                      border: Border.all(
                          color: won
                              ? prize.color.withAlpha(153)
                              : Colors.grey.shade700,
                          width: 2),
                      boxShadow: [
                        BoxShadow(
                          color: won
                              ? prize.color.withAlpha(77)
                              : Colors.transparent,
                          blurRadius: 40,
                          spreadRadius: 4,
                        ),
                      ],
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Icon
                        Container(
                          width: 80, height: 80,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: prize.color.withAlpha(38),
                            border: Border.all(
                                color: prize.color.withAlpha(128), width: 2),
                          ),
                          child: Center(
                            child: Text(
                              won ? '🎉' : '😔',
                              style: const TextStyle(fontSize: 36),
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),

                        Text(
                          won ? 'YOU WON!' : 'BETTER LUCK',
                          style: GoogleFonts.orbitron(
                            color: won ? prize.color : Colors.grey,
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 2,
                          ),
                        ),
                        if (won) ...[
                          const SizedBox(height: 8),
                          Text(
                            prize.label,
                            style: GoogleFonts.orbitron(
                              color: Colors.white,
                              fontSize: 32,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 16),
                          // Coupon code box
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 20, vertical: 12),
                            decoration: BoxDecoration(
                              color: prize.color.withAlpha(31),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                  color: prize.color.withAlpha(102)),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(Icons.local_offer,
                                    size: 16, color: Colors.white70),
                                const SizedBox(width: 8),
                                Text(
                                  prize.couponCode,
                                  style: GoogleFonts.orbitron(
                                    color: Colors.white,
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    letterSpacing: 3,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 20),
                          // Apply to cart button
                          GestureDetector(
                            onTap: () {
                              context.read<CartProvider>()
                                  .applyCoupon(prize.couponCode);
                              setState(() => _showResult = false);
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                      '${prize.couponCode} applied to your cart!'),
                                  backgroundColor: Colors.green,
                                  behavior: SnackBarBehavior.floating,
                                  duration: const Duration(seconds: 2),
                                ),
                              );
                            },
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 28, vertical: 14),
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [
                                    prize.color.withAlpha(204),
                                    prize.color
                                  ],
                                ),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                'APPLY TO CART',
                                style: GoogleFonts.orbitron(
                                  color: prize.textColor,
                                  fontSize: 13,
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 1.5,
                                ),
                              ),
                            ),
                          ),
                        ],
                        const SizedBox(height: 16),
                        Text(
                          won
                              ? 'Tap anywhere to close'
                              : 'Come back tomorrow!',
                          style: TextStyle(
                              color: Colors.grey.shade600, fontSize: 12),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}

// ── Custom wheel painter ──
class _WheelPainter extends CustomPainter {
  final List<_Prize> prizes;

  const _WheelPainter({required this.prizes});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;
    final segmentAngle = (2 * pi) / prizes.length;
    final textPainter = TextPainter(textDirection: TextDirection.ltr);

    for (int i = 0; i < prizes.length; i++) {
      final prize = prizes[i];
      final startAngle = i * segmentAngle - pi / 2;

      // Segment fill
      final paint = Paint()
        ..color = prize.color
        ..style = PaintingStyle.fill;
      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        startAngle,
        segmentAngle,
        true,
        paint,
      );

      // Segment border
      final borderPaint = Paint()
        ..color = Colors.black.withAlpha(89)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.5;
      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        startAngle,
        segmentAngle,
        true,
        borderPaint,
      );

      // Text in segment
      final textAngle = startAngle + segmentAngle / 2;
      final textRadius = radius * 0.62;
      final textX = center.dx + textRadius * cos(textAngle);
      final textY = center.dy + textRadius * sin(textAngle);

      canvas.save();
      canvas.translate(textX, textY);
      canvas.rotate(textAngle + pi / 2);

      // Main label
      textPainter.text = TextSpan(
        text: prize.label,
        style: TextStyle(
          color: prize.textColor,
          fontSize: radius * 0.095,
          fontWeight: FontWeight.bold,
        ),
      );
      textPainter.layout();
      textPainter.paint(canvas,
          Offset(-textPainter.width / 2, -textPainter.height - 1));

      // Sub label (coupon code)
      if (prize.couponCode.isNotEmpty) {
        textPainter.text = TextSpan(
          text: prize.couponCode,
          style: TextStyle(
            color: prize.textColor.withAlpha(179),
            fontSize: radius * 0.065,
            fontWeight: FontWeight.w600,
          ),
        );
        textPainter.layout();
        textPainter.paint(canvas,
            Offset(-textPainter.width / 2, 2));
      }

      canvas.restore();
    }

    // Outer ring
    final ringPaint = Paint()
      ..color = Colors.white.withAlpha(31)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4;
    canvas.drawCircle(center, radius, ringPaint);

    // Inner ring
    final innerRingPaint = Paint()
      ..color = Colors.black.withAlpha(77)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;
    canvas.drawCircle(center, radius * 0.22, innerRingPaint);
  }

  @override
  bool shouldRepaint(_WheelPainter old) => false;
}

// ── Pointer painter ──
class _PointerPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;

    final shadowPaint = Paint()
      ..color = Colors.black.withAlpha(102)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4);

    final path = Path()
      ..moveTo(size.width / 2, size.height * 1.1)
      ..lineTo(0, 0)
      ..lineTo(size.width, 0)
      ..close();

    canvas.drawPath(path, shadowPaint);
    canvas.drawPath(path, paint);

    // Red accent on pointer
    final accentPaint = Paint()
      ..color = AppTheme.primaryRed
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;
    canvas.drawPath(path, accentPaint);
  }

  @override
  bool shouldRepaint(_PointerPainter old) => false;
}

// ── Background glow painter ──
class _GlowPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..shader = RadialGradient(
        colors: [
          AppTheme.primaryRed.withAlpha(20),
          Colors.transparent,
        ],
        radius: 0.7,
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));
    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), paint);
  }

  @override
  bool shouldRepaint(_GlowPainter old) => false;
}