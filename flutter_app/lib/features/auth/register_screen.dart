import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../../core/utils/validators.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/app_button.dart';
import '../../widgets/app_text_field.dart';

class RegisterScreen extends ConsumerStatefulWidget {
  const RegisterScreen({super.key});

  @override
  ConsumerState<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends ConsumerState<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();

  final _fullNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _institutionNameController = TextEditingController();
  final _departmentController = TextEditingController();
  final _titleController = TextEditingController();
  final _contactNumberController = TextEditingController();
  final _cityController = TextEditingController();
  final _stateController = TextEditingController();

  String _institutionType = 'university';
  bool _isLoading = false;
  String? _errorMessage;

  @override
  void dispose() {
    _fullNameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _institutionNameController.dispose();
    _departmentController.dispose();
    _titleController.dispose();
    _contactNumberController.dispose();
    _cityController.dispose();
    _stateController.dispose();
    super.dispose();
  }

  Future<void> _handleRegister() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    final success = await ref.read(authNotifierProvider.notifier).register(
          fullName: _fullNameController.text.trim(),
          email: _emailController.text.trim(),
          password: _passwordController.text,
          institutionName: _institutionNameController.text.trim(),
          institutionType: _institutionType,
          city: _cityController.text.trim(),
          stateName: _stateController.text.trim(),
          contactNumber: _contactNumberController.text.trim(),
          department: _departmentController.text.trim(),
          title: _titleController.text.trim().isEmpty ? 'Researcher' : _titleController.text.trim(),
        );

    if (!mounted) return;

    setState(() {
      _isLoading = false;
    });

    if (success) {
      context.go('/home');
    } else {
      final authState = ref.read(authNotifierProvider);
      setState(() {
        _errorMessage = authState.errorMessage ?? 'Registration failed. Please check the inputs.';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.warmOffWhite,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                Text(
                  'JOIN THE NETWORK',
                  style: AppTypography.labelSmall.copyWith(
                    color: AppColors.deepForest,
                    letterSpacing: 1.0,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  'Create an institutional account.',
                  style: AppTypography.displayLarge,
                ),
                const SizedBox(height: 8),
                Text(
                  'Connect with verified academic, hospital, and private research laboratories.',
                  style: AppTypography.bodyMedium,
                ),
                const SizedBox(height: 24),

                if (_errorMessage != null) ...[
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppColors.errorBg,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: AppColors.error.withOpacity(0.3)),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.error_outline, size: 18, color: AppColors.error),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            _errorMessage!,
                            style: AppTypography.bodySmall.copyWith(color: AppColors.error),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                ],

                // Section 1: Personal Details
                Text('Researcher Information', style: AppTypography.titleMedium),
                const SizedBox(height: 12),

                AppTextField(
                  label: 'Full Name',
                  hint: 'Dr. Jane Doe',
                  controller: _fullNameController,
                  validator: Validators.required,
                  prefixIcon: const Icon(Icons.person_outline, size: 20),
                ),
                const SizedBox(height: 16),

                AppTextField(
                  label: 'Institutional Email',
                  hint: 'j.doe@institution.edu',
                  controller: _emailController,
                  validator: Validators.email,
                  keyboardType: TextInputType.emailAddress,
                  prefixIcon: const Icon(Icons.alternate_email, size: 20),
                ),
                const SizedBox(height: 16),

                AppTextField(
                  label: 'Password',
                  hint: 'Minimum 8 characters',
                  controller: _passwordController,
                  validator: Validators.password,
                  isPassword: true,
                  prefixIcon: const Icon(Icons.lock_outline, size: 20),
                ),
                const SizedBox(height: 16),

                Row(
                  children: [
                    Expanded(
                      child: AppTextField(
                        label: 'Title / Role',
                        hint: 'e.g. Lab Director',
                        controller: _titleController,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: AppTextField(
                        label: 'Contact Number',
                        hint: '+1 (555) 000-0000',
                        controller: _contactNumberController,
                        keyboardType: TextInputType.phone,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 28),

                // Section 2: Institution Details
                Text('Institution & Lab Location', style: AppTypography.titleMedium),
                const SizedBox(height: 12),

                AppTextField(
                  label: 'Institution Name',
                  hint: 'e.g. Stanford University',
                  controller: _institutionNameController,
                  validator: Validators.required,
                  prefixIcon: const Icon(Icons.account_balance_outlined, size: 20),
                ),
                const SizedBox(height: 16),

                // Institution Type Dropdown
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Institution Type',
                      style: AppTypography.titleSmall.copyWith(fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(height: 6),
                    DropdownButtonFormField<String>(
                      value: _institutionType,
                      decoration: const InputDecoration(),
                      items: const [
                        DropdownMenuItem(value: 'university', child: Text('University / College')),
                        DropdownMenuItem(value: 'research_institute', child: Text('Research Institute')),
                        DropdownMenuItem(value: 'hospital', child: Text('Hospital / Clinical Lab')),
                        DropdownMenuItem(value: 'commercial_lab', child: Text('Commercial Laboratory')),
                        DropdownMenuItem(value: 'other', child: Text('Other Scientific Entity')),
                      ],
                      onChanged: (val) {
                        if (val != null) setState(() => _institutionType = val);
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                AppTextField(
                  label: 'Department',
                  hint: 'e.g. Department of Bioengineering',
                  controller: _departmentController,
                ),
                const SizedBox(height: 16),

                Row(
                  children: [
                    Expanded(
                      child: AppTextField(
                        label: 'City',
                        hint: 'e.g. Stanford',
                        controller: _cityController,
                        validator: Validators.required,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: AppTextField(
                        label: 'State',
                        hint: 'e.g. CA',
                        controller: _stateController,
                        validator: Validators.required,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 32),

                // Submit Button
                AppButton(
                  text: 'Create Account',
                  width: double.infinity,
                  isLoading: _isLoading,
                  onPressed: _handleRegister,
                ),
                const SizedBox(height: 20),

                // Back to Login
                Center(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Already have an account?',
                        style: AppTypography.bodyMedium,
                      ),
                      TextButton(
                        onPressed: () => context.pop(),
                        child: Text(
                          'Sign In',
                          style: AppTypography.labelMedium.copyWith(
                            color: AppColors.deepForest,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
