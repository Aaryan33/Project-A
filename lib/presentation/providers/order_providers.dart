import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/models/order_model.dart';
import '../../domain/models/audit_log_model.dart';
import '../../domain/models/filter_options.dart';
import '../../domain/repositories/i_order_repository.dart';
import '../../data/repositories/order_repository_impl.dart';
import 'filter_providers.dart';

final orderRepositoryProvider = Provider<IOrderRepository>((ref) {
  return OrderRepositoryImpl();
});

final ordersStreamProvider = StreamProvider<List<OrderModel>>((ref) {
  final repo = ref.watch(orderRepositoryProvider);
  return repo.getOrdersStream();
});

final auditLogsStreamProvider = StreamProvider<List<AuditLogModel>>((ref) {
  final repo = ref.watch(orderRepositoryProvider);
  return repo.getAuditLogsStream();
});

/// Filtered Orders computed based on user active filters & search query
final filteredOrdersProvider = Provider<List<OrderModel>>((ref) {
  final ordersAsync = ref.watch(ordersStreamProvider);
  final filters = ref.watch(filterProvider);

  return ordersAsync.when(
    data: (orders) {
      List<OrderModel> list = List.from(orders);

      // Search Query filter (Vehicle, Customer, Destination, Material, Company, Date)
      if (filters.searchQuery.trim().isNotEmpty) {
        final query = filters.searchQuery.toLowerCase().trim();
        list = list.where((o) {
          final v = o.vehicleNumber.toLowerCase();
          final c = o.toLocation.toLowerCase();
          final f = o.fromLocation.toLowerCase();
          final m = o.material.toLowerCase();
          final comp = o.company.toLowerCase();
          final remarks = (o.remarks ?? '').toLowerCase();

          return v.contains(query) ||
              c.contains(query) ||
              f.contains(query) ||
              m.contains(query) ||
              comp.contains(query) ||
              remarks.contains(query);
        }).toList();
      }

      // Material filter
      if (filters.material != null && filters.material!.isNotEmpty) {
        list = list.where((o) => o.material.toUpperCase() == filters.material!.toUpperCase()).toList();
      }

      // Vehicle filter
      if (filters.vehicleNumber != null && filters.vehicleNumber!.isNotEmpty) {
        list = list.where((o) => o.vehicleNumber.trim().toLowerCase() == filters.vehicleNumber!.trim().toLowerCase()).toList();
      }

      // Company filter
      if (filters.company != null && filters.company!.isNotEmpty) {
        list = list.where((o) => o.company == filters.company).toList();
      }

      // From/To Location filter
      if (filters.fromLocation != null && filters.fromLocation!.isNotEmpty) {
        list = list.where((o) => o.fromLocation.toLowerCase().contains(filters.fromLocation!.toLowerCase())).toList();
      }
      if (filters.toLocation != null && filters.toLocation!.isNotEmpty) {
        list = list.where((o) => o.toLocation.toLowerCase().contains(filters.toLocation!.toLowerCase())).toList();
      }

      // Status filter
      if (filters.status != null && filters.status!.isNotEmpty) {
        list = list.where((o) => o.status == filters.status).toList();
      }

      // Expense Category filter
      if (filters.expenseCategory != null && filters.expenseCategory!.isNotEmpty) {
        if (filters.expenseCategory == 'ALL_EXPENSES') {
          list = list.where((o) => o.totalExpense > 0 || (o.expenses != null && o.expenses!.isNotEmpty)).toList();
        } else {
          final cat = filters.expenseCategory!;
          list = list.where((o) {
            if (o.expenseBreakdown.containsKey(cat) && (o.expenseBreakdown[cat] ?? 0) > 0) {
              return true;
            }
            if (o.expenses != null && o.expenses!.toLowerCase().contains(cat.toLowerCase())) {
              return true;
            }
            return false;
          }).toList();
        }
      }

      // Date Range Presets
      final now = DateTime.now();
      switch (filters.datePreset) {
        case DateRangePreset.today:
          list = list.where((o) => o.date.year == now.year && o.date.month == now.month && o.date.day == now.day).toList();
          break;
        case DateRangePreset.yesterday:
          final yest = now.subtract(const Duration(days: 1));
          list = list.where((o) => o.date.year == yest.year && o.date.month == yest.month && o.date.day == yest.day).toList();
          break;
        case DateRangePreset.thisWeek:
          final weekAgo = now.subtract(const Duration(days: 7));
          list = list.where((o) => o.date.isAfter(weekAgo)).toList();
          break;
        case DateRangePreset.thisMonth:
          list = list.where((o) => o.date.year == now.year && o.date.month == now.month).toList();
          break;
        case DateRangePreset.lastMonth:
          final lastMonthDate = DateTime(now.year, now.month - 1);
          list = list.where((o) => o.date.year == lastMonthDate.year && o.date.month == lastMonthDate.month).toList();
          break;
        case DateRangePreset.customRange:
          if (filters.startDate != null) {
            list = list.where((o) => o.date.isAfter(filters.startDate!.subtract(const Duration(days: 1)))).toList();
          }
          if (filters.endDate != null) {
            list = list.where((o) => o.date.isBefore(filters.endDate!.add(const Duration(days: 1)))).toList();
          }
          break;
        case DateRangePreset.all:
        default:
          break;
      }

      // Sort
      switch (filters.sortBy) {
        case SortOption.newest:
          list.sort((a, b) => b.date.compareTo(a.date));
          break;
        case SortOption.oldest:
          list.sort((a, b) => a.date.compareTo(b.date));
          break;
        case SortOption.highestQuantity:
          list.sort((a, b) => b.quantity.compareTo(a.quantity));
          break;
        case SortOption.lowestQuantity:
          list.sort((a, b) => a.quantity.compareTo(b.quantity));
          break;
      }

      return list;
    },
    loading: () => [],
    error: (_, __) => [],
  );
});




