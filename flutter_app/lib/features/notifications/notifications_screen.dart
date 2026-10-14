import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../../core/utils/formatters.dart';
import '../../providers/notification_provider.dart';
import '../../widgets/empty_state_view.dart';

class NotificationsScreen extends ConsumerWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(notificationNotifierProvider);
    final notifier = ref.read(notificationNotifierProvider.notifier);

    return Scaffold(
      backgroundColor: AppColors.warmOffWhite,
      appBar: AppBar(
        title: Text('Notifications', style: AppTypography.headlineLarge),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
        actions: [
          if (state.notifications.isNotEmpty && state.unreadCount > 0)
            TextButton(
              onPressed: () => notifier.markAllAsRead(),
              child: Text(
                'Mark all read',
                style: AppTypography.labelSmall.copyWith(color: AppColors.deepForest),
              ),
            ),
          const SizedBox(width: 8),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async => notifier.fetchNotifications(),
        child: state.isLoading && state.notifications.isEmpty
            ? const Center(child: CircularProgressIndicator())
            : state.notifications.isEmpty
                ? const EmptyStateView(
                    icon: Icons.notifications_none_outlined,
                    title: 'No notifications',
                    description: 'You will receive updates here when researchers request or respond to your listings.',
                  )
                : ListView.separated(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                    itemCount: state.notifications.length,
                    separatorBuilder: (context, index) => const SizedBox(height: 12),
                    itemBuilder: (context, index) {
                      final notif = state.notifications[index];
                      return Container(
                        decoration: BoxDecoration(
                          color: notif.isRead ? AppColors.pureWhite : AppColors.softSage.withOpacity(0.3),
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(
                            color: notif.isRead ? AppColors.border : AppColors.mutedGreenAccent.withOpacity(0.4),
                          ),
                        ),
                        child: ListTile(
                          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          leading: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: notif.isRead ? AppColors.warmOffWhite : AppColors.softSage,
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              _getEventIcon(notif.eventType),
                              size: 20,
                              color: AppColors.deepForest,
                            ),
                          ),
                          title: Text(
                            notif.title,
                            style: AppTypography.titleSmall.copyWith(
                              fontWeight: notif.isRead ? FontWeight.normal : FontWeight.w700,
                            ),
                          ),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const SizedBox(height: 4),
                              Text(notif.message, style: AppTypography.bodySmall),
                              const SizedBox(height: 6),
                              Text(
                                Formatters.timeAgo(notif.createdAt),
                                style: AppTypography.labelSmall.copyWith(fontSize: 10, color: AppColors.secondaryText),
                              ),
                            ],
                          ),
                          onTap: () {
                            if (!notif.isRead) notifier.markAsRead(notif.id);
                            if (notif.relatedRequestId != null) {
                              context.push('/requests/${notif.relatedRequestId}');
                            }
                          },
                        ),
                      );
                    },
                  ),
      ),
    );
  }

  IconData _getEventIcon(String type) {
    switch (type) {
      case 'request_created':
        return Icons.add_circle_outline;
      case 'request_approved':
        return Icons.check_circle_outline;
      case 'request_rejected':
        return Icons.cancel_outlined;
      case 'request_cancelled':
        return Icons.remove_circle_outline;
      case 'request_completed':
        return Icons.task_alt;
      default:
        return Icons.info_outline;
    }
  }
}
