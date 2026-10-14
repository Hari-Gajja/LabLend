import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/config/api_config.dart';
import '../../core/constants/app_constants.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../../providers/equipment_provider.dart';
import '../../widgets/app_button.dart';
import '../../widgets/app_text_field.dart';

class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  final _urlController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _urlController.text = ApiConfig.baseUrl;
  }

  @override
  void dispose() {
    _urlController.dispose();
    super.dispose();
  }

  void _saveUrl() {
    ApiConfig.setBaseUrl(_urlController.text.trim());
    ref.read(equipmentNotifierProvider.notifier).fetchEquipment(isRefresh: true);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('API Base URL updated to: ${ApiConfig.baseUrl}'),
        backgroundColor: AppColors.deepForest,
      ),
    );
  }

  void _setPreset(String url) {
    _urlController.text = url;
    _saveUrl();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.warmOffWhite,
      appBar: AppBar(
        title: Text('Settings & Network', style: AppTypography.headlineLarge),
        leading: IconButton(icon: const Icon(Icons.arrow_back), onPressed: () => context.pop()),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Backend Server Configuration
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: AppColors.pureWhite,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.border),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.dns_outlined, color: AppColors.deepForest, size: 22),
                      const SizedBox(width: 10),
                      Text('Backend API Endpoint', style: AppTypography.titleMedium),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Configure the REST API endpoint used by Dio. Android emulators access the host machine via 10.0.2.2. Physical devices use your computer\'s local Wi-Fi IP.',
                    style: AppTypography.bodySmall,
                  ),
                  const SizedBox(height: 16),
                  AppTextField(
                    label: 'Active Base URL',
                    controller: _urlController,
                  ),
                  const SizedBox(height: 12),
                  AppButton(
                    text: 'Update Server URL',
                    width: double.infinity,
                    onPressed: _saveUrl,
                  ),
                  const SizedBox(height: 16),
                  Text('Quick Presets', style: AppTypography.labelSmall),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      ActionChip(
                        avatar: const Icon(Icons.cloud_done, size: 16, color: AppColors.success),
                        label: const Text('Cloud Production (Vercel)'),
                        onPressed: () => _setPreset('https://backend-five-gamma-51.vercel.app/api/v1'),
                      ),
                      ActionChip(
                        label: const Text('Android Emulator (10.0.2.2:5000)'),
                        onPressed: () => _setPreset('http://10.0.2.2:5000/api/v1'),
                      ),
                      ActionChip(
                        label: const Text('Localhost (127.0.0.1:5000)'),
                        onPressed: () => _setPreset('http://localhost:5000/api/v1'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // About LabLend
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: AppColors.pureWhite,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.border),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(AppConstants.appName, style: AppTypography.titleMedium),
                  const SizedBox(height: 4),
                  Text(
                    AppConstants.appTagline,
                    style: AppTypography.bodySmall.copyWith(color: AppColors.secondaryText),
                  ),
                  const Divider(height: 24),
                  _buildInfoRow('Version', '1.0.0 (MVP Build)'),
                  const SizedBox(height: 8),
                  _buildInfoRow('Platform', 'Flutter 3 / Material 3'),
                  const SizedBox(height: 8),
                  _buildInfoRow('State Management', 'Riverpod 2.6'),
                  const SizedBox(height: 8),
                  _buildInfoRow('Cloud Media', 'Cloudinary Direct Signed CDN'),
                  const SizedBox(height: 8),
                  _buildInfoRow('Database', 'MongoDB Atlas Mongoose'),
                ],
              ),
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: AppTypography.bodyMedium),
        Text(value, style: AppTypography.labelMedium.copyWith(color: AppColors.deepForest)),
      ],
    );
  }
}
