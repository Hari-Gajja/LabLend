import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_app/core/theme/app_colors.dart';
import 'package:flutter_app/core/utils/formatters.dart';

void main() {
  group('Theme & Design System Tests', () {
    test('AppColors tokens should match the Loop & Tie inspired palette', () {
      expect(AppColors.primaryInk, const Color(0xFF20251F));
      expect(AppColors.secondaryText, const Color(0xFF686D65));
      expect(AppColors.warmOffWhite, const Color(0xFFF7F7F2));
      expect(AppColors.pureWhite, const Color(0xFFFFFFFF));
      expect(AppColors.softSage, const Color(0xFFDCE8D7));
      expect(AppColors.mutedGreenAccent, const Color(0xFF66866A));
      expect(AppColors.paleSand, const Color(0xFFEEE8DB));
      expect(AppColors.border, const Color(0xFFE5E6DF));
      expect(AppColors.success, const Color(0xFF36764B));
      expect(AppColors.warning, const Color(0xFFA86D22));
      expect(AppColors.error, const Color(0xFFB54747));
    });

    test('Color system integrity and contrast checks', () {
      expect(AppColors.deepForest.computeLuminance() < 0.2, isTrue); // Dark primary
      expect(AppColors.warmOffWhite.computeLuminance() > 0.8, isTrue); // Light canvas
    });

    test('Formatters format currency, dates, and labels accurately', () {
      expect(Formatters.formatCurrency(120), '\$120');
      expect(Formatters.formatCurrency(42000), '\$42,000');
      expect(Formatters.getCategoryLabel('microscopy'), 'Microscopy');
      expect(Formatters.getCategoryLabel('centrifugation'), 'Centrifugation');
      expect(Formatters.getConditionLabel('like_new'), 'Like New');
    });
  });
}