// --------------- old code version --------------- 

// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import '../../domain/models/order_model.dart';
// import '../../domain/models/audit_log_model.dart';
// import '../../domain/models/filter_options.dart';
// import '../../domain/repositories/i_order_repository.dart';
// import '../../data/repositories/order_repository_impl.dart';
// import 'filter_providers.dart';

// final orderRepositoryProvider = Provider<IOrderRepository>((ref) {
//   return OrderRepositoryImpl();
// });

// final ordersStreamProvider = StreamProvider<List<OrderModel>>((ref) {
//   final repo = ref.watch(orderRepositoryProvider);
//   return repo.getOrdersStream();
// });

// final auditLogsStreamProvider = StreamProvider<List<AuditLogModel>>((ref) {
//   final repo = ref.watch(orderRepositoryProvider);
//   return repo.getAuditLogsStream();
// });

// /// Filtered Orders computed based on user active filters & search query
// final filteredOrdersProvider = Provider<List<OrderModel>>((ref) {
//   final ordersAsync = ref.watch(ordersStreamProvider);
//   final filters = ref.watch(filterProvider);

//   return ordersAsync.when(
//     data: (orders) {
//       List<OrderModel> list = List.from(orders);

//       // Search Query filter (Vehicle, Customer, Destination, Material, Company, Date)
//       if (filters.searchQuery.trim().isNotEmpty) {
//         final query = filters.searchQuery.toLowerCase().trim();
//         list = list.where((o) {
//           final v = o.vehicleNumber.toLowerCase();
//           final c = o.toLocation.toLowerCase();
//           final f = o.fromLocation.toLowerCase();
//           final m = o.material.toLowerCase();
//           final comp = o.company.toLowerCase();
//           final remarks = (o.remarks ?? '').toLowerCase();

//           return v.contains(query) ||
//               c.contains(query) ||
//               f.contains(query) ||
//               m.contains(query) ||
//               comp.contains(query) ||
//               remarks.contains(query);
//         }).toList();
//       }

//       // Material filter
//       if (filters.material != null && filters.material!.isNotEmpty) {
//         list = list.where((o) => o.material.toUpperCase() == filters.material!.toUpperCase()).toList();
//       }

//       // Vehicle filter
//       if (filters.vehicleNumber != null && filters.vehicleNumber!.isNotEmpty) {
//         list = list.where((o) => o.vehicleNumber.trim().toLowerCase() == filters.vehicleNumber!.trim().toLowerCase()).toList();
//       }

//       // Company filter
//       if (filters.company != null && filters.company!.isNotEmpty) {
//         list = list.where((o) => o.company == filters.company).toList();
//       }

//       // From/To Location filter
//       if (filters.fromLocation != null && filters.fromLocation!.isNotEmpty) {
//         list = list.where((o) => o.fromLocation.toLowerCase().contains(filters.fromLocation!.toLowerCase())).toList();
//       }
//       if (filters.toLocation != null && filters.toLocation!.isNotEmpty) {
//         list = list.where((o) => o.toLocation.toLowerCase().contains(filters.toLocation!.toLowerCase())).toList();
//       }

//       // Status filter
//       if (filters.status != null && filters.status!.isNotEmpty) {
//         list = list.where((o) => o.status == filters.status).toList();
//       }

//       // Date Range Presets
//       final now = DateTime.now();
//       switch (filters.datePreset) {
//         case DateRangePreset.today:
//           list = list.where((o) => o.date.year == now.year && o.date.month == now.month && o.date.day == now.day).toList();
//           break;
//         case DateRangePreset.yesterday:
//           final yest = now.subtract(const Duration(days: 1));
//           list = list.where((o) => o.date.year == yest.year && o.date.month == yest.month && o.date.day == yest.day).toList();
//           break;
//         case DateRangePreset.thisWeek:
//           final weekAgo = now.subtract(const Duration(days: 7));
//           list = list.where((o) => o.date.isAfter(weekAgo)).toList();
//           break;
//         case DateRangePreset.thisMonth:
//           list = list.where((o) => o.date.year == now.year && o.date.month == now.month).toList();
//           break;
//         case DateRangePreset.lastMonth:
//           final lastMonthDate = DateTime(now.year, now.month - 1);
//           list = list.where((o) => o.date.year == lastMonthDate.year && o.date.month == lastMonthDate.month).toList();
//           break;
//         case DateRangePreset.customRange:
//           if (filters.startDate != null) {
//             list = list.where((o) => o.date.isAfter(filters.startDate!.subtract(const Duration(days: 1)))).toList();
//           }
//           if (filters.endDate != null) {
//             list = list.where((o) => o.date.isBefore(filters.endDate!.add(const Duration(days: 1)))).toList();
//           }
//           break;
//         case DateRangePreset.all:
//         default:
//           break;
//       }

//       // Sort
//       switch (filters.sortBy) {
//         case SortOption.newest:
//           list.sort((a, b) => b.date.compareTo(a.date));
//           break;
//         case SortOption.oldest:
//           list.sort((a, b) => a.date.compareTo(b.date));
//           break;
//         case SortOption.highestQuantity:
//           list.sort((a, b) => b.quantity.compareTo(a.quantity));
//           break;
//         case SortOption.lowestQuantity:
//           list.sort((a, b) => a.quantity.compareTo(b.quantity));
//           break;
//       }

//       return list;
//     },
//     loading: () => [],
//     error: (_, __) => [],
//   );
// });
