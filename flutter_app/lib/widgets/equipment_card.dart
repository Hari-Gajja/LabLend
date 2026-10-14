import 'package:flutter/material.dart';
import '../core/theme/app_colors.dart';
import '../core/theme/app_typography.dart';
import '../core/utils/formatters.dart';
import '../models/equipment_model.dart';
import 'network_image_with_fallback.dart';
import 'status_badge.dart';

class EquipmentCard extends StatelessWidget {
  final EquipmentModel equipment;
  final VoidCallback onTap;
  final double? width;

  const EquipmentCard({
    super.key,
    required this.equipment,
    required this.onTap,
    this.width,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      decoration: BoxDecoration(
        color: AppColors.pureWhite,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border, width: 1),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              // Image container with category pill overlay
              Stack(
                children: [
                  AspectRatio(
                    aspectRatio: 16 / 10,
                    child: NetworkImageWithFallback(
                      imageUrl: equipment.coverImageUrl,
                      borderRadius: const BorderRadius.vertical(top: Radius.circular(15)),
                    ),
                  ),
                  Positioned(
                    top: 10,
                    left: 10,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppColors.primaryInk.withOpacity(0.75),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        Formatters.getCategoryLabel(equipment.category),
                        style: AppTypography.labelSmall.copyWith(
                          color: AppColors.pureWhite,
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                  if (equipment.availability != 'available')
                    Positioned(
                      top: 10,
                      right: 10,
                      child: StatusBadge(
                        status: equipment.availability,
                        isCompact: true,
                      ),
                    ),
                ],
              ),

              // Content Details
              Padding(
                padding: const EdgeInsets.all(14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Institution name & location
                    Row(
                      children: [
                        Icon(
                          Icons.account_balance_outlined,
                          size: 13,
                          color: AppColors.secondaryText,
                        ),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            equipment.ownerInstitution?.name ?? equipment.location.shortDisplay,
                            style: AppTypography.labelSmall.copyWith(
                              color: AppColors.secondaryText,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        if (equipment.ownerInstitution?.isVerified == true) ...[
                          const SizedBox(width: 4),
                          const Icon(
                            Icons.verified,
                            size: 14,
                            color: AppColors.success,
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: 6),

                    // Equipment Title
                    Text(
                      equipment.title,
                      style: AppTypography.titleMedium.copyWith(
                        height: 1.25,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 10),

                    // Pricing Row
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.baseline,
                      textBaseline: TextBaseline.alphabetic,
                      children: [
                        if (equipment.canRent && equipment.rentalPrice != null) ...[
                          Text(
                            Formatters.formatCurrency(equipment.rentalPrice),
                            style: AppTypography.priceMedium,
                          ),
                          Text(
                            ' / ${equipment.rentalPricingUnit}',
                            style: AppTypography.bodySmall.copyWith(fontSize: 11),
                          ),
                        ],
                        if (equipment.listingType == 'both' && equipment.purchasePrice != null) ...[
                          const SizedBox(width: 8),
                          Text(
                            '·',
                            style: AppTypography.titleSmall.copyWith(color: AppColors.borderDark),
                          ),
                          const SizedBox(width: 8),
                        ],
                        if (equipment.canBuy && equipment.purchasePrice != null) ...[
                          Text(
                            '${Formatters.formatCurrency(equipment.purchasePrice)} buy',
                            style: AppTypography.bodySmall.copyWith(
                              color: equipment.canRent ? AppColors.secondaryText : AppColors.deepForest,
                              fontWeight: equipment.canRent ? FontWeight.normal : FontWeight.w700,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
