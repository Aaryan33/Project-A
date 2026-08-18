enum DateRangePreset {
  all,
  today,
  yesterday,
  thisWeek,
  thisMonth,
  lastMonth,
  customRange,
}

enum SortOption {
  newest,
  oldest,
  highestQuantity,
  lowestQuantity,
}

class FilterOptions {
  final DateRangePreset datePreset;
  final DateTime? startDate;
  final DateTime? endDate;
  final String? material;
  final String? vehicleNumber;
  final String? company;
  final String? fromLocation;
  final String? toLocation;
  final String? status;
  final String? expenseCategory;
  final String searchQuery;
  final SortOption sortBy;

  FilterOptions({
    this.datePreset = DateRangePreset.all,
    this.startDate,
    this.endDate,
    this.material,
    this.vehicleNumber,
    this.company,
    this.fromLocation,
    this.toLocation,
    this.status,
    this.expenseCategory,
    this.searchQuery = '',
    this.sortBy = SortOption.newest,
  });

  FilterOptions copyWith({
    DateRangePreset? datePreset,
    DateTime? startDate,
    DateTime? endDate,
    Object? material = _sentinel,
    Object? vehicleNumber = _sentinel,
    Object? company = _sentinel,
    Object? fromLocation = _sentinel,
    Object? toLocation = _sentinel,
    Object? status = _sentinel,
    Object? expenseCategory = _sentinel,
    String? searchQuery,
    SortOption? sortBy,
  }) {
    return FilterOptions(
      datePreset: datePreset ?? this.datePreset,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      material: material == _sentinel ? this.material : material as String?,
      vehicleNumber: vehicleNumber == _sentinel ? this.vehicleNumber : vehicleNumber as String?,
      company: company == _sentinel ? this.company : company as String?,
      fromLocation: fromLocation == _sentinel ? this.fromLocation : fromLocation as String?,
      toLocation: toLocation == _sentinel ? this.toLocation : toLocation as String?,
      status: status == _sentinel ? this.status : status as String?,
      expenseCategory: expenseCategory == _sentinel ? this.expenseCategory : expenseCategory as String?,
      searchQuery: searchQuery ?? this.searchQuery,
      sortBy: sortBy ?? this.sortBy,
    );
  }

  FilterOptions clearFilters() {
    return FilterOptions(
      searchQuery: searchQuery,
      sortBy: sortBy,
    );
  }

  bool get hasActiveFilters {
    return datePreset != DateRangePreset.all ||
        material != null ||
        vehicleNumber != null ||
        company != null ||
        fromLocation != null ||
        toLocation != null ||
        status != null ||
        expenseCategory != null;
  }
}

const Object _sentinel = Object();





// ----------- old code version --------------

// enum DateRangePreset {
//   all,
//   today,
//   yesterday,
//   thisWeek,
//   thisMonth,
//   lastMonth,
//   customRange,
// }

// enum SortOption {
//   newest,
//   oldest,
//   highestQuantity,
//   lowestQuantity,
// }

// class FilterOptions {
//   final DateRangePreset datePreset;
//   final DateTime? startDate;
//   final DateTime? endDate;
//   final String? material;
//   final String? vehicleNumber;
//   final String? company;
//   final String? fromLocation;
//   final String? toLocation;
//   final String? status;
//   final String searchQuery;
//   final SortOption sortBy;

//   FilterOptions({
//     this.datePreset = DateRangePreset.all,
//     this.startDate,
//     this.endDate,
//     this.material,
//     this.vehicleNumber,
//     this.company,
//     this.fromLocation,
//     this.toLocation,
//     this.status,
//     this.searchQuery = '',
//     this.sortBy = SortOption.newest,
//   });

//   FilterOptions copyWith({
//     DateRangePreset? datePreset,
//     DateTime? startDate,
//     DateTime? endDate,
//     Object? material = _sentinel,
//     Object? vehicleNumber = _sentinel,
//     Object? company = _sentinel,
//     Object? fromLocation = _sentinel,
//     Object? toLocation = _sentinel,
//     Object? status = _sentinel,
//     String? searchQuery,
//     SortOption? sortBy,
//   }) {
//     return FilterOptions(
//       datePreset: datePreset ?? this.datePreset,
//       startDate: startDate ?? this.startDate,
//       endDate: endDate ?? this.endDate,
//       material: material == _sentinel ? this.material : material as String?,
//       vehicleNumber: vehicleNumber == _sentinel ? this.vehicleNumber : vehicleNumber as String?,
//       company: company == _sentinel ? this.company : company as String?,
//       fromLocation: fromLocation == _sentinel ? this.fromLocation : fromLocation as String?,
//       toLocation: toLocation == _sentinel ? this.toLocation : toLocation as String?,
//       status: status == _sentinel ? this.status : status as String?,
//       searchQuery: searchQuery ?? this.searchQuery,
//       sortBy: sortBy ?? this.sortBy,
//     );
//   }

//   FilterOptions clearFilters() {
//     return FilterOptions(
//       searchQuery: searchQuery,
//       sortBy: sortBy,
//     );
//   }

//   bool get hasActiveFilters {
//     return datePreset != DateRangePreset.all ||
//         material != null ||
//         vehicleNumber != null ||
//         company != null ||
//         fromLocation != null ||
//         toLocation != null ||
//         status != null;
//   }
// }

// const Object _sentinel = Object();
