import 'package:flutter/material.dart';
import '../core/theme/app_colors.dart';
import '../core/theme/app_typography.dart';

class StatusBadge extends StatelessWidget {
  final String status;
  final bool isCompact;

  const StatusBadge({
    super.key,
    required this.status,
    this.isCompact = false,
  });

  @override
  Widget build(BuildContext context) {
    Color bgColor;
    Color textColor;
    IconData? icon;
    String label;

    switch (status.toLowerCase()) {
      case 'approved':
      case 'available':
      case 'verified':
        bgColor = AppColors.successBg;
        textColor = AppColors.success;
        icon = Icons.check_circle_outline;
        label = status == 'verified' ? 'Verified Institution' : status[0].toUpperCase() + status.substring(1);
        break;

      case 'pending':
        bgColor = AppColors.warningBg;
        textColor = AppColors.warning;
        icon = Icons.schedule;
        label = 'Pending Review';
        break;

      case 'rejected':
      case 'cancelled':
        bgColor = AppColors.errorBg;
        textColor = AppColors.error;
        icon = Icons.cancel_outlined;
        label = status[0].toUpperCase() + status.substring(1);
        break;

      case 'completed':
        bgColor = AppColors.softSage;
        textColor = AppColors.deepForest;
        icon = Icons.task_alt;
        label = 'Completed';
        break;

      case 'maintenance':
      case 'reserved':
      case 'rented':
        bgColor = AppColors.paleSand;
        textColor = AppColors.primaryInk;
        icon = Icons.lock_clock;
        label = status[0].toUpperCase() + status.substring(1);
        break;

      default:
        bgColor = AppColors.warmOffWhite;
        textColor = AppColors.secondaryText;
        label = status;
    }

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: isCompact ? 8 : 10,
        vertical: isCompact ? 3 : 5,
      ),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: textColor.withOpacity(0.2), width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: isCompact ? 12 : 14, color: textColor),
            const SizedBox(width: 4),
          ],
          Text(
            label,
            style: isCompact
                ? AppTypography.labelSmall.copyWith(color: textColor, fontSize: 10)
                : AppTypography.labelSmall.copyWith(color: textColor),
          ),
        ],
      ),
    );
  }
}
