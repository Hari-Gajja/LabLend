import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../../core/utils/validators.dart';
import '../../providers/auth_provider.dart';
import '../../services/profile_service.dart';
import '../../widgets/app_button.dart';
import '../../widgets/app_text_field.dart';

class EditProfileScreen extends ConsumerStatefulWidget {
  const EditProfileScreen({super.key});

  @override
  ConsumerState<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends ConsumerState<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();

  final _titleController = TextEditingController();
  final _departmentController = TextEditingController();
  final _contactNumberController = TextEditingController();

  final _instNameController = TextEditingController();
  final _instDescController = TextEditingController();
  final _instCityController = TextEditingController();
  final _instStateController = TextEditingController();

  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    final user = ref.read(currentUserProvider);
    if (user != null) {
      _titleController.text = user.title;
      _departmentController.text = user.department;
      _contactNumberController.text = user.contactNumber;

      if (user.institution != null) {
        _instNameController.text = user.institution!.name;
        _instDescController.text = user.institution!.description;
        _instCityController.text = user.institution!.city;
        _instStateController.text = user.institution!.state;
      }
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _departmentController.dispose();
    _contactNumberController.dispose();
    _instNameController.dispose();
    _instDescController.dispose();
    _instCityController.dispose();
    _instStateController.dispose();
    super.dispose();
  }

  Future<void> _handleSave() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final profileService = ProfileService();
      // Update institution details
      await profileService.updateMyInstitution({
        'name': _instNameController.text.trim(),
        'description': _instDescController.text.trim(),
        'city': _instCityController.text.trim(),
        'state': _instStateController.text.trim(),
      });

      // Refresh current user
      final authService = ref.read(authServiceProvider);
      final refreshed = await authService.getMe();
      if (refreshed != null) {
        ref.read(authNotifierProvider.notifier).updateUser(refreshed);
      }

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Profile updated successfully')),
      );
      context.pop();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Update failed: $e')),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.warmOffWhite,
      appBar: AppBar(
        title: Text('Edit Profile', style: AppTypography.headlineLarge),
        leading: IconButton(icon: const Icon(Icons.arrow_back), onPressed: () => context.pop()),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Professional Details', style: AppTypography.titleMedium),
              const SizedBox(height: 12),
              AppTextField(
                label: 'Title / Academic Rank',
                hint: 'Principal Investigator',
                controller: _titleController,
              ),
              const SizedBox(height: 16),
              AppTextField(
                label: 'Department',
                hint: 'Department of Bioengineering',
                controller: _departmentController,
              ),
              const SizedBox(height: 16),
              AppTextField(
                label: 'Direct Contact Number',
                hint: '+1 (555) 012-3456',
                controller: _contactNumberController,
                keyboardType: TextInputType.phone,
              ),
              const SizedBox(height: 24),
              Text('Institution Profile', style: AppTypography.titleMedium),
              const SizedBox(height: 12),
              AppTextField(
                label: 'Institution Name',
                hint: 'Stanford Bioengineering Research Core',
                controller: _instNameController,
                validator: Validators.required,
              ),
              const SizedBox(height: 16),
              AppTextField(
                label: 'Facility Description',
                hint: 'Core capabilities and instrumentation overview...',
                controller: _instDescController,
                maxLines: 3,
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: AppTextField(
                      label: 'City',
                      hint: 'Stanford',
                      controller: _instCityController,
                      validator: Validators.required,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: AppTextField(
                      label: 'State',
                      hint: 'CA',
                      controller: _instStateController,
                      validator: Validators.required,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 32),
              AppButton(
                text: 'Save Changes',
                width: double.infinity,
                isLoading: _isLoading,
                onPressed: _handleSave,
              ),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }
}
