import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/constants/app_constants.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../../providers/equipment_provider.dart';
import '../../widgets/empty_state_view.dart';
import '../../widgets/equipment_card.dart';
import '../../widgets/shimmer_placeholder.dart';
import 'filter_bottom_sheet.dart';

class ExploreScreen extends ConsumerStatefulWidget {
  const ExploreScreen({super.key});

  @override
  ConsumerState<ExploreScreen> createState() => _ExploreScreenState();
}

class _ExploreScreenState extends ConsumerState<ExploreScreen> {
  final _searchController = TextEditingController();
  final _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _searchController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >= _scrollController.position.maxScrollExtent - 200) {
      ref.read(equipmentNotifierProvider.notifier).loadMore();
    }
  }

  void _openFilterSheet() {
    final notifier = ref.read(equipmentNotifierProvider.notifier);
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => FilterBottomSheet(
        initialFilter: notifier.filter,
        onApply: (updated) {
          notifier.setFilters(updated);
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(equipmentNotifierProvider);
    final notifier = ref.read(equipmentNotifierProvider.notifier);
    final filter = notifier.filter;

    final hasActiveFilters = filter.category != null ||
        filter.listingType != null ||
        filter.condition != null ||
        filter.minPrice != null ||
        filter.maxPrice != null;

    return Scaffold(
      backgroundColor: AppColors.warmOffWhite,
      appBar: AppBar(
        title: Text('Discover Equipment', style: AppTypography.headlineLarge),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            tooltip: 'Post Equipment',
            onPressed: () => context.push('/equipment/create'),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: Column(
        children: [
          // Search & Filter Bar
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
            child: Row(
              children: [
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      color: AppColors.pureWhite,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppColors.border),
                    ),
                    child: TextField(
                      controller: _searchController,
                      style: AppTypography.bodyLarge,
                      decoration: InputDecoration(
                        hintText: 'Search equipment or keywords...',
                        prefixIcon: const Icon(Icons.search, size: 20, color: AppColors.secondaryText),
                        suffixIcon: _searchController.text.isNotEmpty
                            ? IconButton(
                                icon: const Icon(Icons.clear, size: 18),
                                onPressed: () {
                                  _searchController.clear();
                                  notifier.setSearch('');
                                },
                              )
                            : null,
                        border: InputBorder.none,
                        enabledBorder: InputBorder.none,
                        focusedBorder: InputBorder.none,
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      ),
                      onSubmitted: (query) => notifier.setSearch(query),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                // Filter Button with active indicator
                Stack(
                  children: [
                    IconButton.filledTonal(
                      icon: const Icon(Icons.tune, color: AppColors.deepForest),
                      style: IconButton.styleFrom(
                        backgroundColor: hasActiveFilters ? AppColors.softSage : AppColors.pureWhite,
                        side: const BorderSide(color: AppColors.border),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      onPressed: _openFilterSheet,
                    ),
                    if (hasActiveFilters)
                      Positioned(
                        top: 6,
                        right: 6,
                        child: Container(
                          width: 8,
                          height: 8,
                          decoration: const BoxDecoration(
                            color: AppColors.deepForest,
                            shape: BoxShape.circle,
                          ),
                        ),
                      ),
                  ],
                ),
              ],
            ),
          ),

          // Categories Horizontal Filter Bar
          SizedBox(
            height: 44,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 20),
              itemCount: AppConstants.categories.length + 1,
              separatorBuilder: (context, index) => const SizedBox(width: 8),
              itemBuilder: (context, index) {
                if (index == 0) {
                  final isAll = filter.category == null;
                  return ChoiceChip(
                    label: const Text('All Domains'),
                    selected: isAll,
                    selectedColor: AppColors.softSage,
                    backgroundColor: AppColors.pureWhite,
                    side: const BorderSide(color: AppColors.border),
                    onSelected: (_) => notifier.setCategory(null),
                  );
                }
                final cat = AppConstants.categories[index - 1];
                final isSelected = filter.category == cat['id'];
                return ChoiceChip(
                  label: Text(cat['label']!),
                  selected: isSelected,
                  selectedColor: AppColors.softSage,
                  backgroundColor: AppColors.pureWhite,
                  side: const BorderSide(color: AppColors.border),
                  onSelected: (_) => notifier.setCategory(cat['id']),
                );
              },
            ),
          ),

          // Results counter & active filter badges
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 6),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '${state.total} ${state.total == 1 ? 'instrument' : 'instruments'} available',
                  style: AppTypography.labelMedium.copyWith(color: AppColors.secondaryText),
                ),
                if (hasActiveFilters)
                  GestureDetector(
                    onTap: () {
                      _searchController.clear();
                      notifier.resetFilters();
                    },
                    child: Text(
                      'Clear filters',
                      style: AppTypography.labelSmall.copyWith(
                        color: AppColors.deepForest,
                        decoration: TextDecoration.underline,
                      ),
                    ),
                  ),
              ],
            ),
          ),

          // Equipment List Grid
          Expanded(
            child: RefreshIndicator(
              onRefresh: () async => notifier.fetchEquipment(isRefresh: true),
              child: state.isLoading
                  ? const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                      child: EquipmentGridSkeleton(count: 4),
                    )
                  : state.items.isEmpty
                      ? EmptyStateView(
                          icon: Icons.search_off,
                          title: 'No matching equipment found',
                          description:
                              'Try adjusting your search criteria, widening price limits, or clearing category filters.',
                          buttonText: 'Reset Filters',
                          onButtonPressed: () {
                            _searchController.clear();
                            notifier.resetFilters();
                          },
                        )
                      : ListView.separated(
                          controller: _scrollController,
                          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                          itemCount: state.items.length + (state.isMoreLoading ? 1 : 0),
                          separatorBuilder: (context, index) => const SizedBox(height: 16),
                          itemBuilder: (context, index) {
                            if (index >= state.items.length) {
                              return const Center(
                                child: Padding(
                                  padding: EdgeInsets.all(16),
                                  child: CircularProgressIndicator(strokeWidth: 2),
                                ),
                              );
                            }
                            final item = state.items[index];
                            return EquipmentCard(
                              equipment: item,
                              onTap: () => context.push('/equipment/${item.id}'),
                            );
                          },
                        ),
            ),
          ),
        ],
      ),
    );
  }
}
