import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../../core/utils/formatters.dart';
import '../../models/equipment_model.dart';
import '../../providers/equipment_provider.dart';
import '../../widgets/empty_state_view.dart';
import '../../widgets/network_image_with_fallback.dart';
import '../../widgets/status_badge.dart';

class MyListingsScreen extends ConsumerWidget {
  const MyListingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final listingsAsync = ref.watch(myListingsProvider);

    return Scaffold(
      backgroundColor: AppColors.warmOffWhite,
      appBar: AppBar(
        title: Text('My Equipment Listings', style: AppTypography.headlineLarge),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            tooltip: 'Add Listing',
            onPressed: () => context.push('/equipment/create'),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: listingsAsync.when(
        data: (listings) {
          if (listings.isEmpty) {
            return EmptyStateView(
              icon: Icons.inventory_2_outlined,
              title: 'No equipment listed yet',
              description: 'Share your laboratory apparatus with peer institutions to support ongoing research.',
              buttonText: 'List New Equipment',
              onButtonPressed: () => context.push('/equipment/create'),
            );
          }

          return ListView.separated(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            itemCount: listings.length,
            separatorBuilder: (context, index) => const SizedBox(height: 16),
            itemBuilder: (context, index) {
              final item = listings[index];
              return _buildListingCard(context, ref, item);
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(
          child: Text('Failed to load listings: $e', style: AppTypography.bodyMedium),
        ),
      ),
    );
  }

  Widget _buildListingCard(BuildContext context, WidgetRef ref, EquipmentModel item) {
    final notifier = ref.read(myListingsProvider.notifier);

    return Container(
      decoration: BoxDecoration(
        color: AppColors.pureWhite,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(14),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: SizedBox(
                    width: 80,
                    height: 80,
                    child: NetworkImageWithFallback(imageUrl: item.coverImageUrl),
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(
                              color: AppColors.softSage,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              Formatters.getCategoryLabel(item.category),
                              style: AppTypography.labelSmall.copyWith(
                                color: AppColors.deepForest,
                                fontSize: 10,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                          StatusBadge(status: item.availability, isCompact: true),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Text(
                        item.title,
                        style: AppTypography.titleSmall,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        item.canRent
                            ? '${Formatters.formatCurrency(item.rentalPrice)} / ${item.rentalPricingUnit}'
                            : Formatters.formatCurrency(item.purchasePrice),
                        style: AppTypography.priceMedium.copyWith(fontSize: 14),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            child: Row(
              children: [
                TextButton.icon(
                  icon: Icon(
                    item.availability == 'available' ? Icons.pause_circle_outline : Icons.play_circle_outline,
                    size: 18,
                    color: AppColors.primaryInk,
                  ),
                  label: Text(
                    item.availability == 'available' ? 'Mark Maintenance' : 'Set Available',
                    style: AppTypography.labelSmall.copyWith(color: AppColors.primaryInk),
                  ),
                  onPressed: () => notifier.toggleAvailability(item.id, item.availability),
                ),
                const Spacer(),
                IconButton(
                  icon: const Icon(Icons.edit_outlined, size: 20, color: AppColors.secondaryText),
                  tooltip: 'Edit',
                  onPressed: () => context.push('/equipment/${item.id}/edit'),
                ),
                IconButton(
                  icon: const Icon(Icons.delete_outline, size: 20, color: AppColors.error),
                  tooltip: 'Delete',
                  onPressed: () => _confirmDelete(context, notifier, item.id),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _confirmDelete(BuildContext context, MyListingsNotifier notifier, String id) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Archive Listing?', style: AppTypography.headlineMedium),
        content: Text(
          'This instrument listing will be archived and removed from public search results.',
          style: AppTypography.bodyMedium,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              notifier.deleteListing(id);
              Navigator.of(ctx).pop();
            },
            child: Text('Archive', style: TextStyle(color: AppColors.error)),
          ),
        ],
      ),
    );
  }
}
