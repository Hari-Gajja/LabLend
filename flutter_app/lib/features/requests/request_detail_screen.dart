import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../../core/utils/formatters.dart';
import '../../models/request_model.dart';
import '../../providers/auth_provider.dart';
import '../../providers/request_provider.dart';
import '../../widgets/app_button.dart';
import '../../widgets/app_text_field.dart';
import '../../widgets/network_image_with_fallback.dart';
import '../../widgets/status_badge.dart';

class RequestDetailScreen extends ConsumerStatefulWidget {
  final String requestId;

  const RequestDetailScreen({
    super.key,
    required this.requestId,
  });

  @override
  ConsumerState<RequestDetailScreen> createState() => _RequestDetailScreenState();
}

class _RequestDetailScreenState extends ConsumerState<RequestDetailScreen> {
  final _reasonController = TextEditingController();
  final _notesController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _reasonController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  void _showApproveDialog(RequestModel req) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Approve Request', style: AppTypography.headlineMedium),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Approving confirms the reservation schedule and authorizes access to ${req.equipment?.title}.',
              style: AppTypography.bodyMedium,
            ),
            const SizedBox(height: 16),
            AppTextField(
              label: 'Orientation or Safety Notes (Optional)',
              hint: 'e.g. Please bring laser safety eyewear and check in at Room B-104.',
              controller: _notesController,
              maxLines: 2,
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.of(ctx).pop(), child: const Text('Cancel')),
          TextButton(
            onPressed: () async {
              Navigator.of(ctx).pop();
              setState(() => _isLoading = true);
              final success = await ref
                  .read(requestsNotifierProvider.notifier)
                  .approveRequest(req.id, notes: _notesController.text.trim());
              setState(() => _isLoading = false);
              if (success && mounted) {
                ref.invalidate(singleRequestProvider(req.id));
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Request approved successfully')),
                );
              }
            },
            child: Text('Confirm Approval', style: TextStyle(color: AppColors.deepForest, fontWeight: FontWeight.w700)),
          ),
        ],
      ),
    );
  }

  void _showRejectDialog(RequestModel req) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Decline Request', style: AppTypography.headlineMedium),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Please specify why this request cannot be fulfilled at this time:', style: AppTypography.bodyMedium),
            const SizedBox(height: 16),
            AppTextField(
              label: 'Reason for Rejection',
              hint: 'e.g. Instrument is scheduled for quarterly recalibration.',
              controller: _reasonController,
              maxLines: 3,
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.of(ctx).pop(), child: const Text('Cancel')),
          TextButton(
            onPressed: () async {
              if (_reasonController.text.trim().isEmpty) return;
              Navigator.of(ctx).pop();
              setState(() => _isLoading = true);
              final success = await ref
                  .read(requestsNotifierProvider.notifier)
                  .rejectRequest(req.id, reason: _reasonController.text.trim());
              setState(() => _isLoading = false);
              if (success && mounted) {
                ref.invalidate(singleRequestProvider(req.id));
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Request declined')),
                );
              }
            },
            child: Text('Confirm Decline', style: TextStyle(color: AppColors.error, fontWeight: FontWeight.w700)),
          ),
        ],
      ),
    );
  }

  void _handleCancel(RequestModel req) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Cancel Request?', style: AppTypography.headlineMedium),
        content: Text('Are you sure you want to cancel your request for ${req.equipment?.title}?', style: AppTypography.bodyMedium),
        actions: [
          TextButton(onPressed: () => Navigator.of(ctx).pop(false), child: const Text('No')),
          TextButton(onPressed: () => Navigator.of(ctx).pop(true), child: Text('Yes, Cancel', style: TextStyle(color: AppColors.error))),
        ],
      ),
    );

    if (confirm == true) {
      setState(() => _isLoading = true);
      final success = await ref
          .read(requestsNotifierProvider.notifier)
          .cancelRequest(req.id, reason: 'Cancelled by requester');
      setState(() => _isLoading = false);
      if (success && mounted) {
        ref.invalidate(singleRequestProvider(req.id));
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Request cancelled')),
        );
      }
    }
  }

  void _handleComplete(RequestModel req) async {
    setState(() => _isLoading = true);
    final success = await ref
        .read(requestsNotifierProvider.notifier)
        .completeRequest(req.id, notes: 'Completed transaction/loan');
    setState(() => _isLoading = false);
    if (success && mounted) {
      ref.invalidate(singleRequestProvider(req.id));
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Request marked as completed')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final requestAsync = ref.watch(singleRequestProvider(widget.requestId));
    final currentUser = ref.watch(currentUserProvider);

    return Scaffold(
      backgroundColor: AppColors.warmOffWhite,
      appBar: AppBar(
        title: Text('Request Details', style: AppTypography.headlineLarge),
        leading: IconButton(icon: const Icon(Icons.arrow_back), onPressed: () => context.pop()),
      ),
      body: requestAsync.when(
        data: (req) {
          final isOwner = currentUser != null && req.listingOwnerId == currentUser.id;
          final isRequester = currentUser != null && req.requesterUserId == currentUser.id;

          return SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.pureWhite,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('STATUS', style: AppTypography.labelSmall.copyWith(fontSize: 10)),
                          const SizedBox(height: 4),
                          StatusBadge(status: req.status),
                        ],
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text('TRANSACTION', style: AppTypography.labelSmall.copyWith(fontSize: 10)),
                          const SizedBox(height: 4),
                          Text(
                            req.isRental ? 'Rental Reservation' : 'Purchase Request',
                            style: AppTypography.titleSmall,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),

                if (req.equipment != null) ...[
                  Text('Target Instrument', style: AppTypography.titleMedium),
                  const SizedBox(height: 8),
                  GestureDetector(
                    onTap: () => context.push('/equipment/${req.equipment!.id}'),
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppColors.pureWhite,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: AppColors.border),
                      ),
                      child: Row(
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(10),
                            child: SizedBox(
                              width: 70,
                              height: 70,
                              child: NetworkImageWithFallback(imageUrl: req.equipment!.coverImageUrl),
                            ),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(req.equipment!.title, style: AppTypography.titleSmall),
                                const SizedBox(height: 4),
                                Text(
                                  req.isRental
                                      ? '${Formatters.formatCurrency(req.equipment!.rentalPrice)} / ${req.equipment!.rentalPricingUnit}'
                                      : Formatters.formatCurrency(req.equipment!.purchasePrice),
                                  style: AppTypography.priceMedium.copyWith(fontSize: 14),
                                ),
                              ],
                            ),
                          ),
                          const Icon(Icons.chevron_right, color: AppColors.secondaryText),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                ],

                if (req.isRental && req.rentalStartDate != null) ...[
                  Text('Reservation Schedule', style: AppTypography.titleMedium),
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
                        const Icon(Icons.date_range, color: AppColors.deepForest),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                Formatters.formatDateRange(req.rentalStartDate!, req.rentalEndDate!),
                                style: AppTypography.titleSmall,
                              ),
                              Text(
                                '${req.rentalEndDate!.difference(req.rentalStartDate!).inDays} days duration',
                                style: AppTypography.bodySmall,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                ],

                Text('Intended Research Protocol', style: AppTypography.titleMedium),
                const SizedBox(height: 8),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.pureWhite,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: Text(req.intendedUse, style: AppTypography.bodyMedium.copyWith(height: 1.5)),
                ),
                const SizedBox(height: 20),

                if (req.message.isNotEmpty) ...[
                  Text('Message to Host', style: AppTypography.titleMedium),
                  const SizedBox(height: 8),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppColors.pureWhite,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: AppColors.border),
                    ),
                    child: Text(req.message, style: AppTypography.bodyMedium),
                  ),
                  const SizedBox(height: 20),
                ],

                if (req.decisionMetadata != null && req.decisionMetadata!['reason'] != null) ...[
                  Text('Decision Notes', style: AppTypography.titleMedium),
                  const SizedBox(height: 8),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: req.isApproved ? AppColors.successBg : AppColors.errorBg,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                        color: req.isApproved
                            ? AppColors.success.withValues(alpha: 0.3)
                            : AppColors.error.withValues(alpha: 0.3),
                      ),
                    ),
                    child: Text(
                      req.decisionMetadata!['reason'] ?? req.decisionMetadata!['notes'] ?? '',
                      style: AppTypography.bodyMedium,
                    ),
                  ),
                  const SizedBox(height: 24),
                ],

                if (_isLoading)
                  const Center(child: CircularProgressIndicator())
                else if (isOwner && req.isPending) ...[
                  Row(
                    children: [
                      Expanded(
                        child: AppButton(
                          text: 'Approve',
                          variant: AppButtonVariant.primary,
                          onPressed: () => _showApproveDialog(req),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: AppButton(
                          text: 'Decline',
                          variant: AppButtonVariant.danger,
                          onPressed: () => _showRejectDialog(req),
                        ),
                      ),
                    ],
                  ),
                ] else if (isRequester && (req.isPending || req.isApproved)) ...[
                  AppButton(
                    text: 'Cancel Request',
                    variant: AppButtonVariant.danger,
                    width: double.infinity,
                    onPressed: () => _handleCancel(req),
                  ),
                ],

                if (req.isApproved) ...[
                  const SizedBox(height: 12),
                  AppButton(
                    text: 'Mark Loan / Purchase Completed',
                    variant: AppButtonVariant.secondary,
                    width: double.infinity,
                    onPressed: () => _handleComplete(req),
                  ),
                ],
                const SizedBox(height: 32),
              ],
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Failed to load request: $e')),
      ),
    );
  }
}
