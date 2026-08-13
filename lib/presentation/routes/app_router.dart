import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/auth_provider.dart';
import '../screens/login_screen.dart';
import '../screens/dashboard_screen.dart';
import '../screens/orders_list_screen.dart';
import '../screens/product_orders_screen.dart';
import '../screens/add_edit_order_screen.dart';
import '../screens/order_details_screen.dart';
import '../screens/analytics_screen.dart';
import '../screens/notifications_screen.dart';
import '../screens/excel_import_export_screen.dart';
import '../screens/settings_screen.dart';

final routerProvider = Provider<GoRouter>((ref) {
  final authState = ref.watch(authProvider);

  return GoRouter(
    initialLocation: '/',
    redirect: (context, state) {
      final isLoggedIn = authState.isAuthenticated;
      final isLoggingIn = state.matchedLocation == '/login';

      if (!isLoggedIn && !isLoggingIn) return '/login';
      if (isLoggedIn && isLoggingIn) return '/';
      return null;
    },
    routes: [
      GoRoute(
        path: '/login',
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: '/',
        builder: (context, state) => const DashboardScreen(),
      ),
      GoRoute(
        path: '/orders',
        builder: (context, state) {
          final preset = state.uri.queryParameters['preset'];
          return OrdersListScreen(initialPreset: preset);
        },
      ),
      GoRoute(
        path: '/product-orders/:product',
        builder: (context, state) {
          final product = state.pathParameters['product'] ?? 'FLYASH';
          return ProductOrdersScreen(productName: product);
        },
      ),
      GoRoute(
        path: '/add-order',
        builder: (context, state) => const AddEditOrderScreen(),
      ),
      GoRoute(
        path: '/edit-order/:id',
        builder: (context, state) {
          final id = state.pathParameters['id'];
          return AddEditOrderScreen(orderId: id);
        },
      ),
      GoRoute(
        path: '/order-details/:id',
        builder: (context, state) {
          final id = state.pathParameters['id'] ?? '';
          return OrderDetailsScreen(orderId: id);
        },
      ),
      GoRoute(
        path: '/analytics',
        builder: (context, state) => const AnalyticsScreen(),
      ),
      GoRoute(
        path: '/notifications',
        builder: (context, state) => const NotificationsScreen(),
      ),
      GoRoute(
        path: '/excel-import-export',
        builder: (context, state) => const ExcelImportExportScreen(),
      ),
      GoRoute(
        path: '/settings',
        builder: (context, state) => const SettingsScreen(),
      ),
    ],
  );
});
