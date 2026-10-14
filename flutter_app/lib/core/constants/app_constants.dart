class AppConstants {
  AppConstants._();

  static const String appName = 'LabLend';
  static const String appTagline = 'Better access to science.';

  // Categories with display names and icons
  static const List<Map<String, String>> categories = [
    {'id': 'microscopy', 'label': 'Microscopy', 'icon': 'biotech'},
    {'id': 'spectroscopy', 'label': 'Spectroscopy', 'icon': 'wb_iridescent'},
    {'id': 'centrifugation', 'label': 'Centrifugation', 'icon': 'rotate_right'},
    {'id': 'chromatography', 'label': 'Chromatography', 'icon': 'science'},
    {'id': 'thermal_analysis', 'label': 'Thermal Analysis', 'icon': 'thermostat'},
    {'id': 'electronics', 'label': 'Electronics', 'icon': 'memory'},
    {'id': 'cell_culture', 'label': 'Cell Culture', 'icon': 'bubble_chart'},
    {'id': 'analytical_chemistry', 'label': 'Analytical Chem', 'icon': 'scale'},
    {'id': 'general_lab', 'label': 'General Lab', 'icon': 'home_repair_service'},
  ];

  // Equipment Conditions
  static const List<Map<String, String>> conditions = [
    {'id': 'like_new', 'label': 'Like New'},
    {'id': 'excellent', 'label': 'Excellent'},
    {'id': 'good', 'label': 'Good'},
    {'id': 'fair', 'label': 'Fair'},
  ];

  // Listing Types
  static const List<Map<String, String>> listingTypes = [
    {'id': 'rent', 'label': 'For Rent'},
    {'id': 'buy', 'label': 'For Purchase'},
    {'id': 'both', 'label': 'Rent & Buy'},
  ];

  // Pricing Units
  static const List<Map<String, String>> pricingUnits = [
    {'id': 'hour', 'label': 'per hour'},
    {'id': 'day', 'label': 'per day'},
    {'id': 'week', 'label': 'per week'},
    {'id': 'month', 'label': 'per month'},
  ];

  // Secure storage keys
  static const String tokenStorageKey = 'lablend_jwt_token';
  static const String userStorageKey = 'lablend_user_data';
  static const String onboardingCompletedKey = 'lablend_onboarding_done';
}
