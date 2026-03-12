import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../views/auth/splash_screen.dart';
import '../../views/auth/onboarding_screen.dart';
import '../../views/spin/spin_wheel_screen.dart';
import '../../views/auth/auth_screen.dart';
import '../../views/auth/login_screen.dart';
import '../../views/auth/register_screen.dart';
import '../../views/home/home_screen.dart';
import '../../views/seller/seller_dashboard_screen.dart';
import '../../views/cart/cart_screen.dart';
import '../../views/profile/profile_screen.dart';
import '../../views/products/product_screen.dart';
import '../../views/admin/admin_shell.dart';
import '../../views/products/product_detail_screen.dart';
import '../../../views/checkout/checkout_screen.dart';
import '../../views/orders/orders_screen.dart';
import '../../views/payment/payment_screen.dart';
import '../../views/seller/store_page_screen.dart';
import '../../providers/auth_provider.dart';
import '../theme/app_theme.dart';
import 'package:google_fonts/google_fonts.dart';

class MainShell extends StatelessWidget {
  final Widget child;
  const MainShell({super.key, required this.child});

  int _currentIndex(BuildContext context) {
    final location = GoRouterState.of(context).uri.toString();
    if (location.startsWith('/products')) return 1;
    if (location.startsWith('/cart')) return 2;
    if (location.startsWith('/profile')) return 3;
    return 0;
  }

  @override
  Widget build(BuildContext context) {
    final index = _currentIndex(context);
    return Scaffold(
      backgroundColor: AppTheme.darkGrey,
      body: child,
      floatingActionButton: Container(
        width: 76,
        height: 76,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: const Color(0xFF2C2C2C),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.4),
              blurRadius: 8,
              spreadRadius: 2,
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(6),
          child: GestureDetector(
            onTap: () => context.push('/spin'),
            child: Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: const LinearGradient(
                  colors: [
                    Color(0xFF8B0000),
                    AppTheme.primaryRed,
                    Color(0xFFFF6B3B)
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                boxShadow: [
                  BoxShadow(
                    color: AppTheme.primaryRed.withOpacity(0.55),
                    blurRadius: 14,
                    spreadRadius: 1,
                  ),
                ],
                border: Border.all(
                    color: Colors.white.withOpacity(0.12), width: 1.5),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.casino_outlined,
                      color: Colors.white, size: 22),
                  const SizedBox(height: 1),
                  Text('SPIN',
                      style: GoogleFonts.orbitron(
                          color: Colors.white,
                          fontSize: 7,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1)),
                ],
              ),
            ),
          ),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: BottomAppBar(
        color: AppTheme.darkGrey,
        shape: const CircularNotchedRectangle(),
        notchMargin: 6,
        child: SizedBox(
          height: 60,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _NavItem(
                  icon: Icons.home_outlined,
                  selectedIcon: Icons.home,
                  label: 'Home',
                  selected: index == 0,
                  onTap: () => context.go('/home')),
              _NavItem(
                  icon: Icons.sports_esports_outlined,
                  selectedIcon: Icons.sports_esports,
                  label: 'Products',
                  selected: index == 1,
                  onTap: () => context.go('/products')),
              const SizedBox(width: 62),
              _NavItem(
                  icon: Icons.shopping_cart_outlined,
                  selectedIcon: Icons.shopping_cart,
                  label: 'Cart',
                  selected: index == 2,
                  onTap: () => context.go('/cart')),
              _NavItem(
                  icon: Icons.person_outline,
                  selectedIcon: Icons.person,
                  label: 'Profile',
                  selected: index == 3,
                  onTap: () => context.go('/profile')),
            ],
          ),
        ),
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  final IconData icon;
  final IconData selectedIcon;
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _NavItem({
    required this.icon,
    required this.selectedIcon,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: SizedBox(
        width: 70,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(selected ? selectedIcon : icon,
                color: selected ? AppTheme.primaryRed : Colors.grey, size: 22),
            const SizedBox(height: 3),
            Text(label,
                style: TextStyle(
                    color: selected ? AppTheme.primaryRed : Colors.grey,
                    fontSize: 10,
                    fontWeight:
                        selected ? FontWeight.bold : FontWeight.normal)),
          ],
        ),
      ),
    );
  }
}

