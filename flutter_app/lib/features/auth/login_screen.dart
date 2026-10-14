import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../../core/utils/validators.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/app_button.dart';
import '../../widgets/app_text_field.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;
  String? _errorMessage;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    final success = await ref.read(authNotifierProvider.notifier).login(
          _emailController.text.trim(),
          _passwordController.text,
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
        _errorMessage = authState.errorMessage ?? 'Login failed. Please check your credentials.';
      });
    }
  }

  void _fillDemoCredentials(String email, String password) {
    _emailController.text = email;
    _passwordController.text = password;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.warmOffWhite,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go('/onboarding'),
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
                // Editorial Tag
                Text(
                  'WELCOME BACK',
                  style: AppTypography.labelSmall.copyWith(
                    color: AppColors.deepForest,
                    letterSpacing: 1.0,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 6),

                // Screen Title
                Text(
                  'Sign in to your lab account.',
                  style: AppTypography.displayLarge,
                ),
                const SizedBox(height: 8),

                Text(
                  'Access equipment listings, reservations, and institutional collaboration tools.',
                  style: AppTypography.bodyMedium,
                ),
                const SizedBox(height: 32),

                // Error Message banner
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

                // Email field
                AppTextField(
                  label: 'Institutional Email',
                  hint: 'name@university.edu',
                  controller: _emailController,
                  validator: Validators.email,
                  keyboardType: TextInputType.emailAddress,
                  prefixIcon: const Icon(Icons.alternate_email, size: 20),
                ),
                const SizedBox(height: 20),

                // Password field
                AppTextField(
                  label: 'Password',
                  hint: 'Enter your account password',
                  controller: _passwordController,
                  validator: Validators.password,
                  isPassword: true,
                  prefixIcon: const Icon(Icons.lock_outline, size: 20),
                ),
                const SizedBox(height: 8),

                // Forgot Password link
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: () => context.push('/forgot-password'),
                    child: Text(
                      'Forgot password?',
                      style: AppTypography.labelMedium.copyWith(color: AppColors.deepForest),
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                // Submit Button
                AppButton(
                  text: 'Sign In',
                  width: double.infinity,
                  isLoading: _isLoading,
                  onPressed: _handleLogin,
                ),
                const SizedBox(height: 24),

                // Demo Accounts Box for Evaluators
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: AppColors.paleSand.withOpacity(0.6),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.warmStone),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.bolt, size: 16, color: AppColors.warning),
                          const SizedBox(width: 6),
                          Text(
                            'Quick Demo Accounts (1-Tap Fill)',
                            style: AppTypography.labelSmall.copyWith(
                              color: AppColors.primaryInk,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: [
                          ActionChip(
                            label: const Text('Stanford (Elena)'),
                            backgroundColor: AppColors.pureWhite,
                            onPressed: () => _fillDemoCredentials(
                              'erostova@stanford.edu',
                              'Password123!',
                            ),
                          ),
                          ActionChip(
                            label: const Text('MIT (Marcus)'),
                            backgroundColor: AppColors.pureWhite,
                            onPressed: () => _fillDemoCredentials(
                              'mchen@mit.edu',
                              'Password123!',
                            ),
                          ),
                          ActionChip(
                            label: const Text('Salk (Julian)'),
                            backgroundColor: AppColors.pureWhite,
                            onPressed: () => _fillDemoCredentials(
                              'jvance@salk.edu',
                              'Password123!',
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // Switch to Register
                Center(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Don\'t have an account?',
                        style: AppTypography.bodyMedium,
                      ),
                      TextButton(
                        onPressed: () => context.push('/register'),
                        child: Text(
                          'Register lab',
                          style: AppTypography.labelMedium.copyWith(
                            color: AppColors.deepForest,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
