import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:provider/provider.dart';
import 'app/routes/app_router.dart';
import 'app/theme/app_theme.dart';
import 'providers/auth_provider.dart';
import 'providers/cart_provider.dart';
import 'providers/product_provider.dart';
import 'providers/wishlist_provider.dart';
import 'providers/notification_provider.dart';
import 'providers/user_data_provider.dart';
import 'providers/seller_provider.dart';
import 'services/user_storage_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Hive.initFlutter();
  await UserStorageService.init();
  runApp(const GameStopApp());
}

class GameStopApp extends StatelessWidget {
  const GameStopApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<AuthProvider>(
          create: (_) {
            final auth = AuthProvider();
            auth.init().then((_) => RouterNotifier().attachTo(auth));
            return auth;
          },
        ),
        ChangeNotifierProvider(create: (_) => CartProvider()),
        ChangeNotifierProvider(create: (_) => ProductProvider()),
        ChangeNotifierProvider(create: (_) => WishlistProvider()),
        ChangeNotifierProvider(create: (_) => NotificationProvider()),
        ChangeNotifierProvider(create: (_) => UserDataProvider()),
        ChangeNotifierProvider(create: (_) => SellerProvider()),
      ],
      child: Consumer<AuthProvider>(
        builder: (context, auth, _) {
          // When auth state changes, load/clear per-user data
          if (auth.isAuthenticated && auth.currentUser != null) {
            final uid = auth.currentUser!.id;
            final user = auth.currentUser!;
            Future.microtask(() {
              context.read<CartProvider>().loadForUser(uid);
              context.read<NotificationProvider>().loadForUser(uid);
              context.read<UserDataProvider>().loadForUser(uid);
              context.read<WishlistProvider>().loadForUser(uid);
              context.read<ProductProvider>().loadSellerProducts();
              // Load seller products if user is a seller
              if (user.role.name == 'seller') {
                context.read<SellerProvider>().loadForSeller(uid);
              }
            });
          } else if (!auth.isAuthenticated) {
            Future.microtask(() {
              context.read<CartProvider>().clearForLogout();
              context.read<NotificationProvider>().clearForLogout();
              context.read<UserDataProvider>().clearForLogout();
              context.read<WishlistProvider>().clearForLogout();
              context.read<SellerProvider>().clearForLogout();
            });
          }

          return MaterialApp.router(
            title: 'GameStop',
            debugShowCheckedModeBanner: false,
            theme: AppTheme.darkTheme,
            routerConfig: AppRouter.router,
          );
        },
      ),
    );
  }
}
