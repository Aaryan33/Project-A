import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../core/theme/app_colors.dart';
import '../../core/utils/date_formatter.dart';
import '../../domain/models/order_model.dart';
import '../providers/order_providers.dart';
import '../widgets/custom_app_bar.dart';
import '../widgets/kpi_card.dart';

class AnalyticsScreen extends ConsumerWidget {
  const AnalyticsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ordersAsync = ref.watch(ordersStreamProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: const CustomAppBar(
        title: 'Reports & Business Analytics',
        showBackButton: true,
      ),
      body: ordersAsync.when(
        data: (orders) => _buildAnalyticsView(context, orders, isDark),
        loading: () => const Center(child: CircularProgressIndicator(color: AppColors.accentOrange)),
        error: (err, stack) => Center(child: Text('Error loading analytics: $err')),
      ),
    );
  }

  Widget _buildAnalyticsView(BuildContext context, List<OrderModel> orders, bool isDark) {
    final totalTrips = orders.length;
    final totalTonnage = orders.fold<double>(0.0, (sum, o) => sum + o.quantity);

    final flyAshQty = orders.where((o) => o.material.toUpperCase() == 'FLYASH').fold<double>(0.0, (sum, o) => sum + o.quantity);
    final ggbsQty = orders.where((o) => o.material.toUpperCase() == 'GGBS').fold<double>(0.0, (sum, o) => sum + o.quantity);
    final cementQty = orders.where((o) => o.material.toUpperCase() == 'CEMENT').fold<double>(0.0, (sum, o) => sum + o.quantity);

    final Map<String, double> customerTonnages = {};
    final Map<String, int> vehicleTrips = {};
    for (var o in orders) {
      customerTonnages[o.toLocation] = (customerTonnages[o.toLocation] ?? 0) + o.quantity;
      vehicleTrips[o.vehicleNumber] = (vehicleTrips[o.vehicleNumber] ?? 0) + 1;
    }

    String topCustomer = 'CEMECH SOLUTIONS';
    if (customerTonnages.isNotEmpty) {
      topCustomer = customerTonnages.entries.reduce((a, b) => a.value > b.value ? a : b).key;
    }

    String topVehicle = 'GJ-05-4500';
    if (vehicleTrips.isNotEmpty) {
      topVehicle = vehicleTrips.entries.reduce((a, b) => a.value > b.value ? a : b).key;
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      physics: const BouncingScrollPhysics(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Executive Performance KPI',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: KpiCard(
                  title: 'Total Trips Recorded',
                  value: '$totalTrips Trips',
                  icon: Icons.local_shipping_rounded,
                  iconColor: AppColors.royalBlue,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: KpiCard(
                  title: 'Total Tonnage Volume',
                  value: DateFormatter.formatQuantity(totalTonnage),
                  icon: Icons.scale_rounded,
                  iconColor: AppColors.statusDelivered,
                ),
              ),
            ],
          ),
          const SizedBox(height: 28),

          // Top Highlights Cards with Flexed Expanded layout
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: isDark ? AppColors.darkCard : AppColors.lightSurface,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: AppColors.accentOrange.withOpacity(0.4)),
            ),
            child: Row(
              children: [
                Expanded(child: _buildTopStat('TOP CUSTOMER', topCustomer, Icons.business_rounded, AppColors.royalBlue)),
                Container(width: 1, height: 40, color: Colors.grey.withOpacity(0.3)),
                Expanded(child: _buildTopStat('TOP VEHICLE', topVehicle, Icons.directions_bus_rounded, AppColors.accentOrange)),
                Container(width: 1, height: 40, color: Colors.grey.withOpacity(0.3)),
                Expanded(child: _buildTopStat('TOP MATERIAL', 'FLYASH', Icons.category_rounded, AppColors.statusDelivered)),
              ],
            ),
          ),
          const SizedBox(height: 28),

          const Text(
            'Material Distribution (Tonnage)',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          Container(
            height: 240,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: isDark ? AppColors.darkCard : AppColors.lightSurface,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: isDark ? AppColors.darkBorder : AppColors.lightBorder),
            ),
            child: Row(
              children: [
                Expanded(
                  child: PieChart(
                    PieChartData(
                      sectionsSpace: 4,
                      centerSpaceRadius: 40,
                      sections: [
                        PieChartSectionData(
                          color: AppColors.royalBlue,
                          value: flyAshQty,
                          title: '${((flyAshQty / (totalTonnage == 0 ? 1 : totalTonnage)) * 100).toStringAsFixed(0)}%',
                          radius: 50,
                          titleStyle: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
                        ),
                        PieChartSectionData(
                          color: AppColors.statusDelivered,
                          value: ggbsQty,
                          title: '${((ggbsQty / (totalTonnage == 0 ? 1 : totalTonnage)) * 100).toStringAsFixed(0)}%',
                          radius: 50,
                          titleStyle: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
                        ),
                        PieChartSectionData(
                          color: AppColors.accentOrange,
                          value: cementQty,
                          title: '${((cementQty / (totalTonnage == 0 ? 1 : totalTonnage)) * 100).toStringAsFixed(0)}%',
                          radius: 50,
                          titleStyle: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
                        ),
                      ],
                    ),
                  ),
                ),
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildLegendItem('Fly Ash', '${flyAshQty.toStringAsFixed(1)} MT', AppColors.royalBlue),
                    const SizedBox(height: 8),
                    _buildLegendItem('GGBS', '${ggbsQty.toStringAsFixed(1)} MT', AppColors.statusDelivered),
                    const SizedBox(height: 8),
                    _buildLegendItem('Cement', '${cementQty.toStringAsFixed(1)} MT', AppColors.accentOrange),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 28),

          const Text(
            'Vehicle Trip Frequency (Bar Chart)',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          Container(
            height: 240,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: isDark ? AppColors.darkCard : AppColors.lightSurface,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: isDark ? AppColors.darkBorder : AppColors.lightBorder),
            ),
            child: BarChart(
              BarChartData(
                alignment: BarChartAlignment.spaceAround,
                barTouchData: BarTouchData(enabled: true),
                titlesData: FlTitlesData(
                  show: true,
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (val, meta) {
                        final labels = ['4500', '8082', '3600', '8280', '6300', '7200'];
                        if (val.toInt() >= 0 && val.toInt() < labels.length) {
                          return Text(labels[val.toInt()], style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold));
                        }
                        return const Text('');
                      },
                    ),
                  ),
                  leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                ),
                gridData: const FlGridData(show: false),
                borderData: FlBorderData(show: false),
                barGroups: [
                  _makeBarGroup(0, 12, AppColors.royalBlue),
                  _makeBarGroup(1, 9, AppColors.accentOrange),
                  _makeBarGroup(2, 11, AppColors.statusDelivered),
                  _makeBarGroup(3, 8, AppColors.purpleAccent),
                  _makeBarGroup(4, 5, AppColors.cyanAccent),
                  _makeBarGroup(5, 4, Colors.amber),
                ],
              ),
            ),
          ),
          const SizedBox(height: 28),

          const Text(
            'Weekly Volume Trend (Line Chart)',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          Container(
            height: 220,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: isDark ? AppColors.darkCard : AppColors.lightSurface,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: isDark ? AppColors.darkBorder : AppColors.lightBorder),
            ),
            child: LineChart(
              LineChartData(
                gridData: const FlGridData(show: false),
                titlesData: const FlTitlesData(
                  rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                ),
                borderData: FlBorderData(show: false),
                lineBarsData: [
                  LineChartBarData(
                    spots: const [
                      FlSpot(1, 120),
                      FlSpot(2, 190),
                      FlSpot(3, 280),
                      FlSpot(4, 340),
                      FlSpot(5, 490),
                      FlSpot(6, 610),
                    ],
                    isCurved: true,
                    color: AppColors.accentOrange,
                    barWidth: 4,
                    belowBarData: BarAreaData(
                      show: true,
                      color: AppColors.accentOrange.withOpacity(0.15),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTopStat(String label, String value, IconData icon, Color color) {
    return Column(
      children: [
        Icon(icon, color: color, size: 20),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 12),
          textAlign: TextAlign.center,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        Text(
          label,
          style: const TextStyle(fontSize: 8, color: Colors.grey, fontWeight: FontWeight.bold),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildLegendItem(String title, String value, Color color) {
    return Row(
      children: [
        Container(width: 12, height: 12, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
        const SizedBox(width: 6),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
            Text(value, style: const TextStyle(fontSize: 10, color: Colors.grey)),
          ],
        ),
      ],
    );
  }

  BarChartGroupData _makeBarGroup(int x, double y, Color color) {
    return BarChartGroupData(
      x: x,
      barRods: [
        BarChartRodData(
          toY: y,
          color: color,
          width: 18,
          borderRadius: BorderRadius.circular(6),
        ),
      ],
    );
  }
}
