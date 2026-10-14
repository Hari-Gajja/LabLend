import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/constants/app_constants.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../../core/utils/formatters.dart';
import '../../models/equipment_model.dart';
import '../../providers/auth_provider.dart';
import '../../providers/equipment_provider.dart';
import '../../providers/notification_provider.dart';
import '../../widgets/editorial_header.dart';
import '../../widgets/equipment_card.dart';
import '../../widgets/network_image_with_fallback.dart';
import '../../widgets/shimmer_placeholder.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentUser = ref.watch(currentUserProvider);
    final featuredAsync = ref.watch(featuredEquipmentProvider);
    final recentAsync = ref.watch(recentEquipmentProvider);
    final unreadCount = ref.watch(notificationNotifierProvider).unreadCount;

    return Scaffold(
      backgroundColor: AppColors.warmOffWhite,
      appBar: AppBar(
        titleSpacing: 20,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'LABLEND',
              style: AppTypography.labelSmall.copyWith(
                color: AppColors.deepForest,
                letterSpacing: 1.2,
                fontWeight: FontWeight.w800,
              ),
            ),
            Text(
              currentUser != null
                  ? 'Hello, ${currentUser.fullName.split(' ').first}'
                  : 'Welcome to LabLend',
              style: AppTypography.headlineMedium,
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: unreadCount > 0
                ? Badge(
                    label: Text('$unreadCount'),
                    backgroundColor: AppColors.error,
                    child: const Icon(Icons.notifications_outlined),
                  )
                : const Icon(Icons.notifications_outlined),
            onPressed: () => context.push('/notifications'),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          ref.invalidate(featuredEquipmentProvider);
          ref.invalidate(recentEquipmentProvider);
        },
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Search Input Action Area
              GestureDetector(
                onTap: () => context.go('/explore'),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  decoration: BoxDecoration(
                    color: AppColors.pureWhite,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: AppColors.border),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.02),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.search, color: AppColors.secondaryText, size: 22),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'Search microscopes, centrifuges, specs...',
                          style: AppTypography.bodyMedium.copyWith(color: AppColors.tertiaryText),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: AppColors.warmOffWhite,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: AppColors.borderLight),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.tune, size: 14, color: AppColors.deepForest),
                            const SizedBox(width: 4),
                            Text(
                              'Filter',
                              style: AppTypography.labelSmall.copyWith(
                                color: AppColors.deepForest,
                                fontSize: 11,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Editorial Hero Panel (Loop & Tie style)
              featuredAsync.when(
                data: (featuredList) {
                  if (featuredList.isEmpty) return const SizedBox.shrink();
                  final item = featuredList.first;
                  return _buildHeroPanel(context, item);
                },
                loading: () => const AspectRatio(
                  aspectRatio: 16 / 10,
                  child: EquipmentCardSkeleton(),
                ),
                error: (err, stack) => const SizedBox.shrink(),
              ),
              const SizedBox(height: 28),

              // Categories Header & Horizontal Carousel
              EditorialHeader(
                title: 'Instrumentation',
                subtitle: 'Browse by laboratory domain and scientific function',
                actionText: 'View All',
                onActionTap: () => context.go('/explore'),
              ),
              const SizedBox(height: 12),
              _buildCategoryChips(context, ref),
              const SizedBox(height: 32),

              // Quick Actions Bar: Post Equipment & My Requests
              _buildQuickActions(context),
              const SizedBox(height: 32),

              // Recently Listed Equipment
              EditorialHeader(
                title: 'Available Instruments',
                subtitle: 'Recently listed by verified academic and research institutions',
                actionText: 'Explore',
                onActionTap: () => context.go('/explore'),
              ),
              const SizedBox(height: 12),
              recentAsync.when(
                data: (recentList) {
                  if (recentList.isEmpty) {
                    return Center(
                      child: Padding(
                        padding: const EdgeInsets.all(24),
                        child: Text(
                          'No equipment currently listed.',
                          style: AppTypography.bodyMedium,
                        ),
                      ),
                    );
                  }
                  return ListView.separated(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: recentList.length,
                    separatorBuilder: (context, index) => const SizedBox(height: 16),
                    itemBuilder: (context, index) {
                      final equip = recentList[index];
                      return EquipmentCard(
                        equipment: equip,
                        onTap: () => context.push('/equipment/${equip.id}'),
                      );
                    },
                  );
                },
                loading: () => const EquipmentGridSkeleton(count: 3),
                error: (e, _) => Center(
                  child: Text('Failed to load equipment: $e', style: AppTypography.bodyMedium),
                ),
              ),
              const SizedBox(height: 36),

              // Editorial "How LabLend Works" Section
              _buildHowItWorksSection(context),
              const SizedBox(height: 32),

              // Trust & Institution Verification Banner
              _buildTrustBanner(),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeroPanel(BuildContext context, EquipmentModel item) {
    return GestureDetector(
      onTap: () => context.push('/equipment/${item.id}'),
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.pureWhite,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AppColors.border),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 16,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        clipBehavior: Clip.antiAlias,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              children: [
                AspectRatio(
                  aspectRatio: 16 / 9,
                  child: NetworkImageWithFallback(
                    imageUrl: item.coverImageUrl,
                  ),
                ),
                Positioned(
                  top: 14,
                  left: 14,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(
                      color: AppColors.deepForest,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      'FEATURED APPARATUS',
                      style: AppTypography.labelSmall.copyWith(
                        color: AppColors.pureWhite,
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.6,
                      ),
                    ),
                  ),
                ),
                if (item.rentalPrice != null)
                  Positioned(
                    bottom: 14,
                    right: 14,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: AppColors.pureWhite.withOpacity(0.95),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: AppColors.border),
                      ),
                      child: Text(
                        '${Formatters.formatCurrency(item.rentalPrice)} / ${item.rentalPricingUnit}',
                        style: AppTypography.titleSmall.copyWith(
                          color: AppColors.deepForest,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.all(18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.verified, size: 15, color: AppColors.success),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          item.ownerInstitution?.name ?? 'Verified Facility',
                          style: AppTypography.labelSmall.copyWith(color: AppColors.deepForest),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(
                    item.title,
                    style: AppTypography.headlineMedium,
                  ),
                  const SizedBox(height: 6),
                  Text(
                    item.description,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: AppTypography.bodyMedium,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoryChips(BuildContext context, WidgetRef ref) {
    return SizedBox(
      height: 42,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: AppConstants.categories.length,
        separatorBuilder: (context, index) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final cat = AppConstants.categories[index];
          return ActionChip(
            label: Text(cat['label']!),
            backgroundColor: AppColors.pureWhite,
            side: const BorderSide(color: AppColors.border),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            onPressed: () {
              ref.read(equipmentNotifierProvider.notifier).setCategory(cat['id']);
              context.go('/explore');
            },
          );
        },
      ),
    );
  }

  Widget _buildQuickActions(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: GestureDetector(
            onTap: () => context.push('/equipment/create'),
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.softSage.withOpacity(0.6),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.border),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppColors.deepForest,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(Icons.add_circle_outline, color: AppColors.pureWhite, size: 20),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('List Equipment', style: AppTypography.titleSmall),
                        Text('Lend or sell instruments', style: AppTypography.bodySmall.copyWith(fontSize: 11)),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: GestureDetector(
            onTap: () => context.go('/requests'),
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.pureWhite,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.border),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppColors.paleSand,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(Icons.calendar_today_outlined, color: AppColors.deepForest, size: 20),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Reservations', style: AppTypography.titleSmall),
                        Text('Manage bookings', style: AppTypography.bodySmall.copyWith(fontSize: 11)),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildHowItWorksSection(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.pureWhite,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'HOW LABLEND WORKS',
            style: AppTypography.labelSmall.copyWith(
              color: AppColors.deepForest,
              letterSpacing: 1.0,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Better access to science.',
            style: AppTypography.displayMedium,
          ),
          const SizedBox(height: 16),
          _buildStepRow(
            number: '01',
            title: 'Discover Specialized Assets',
            desc: 'Search calibrated microscopes, centrifuges, and analyzers from accredited labs.',
          ),
          const Divider(height: 24),
          _buildStepRow(
            number: '02',
            title: 'Submit Reservation Requests',
            desc: 'Select rental duration or purchase option with transparent institutional invoicing.',
          ),
          const Divider(height: 24),
          _buildStepRow(
            number: '03',
            title: 'Collaborative Execution',
            desc: 'Coordinate sample delivery, laboratory orientation, and data collection seamlessly.',
          ),
        ],
      ),
    );
  }

  Widget _buildStepRow({required String number, required String title, required String desc}) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          number,
          style: AppTypography.headlineLarge.copyWith(color: AppColors.mutedGreenAccent),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: AppTypography.titleSmall),
              const SizedBox(height: 2),
              Text(desc, style: AppTypography.bodySmall),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildTrustBanner() {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.deepForest,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AppColors.pureWhite.withOpacity(0.12),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.shield_outlined, color: AppColors.pureWhite, size: 26),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Verified Academic Network',
                  style: AppTypography.titleSmall.copyWith(color: AppColors.pureWhite),
                ),
                const SizedBox(height: 2),
                Text(
                  'All participating laboratories undergo institutional verification before transactions occur.',
                  style: AppTypography.bodySmall.copyWith(
                    color: AppColors.pureWhite.withOpacity(0.8),
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
