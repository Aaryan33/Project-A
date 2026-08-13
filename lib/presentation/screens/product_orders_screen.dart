import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_colors.dart';
import '../../core/utils/date_formatter.dart';
import '../providers/order_providers.dart';
import '../widgets/custom_app_bar.dart';
import '../widgets/order_card.dart';

class ProductOrdersScreen extends ConsumerWidget {
  final String productName;

  const ProductOrdersScreen({super.key, required this.productName});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ordersAsync = ref.watch(ordersStreamProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final normProduct = productName.toUpperCase();

    return Scaffold(
      appBar: CustomAppBar(
        title: '$normProduct Orders & Trips',
        showBackButton: true,
      ),
      body: ordersAsync.when(
        data: (orders) {
          final productOrders = orders.where((o) => o.material.toUpperCase() == normProduct).toList();
          final totalQty = productOrders.fold<double>(0.0, (sum, o) => sum + o.quantity);
          final umiyaTrips = productOrders.where((o) => o.company == 'UMIYA').length;
          final pnjTrips = productOrders.where((o) => o.company == 'PNJ').length;

          return SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: _getGradient(normProduct),
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: _getGradient(normProduct).first.withOpacity(0.4),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            '$normProduct MATERIAL',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 22,
                              fontWeight: FontWeight.w900,
                              letterSpacing: 0.5,
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              '${productOrders.length} TRIPS',
                              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'TOTAL VOLUME',
                                style: TextStyle(color: Colors.white.withOpacity(0.8), fontSize: 10, fontWeight: FontWeight.bold),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                DateFormatter.formatQuantity(totalQty),
                                style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w800),
                              ),
                            ],
                          ),
                          Row(
                            children: [
                              _buildMiniBadge('UMIYA', '$umiyaTrips trips'),
                              const SizedBox(width: 8),
                              _buildMiniBadge('PNJ', '$pnjTrips trips'),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'All $normProduct Trips (${productOrders.length})',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),

                if (productOrders.isEmpty)
                  Center(
                    child: Padding(
                      padding: const EdgeInsets.all(40),
                      child: Column(
                        children: [
                          Icon(Icons.inbox_rounded, size: 60, color: Colors.grey.shade400),
                          const SizedBox(height: 12),
                          Text('No orders found for $normProduct', style: const TextStyle(color: Colors.grey)),
                        ],
                      ),
                    ),
                  )
                else
                  ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: productOrders.length,
                    itemBuilder: (context, index) {
                      final order = productOrders[index];
                      return OrderCard(
                        order: order,
                        onTap: () => context.push('/order-details/${order.id}'),
                      );
                    },
                  ),
              ],
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator(color: AppColors.accentOrange)),
        error: (err, stack) => Center(child: Text('Error: $err')),
      ),
    );
  }

  Widget _buildMiniBadge(String label, String sub) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.25),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        children: [
          Text(label, style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)),
          Text(sub, style: TextStyle(color: Colors.white.withOpacity(0.8), fontSize: 9)),
        ],
      ),
    );
  }

  List<Color> _getGradient(String mat) {
    switch (mat) {
      case 'FLYASH':
        return AppColors.flyAshGradient;
      case 'GGBS':
        return AppColors.ggbsGradient;
      case 'CEMENT':
      default:
        return AppColors.cementGradient;
    }
  }
}
