import 'package:flutter/material.dart';
import '../../app/theme/app_theme.dart';

class OrdersScreen extends StatelessWidget {
  const OrdersScreen({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.darkGrey,
      appBar: AppBar(title: const Text('Orders'),
          backgroundColor: AppTheme.darkGrey),
      body: Center(child: Text('Orders coming soon',
          style: TextStyle(color: Colors.grey.shade400))),
    );
  }
}