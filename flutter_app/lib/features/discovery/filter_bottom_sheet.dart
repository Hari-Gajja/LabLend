import 'package:flutter/material.dart';
import '../../core/constants/app_constants.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../../providers/equipment_provider.dart';
import '../../widgets/app_button.dart';

class FilterBottomSheet extends StatefulWidget {
  final EquipmentFilterState initialFilter;
  final void Function(EquipmentFilterState) onApply;

  const FilterBottomSheet({
    super.key,
    required this.initialFilter,
    required this.onApply,
  });

  @override
  State<FilterBottomSheet> createState() => _FilterBottomSheetState();
}

class _FilterBottomSheetState extends State<FilterBottomSheet> {
  late String? _selectedCategory;
  late String? _selectedListingType;
  late String? _selectedCondition;
  late String _sort;
  RangeValues _priceRange = const RangeValues(0, 50000);

  @override
  void initState() {
    super.initState();
    _selectedCategory = widget.initialFilter.category;
    _selectedListingType = widget.initialFilter.listingType;
    _selectedCondition = widget.initialFilter.condition;
    _sort = widget.initialFilter.sort;

    final min = widget.initialFilter.minPrice?.toDouble() ?? 0;
    final max = widget.initialFilter.maxPrice?.toDouble() ?? 50000;
    _priceRange = RangeValues(min, max);
  }

  void _reset() {
    setState(() {
      _selectedCategory = null;
      _selectedListingType = null;
      _selectedCondition = null;
      _sort = 'newest';
      _priceRange = const RangeValues(0, 50000);
    });
  }

  void _apply() {
    final updated = widget.initialFilter.copyWith(
      category: _selectedCategory,
      clearCategory: _selectedCategory == null,
      listingType: _selectedListingType,
      condition: _selectedCondition,
      sort: _sort,
      minPrice: _priceRange.start > 0 ? _priceRange.start : null,
      maxPrice: _priceRange.end < 50000 ? _priceRange.end : null,
    );
    widget.onApply(updated);
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.pureWhite,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: EdgeInsets.only(
        left: 20,
        right: 20,
        top: 16,
        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
      ),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            // Handle bar
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.border,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Header Row
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Filter & Sort', style: AppTypography.headlineMedium),
                TextButton(
                  onPressed: _reset,
                  child: Text(
                    'Reset all',
                    style: AppTypography.labelMedium.copyWith(color: AppColors.secondaryText),
                  ),
                ),
              ],
            ),
            const Divider(height: 24),

            // Sort By
            Text('Sort By', style: AppTypography.titleSmall),
            const SizedBox(height: 10),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                _buildSortChip('newest', 'Newest Listed'),
                _buildSortChip('price_asc', 'Price: Low to High'),
                _buildSortChip('price_desc', 'Price: High to Low'),
                _buildSortChip('popular', 'Most Requested'),
              ],
            ),
            const SizedBox(height: 20),

            // Listing Type
            Text('Transaction Type', style: AppTypography.titleSmall),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: _buildFilterOption(
                    title: 'All',
                    isSelected: _selectedListingType == null,
                    onTap: () => setState(() => _selectedListingType = null),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _buildFilterOption(
                    title: 'Rent',
                    isSelected: _selectedListingType == 'rent',
                    onTap: () => setState(() => _selectedListingType = 'rent'),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _buildFilterOption(
                    title: 'Buy',
                    isSelected: _selectedListingType == 'buy',
                    onTap: () => setState(() => _selectedListingType = 'buy'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // Categories
            Text('Equipment Domain', style: AppTypography.titleSmall),
            const SizedBox(height: 10),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: AppConstants.categories.map((cat) {
                final isSelected = _selectedCategory == cat['id'];
                return ChoiceChip(
                  label: Text(cat['label']!),
                  selected: isSelected,
                  selectedColor: AppColors.softSage,
                  backgroundColor: AppColors.warmOffWhite,
                  onSelected: (selected) {
                    setState(() {
                      _selectedCategory = selected ? cat['id'] : null;
                    });
                  },
                );
              }).toList(),
            ),
            const SizedBox(height: 20),

            // Price Range Slider
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Price Limit', style: AppTypography.titleSmall),
                Text(
                  '\$${_priceRange.start.toInt()} – \$${_priceRange.end.toInt()}',
                  style: AppTypography.labelMedium.copyWith(color: AppColors.deepForest),
                ),
              ],
            ),
            RangeSlider(
              values: _priceRange,
              min: 0,
              max: 50000,
              divisions: 50,
              activeColor: AppColors.deepForest,
              inactiveColor: AppColors.border,
              onChanged: (values) {
                setState(() => _priceRange = values);
              },
            ),
            const SizedBox(height: 24),

            // Apply Button
            AppButton(
              text: 'Apply Filters',
              width: double.infinity,
              onPressed: _apply,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSortChip(String value, String label) {
    final isSelected = _sort == value;
    return ChoiceChip(
      label: Text(label),
      selected: isSelected,
      selectedColor: AppColors.softSage,
      backgroundColor: AppColors.warmOffWhite,
      onSelected: (selected) {
        if (selected) setState(() => _sort = value);
      },
    );
  }

  Widget _buildFilterOption({
    required String title,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.softSage : AppColors.warmOffWhite,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: isSelected ? AppColors.mutedGreenAccent : AppColors.border,
          ),
        ),
        child: Center(
          child: Text(
            title,
            style: AppTypography.labelMedium.copyWith(
              color: isSelected ? AppColors.deepForest : AppColors.secondaryText,
              fontWeight: isSelected ? FontWeight.w700 : FontWeight.normal,
            ),
          ),
        ),
      ),
    );
  }
}
