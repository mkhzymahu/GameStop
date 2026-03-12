import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:provider/provider.dart';
import '../../app/theme/app_theme.dart';
import '../../providers/cart_provider.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final ScrollController _scrollController = ScrollController();
  final PageController _heroController = PageController();
  int _heroIndex = 0;

  // ── Hero banner data ──
  static const List<Map<String, String>> _heroBanners = [
    {
      'tag': 'NEW RELEASE',
      'title': 'RTX 5090',
      'subtitle': 'The most powerful GPU ever built. 120 TFLOPS of raw power.',
      'price': '\$1,999',
      'image':
          'https://images.unsplash.com/photo-1587202372775-e229f172b9d7?w=900&auto=format',
      'accent': 'FF3B3B',
    },
    {
      'tag': 'TRENDING',
      'title': 'PS5 Pro',
      'subtitle': 'Next-gen gaming at 8K. Experience the future today.',
      'price': '\$699',
      'image':
          'https://images.unsplash.com/photo-1606813907291-d86efa9b94db?w=900&auto=format',
      'accent': '3B8EFF',
    },
    {
      'tag': 'HOT DEAL',
      'title': 'Steam Deck OLED',
      'subtitle': 'Your entire library, anywhere. Vivid OLED display.',
      'price': '\$549',
      'image':
          'https://images.unsplash.com/photo-1538481199705-c710c4e965fc?w=900&auto=format',
      'accent': '3BFF8E',
    },
  ];

  // ── News items ──
  static const List<Map<String, String>> _news = [
    {
      'category': 'GPU NEWS',
      'title': 'NVIDIA announces RTX 5000 series with DLSS 4.0',
      'time': '2 hours ago',
      'image':
          'https://images.unsplash.com/photo-1591488320449-011701bb6704?w=400&auto=format',
    },
    {
      'category': 'GAMING',
      'title': 'GTA VI release date confirmed for Fall 2025',
      'time': '5 hours ago',
      'image':
          'https://images.unsplash.com/photo-1542751371-adc38448a05e?w=400&auto=format',
    },
    {
      'category': 'HARDWARE',
      'title': 'AMD Ryzen 9000 benchmarks shatter records',
      'time': '1 day ago',
      'image':
          'https://images.unsplash.com/photo-1562976540-1502c2145186?w=400&auto=format',
    },
    {
      'category': 'DEALS',
      'title': 'Black Friday early deals: Up to 60% off peripherals',
      'time': '1 day ago',
      'image':
          'https://images.unsplash.com/photo-1505740420928-5e560c06d30e?w=400&auto=format',
    },
  ];

  // ── Featured products ──
  static const List<Map<String, String>> _featured = [
    {
      'id': 'prod1',
      'name': 'RTX 4090',
      'brand': 'NVIDIA',
      'price': '\$1,599',
      'originalPrice': '\$1,899',
      'tag': 'BEST SELLER',
      'tagColor': 'FF3B3B',
      'image':
          'https://images.unsplash.com/photo-1587202372775-e229f172b9d7?w=400&auto=format',
      'rating': '4.9',
    },
    {
      'id': 'prod3',
      'name': 'DualSense Edge',
      'brand': 'SONY',
      'price': '\$199',
      'originalPrice': '',
      'tag': 'NEW',
      'tagColor': '3BFF8E',
      'image':
          'https://images.unsplash.com/photo-1562976540-1502c2145186?w=400&auto=format',
      'rating': '4.7',
    },
    {
      'id': 'prod4',
      'name': 'Ryzen 9 7950X',
      'brand': 'AMD',
      'price': '\$549',
      'originalPrice': '\$699',
      'tag': 'SALE',
      'tagColor': 'FFB83B',
      'image':
          'https://images.unsplash.com/photo-1542751371-adc38448a05e?w=400&auto=format',
      'rating': '4.8',
    },
    {
      'id': 'prod5',
      'name': 'Odyssey G9',
      'brand': 'SAMSUNG',
      'price': '\$1,199',
      'originalPrice': '\$1,499',
      'tag': 'HOT',
      'tagColor': 'FF3B3B',
      'image':
          'https://images.unsplash.com/photo-1538481199705-c710c4e965fc?w=400&auto=format',
      'rating': '4.6',
    },
  ];

  // ── Categories ──
  static const List<Map<String, dynamic>> _categories = [
    {'label': 'GPUs', 'icon': Icons.memory, 'color': 0xFFFF3B3B},
    {'label': 'CPUs', 'icon': Icons.developer_board, 'color': 0xFF3B8EFF},
    {'label': 'Monitors', 'icon': Icons.monitor, 'color': 0xFF3BFF8E},
    {'label': 'Controllers', 'icon': Icons.sports_esports, 'color': 0xFFFFB83B},
    {'label': 'Headsets', 'icon': Icons.headset, 'color': 0xFFB83BFF},
    {'label': 'Keyboards', 'icon': Icons.keyboard, 'color': 0xFFFF8E3B},
  ];

  @override
  void initState() {
    super.initState();
    // Auto-scroll hero every 4 seconds
    Future.doWhile(() async {
      await Future.delayed(const Duration(seconds: 4));
      if (!mounted) return false;
      final next = (_heroIndex + 1) % _heroBanners.length;
      _heroController.animateToPage(next,
          duration: const Duration(milliseconds: 600), curve: Curves.easeInOut);
      return true;
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _heroController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.darkGrey,
      body: CustomScrollView(
        controller: _scrollController,
        slivers: [
          // ── App bar ──
          _buildAppBar(context),

          SliverToBoxAdapter(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ── Hero carousel ──
                _buildHeroCarousel(),
                const SizedBox(height: 28),

                // ── Categories ──
                _buildSectionHeader('SHOP BY CATEGORY',
                    onTap: () => context.go('/products')),
                const SizedBox(height: 14),
                _buildCategories(),
                const SizedBox(height: 28),

                // ── Featured products ──
                _buildSectionHeader('FEATURED PRODUCTS',
                    onTap: () => context.go('/products')),
                const SizedBox(height: 14),
                _buildFeaturedProducts(context),
                const SizedBox(height: 28),

                // ── News ──
                _buildSectionHeader('LATEST NEWS', onTap: () {}),
                const SizedBox(height: 14),
                _buildNews(),
                const SizedBox(height: 28),

                // ── Promo banner ──
                _buildPromoBanner(context),
                const SizedBox(height: 28),

                // ── Top picks ──
                _buildSectionHeader('TOP PICKS FOR YOU',
                    onTap: () => context.go('/products')),
                const SizedBox(height: 6),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Text(
                    'Based on your browsing — personalization coming soon',
                    style: TextStyle(color: Colors.grey.shade600, fontSize: 11),
                  ),
                ),
                const SizedBox(height: 14),
                _buildTopPicks(context),
                const SizedBox(height: 32),
                // ── Contact support ──
                _buildContactSupport(context),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ── App bar ──
  Widget _buildAppBar(BuildContext context) {
    return SliverAppBar(
      floating: true,
      snap: true,
      backgroundColor: AppTheme.darkGrey,
      elevation: 0,
      title: Text(
        'GAMESTOP',
        style: GoogleFonts.orbitron(
            fontWeight: FontWeight.bold,
            color: AppTheme.primaryRed,
            letterSpacing: 3,
            fontSize: 20),
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.search, color: Colors.white),
          onPressed: () => context.go('/products'),
        ),
        IconButton(
          icon: const Icon(Icons.favorite_border, color: Colors.white),
          onPressed: () {},
        ),
        Stack(
          children: [
            IconButton(
              icon:
                  const Icon(Icons.shopping_cart_outlined, color: Colors.white),
              onPressed: () => context.go('/cart'),
            ),
            Consumer<CartProvider>(
              builder: (context, cart, _) {
                if (cart.itemCount == 0) return const SizedBox();
                return Positioned(
                  right: 6,
                  top: 6,
                  child: Container(
                    padding: const EdgeInsets.all(3),
                    decoration: const BoxDecoration(
                        color: AppTheme.primaryRed, shape: BoxShape.circle),
                    child: Text('${cart.itemCount}',
                        style: const TextStyle(
                            color: Colors.white,
                            fontSize: 9,
                            fontWeight: FontWeight.bold)),
                  ),
                );
              },
            ),
          ],
        ),
        const SizedBox(width: 4),
      ],
    );
  }

  // ── Hero carousel ──
  Widget _buildHeroCarousel() {
    return SizedBox(
      height: 240,
      child: Stack(
        children: [
          PageView.builder(
            controller: _heroController,
            itemCount: _heroBanners.length,
            onPageChanged: (i) => setState(() => _heroIndex = i),
            itemBuilder: (context, index) {
              final banner = _heroBanners[index];
              final accentColor =
                  Color(int.parse('FF${banner['accent']}', radix: 16));
              return GestureDetector(
                onTap: () => context.go('/products'),
                child: Container(
                  margin: const EdgeInsets.symmetric(horizontal: 16),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    color: const Color(0xFF2A2A2A),
                  ),
                  clipBehavior: Clip.hardEdge,
                  child: Stack(
                    children: [
                      // Background image
                      Positioned(
                        right: 0,
                        top: 0,
                        bottom: 0,
                        width: 200,
                        child: CachedNetworkImage(
                          imageUrl: banner['image']!,
                          fit: BoxFit.cover,
                          placeholder: (_, __) =>
                              Container(color: Colors.grey.shade900),
                          errorWidget: (_, __, ___) =>
                              Container(color: Colors.grey.shade900),
                        ),
                      ),
                      // Gradient overlay
                      Positioned.fill(
                        child: DecoratedBox(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                const Color(0xFF2A2A2A),
                                const Color(0xFF2A2A2A).withOpacity(0.85),
                                Colors.transparent,
                              ],
                              stops: const [0.0, 0.45, 1.0],
                            ),
                          ),
                        ),
                      ),
                      // Text content
                      Padding(
                        padding: const EdgeInsets.all(22),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 3),
                              decoration: BoxDecoration(
                                color: accentColor,
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(banner['tag']!,
                                  style: GoogleFonts.orbitron(
                                      color: Colors.white,
                                      fontSize: 9,
                                      fontWeight: FontWeight.bold,
                                      letterSpacing: 1)),
                            ),
                            const SizedBox(height: 10),
                            Text(
                              banner['title']!,
                              style: GoogleFonts.orbitron(
                                color: Colors.white,
                                fontSize: 26,
                                fontWeight: FontWeight.bold,
                                height: 1.1,
                              ),
                            ),
                            const SizedBox(height: 8),
                            SizedBox(
                              width: 180,
                              child: Text(
                                banner['subtitle']!,
                                style: TextStyle(
                                    color: Colors.grey.shade400,
                                    fontSize: 11,
                                    height: 1.4),
                              ),
                            ),
                            const SizedBox(height: 14),
                            Row(children: [
                              Text(
                                banner['price']!,
                                style: TextStyle(
                                    color: accentColor,
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold),
                              ),
                              const SizedBox(width: 12),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 12, vertical: 6),
                                decoration: BoxDecoration(
                                  color: accentColor,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text('Shop Now',
                                    style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 11,
                                        fontWeight: FontWeight.bold)),
                              ),
                            ]),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),

          // Dots indicator
          Positioned(
            bottom: 10,
            left: 0,
            right: 0,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                  _heroBanners.length,
                  (i) => AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        margin: const EdgeInsets.symmetric(horizontal: 3),
                        width: _heroIndex == i ? 20 : 6,
                        height: 6,
                        decoration: BoxDecoration(
                          color: _heroIndex == i
                              ? AppTheme.primaryRed
                              : Colors.grey.shade600,
                          borderRadius: BorderRadius.circular(3),
                        ),
                      )),
            ),
          ),
        ],
      ),
    );
  }

  // ── Section header ──
  Widget _buildSectionHeader(String title, {VoidCallback? onTap}) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Flexible(
            child: Row(children: [
              Container(
                width: 3,
                height: 18,
                decoration: BoxDecoration(
                    color: AppTheme.primaryRed,
                    borderRadius: BorderRadius.circular(2)),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.orbitron(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.5)),
              ),
            ]),
          ),
          if (onTap != null)
            GestureDetector(
              onTap: onTap,
              child: Text('See all',
                  style: TextStyle(
                      color: AppTheme.primaryRed,
                      fontSize: 12,
                      fontWeight: FontWeight.w600)),
            ),
        ],
      ),
    );
  }

  // ── Categories ──
  Widget _buildCategories() {
    return SizedBox(
      height: 90,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: _categories.length,
        itemBuilder: (context, index) {
          final cat = _categories[index];
          final color = Color(cat['color'] as int);
          return GestureDetector(
            onTap: () => context.go('/products'),
            child: Container(
              width: 72,
              margin: const EdgeInsets.symmetric(horizontal: 5),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: color.withOpacity(0.3)),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(cat['icon'] as IconData, color: color, size: 26),
                  const SizedBox(height: 6),
                  Text(cat['label'] as String,
                      style: TextStyle(
                          color: Colors.grey.shade300,
                          fontSize: 10,
                          fontWeight: FontWeight.w600)),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  // ── Featured products horizontal scroll ──
  Widget _buildFeaturedProducts(BuildContext context) {
    return SizedBox(
      height: 230,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: _featured.length,
        itemBuilder: (context, index) {
          final p = _featured[index];
          final tagColor = Color(int.parse('FF${p['tagColor']}', radix: 16));
          return GestureDetector(
            onTap: () => context
                .pushNamed('productDetail', pathParameters: {'id': p['id']!}),
            child: Container(
              width: 155,
              margin: const EdgeInsets.symmetric(horizontal: 5),
              decoration: BoxDecoration(
                color: const Color(0xFF2A2A2A),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.grey.shade800),
              ),
              clipBehavior: Clip.hardEdge,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Image
                  Stack(children: [
                    CachedNetworkImage(
                      imageUrl: p['image']!,
                      height: 120,
                      width: double.infinity,
                      fit: BoxFit.cover,
                      placeholder: (_, __) =>
                          Container(height: 120, color: Colors.grey.shade900),
                      errorWidget: (_, __, ___) => Container(
                          height: 120,
                          color: Colors.grey.shade900,
                          child: const Icon(Icons.image_not_supported,
                              color: Colors.grey)),
                    ),
                    Positioned(
                      top: 8,
                      left: 8,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                            color: tagColor,
                            borderRadius: BorderRadius.circular(4)),
                        child: Text(p['tag']!,
                            style: const TextStyle(
                                color: Colors.white,
                                fontSize: 8,
                                fontWeight: FontWeight.bold)),
                      ),
                    ),
                    Positioned(
                      top: 8,
                      right: 8,
                      child: GestureDetector(
                        onTap: () {},
                        child: Container(
                          padding: const EdgeInsets.all(4),
                          decoration: BoxDecoration(
                              color: Colors.black54,
                              borderRadius: BorderRadius.circular(6)),
                          child: const Icon(Icons.favorite_border,
                              color: Colors.white, size: 14),
                        ),
                      ),
                    ),
                  ]),
                  // Info
                  Padding(
                    padding: const EdgeInsets.all(10),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(p['brand']!,
                            style: const TextStyle(
                                color: AppTheme.primaryRed,
                                fontSize: 9,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 0.5)),
                        const SizedBox(height: 2),
                        Text(p['name']!,
                            style: const TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                                fontWeight: FontWeight.w600),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis),
                        const SizedBox(height: 4),
                        Row(children: [
                          const Icon(Icons.star, color: Colors.amber, size: 11),
                          const SizedBox(width: 3),
                          Text(p['rating']!,
                              style: TextStyle(
                                  color: Colors.grey.shade400, fontSize: 10)),
                        ]),
                        const SizedBox(height: 4),
                        Row(children: [
                          Text(p['price']!,
                              style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 13,
                                  fontWeight: FontWeight.bold)),
                          if (p['originalPrice']!.isNotEmpty) ...[
                            const SizedBox(width: 5),
                            Text(p['originalPrice']!,
                                style: TextStyle(
                                    color: Colors.grey.shade600,
                                    fontSize: 10,
                                    decoration: TextDecoration.lineThrough)),
                          ],
                        ]),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  // ── News ──
  Widget _buildNews() {
    return SizedBox(
      height: 150,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: _news.length,
        itemBuilder: (context, index) {
          final item = _news[index];
          return Container(
            width: 240,
            margin: const EdgeInsets.symmetric(horizontal: 5),
            decoration: BoxDecoration(
              color: const Color(0xFF2A2A2A),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: Colors.grey.shade800),
            ),
            clipBehavior: Clip.hardEdge,
            child: Row(children: [
              CachedNetworkImage(
                imageUrl: item['image']!,
                width: 85,
                height: double.infinity,
                fit: BoxFit.cover,
                placeholder: (_, __) =>
                    Container(width: 85, color: Colors.grey.shade900),
                errorWidget: (_, __, ___) =>
                    Container(width: 85, color: Colors.grey.shade900),
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 5, vertical: 2),
                        decoration: BoxDecoration(
                          color: AppTheme.primaryRed.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(3),
                        ),
                        child: Text(item['category']!,
                            style: const TextStyle(
                                color: AppTheme.primaryRed,
                                fontSize: 8,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 0.5)),
                      ),
                      const SizedBox(height: 6),
                      Text(item['title']!,
                          style: const TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              height: 1.3),
                          maxLines: 3,
                          overflow: TextOverflow.ellipsis),
                      const SizedBox(height: 6),
                      Text(item['time']!,
                          style: TextStyle(
                              color: Colors.grey.shade600, fontSize: 10)),
                    ],
                  ),
                ),
              ),
            ]),
          );
        },
      ),
    );
  }

  // ── Promo banner ──
  Widget _buildPromoBanner(BuildContext context) {
    return GestureDetector(
      onTap: () => context.go('/products'),
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16),
        height: 110,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(18),
          gradient: const LinearGradient(
            colors: [Color(0xFF8B0000), Color(0xFFFF3B3B), Color(0xFFFF6B3B)],
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
          ),
        ),
        clipBehavior: Clip.hardEdge,
        child: Stack(children: [
          // Decorative circles
          Positioned(
            right: -20,
            top: -20,
            child: Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withOpacity(0.08)),
            ),
          ),
          Positioned(
            right: 40,
            bottom: -30,
            child: Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withOpacity(0.06)),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 18),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text('BLACK FRIDAY',
                        style: GoogleFonts.orbitron(
                            color: Colors.white.withOpacity(0.7),
                            fontSize: 10,
                            letterSpacing: 2)),
                    const SizedBox(height: 4),
                    Text('UP TO 60% OFF',
                        style: GoogleFonts.orbitron(
                            color: Colors.white,
                            fontSize: 22,
                            fontWeight: FontWeight.bold)),
                    const SizedBox(height: 4),
                    Text('On selected gaming gear',
                        style: TextStyle(
                            color: Colors.white.withOpacity(0.8),
                            fontSize: 12)),
                  ],
                ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text('Shop Now',
                      style: TextStyle(
                          color: AppTheme.primaryRed,
                          fontSize: 13,
                          fontWeight: FontWeight.bold)),
                ),
              ],
            ),
          ),
        ]),
      ),
    );
  }

  // ── Top picks (placeholder for personalization) ──
  Widget _buildTopPicks(BuildContext context) {
    // Reverse featured list as a placeholder for "personalized" picks
    final picks = [..._featured.reversed];
    return SizedBox(
      height: 140,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: picks.length,
        itemBuilder: (context, index) {
          final p = picks[index];
          return GestureDetector(
            onTap: () => context
                .pushNamed('productDetail', pathParameters: {'id': p['id']!}),
            child: Container(
              width: 200,
              margin: const EdgeInsets.symmetric(horizontal: 5),
              decoration: BoxDecoration(
                color: const Color(0xFF2A2A2A),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: Colors.grey.shade800),
              ),
              clipBehavior: Clip.hardEdge,
              child: Row(children: [
                CachedNetworkImage(
                  imageUrl: p['image']!,
                  width: 70,
                  height: double.infinity,
                  fit: BoxFit.cover,
                  placeholder: (_, __) =>
                      Container(width: 70, color: Colors.grey.shade900),
                  errorWidget: (_, __, ___) =>
                      Container(width: 70, color: Colors.grey.shade900),
                ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(10),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(p['brand']!,
                            style: const TextStyle(
                                color: AppTheme.primaryRed,
                                fontSize: 9,
                                fontWeight: FontWeight.bold)),
                        const SizedBox(height: 3),
                        Text(p['name']!,
                            style: const TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                                fontWeight: FontWeight.w600),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis),
                        const SizedBox(height: 5),
                        Text(p['price']!,
                            style: const TextStyle(
                                color: AppTheme.primaryRed,
                                fontSize: 14,
                                fontWeight: FontWeight.bold)),
                      ],
                    ),
                  ),
                ),
              ]),
            ),
          );
        },
      ),
    );
  }

  // ── Contact support section ──
  Widget _buildContactSupport(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader('SUPPORT & CONTACT', onTap: null),
        const SizedBox(height: 14),

        // ── Hero support banner ──
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 16),
          height: 130,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(18),
            color: const Color(0xFF1E1E1E),
            border: Border.all(color: Colors.grey.shade800),
          ),
          clipBehavior: Clip.hardEdge,
          child: Row(
            children: [
              // Image side
              SizedBox(
                width: 130,
                child: CachedNetworkImage(
                  imageUrl:
                      'https://images.unsplash.com/photo-1486312338219-ce68d2c6f44d?w=400&auto=format',
                  fit: BoxFit.cover,
                  placeholder: (_, __) =>
                      Container(color: Colors.grey.shade900),
                  errorWidget: (_, __, ___) =>
                      Container(color: Colors.grey.shade900),
                ),
              ),
              // Gradient separator
              Container(
                width: 40,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Colors.transparent,
                      const Color(0xFF1E1E1E),
                    ],
                  ),
                ),
              ),
              // Text side
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(0, 16, 16, 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        '24/7 SUPPORT',
                        style: GoogleFonts.orbitron(
                          color: AppTheme.primaryRed,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1.5,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'We\'re always\nhere to help',
                        style: GoogleFonts.poppins(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          height: 1.2,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Real humans. Real answers.',
                        style: TextStyle(
                            color: Colors.grey.shade500, fontSize: 11),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 14),

        // ── Contact channel cards ──
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            children: [
              Expanded(
                child: _buildChannelCard(
                  image:
                      'https://images.unsplash.com/photo-1611746872915-64382b5c76da?w=400&auto=format',
                  icon: Icons.chat_bubble_outline,
                  title: 'Live Chat',
                  subtitle: 'Avg. reply\n< 2 min',
                  accentColor: const Color(0xFF3BFF8E),
                  onTap: () {},
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _buildChannelCard(
                  image:
                      'https://images.unsplash.com/photo-1534536281715-e28d76689b4d?w=400&auto=format',
                  icon: Icons.phone_outlined,
                  title: 'Call Us',
                  subtitle: '1-800\nGAMESTOP',
                  accentColor: const Color(0xFF3B8EFF),
                  onTap: () {},
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _buildChannelCard(
                  image:
                      'https://images.unsplash.com/photo-1596526131083-e8c633064abb?w=400&auto=format',
                  icon: Icons.email_outlined,
                  title: 'Email',
                  subtitle: 'Reply in\n24 hours',
                  accentColor: const Color(0xFFFFB83B),
                  onTap: () {},
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 14),

        // ── FAQ quick-access strip ──
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 16),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: const Color(0xFF1E1E1E),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.grey.shade800),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(children: [
                const Icon(Icons.help_outline,
                    color: AppTheme.primaryRed, size: 18),
                const SizedBox(width: 8),
                Text('QUICK ANSWERS',
                    style: GoogleFonts.orbitron(
                        color: Colors.white,
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1)),
              ]),
              const SizedBox(height: 12),
              ...[
                ('Track my order', Icons.local_shipping_outlined),
                ('Returns & refunds', Icons.assignment_return_outlined),
                ('Payment issues', Icons.credit_card_outlined),
                ('Product warranty', Icons.verified_outlined),
              ].map((item) => GestureDetector(
                    onTap: () {},
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 7),
                      child: Row(children: [
                        Icon(item.$2, color: Colors.grey.shade600, size: 16),
                        const SizedBox(width: 10),
                        Text(item.$1,
                            style: TextStyle(
                                color: Colors.grey.shade300, fontSize: 13)),
                        const Spacer(),
                        Icon(Icons.chevron_right,
                            color: Colors.grey.shade700, size: 18),
                      ]),
                    ),
                  )),
            ],
          ),
        ),

        const SizedBox(height: 32),
      ],
    );
  }

  Widget _buildChannelCard({
    required String image,
    required IconData icon,
    required String title,
    required String subtitle,
    required Color accentColor,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 140,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(14),
          color: const Color(0xFF1E1E1E),
          border: Border.all(color: Colors.grey.shade800),
        ),
        clipBehavior: Clip.hardEdge,
        child: Stack(
          children: [
            // Background image with dark overlay
            Positioned.fill(
              child: CachedNetworkImage(
                imageUrl: image,
                fit: BoxFit.cover,
                placeholder: (_, __) => Container(color: Colors.grey.shade900),
                errorWidget: (_, __, ___) =>
                    Container(color: Colors.grey.shade900),
              ),
            ),
            // Dark overlay
            Positioned.fill(
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Colors.black.withOpacity(0.75),
                      Colors.black.withOpacity(0.55),
                    ],
                    begin: Alignment.bottomCenter,
                    end: Alignment.topCenter,
                  ),
                ),
              ),
            ),
            // Accent top bar
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: Container(
                height: 3,
                color: accentColor,
              ),
            ),
            // Content
            Positioned.fill(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: accentColor.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: accentColor.withOpacity(0.4)),
                      ),
                      child: Icon(icon, color: accentColor, size: 16),
                    ),
                    const SizedBox(height: 6),
                    Text(title,
                        maxLines: 2,
                        softWrap: true,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                            color: Colors.white,
                            fontSize: 13,
                            fontWeight: FontWeight.bold)),
                    const SizedBox(height: 2),
                    Text(subtitle,
                        maxLines: 3,
                        softWrap: true,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                            color: Colors.grey.shade400,
                            fontSize: 10,
                            height: 1.3)),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
