import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/models/filter_options.dart';

class FilterNotifier extends StateNotifier<FilterOptions> {
  FilterNotifier() : super(FilterOptions());

  void applyFilters(FilterOptions options) {
    state = options;
  }

  void setSearchQuery(String query) {
    state = state.copyWith(searchQuery: query);
  }

  void setDatePreset(DateRangePreset preset, {DateTime? customStart, DateTime? customEnd}) {
    state = state.copyWith(
      datePreset: preset,
      startDate: customStart,
      endDate: customEnd,
    );
  }

  void setMaterial(String? material) {
    state = state.copyWith(material: material);
  }

  void setVehicle(String? vehicle) {
    state = state.copyWith(vehicleNumber: vehicle);
  }

  void setCompany(String? company) {
    state = state.copyWith(company: company);
  }

  void setFromLocation(String? from) {
    state = state.copyWith(fromLocation: from);
  }

  void setToLocation(String? to) {
    state = state.copyWith(toLocation: to);
  }

  void setStatus(String? status) {
    state = state.copyWith(status: status);
  }

  void setSortOption(SortOption sortBy) {
    state = state.copyWith(sortBy: sortBy);
  }

  void resetFilters() {
    state = FilterOptions(searchQuery: state.searchQuery);
  }
}

final filterProvider = StateNotifierProvider<FilterNotifier, FilterOptions>((ref) {
  return FilterNotifier();
});
