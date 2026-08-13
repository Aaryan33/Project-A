import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme/app_colors.dart';
import '../../core/constants/app_constants.dart';
import '../../domain/models/filter_options.dart';
import '../providers/filter_providers.dart';
import '../providers/order_providers.dart';

class FilterBottomSheet extends ConsumerStatefulWidget {
  const FilterBottomSheet({super.key});

  @override
  ConsumerState<FilterBottomSheet> createState() => _FilterBottomSheetState();
}

class _FilterBottomSheetState extends ConsumerState<FilterBottomSheet> {
  late FilterOptions _tempFilters;

  @override
  void initState() {
    super.initState();
    _tempFilters = ref.read(filterProvider);
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final ordersAsync = ref.watch(ordersStreamProvider);

    final vehicles = ordersAsync.maybeWhen(
      data: (orders) => orders.map((o) => o.vehicleNumber).where((v) => v.isNotEmpty).toSet().toList()..sort(),
      orElse: () => <String>[],
    );

    return Container(
      padding: EdgeInsets.only(
        left: 20,
        right: 20,
        top: 20,
        bottom: MediaQuery.of(context).viewInsets.bottom + 20,
      ),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkCard : AppColors.lightSurface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 16),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Advanced Filters',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
                ),
                TextButton(
                  onPressed: () {
                    setState(() {
                      _tempFilters = FilterOptions();
                    });
                  },
                  child: const Text('Reset All', style: TextStyle(color: AppColors.accentOrange)),
                ),
              ],
            ),
            const Divider(),

            _buildSectionHeader('DATE RANGE'),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                _buildPresetChip('All Time', DateRangePreset.all),
                _buildPresetChip('Today', DateRangePreset.today),
                _buildPresetChip('Yesterday', DateRangePreset.yesterday),
                _buildPresetChip('This Week', DateRangePreset.thisWeek),
                _buildPresetChip('This Month', DateRangePreset.thisMonth),
                _buildPresetChip('Last Month', DateRangePreset.lastMonth),
              ],
            ),
            const SizedBox(height: 16),

            _buildSectionHeader('VEHICLE NUMBER'),
            DropdownButtonFormField<String>(
              value: _tempFilters.vehicleNumber,
              isExpanded: true,
              decoration: InputDecoration(
                hintText: 'All Vehicles',
                isDense: true,
                contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                prefixIcon: const Icon(Icons.directions_bus_rounded, color: AppColors.accentOrange, size: 18),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
              items: [
                const DropdownMenuItem<String>(
                  value: null,
                  child: Text('All Vehicles', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                ),
                ...vehicles.map((v) {
                  return DropdownMenuItem<String>(
                    value: v,
                    child: Text(v, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                  );
                }),
              ],
              onChanged: (val) {
                setState(() {
                  _tempFilters = _tempFilters.copyWith(vehicleNumber: val);
                });
              },
            ),
            const SizedBox(height: 16),

            _buildSectionHeader('MATERIAL'),
            Wrap(
              spacing: 8,
              children: [
                _buildChip('All Materials', _tempFilters.material == null, () {
                  setState(() => _tempFilters = _tempFilters.copyWith(material: null));
                }),
                ...AppConstants.materials.map((m) {
                  return _buildChip(m, _tempFilters.material == m, () {
                    setState(() => _tempFilters = _tempFilters.copyWith(material: m));
                  });
                }),
              ],
            ),
            const SizedBox(height: 16),

            _buildSectionHeader('COMPANY'),
            Row(
              children: [
                Expanded(
                  child: _buildChip('All Companies', _tempFilters.company == null, () {
                    setState(() => _tempFilters = _tempFilters.copyWith(company: null));
                  }),
                ),
                ...AppConstants.companies.map((c) {
                  return Expanded(
                    child: Padding(
                      padding: const EdgeInsets.only(left: 8),
                      child: _buildChip(c, _tempFilters.company == c, () {
                        setState(() => _tempFilters = _tempFilters.copyWith(company: c));
                      }),
                    ),
                  );
                }),
              ],
            ),
            const SizedBox(height: 16),

            _buildSectionHeader('SORT BY'),
            Column(
              children: [
                RadioListTile<SortOption>(
                  title: const Text('Newest First', style: TextStyle(fontSize: 13)),
                  value: SortOption.newest,
                  groupValue: _tempFilters.sortBy,
                  activeColor: AppColors.accentOrange,
                  onChanged: (val) {
                    if (val != null) setState(() => _tempFilters = _tempFilters.copyWith(sortBy: val));
                  },
                ),
                RadioListTile<SortOption>(
                  title: const Text('Oldest First', style: TextStyle(fontSize: 13)),
                  value: SortOption.oldest,
                  groupValue: _tempFilters.sortBy,
                  activeColor: AppColors.accentOrange,
                  onChanged: (val) {
                    if (val != null) setState(() => _tempFilters = _tempFilters.copyWith(sortBy: val));
                  },
                ),
                RadioListTile<SortOption>(
                  title: const Text('Highest Quantity (Tonnage)', style: TextStyle(fontSize: 13)),
                  value: SortOption.highestQuantity,
                  groupValue: _tempFilters.sortBy,
                  activeColor: AppColors.accentOrange,
                  onChanged: (val) {
                    if (val != null) setState(() => _tempFilters = _tempFilters.copyWith(sortBy: val));
                  },
                ),
              ],
            ),
            const SizedBox(height: 20),

            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: () {
                  ref.read(filterProvider.notifier).applyFilters(_tempFilters);
                  Navigator.pop(context);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.accentOrange,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                ),
                child: const Text('Apply Filters', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        title,
        style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.accentOrange, letterSpacing: 0.8),
      ),
    );
  }

  Widget _buildPresetChip(String label, DateRangePreset preset) {
    final isSelected = _tempFilters.datePreset == preset;
    return ChoiceChip(
      label: Text(label),
      selected: isSelected,
      selectedColor: AppColors.accentOrange,
      labelStyle: TextStyle(
        color: isSelected ? Colors.white : null,
        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
        fontSize: 12,
      ),
      onSelected: (selected) {
        if (selected) {
          setState(() => _tempFilters = _tempFilters.copyWith(datePreset: preset));
        }
      },
    );
  }

  Widget _buildChip(String label, bool isSelected, VoidCallback onTap) {
    return ChoiceChip(
      label: Text(label),
      selected: isSelected,
      selectedColor: AppColors.royalBlue,
      labelStyle: TextStyle(
        color: isSelected ? Colors.white : null,
        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
        fontSize: 12,
      ),
      onSelected: (_) => onTap(),
    );
  }
}
