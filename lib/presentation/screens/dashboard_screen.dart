import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_colors.dart';
import '../../core/utils/date_formatter.dart';
import '../../domain/models/order_model.dart';
import '../providers/order_providers.dart';
import '../providers/auth_provider.dart';
import '../widgets/custom_app_bar.dart';
import '../widgets/kpi_card.dart';
import '../widgets/product_card.dart';
import '../widgets/order_card.dart';

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ordersAsync = ref.watch(ordersStreamProvider);
    final authState = ref.watch(authProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: const CustomAppBar(title: 'Dashboard'),
      body: ordersAsync.when(
        data: (orders) => _buildDashboardContent(context, ref, orders, authState, isDark),
        loading: () => const Center(child: CircularProgressIndicator(color: AppColors.accentOrange)),
        error: (err, stack) => Center(child: Text('Error loading orders: $err')),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push('/add-order'),
        icon: const Icon(Icons.add_rounded, size: 24),
        label: const Text('Add Order', style: TextStyle(fontWeight: FontWeight.bold)),
      ),
    );
  }

  Widget _buildDashboardContent(
    BuildContext context,
    WidgetRef ref,
    List<OrderModel> orders,
    AuthState authState,
    bool isDark,
  ) {
    final now = DateTime.now();

    // STRICTLY today's orders (matching exact year, month, and day)
    final todayOrdersList = orders.where((o) =>
        o.date.year == now.year && o.date.month == now.month && o.date.day == now.day).toList();

    final todayOrdersCount = todayOrdersList.length;
    final totalOrdersCount = orders.length;
    final totalQuantity = orders.fold<double>(0.0, (sum, o) => sum + o.quantity);

    final flyAshOrders = orders.where((o) => o.material.toUpperCase() == 'FLYASH').toList();
    final flyAshQty = flyAshOrders.fold<double>(0.0, (sum, o) => sum + o.quantity);

    final ggbsOrders = orders.where((o) => o.material.toUpperCase() == 'GGBS').toList();
    final ggbsQty = ggbsOrders.fold<double>(0.0, (sum, o) => sum + o.quantity);

    final cementOrders = orders.where((o) => o.material.toUpperCase() == 'CEMENT').toList();
    final cementQty = cementOrders.fold<double>(0.0, (sum, o) => sum + o.quantity);

    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Greeting Header ("Welcome back") & Live Sync Badge
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Welcome back',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w900,
                        color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
                      ),
                    ),
                    const SizedBox(height: 2),
                    const Text(
                      'UMIYA IMPEX | PNJ VENTURES',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: AppColors.accentOrange,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
            ],
          ),
          const SizedBox(height: 16),

          // Top 2 Cards: "Today's Orders" (Strictly Today) & "All Orders" (With Filters)
          Row(
            children: [
              Expanded(
                child: KpiCard(
                  title: "Today's Orders",
                  value: '$todayOrdersCount Trips',
                  subtitle: DateFormatter.formatDate(now),
                  icon: Icons.today_rounded,
                  iconColor: AppColors.royalBlue,
                  onTap: () => context.push('/orders?preset=today'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: KpiCard(
                  title: 'All Orders',
                  value: '$totalOrdersCount Trips',
                  subtitle: 'Total ${DateFormatter.formatQuantity(totalQuantity)}',
                  icon: Icons.receipt_long_rounded,
                  iconColor: AppColors.statusDelivered,
                  onTap: () => context.push('/orders?preset=all'),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // Products Category Section Header
          const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Products Category',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800),
              ),
              SizedBox(height: 2),
              Text(
                'Material-wise volume and trip statistics',
                style: TextStyle(fontSize: 11, color: AppColors.lightTextSecondary),
              ),
            ],
          ),
          const SizedBox(height: 10),

          // Fixed 3-Column Row for Fly Ash, GGBS, Cement (100% On-Screen, No Scrolling)
          Row(
            children: [
              Expanded(
                child: ProductCard(
                  name: 'Fly Ash',
                  icon: Icons.cloud_queue_rounded,
                  gradient: AppColors.flyAshGradient,
                  totalOrders: flyAshOrders.length,
                  totalQuantity: flyAshQty,
                  onViewDetails: () => context.push('/product-orders/FLYASH'),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: ProductCard(
                  name: 'GGBS',
                  icon: Icons.architecture_rounded,
                  gradient: AppColors.ggbsGradient,
                  totalOrders: ggbsOrders.length,
                  totalQuantity: ggbsQty,
                  onViewDetails: () => context.push('/product-orders/GGBS'),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: ProductCard(
                  name: 'Cement',
                  icon: Icons.domain_rounded,
                  gradient: AppColors.cementGradient,
                  totalOrders: cementOrders.length,
                  totalQuantity: cementQty,
                  onViewDetails: () => context.push('/product-orders/CEMENT'),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Recent Trip Activity Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Recent Trip Activity',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800),
              ),
              TextButton.icon(
                onPressed: () => context.push('/orders?preset=all'),
                icon: const Icon(Icons.arrow_forward_rounded, size: 14, color: AppColors.accentOrange),
                label: const Text('View All', style: TextStyle(color: AppColors.accentOrange, fontWeight: FontWeight.bold, fontSize: 12)),
              ),
            ],
          ),
          const SizedBox(height: 10),

          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: orders.length > 5 ? 5 : orders.length,
            itemBuilder: (context, index) {
              final order = orders[index];
              return OrderCard(
                order: order,
                onTap: () => context.push('/order-details/${order.id}'),
              );
            },
          ),
        ],
      ),
    );
  }
}
