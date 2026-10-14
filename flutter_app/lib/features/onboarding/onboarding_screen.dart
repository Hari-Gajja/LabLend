import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:go_router/go_router.dart';
import '../../core/constants/app_constants.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../../widgets/app_button.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentIndex = 0;

  final List<Map<String, dynamic>> _slides = [
    {
      'title': 'Curated scientific discovery.',
      'subtitle':
          'Access specialized instrumentation from leading universities and research institutes without capital barriers.',
      'icon': Icons.explore_outlined,
      'badge': 'INSTITUTIONAL NETWORK',
    },
    {
      'title': 'Verified collaboration.',
      'subtitle':
          'Transparent reservations, clear rental schedules, and peer-to-peer coordination between verified researchers.',
      'icon': Icons.handshake_outlined,
      'badge': 'TRUST & COMPLIANCE',
    },
    {
      'title': 'Maximize research impact.',
      'subtitle':
          'Lend underutilized equipment to accelerate shared scientific discovery and support laboratory operations.',
      'icon': Icons.hub_outlined,
      'badge': 'RESOURCE MOBILIZATION',
    },
  ];

  Future<void> _completeOnboarding(String destination) async {
    const storage = FlutterSecureStorage();
    await storage.write(key: AppConstants.onboardingCompletedKey, value: 'true');
    if (!mounted) return;
    context.go(destination);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.warmOffWhite,
      appBar: AppBar(
        actions: [
          TextButton(
            onPressed: () => _completeOnboarding('/login'),
            child: Text(
              'Skip',
              style: AppTypography.labelMedium.copyWith(color: AppColors.secondaryText),
            ),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          child: Column(
            children: [
              // Page View
              Expanded(
                child: PageView.builder(
                  controller: _pageController,
                  itemCount: _slides.length,
                  onPageChanged: (index) {
                    setState(() {
                      _currentIndex = index;
                    });
                  },
                  itemBuilder: (context, index) {
                    final slide = _slides[index];
                    return Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Category Pill
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                          decoration: BoxDecoration(
                            color: AppColors.softSage,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            slide['badge'],
                            style: AppTypography.labelSmall.copyWith(
                              color: AppColors.deepForest,
                              fontSize: 10,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 0.8,
                            ),
                          ),
                        ),
                        const SizedBox(height: 24),

                        // Center Icon Visual
                        Container(
                          width: 100,
                          height: 100,
                          decoration: BoxDecoration(
                            color: AppColors.pureWhite,
                            borderRadius: BorderRadius.circular(28),
                            border: Border.all(color: AppColors.border),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.04),
                                blurRadius: 16,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Icon(
                            slide['icon'] as IconData,
                            size: 48,
                            color: AppColors.deepForest,
                          ),
                        )
                            .animate(key: ValueKey(index))
                            .scale(duration: 400.ms, curve: Curves.easeOutCubic)
                            .fadeIn(duration: 300.ms),

                        const SizedBox(height: 36),

                        // Title
                        Text(
                          slide['title'],
                          style: AppTypography.displayLarge.copyWith(height: 1.15),
                        )
                            .animate(key: ValueKey('title_$index'))
                            .fadeIn(duration: 400.ms)
                            .slideY(begin: 0.1, end: 0, duration: 400.ms),

                        const SizedBox(height: 16),

                        // Subtitle
                        Text(
                          slide['subtitle'],
                          style: AppTypography.bodyLarge.copyWith(
                            color: AppColors.secondaryText,
                            height: 1.55,
                          ),
                        )
                            .animate(key: ValueKey('sub_$index'))
                            .fadeIn(delay: 100.ms, duration: 400.ms),
                      ],
                    );
                  },
                ),
              ),

              // Page Indicator
              Row(
                children: List.generate(_slides.length, (index) {
                  final isActive = _currentIndex == index;
                  return AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    margin: const EdgeInsets.only(right: 8),
                    height: 6,
                    width: isActive ? 24 : 6,
                    decoration: BoxDecoration(
                      color: isActive ? AppColors.deepForest : AppColors.borderDark,
                      borderRadius: BorderRadius.circular(3),
                    ),
                  );
                }),
              ),

              const SizedBox(height: 32),

              // Action buttons
              Column(
                children: [
                  AppButton(
                    text: _currentIndex == _slides.length - 1 ? 'Get Started' : 'Continue',
                    width: double.infinity,
                    onPressed: () {
                      if (_currentIndex < _slides.length - 1) {
                        _pageController.nextPage(
                          duration: const Duration(milliseconds: 350),
                          curve: Curves.easeOutCubic,
                        );
                      } else {
                        _completeOnboarding('/register');
                      }
                    },
                  ),
                  const SizedBox(height: 12),
                  AppButton(
                    text: 'Sign In to Existing Account',
                    variant: AppButtonVariant.secondary,
                    width: double.infinity,
                    onPressed: () => _completeOnboarding('/login'),
                  ),
                ],
              ),
              const SizedBox(height: 12),
            ],
          ),
        ),
      ),
    );
  }
}
