import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../../providers/auth_provider.dart';
import '../../providers/equipment_provider.dart';
import '../../widgets/app_button.dart';
import '../../widgets/status_badge.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  void _confirmLogout(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Sign Out', style: AppTypography.headlineMedium),
        content: Text('Are you sure you want to end your current LabLend session?', style: AppTypography.bodyMedium),
        actions: [
          TextButton(onPressed: () => Navigator.of(ctx).pop(), child: const Text('Cancel')),
          TextButton(
            onPressed: () async {
              Navigator.of(ctx).pop();
              await ref.read(authNotifierProvider.notifier).logout();
              if (context.mounted) context.go('/login');
            },
            child: Text('Sign Out', style: TextStyle(color: AppColors.error, fontWeight: FontWeight.w700)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(currentUserProvider);
    final myListingsCount = ref.watch(myListingsProvider).maybeWhen(
          data: (l) => l.length,
          orElse: () => 0,
        );

    if (user == null) {
      return Scaffold(
        backgroundColor: AppColors.warmOffWhite,
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text('You are currently not signed in.', style: AppTypography.bodyLarge),
              const SizedBox(height: 16),
              AppButton(
                text: 'Sign In',
                onPressed: () => context.go('/login'),
              ),
            ],
          ),
        ),
      );
    }

    final initials = user.fullName
        .split(' ')
        .where((s) => s.isNotEmpty)
        .take(2)
        .map((s) => s[0].toUpperCase())
        .join();

    return Scaffold(
      backgroundColor: AppColors.warmOffWhite,
      appBar: AppBar(
        title: Text('Account & Laboratory', style: AppTypography.headlineLarge),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings_outlined),
            tooltip: 'Settings',
            onPressed: () => context.push('/settings'),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        child: Column(
          children: [
            // User Card
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppColors.pureWhite,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: AppColors.border),
              ),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 32,
                    backgroundColor: AppColors.softSage,
                    child: Text(
                      initials,
                      style: AppTypography.titleLarge.copyWith(color: AppColors.deepForest),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(user.fullName, style: AppTypography.titleLarge),
                        const SizedBox(height: 2),
                        Text(
                          '${user.title} · ${user.department}',
                          style: AppTypography.bodySmall,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          user.email,
                          style: AppTypography.bodySmall.copyWith(
                            color: AppColors.secondaryText,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Institution Verification Card
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: AppColors.pureWhite,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: AppColors.border),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('INSTITUTION AFFILIATION', style: AppTypography.labelSmall.copyWith(fontSize: 10)),
                      StatusBadge(status: user.institution?.verificationStatus ?? 'unverified', isCompact: true),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    user.institution?.name ?? 'Affiliated Research Institute',
                    style: AppTypography.titleSmall,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    user.institution?.locationDisplay ?? 'Location pending',
                    style: AppTypography.bodySmall,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Menu Options
            Container(
              decoration: BoxDecoration(
                color: AppColors.pureWhite,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: AppColors.border),
              ),
              child: Column(
                children: [
                  _buildMenuTile(
                    icon: Icons.inventory_2_outlined,
                    title: 'My Equipment Listings',
                    subtitle: '$myListingsCount active listings',
                    onTap: () => context.push('/my-listings'),
                  ),
                  const Divider(height: 1),
                  _buildMenuTile(
                    icon: Icons.add_circle_outline,
                    title: 'List New Equipment',
                    subtitle: 'Lend or sell instruments',
                    onTap: () => context.push('/equipment/create'),
                  ),
                  const Divider(height: 1),
                  _buildMenuTile(
                    icon: Icons.swap_horiz_outlined,
                    title: 'My Reservations & Requests',
                    subtitle: 'Sent and received transactions',
                    onTap: () => context.go('/requests'),
                  ),
                  const Divider(height: 1),
                  _buildMenuTile(
                    icon: Icons.edit_note_outlined,
                    title: 'Edit Profile & Affiliation',
                    subtitle: 'Update contact and facility details',
                    onTap: () => context.push('/profile/edit'),
                  ),
                  const Divider(height: 1),
                  _buildMenuTile(
                    icon: Icons.tune,
                    title: 'Network & Emulator Settings',
                    subtitle: 'Configure backend server URL',
                    onTap: () => context.push('/settings'),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 28),

            // Sign out button
            AppButton(
              text: 'Sign Out',
              variant: AppButtonVariant.secondary,
              width: double.infinity,
              icon: Icons.logout,
              onPressed: () => _confirmLogout(context, ref),
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildMenuTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: AppColors.warmOffWhite,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon, color: AppColors.deepForest, size: 20),
      ),
      title: Text(title, style: AppTypography.titleSmall),
      subtitle: Text(subtitle, style: AppTypography.bodySmall.copyWith(fontSize: 11)),
      trailing: const Icon(Icons.chevron_right, size: 20, color: AppColors.secondaryText),
      onTap: onTap,
    );
  }
}
