import 'package:flutter/material.dart';

class AppConstants {
  // Colors
  static const Color primaryColor = Color(0xFFE87B5A); // Coral orange CTA color
  static const Color secondaryColor = Color(0xFFF59E0B);
  static const Color successColor = Color(0xFF10B981);
  static const Color errorColor = Color(0xFFEF4444);
  static const Color backgroundColor = Color(0xFFF9FAFB);
  
  // Spacing
  static const double spacingXS = 4.0;
  static const double spacingSM = 8.0;
  static const double spacingMD = 16.0;
  static const double spacingLG = 24.0;
  static const double spacingXL = 32.0;
  
  // Border radius
  static const double radiusSM = 8.0;
  static const double radiusMD = 12.0;
  static const double radiusLG = 16.0;
  
  // Asset types and their icons
  static const Map<String, IconData> assetIcons = {
    'bank_account': Icons.account_balance,
    'mutual_fund': Icons.trending_up,
    'insurance': Icons.security,
    'fd': Icons.savings,
    'nps': Icons.account_balance_wallet,
    'securities': Icons.show_chart,
  };
  
  // Relationship options
  static const List<String> relationships = [
    'spouse',
    'child',
    'parent',
    'sibling',
    'other',
  ];
}

