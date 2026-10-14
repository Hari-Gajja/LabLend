import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../../core/utils/formatters.dart';
import '../../models/request_model.dart';
import '../../providers/request_provider.dart';
import '../../widgets/empty_state_view.dart';
import '../../widgets/network_image_with_fallback.dart';
import '../../widgets/status_badge.dart';

class RequestsScreen extends ConsumerStatefulWidget {
  const RequestsScreen({super.key});

  @override
  ConsumerState<RequestsScreen> createState() => _RequestsScreenState();
}

class _RequestsScreenState extends ConsumerState<RequestsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(requestsNotifierProvider);
    final notifier = ref.read(requestsNotifierProvider.notifier);

    return Scaffold(
      backgroundColor: AppColors.warmOffWhite,
      appBar: AppBar(
        title: Text('Equipment Requests', style: AppTypography.headlineLarge),
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: AppColors.deepForest,
          indicatorWeight: 3,
          labelColor: AppColors.deepForest,
          unselectedLabelColor: AppColors.secondaryText,
          labelStyle: AppTypography.labelMedium.copyWith(fontWeight: FontWeight.w700),
          tabs: [
            Tab(text: 'Sent Requests (${state.sent.length})'),
            Tab(text: 'Received Requests (${state.received.length})'),
          ],
        ),
      ),
      body: RefreshIndicator(
        onRefresh: () async => notifier.fetchAll(),
        child: TabBarView(
          controller: _tabController,
          children: [
            _buildRequestsList(state.sent, isSent: true),
            _buildRequestsList(state.received, isSent: false),
          ],
        ),
      ),
    );
  }

  Widget _buildRequestsList(List<RequestModel> list, {required bool isSent}) {
    if (list.isEmpty) {
      return EmptyStateView(
        icon: Icons.calendar_today_outlined,
        title: isSent ? 'No sent requests' : 'No incoming requests',
        description: isSent
            ? 'Explore available instruments and submit rental or purchase requests.'
            : 'Incoming requests for your laboratory listings will appear here for review.',
        buttonText: isSent ? 'Explore Equipment' : null,
        onButtonPressed: isSent ? () => context.go('/explore') : null,
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      itemCount: list.length,
      separatorBuilder: (context, index) => const SizedBox(height: 14),
      itemBuilder: (context, index) {
        final req = list[index];
        return _buildRequestCard(req, isSent);
      },
    );
  }

  Widget _buildRequestCard(RequestModel req, bool isSent) {
    final equip = req.equipment;

    return Container(
      decoration: BoxDecoration(
        color: AppColors.pureWhite,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => context.push('/requests/${req.id}'),
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Top row with status badge & date
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    StatusBadge(status: req.status, isCompact: true),
                    Text(
                      Formatters.timeAgo(req.createdAt),
                      style: AppTypography.labelSmall.copyWith(color: AppColors.secondaryText),
                    ),
                  ],
                ),
                const SizedBox(height: 12),

                // Equipment Info Row
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: SizedBox(
                        width: 60,
                        height: 60,
                        child: NetworkImageWithFallback(imageUrl: equip?.coverImageUrl ?? ''),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            equip?.title ?? 'Scientific Equipment',
                            style: AppTypography.titleSmall,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            isSent
                                ? 'Host: ${req.listingOwner?.fullName ?? 'Facility Director'}'
                                : 'Requester: ${req.requesterUser?.fullName ?? 'Researcher'} (${req.requesterInstitution?.name ?? 'Institution'})',
                            style: AppTypography.bodySmall.copyWith(fontSize: 11),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            req.isRental && req.rentalStartDate != null
                                ? 'Reservation: ${Formatters.formatDateRange(req.rentalStartDate!, req.rentalEndDate!)}'
                                : 'Purchase Offer · Qty: ${req.requestedQuantity}',
                            style: AppTypography.labelSmall.copyWith(
                              color: AppColors.deepForest,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
