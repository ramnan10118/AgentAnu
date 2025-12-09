import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

enum AssetCategory {
  bankSavings,
  loans,
  assets,
  mutualFunds,
  stocks,
  digitalGold,
  insurance,
  other,
}

class AssetCategoryCard extends StatelessWidget {
  final AssetCategory category;
  final double amount;
  final int count;
  final String countLabel;
  final VoidCallback? onTap;

  const AssetCategoryCard({
    super.key,
    required this.category,
    required this.amount,
    required this.count,
    required this.countLabel,
    this.onTap,
  });

  String _formatCurrency(double amount) {
    final formatter = NumberFormat.currency(
      locale: 'en_IN',
      symbol: '₹',
      decimalDigits: 0,
    );
    return formatter.format(amount);
  }

  Color get _backgroundColor {
    switch (category) {
      case AssetCategory.bankSavings:
        return const Color(0xFFDBE4FF);
      case AssetCategory.loans:
        return const Color(0xFFFFE3E3);
      case AssetCategory.assets:
        return const Color(0xFFD3F9D8);
      case AssetCategory.mutualFunds:
        return const Color(0xFFE5DBFF);
      case AssetCategory.stocks:
        return const Color(0xFFFFE8CC);
      case AssetCategory.digitalGold:
        return const Color(0xFFFFF3BF);
      case AssetCategory.insurance:
        return const Color(0xFFD0EBFF);
      case AssetCategory.other:
        return const Color(0xFFE9ECEF);
    }
  }

  Color get _iconColor {
    switch (category) {
      case AssetCategory.bankSavings:
        return const Color(0xFF4263EB);
      case AssetCategory.loans:
        return const Color(0xFFFA5252);
      case AssetCategory.assets:
        return const Color(0xFF40C057);
      case AssetCategory.mutualFunds:
        return const Color(0xFF7950F2);
      case AssetCategory.stocks:
        return const Color(0xFFFD7E14);
      case AssetCategory.digitalGold:
        return const Color(0xFFFAB005);
      case AssetCategory.insurance:
        return const Color(0xFF228BE6);
      case AssetCategory.other:
        return const Color(0xFF868E96);
    }
  }

  IconData get _icon {
    switch (category) {
      case AssetCategory.bankSavings:
        return Icons.account_balance;
      case AssetCategory.loans:
        return Icons.payments_outlined;
      case AssetCategory.assets:
        return Icons.home_work_outlined;
      case AssetCategory.mutualFunds:
        return Icons.pie_chart_outline;
      case AssetCategory.stocks:
        return Icons.trending_up;
      case AssetCategory.digitalGold:
        return Icons.monetization_on_outlined;
      case AssetCategory.insurance:
        return Icons.health_and_safety_outlined;
      case AssetCategory.other:
        return Icons.folder_outlined;
    }
  }

  String get _title {
    switch (category) {
      case AssetCategory.bankSavings:
        return 'Bank Savings';
      case AssetCategory.loans:
        return 'Loans';
      case AssetCategory.assets:
        return 'Assets';
      case AssetCategory.mutualFunds:
        return 'Mutual Funds';
      case AssetCategory.stocks:
        return 'Stocks';
      case AssetCategory.digitalGold:
        return 'Digital Gold';
      case AssetCategory.insurance:
        return 'Insurance';
      case AssetCategory.other:
        return 'Other';
    }
  }

  bool get _isLiability => category == AssetCategory.loans;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey.shade200),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Stack(
          children: [
            // Decorative circle
            Positioned(
              top: -16,
              right: -16,
              child: Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: _backgroundColor.withOpacity(0.5),
                ),
              ),
            ),
            // Content
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header row
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        _title,
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          color: Colors.grey.shade600,
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: _backgroundColor,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Icon(
                          _icon,
                          size: 18,
                          color: _iconColor,
                        ),
                      ),
                    ],
                  ),
                  const Spacer(),
                  // Amount
                  Text(
                    _formatCurrency(amount),
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: _isLiability ? const Color(0xFFFA5252) : Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 4),
                  // Count
                  Text(
                    '$count $countLabel',
                    style: TextStyle(
                      fontSize: 11,
                      color: Colors.grey.shade500,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

