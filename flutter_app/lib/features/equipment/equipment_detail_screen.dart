import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../../core/utils/formatters.dart';
import '../../models/equipment_model.dart';
import '../../providers/auth_provider.dart';
import '../../providers/equipment_provider.dart';
import '../../widgets/app_button.dart';
import '../../widgets/network_image_with_fallback.dart';
import '../../widgets/status_badge.dart';
import 'booking_request_sheet.dart';

class EquipmentDetailScreen extends ConsumerStatefulWidget {
  final String equipmentId;

  const EquipmentDetailScreen({
    super.key,
    required this.equipmentId,
  });

  @override
  ConsumerState<EquipmentDetailScreen> createState() => _EquipmentDetailScreenState();
}

class _EquipmentDetailScreenState extends ConsumerState<EquipmentDetailScreen> {
  final PageController _pageController = PageController();
  int _activeImageIndex = 0;

  void _openBookingSheet(EquipmentModel equipment, String requestType) async {
    final result = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => BookingRequestSheet(
        equipment: equipment,
        requestType: requestType,
      ),
    );

    if (result == true && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Your $requestType request has been submitted successfully!'),
          backgroundColor: AppColors.deepForest,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final equipmentAsync = ref.watch(equipmentDetailProvider(widget.equipmentId));
    final currentUser = ref.watch(currentUserProvider);

    return Scaffold(
      backgroundColor: AppColors.warmOffWhite,
      body: equipmentAsync.when(
        data: (equipment) {
          final isOwner = currentUser != null && equipment.ownerUserId == currentUser.id;

          return Stack(
            children: [
              CustomScrollView(
                slivers: [
                  // App Bar with Image Gallery
                  SliverAppBar(
                    expandedHeight: 320,
                    pinned: true,
                    backgroundColor: AppColors.warmOffWhite,
                    leading: Container(
                      margin: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: AppColors.pureWhite.withOpacity(0.9),
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(color: Colors.black.withOpacity(0.08), blurRadius: 8),
                        ],
                      ),
                      child: IconButton(
                        icon: const Icon(Icons.arrow_back, color: AppColors.primaryInk),
                        onPressed: () => context.pop(),
                      ),
                    ),
                    actions: [
                      if (isOwner)
                        Container(
                          margin: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: AppColors.pureWhite.withOpacity(0.9),
                            shape: BoxShape.circle,
                          ),
                          child: IconButton(
                            icon: const Icon(Icons.edit, color: AppColors.deepForest),
                            tooltip: 'Edit Listing',
                            onPressed: () => context.push('/equipment/${equipment.id}/edit'),
                          ),
                        ),
                    ],
                    flexibleSpace: FlexibleSpaceBar(
                      background: Stack(
                        fit: StackFit.expand,
                        children: [
                          PageView.builder(
                            controller: _pageController,
                            itemCount: equipment.images.isNotEmpty ? equipment.images.length : 1,
                            onPageChanged: (i) => setState(() => _activeImageIndex = i),
                            itemBuilder: (context, index) {
                              final imgUrl = equipment.images.isNotEmpty
                                  ? equipment.images[index].url
                                  : '';
                              return NetworkImageWithFallback(imageUrl: imgUrl);
                            },
                          ),
                          // Gallery Dots Indicator
                          if (equipment.images.length > 1)
                            Positioned(
                              bottom: 16,
                              left: 0,
                              right: 0,
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: List.generate(equipment.images.length, (i) {
                                  final isActive = _activeImageIndex == i;
                                  return AnimatedContainer(
                                    duration: const Duration(milliseconds: 200),
                                    margin: const EdgeInsets.symmetric(horizontal: 4),
                                    width: isActive ? 18 : 6,
                                    height: 6,
                                    decoration: BoxDecoration(
                                      color: isActive
                                          ? AppColors.pureWhite
                                          : AppColors.pureWhite.withOpacity(0.5),
                                      borderRadius: BorderRadius.circular(3),
                                    ),
                                  );
                                }),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),

                  // Body Content
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(20, 20, 20, 110),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Category and Status Badges
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                decoration: BoxDecoration(
                                  color: AppColors.softSage,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Text(
                                  Formatters.getCategoryLabel(equipment.category),
                                  style: AppTypography.labelSmall.copyWith(
                                    color: AppColors.deepForest,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                decoration: BoxDecoration(
                                  color: AppColors.paleSand,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Text(
                                  'Condition: ${Formatters.getConditionLabel(equipment.condition)}',
                                  style: AppTypography.labelSmall.copyWith(
                                    color: AppColors.primaryInk,
                                  ),
                                ),
                              ),
                              const Spacer(),
                              StatusBadge(status: equipment.availability),
                            ],
                          ),
                          const SizedBox(height: 16),

                          // Title
                          Text(
                            equipment.title,
                            style: AppTypography.displayMedium.copyWith(fontSize: 24),
                          ),
                          const SizedBox(height: 16),

                          // Owner Institution Card
                          _buildInstitutionCard(equipment),
                          const SizedBox(height: 24),

                          // Description
                          Text('Overview', style: AppTypography.titleMedium),
                          const SizedBox(height: 8),
                          Text(
                            equipment.description,
                            style: AppTypography.bodyLarge.copyWith(
                              color: AppColors.primaryInk.withOpacity(0.85),
                              height: 1.6,
                            ),
                          ),
                          const SizedBox(height: 24),

                          // Technical Specifications Sheet
                          if (equipment.technicalSpecs.isNotEmpty) ...[
                            Text('Technical Specifications', style: AppTypography.titleMedium),
                            const SizedBox(height: 12),
                            _buildSpecsTable(equipment.technicalSpecs),
                            const SizedBox(height: 24),
                          ],

                          // Location & Access terms
                          Text('Laboratory Location', style: AppTypography.titleMedium),
                          const SizedBox(height: 8),
                          Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: AppColors.pureWhite,
                              borderRadius: BorderRadius.circular(14),
                              border: Border.all(color: AppColors.border),
                            ),
                            child: Row(
                              children: [
                                const Icon(Icons.location_on_outlined, color: AppColors.deepForest),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        equipment.location.fullDisplay,
                                        style: AppTypography.bodyMedium.copyWith(
                                          fontWeight: FontWeight.w600,
                                          color: AppColors.primaryInk,
                                        ),
                                      ),
                                      Text(
                                        'Physical access requires institutional visitor badge.',
                                        style: AppTypography.bodySmall,
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),

              // Persistent Pinned Bottom Action Area
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: _buildBottomActionBar(context, equipment, isOwner),
              ),
            ],
          );
        },
        loading: () => const Scaffold(
          body: Center(child: CircularProgressIndicator()),
        ),
        error: (err, _) => Scaffold(
          appBar: AppBar(),
          body: Center(
            child: Text('Failed to load equipment: $err'),
          ),
        ),
      ),
    );
  }

  Widget _buildInstitutionCard(EquipmentModel equipment) {
    final inst = equipment.ownerInstitution;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.pureWhite,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: AppColors.softSage,
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.account_balance, color: AppColors.deepForest, size: 22),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Flexible(
                      child: Text(
                        inst?.name ?? 'Academic Core Facility',
                        style: AppTypography.titleSmall,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    if (inst?.isVerified == true) ...[
                      const SizedBox(width: 6),
                      const Icon(Icons.verified, size: 16, color: AppColors.success),
                    ],
                  ],
                ),
                Text(
                  inst?.locationDisplay ?? equipment.location.shortDisplay,
                  style: AppTypography.bodySmall,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSpecsTable(List<TechnicalSpec> specs) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.pureWhite,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        children: specs.asMap().entries.map((entry) {
          final isEven = entry.key % 2 == 0;
          final spec = entry.value;
          return Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            color: isEven ? AppColors.pureWhite : AppColors.warmOffWhite.withOpacity(0.6),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                  width: 140,
                  child: Text(
                    spec.key,
                    style: AppTypography.labelMedium.copyWith(color: AppColors.secondaryText),
                  ),
                ),
                Expanded(
                  child: Text(
                    spec.value,
                    style: AppTypography.bodyMedium.copyWith(
                      fontWeight: FontWeight.w600,
                      color: AppColors.primaryInk,
                    ),
                  ),
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildBottomActionBar(
    BuildContext context,
    EquipmentModel equipment,
    bool isOwner,
  ) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: BoxDecoration(
        color: AppColors.pureWhite,
        border: const Border(top: BorderSide(color: AppColors.border)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 12,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Row(
          children: [
            // Price info column
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Pricing',
                    style: AppTypography.labelSmall.copyWith(fontSize: 10),
                  ),
                  if (equipment.canRent && equipment.rentalPrice != null)
                    Text(
                      '${Formatters.formatCurrency(equipment.rentalPrice)} / ${equipment.rentalPricingUnit}',
                      style: AppTypography.priceMedium,
                    )
                  else if (equipment.canBuy && equipment.purchasePrice != null)
                    Text(
                      Formatters.formatCurrency(equipment.purchasePrice),
                      style: AppTypography.priceMedium,
                    ),
                ],
              ),
            ),

            // Actions
            if (isOwner)
              AppButton(
                text: 'Manage Listing',
                onPressed: () => context.push('/equipment/${equipment.id}/edit'),
              )
            else ...[
              if (equipment.canRent)
                AppButton(
                  text: 'Rent',
                  onPressed: equipment.isAvailable
                      ? () => _openBookingSheet(equipment, 'rental')
                      : null,
                ),
              if (equipment.canRent && equipment.canBuy) const SizedBox(width: 8),
              if (equipment.canBuy)
                AppButton(
                  text: 'Buy',
                  variant: equipment.canRent ? AppButtonVariant.secondary : AppButtonVariant.primary,
                  onPressed: equipment.isAvailable
                      ? () => _openBookingSheet(equipment, 'purchase')
                      : null,
                ),
            ],
          ],
        ),
      ),
    );
  }
}
