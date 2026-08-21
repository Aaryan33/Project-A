import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_colors.dart';
import '../../core/constants/app_constants.dart';
import '../../core/utils/date_formatter.dart';
import '../../domain/models/filter_options.dart';
import '../providers/order_providers.dart';
import '../providers/filter_providers.dart';
import '../widgets/custom_app_bar.dart';
import '../widgets/order_card.dart';
import '../widgets/filter_bottom_sheet.dart';

class OrdersListScreen extends ConsumerStatefulWidget {
  final String? initialPreset;

  const OrdersListScreen({super.key, this.initialPreset});

  @override
  ConsumerState<OrdersListScreen> createState() => _OrdersListScreenState();
}

class _OrdersListScreenState extends ConsumerState<OrdersListScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (widget.initialPreset == 'today') {
        ref.read(filterProvider.notifier).resetFilters();
        ref.read(filterProvider.notifier).setDatePreset(DateRangePreset.today);
      } else if (widget.initialPreset == 'all') {
        ref.read(filterProvider.notifier).resetFilters();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final isTodayMode = widget.initialPreset == 'today';
    final filteredOrders = ref.watch(filteredOrdersProvider);
    final filterState = ref.watch(filterProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: CustomAppBar(
        title: isTodayMode ? "Today's Orders (${DateFormatter.formatDate(DateTime.now())})" : 'All Orders & Trip Records',
        showBackButton: true,
      ),
      body: Column(
        children: [
          // Banner Indicator for Today's Orders Mode
          if (isTodayMode)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              color: AppColors.royalBlue.withOpacity(0.12),
              child: Row(
                children: [
                  const Icon(Icons.today_rounded, size: 18, color: AppColors.royalBlue),
                  const SizedBox(width: 8),
                  Text(
                    "Showing Today's Trips strictly for ${DateFormatter.formatDate(DateTime.now())}",
                    style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.royalBlue),
                  ),
                ],
              ),
            ),

          // Search & Material Filter Chips Bar
          Container(
            padding: const EdgeInsets.all(16),
            color: isDark ? AppColors.darkCard : AppColors.lightSurface,
            child: Column(
              children: [
                TextField(
                  onChanged: (val) {
                    ref.read(filterProvider.notifier).setSearchQuery(val);
                  },
                  decoration: InputDecoration(
                    hintText: 'Search',
                    prefixIcon: const Icon(Icons.search_rounded, color: AppColors.accentOrange),
                    suffixIcon: filterState.searchQuery.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear_rounded, size: 18),
                            onPressed: () {
                              ref.read(filterProvider.notifier).setSearchQuery('');
                            },
                          )
                        : null,
                  ),
                ),
                if (!isTodayMode) ...[
                  const SizedBox(height: 12),

                  // Material Filter Chips Row + Filter Section Button right beside Cement chip!
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    physics: const BouncingScrollPhysics(),
                    child: Row(
                      children: [
                        _buildQuickChip(
                          ref,
                          label: 'All Materials',
                          isSelected: filterState.material == null,
                          onTap: () => ref.read(filterProvider.notifier).setMaterial(null),
                        ),
                        ...AppConstants.materials.map((m) {
                          return _buildQuickChip(
                            ref,
                            label: m,
                            isSelected: filterState.material == m,
                            onTap: () => ref.read(filterProvider.notifier).setMaterial(
                                  filterState.material == m ? null : m,
                                ),
                          );
                        }),
                        const SizedBox(width: 1),

                        // Filter Button right beside Cement chip
                        InkWell(
                          onTap: () {
                            showModalBottomSheet(
                              context: context,
                              isScrollControlled: true,
                              backgroundColor: Colors.transparent,
                              builder: (context) => const FilterBottomSheet(),
                            );
                          },
                          borderRadius: BorderRadius.circular(20),
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 7),
                            decoration: BoxDecoration(
                              color: filterState.hasActiveFilters
                                  ? AppColors.accentOrange
                                  : (isDark ? AppColors.slateNavy : Colors.blueGrey.shade50),
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                color: filterState.hasActiveFilters ? AppColors.accentOrange : AppColors.accentOrange.withOpacity(0.5),
                              ),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                // Icon(
                                //   Icons.tune_rounded,
                                //   size: 14,
                                //   color: filterState.hasActiveFilters ? Colors.white : AppColors.accentOrange,
                                // ),
                                // const SizedBox(width: 4),
                                Text(
                                  'Filter',
                                  style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.bold,
                                    color: filterState.hasActiveFilters ? Colors.white : AppColors.accentOrange,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),

          // Banner Indicator for Expense Filter Mode
          if (!isTodayMode && filterState.expenseCategory != null) ...[
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              color: AppColors.accentOrange.withOpacity(0.12),
              child: Row(
                children: [
                  const Icon(Icons.account_balance_wallet_rounded, size: 18, color: AppColors.accentOrange),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      filterState.expenseCategory == 'ALL_EXPENSES'
                          ? "Total Expenses (${filteredOrders.length} Trips): ₹${filteredOrders.fold<double>(0.0, (sum, o) => sum + o.totalExpense).toStringAsFixed(2)}"
                          : filterState.expenseCategory == 'Diesel (Litre)'
                              ? "Total Diesel Volume (${filteredOrders.length} Trips): ${filteredOrders.fold<double>(0.0, (sum, o) => sum + (o.expenseBreakdown['Diesel (Litre)'] ?? 0.0)).toStringAsFixed(0)} Litres"
                              : "Total ${filterState.expenseCategory} Expense (${filteredOrders.length} Trips): ₹${filteredOrders.fold<double>(0.0, (sum, o) => sum + (o.expenseBreakdown[filterState.expenseCategory!] ?? 0.0)).toStringAsFixed(2)}",
                      style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.accentOrange),
                    ),
                  ),
                ],
              ),
            ),
          ],

          // Orders Count & Reset Bar
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Showing ${filteredOrders.length} Trip Records',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                  ),
                ),
                if (!isTodayMode && filterState.hasActiveFilters)
                  TextButton.icon(
                    onPressed: () => ref.read(filterProvider.notifier).resetFilters(),
                    icon: const Icon(Icons.refresh_rounded, size: 14, color: AppColors.accentOrange),
                    label: const Text('Reset Filters', style: TextStyle(color: AppColors.accentOrange, fontSize: 12)),
                  ),
              ],
            ),
          ),

          // Orders List Stream
          Expanded(
            child: filteredOrders.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.search_off_rounded,
                          size: 56,
                          color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                        ),
                        const SizedBox(height: 12),
                        Text(
                          isTodayMode ? 'No orders recorded for today.' : 'No orders found matching filters.',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                            color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                          ),
                        ),
                        if (isTodayMode) ...[
                          const SizedBox(height: 16),
                          ElevatedButton.icon(
                            onPressed: () => context.push('/add-order'),
                            // icon: const Icon(Icons.add_rounded),
                            label: Text('Add Today Order', style: TextStyle(
                              fontSize: 15,
                              color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
                            ),),
                            style: ElevatedButton.styleFrom(backgroundColor: AppColors.accentOrange),
                          ),
                        ],
                      ],
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    itemCount: filteredOrders.length,
                    itemBuilder: (context, index) {
                      final order = filteredOrders[index];
                      return OrderCard(
                        order: order,
                        onTap: () => context.push('/order-details/${order.id}'),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickChip(
    WidgetRef ref, {
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return Padding(
      padding: const EdgeInsets.only(right: 4),
      child: FilterChip(
        label: Text(label),
        selected: isSelected,
        onSelected: (_) => onTap(),
        selectedColor: AppColors.accentOrange,
        labelStyle: TextStyle(
          color: isSelected ? Colors.white : AppColors.slateNavy,
          fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
          fontSize: 10,
        ),
        showCheckmark: false,
      ),
    );
  }
}






// ----------------- old code version -------------------

// import 'package:flutter/material.dart';
// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:go_router/go_router.dart';
// import '../../core/theme/app_colors.dart';
// import '../../core/constants/app_constants.dart';
// import '../../core/utils/date_formatter.dart';
// import '../../domain/models/filter_options.dart';
// import '../providers/order_providers.dart';
// import '../providers/filter_providers.dart';
// import '../widgets/custom_app_bar.dart';
// import '../widgets/order_card.dart';
// import '../widgets/filter_bottom_sheet.dart';

// class OrdersListScreen extends ConsumerStatefulWidget {
//   final String? initialPreset;

//   const OrdersListScreen({super.key, this.initialPreset});

//   @override
//   ConsumerState<OrdersListScreen> createState() => _OrdersListScreenState();
// }

// class _OrdersListScreenState extends ConsumerState<OrdersListScreen> {
//   @override
//   void initState() {
//     super.initState();
//     WidgetsBinding.instance.addPostFrameCallback((_) {
//       if (widget.initialPreset == 'today') {
//         ref.read(filterProvider.notifier).resetFilters();
//         ref.read(filterProvider.notifier).setDatePreset(DateRangePreset.today);
//       } else if (widget.initialPreset == 'all') {
//         ref.read(filterProvider.notifier).resetFilters();
//       }
//     });
//   }

//   @override
//   Widget build(BuildContext context) {
//     final isTodayMode = widget.initialPreset == 'today';
//     final filteredOrders = ref.watch(filteredOrdersProvider);
//     final filterState = ref.watch(filterProvider);
//     final isDark = Theme.of(context).brightness == Brightness.dark;

//     return Scaffold(
//       appBar: CustomAppBar(
//         title: isTodayMode ? "Today's Orders (${DateFormatter.formatDate(DateTime.now())})" : 'All Orders & Trip Records',
//         showBackButton: true,
//       ),
//       body: Column(
//         children: [
//           // Banner Indicator for Today's Orders Mode
//           if (isTodayMode)
//             Container(
//               width: double.infinity,
//               padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
//               color: AppColors.royalBlue.withOpacity(0.12),
//               child: Row(
//                 children: [
//                   const Icon(Icons.today_rounded, size: 18, color: AppColors.royalBlue),
//                   const SizedBox(width: 8),
//                   Text(
//                     "Showing Today's Trips strictly for ${DateFormatter.formatDate(DateTime.now())}",
//                     style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.royalBlue),
//                   ),
//                 ],
//               ),
//             ),

//           // Search & Material Filter Chips Bar
//           Container(
//             padding: const EdgeInsets.all(16),
//             color: isDark ? AppColors.darkCard : AppColors.lightSurface,
//             child: Column(
//               children: [
//                 TextField(
//                   onChanged: (val) {
//                     ref.read(filterProvider.notifier).setSearchQuery(val);
//                   },
//                   decoration: InputDecoration(
//                     hintText: 'Search vehicle, customer, destination...',
//                     prefixIcon: const Icon(Icons.search_rounded, color: AppColors.accentOrange),
//                     suffixIcon: filterState.searchQuery.isNotEmpty
//                         ? IconButton(
//                             icon: const Icon(Icons.clear_rounded, size: 18),
//                             onPressed: () {
//                               ref.read(filterProvider.notifier).setSearchQuery('');
//                             },
//                           )
//                         : null,
//                   ),
//                 ),
//                 if (!isTodayMode) ...[
//                   const SizedBox(height: 12),

//                   // Material Filter Chips Row + Filter Section Button right beside Cement chip!
//                   SingleChildScrollView(
//                     scrollDirection: Axis.horizontal,
//                     physics: const BouncingScrollPhysics(),
//                     child: Row(
//                       children: [
//                         _buildQuickChip(
//                           ref,
//                           label: 'All Materials',
//                           isSelected: filterState.material == null,
//                           onTap: () => ref.read(filterProvider.notifier).setMaterial(null),
//                         ),
//                         ...AppConstants.materials.map((m) {
//                           return _buildQuickChip(
//                             ref,
//                             label: m,
//                             isSelected: filterState.material == m,
//                             onTap: () => ref.read(filterProvider.notifier).setMaterial(
//                                   filterState.material == m ? null : m,
//                                 ),
//                           );
//                         }),
//                         const SizedBox(width: 4),

//                         // Filter Button right beside Cement chip
//                         InkWell(
//                           onTap: () {
//                             showModalBottomSheet(
//                               context: context,
//                               isScrollControlled: true,
//                               backgroundColor: Colors.transparent,
//                               builder: (context) => const FilterBottomSheet(),
//                             );
//                           },
//                           borderRadius: BorderRadius.circular(20),
//                           child: Container(
//                             padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
//                             decoration: BoxDecoration(
//                               color: filterState.hasActiveFilters
//                                   ? AppColors.accentOrange
//                                   : (isDark ? AppColors.slateNavy : Colors.blueGrey.shade100),
//                               borderRadius: BorderRadius.circular(20),
//                               border: Border.all(
//                                 color: filterState.hasActiveFilters ? AppColors.accentOrange : AppColors.accentOrange.withOpacity(0.5),
//                               ),
//                             ),
//                             child: Row(
//                               mainAxisSize: MainAxisSize.min,
//                               children: [
//                                 Icon(
//                                   Icons.tune_rounded,
//                                   size: 14,
//                                   color: filterState.hasActiveFilters ? Colors.white : AppColors.accentOrange,
//                                 ),
//                                 const SizedBox(width: 4),
//                                 Text(
//                                   'Filter',
//                                   style: TextStyle(
//                                     fontSize: 11,
//                                     fontWeight: FontWeight.bold,
//                                     color: filterState.hasActiveFilters ? Colors.white : AppColors.accentOrange,
//                                   ),
//                                 ),
//                               ],
//                             ),
//                           ),
//                         ),
//                       ],
//                     ),
//                   ),
//                 ],
//               ],
//             ),
//           ),

//           // Orders Count & Reset Bar
//           Padding(
//             padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
//             child: Row(
//               mainAxisAlignment: MainAxisAlignment.spaceBetween,
//               children: [
//                 Text(
//                   'Showing ${filteredOrders.length} Trip Records',
//                   style: TextStyle(
//                     fontSize: 12,
//                     fontWeight: FontWeight.bold,
//                     color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
//                   ),
//                 ),
//                 if (!isTodayMode && filterState.hasActiveFilters)
//                   TextButton.icon(
//                     onPressed: () => ref.read(filterProvider.notifier).resetFilters(),
//                     icon: const Icon(Icons.refresh_rounded, size: 14, color: AppColors.accentOrange),
//                     label: const Text('Reset Filters', style: TextStyle(color: AppColors.accentOrange, fontSize: 12)),
//                   ),
//               ],
//             ),
//           ),

//           // Orders List Stream
//           Expanded(
//             child: filteredOrders.isEmpty
//                 ? Center(
//                     child: Column(
//                       mainAxisAlignment: MainAxisAlignment.center,
//                       children: [
//                         Icon(
//                           Icons.search_off_rounded,
//                           size: 56,
//                           color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
//                         ),
//                         const SizedBox(height: 12),
//                         Text(
//                           isTodayMode ? 'No orders recorded for today yet.' : 'No orders found matching filters.',
//                           style: TextStyle(
//                             fontSize: 15,
//                             fontWeight: FontWeight.bold,
//                             color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
//                           ),
//                         ),
//                         if (isTodayMode) ...[
//                           const SizedBox(height: 16),
//                           ElevatedButton.icon(
//                             onPressed: () => context.push('/add-order'),
//                             icon: const Icon(Icons.add_rounded),
//                             label: const Text('Add Today Order'),
//                             style: ElevatedButton.styleFrom(backgroundColor: AppColors.accentOrange),
//                           ),
//                         ],
//                       ],
//                     ),
//                   )
//                 : ListView.builder(
//                     padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
//                     itemCount: filteredOrders.length,
//                     itemBuilder: (context, index) {
//                       final order = filteredOrders[index];
//                       return OrderCard(
//                         order: order,
//                         onTap: () => context.push('/order-details/${order.id}'),
//                       );
//                     },
//                   ),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildQuickChip(
//     WidgetRef ref, {
//     required String label,
//     required bool isSelected,
//     required VoidCallback onTap,
//   }) {
//     return Padding(
//       padding: const EdgeInsets.only(right: 8),
//       child: FilterChip(
//         label: Text(label),
//         selected: isSelected,
//         onSelected: (_) => onTap(),
//         selectedColor: AppColors.accentOrange,
//         labelStyle: TextStyle(
//           color: isSelected ? Colors.white : AppColors.slateNavy,
//           fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
//           fontSize: 11,
//         ),
//         showCheckmark: false,
//       ),
//     );
//   }
// }