class AppRouter {
  static final GoRouter router = GoRouter(
    initialLocation: '/splash',
    refreshListenable: RouterNotifier(),
    redirect: (context, state) {
      // Read auth state directly from the provider reference
      final auth = context.read<AuthProvider>();
      final location = state.uri.toString();

      final isAuthenticated = auth.isAuthenticated;
      final isSeller = auth.isSeller;

      // Routes that don't require auth
      final publicRoutes = [
        '/splash',
        '/onboarding',
        '/auth',
        '/auth/login',
        '/auth/register'
      ];
      final isPublic = publicRoutes.any((r) => location.startsWith(r));

      // If not authenticated and trying to access a protected route → send to /auth
      if (!isAuthenticated && !isPublic) {
        return '/auth';
      }

      // If authenticated as seller and on a customer route → send to /seller
      if (isAuthenticated &&
          isSeller &&
          !location.startsWith('/seller') &&
          !isPublic) {
        return '/seller';
      }

      // If authenticated as customer/admin and somehow on /seller → send to /home
      if (isAuthenticated && !isSeller && location.startsWith('/seller')) {
        return '/home';
      }

// If authenticated as admin → send to /admin
      if (isAuthenticated &&
          auth.isAdmin &&
          !location.startsWith('/admin') &&
          !isPublic) {
        return '/admin';
      }

      return null; // no redirect needed
    },
    routes: [
      GoRoute(
          path: '/splash',
          name: 'splash',
          builder: (context, state) => const SplashScreen()),
      GoRoute(
          path: '/onboarding',
          name: 'onboarding',
          builder: (context, state) => const OnboardingScreen()),
      GoRoute(
          path: '/auth',
          name: 'auth',
          builder: (context, state) => const AuthScreen()),
      GoRoute(
          path: '/auth/login',
          name: 'login',
          builder: (context, state) => const LoginScreen()),
      GoRoute(
          path: '/auth/register',
          name: 'register',
          builder: (context, state) => const RegisterScreen()),
      GoRoute(
          path: '/product/:id',
          name: 'productDetail',
          builder: (context, state) =>
              ProductDetailScreen(productId: state.pathParameters['id']!)),
      GoRoute(
        path: '/spin',
        name: 'spin',
        builder: (context, state) => const SpinWheelScreen(),
      ),
      GoRoute(
        path: '/seller',
        name: 'seller',
        builder: (context, state) => const SellerDashboardScreen(),
      ),
      GoRoute(
        path: '/admin',
        name: 'admin',
        builder: (context, state) => const AdminShell(),
      ),
      GoRoute(
        path: '/store/:sellerId',
        name: 'store',
        builder: (context, state) => StorePageScreen(
          sellerId: state.pathParameters['sellerId']!,
        ),
      ),
      ShellRoute(
        builder: (context, state, child) => MainShell(child: child),
        routes: [
          GoRoute(
              path: '/home',
              name: 'home',
              builder: (context, state) => const HomeScreen()),
          GoRoute(
              path: '/products',
              name: 'products',
              builder: (context, state) => const ProductsScreen()),
          GoRoute(
              path: '/cart',
              name: 'cart',
              builder: (context, state) => const CartScreen()),
          GoRoute(
              path: '/profile',
              name: 'profile',
              builder: (context, state) => const ProfileScreen()),
          GoRoute(
            path: '/checkout',
            name: 'checkout',
            builder: (context, state) => const CheckoutScreen(),
          ),
          GoRoute(
              path: '/orders',
              name: 'orders',
              builder: (context, state) => const OrdersScreen()),
          GoRoute(
              path: '/payment',
              name: 'payment',
              builder: (context, state) => const PaymentScreen()),
        ],
      ),
    ],
    errorBuilder: (context, state) => const NotFoundScreen(),
  );
}

/// Notifier that tells GoRouter to re-evaluate redirects when auth changes.
/// Wire this up in main.dart by calling RouterNotifier().attachTo(authProvider).
class RouterNotifier extends ChangeNotifier {
  static final RouterNotifier _instance = RouterNotifier._internal();
  factory RouterNotifier() => _instance;
  RouterNotifier._internal();

  /// Call this once in main.dart after providers are ready.
  void attachTo(AuthProvider auth) {
    auth.addListener(notifyListeners);
  }
}

class NotFoundScreen extends StatelessWidget {
  const NotFoundScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.darkGrey,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline,
                size: 80, color: AppTheme.primaryRed),
            const SizedBox(height: 30),
            Text('404',
                style: GoogleFonts.orbitron(
                    fontSize: 48,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.primaryRed)),
            const SizedBox(height: 10),
            Text('Page Not Found',
                style: GoogleFonts.poppins(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.white)),
            const SizedBox(height: 40),
            ElevatedButton(
              onPressed: () => context.go('/home'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primaryRed,
                foregroundColor: Colors.white,
                padding:
                    const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30)),
              ),
              child: const Text('Go Home'),
            ),
          ],
        ),
      ),
    );
  }
}
