import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../utils/shadcn_colors.dart';

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

class AssetCategoryCard extends StatefulWidget {
  final AssetCategory category;
  final double amount;
  final int count;
  final String countLabel;
  final List<dynamic>? assets; // For loan summary on flip

  const AssetCategoryCard({
    super.key,
    required this.category,
    required this.amount,
    required this.count,
    required this.countLabel,
    this.assets,
  });

  @override
  State<AssetCategoryCard> createState() => _AssetCategoryCardState();
}

class _AssetCategoryCardState extends State<AssetCategoryCard> {
  bool _isFlipped = false;

  String _formatCurrency(double amount) {
    final formatter = NumberFormat.currency(
      locale: 'en_IN',
      symbol: '₹',
      decimalDigits: 0,
    );
    return formatter.format(amount);
  }

  Color get _backgroundColor {
    switch (widget.category) {
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
    switch (widget.category) {
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
    switch (widget.category) {
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
    switch (widget.category) {
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

  bool get _isLiability => widget.category == AssetCategory.loans;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => setState(() => _isFlipped = !_isFlipped),
      child: TweenAnimationBuilder<double>(
        tween: Tween(begin: 0.0, end: _isFlipped ? 1.0 : 0.0),
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOut,
        builder: (context, value, child) {
          return Transform(
            alignment: Alignment.center,
            transform: Matrix4.identity()
              ..setEntry(3, 2, 0.001)
              ..rotateY(value * 3.14159),
            child: value < 0.5
                ? _buildFront()
                : Transform(
                    alignment: Alignment.center,
                    transform: Matrix4.identity()..rotateY(3.14159),
                    child: _buildBack(),
                  ),
          );
        },
      ),
    );
  }

  Widget _buildFront() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.shade200, width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 4,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child:                       Text(
                        _title,
                        style: const TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w500,
                          color: ShadcnColors.mutedForeground,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                ),
                Container(
                  padding: const EdgeInsets.all(3),
                  decoration: BoxDecoration(
                    color: _backgroundColor,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Icon(
                    _icon,
                    size: 11,
                    color: _iconColor,
                  ),
                ),
              ],
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _formatCurrency(widget.amount),
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: _isLiability ? ShadcnColors.destructive : ShadcnColors.foreground,
                    height: 1.0,
                  ),
                ),
                const SizedBox(height: 1),
                Text(
                  '${widget.count} ${widget.countLabel}',
                  style: const TextStyle(
                    fontSize: 9,
                    color: ShadcnColors.mutedForeground,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBack() {
    if (widget.category == AssetCategory.loans && widget.assets != null && widget.assets!.isNotEmpty) {
      return _buildLoanSummary();
    }
    
    return Container(
      decoration: BoxDecoration(
        color: ShadcnColors.card,
        borderRadius: BorderRadius.circular(ShadcnColors.radius),
        border: Border.all(color: ShadcnColors.border, width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 4,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(10),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              _title,
              style: const TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w600,
                color: ShadcnColors.foreground,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 6),
            Text(
              '${widget.count}',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: _iconColor,
              ),
            ),
            Text(
              widget.countLabel,
              style: const TextStyle(
                fontSize: 9,
                color: ShadcnColors.mutedForeground,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLoanSummary() {
    final loans = widget.assets!;
    final totalEMI = loans.fold<double>(0.0, (sum, loan) {
      final emi = (loan.details['emi'] as num?)?.toDouble() ?? 0.0;
      return sum + emi;
    });
    
    final avgRemainingMonths = loans.isEmpty ? 0 : (loans.fold<int>(0, (sum, loan) {
      final months = (loan.details['remainingMonths'] as num?)?.toInt() ?? 0;
      return sum + months;
    }) / loans.length).round();

    return Container(
      decoration: BoxDecoration(
        color: ShadcnColors.card,
        borderRadius: BorderRadius.circular(ShadcnColors.radius),
        border: Border.all(color: ShadcnColors.border, width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 4,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(10),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              _title,
              style: const TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w600,
                color: ShadcnColors.foreground,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 6),
            Text(
              '${loans.length}',
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: ShadcnColors.destructive,
              ),
            ),
            const Text(
              'loans',
              style: TextStyle(
                fontSize: 9,
                color: ShadcnColors.mutedForeground,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              '₹${totalEMI.toStringAsFixed(0).replaceAllMapped(
                RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
                (Match m) => '${m[1]},',
              )}/mo',
              style: const TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w600,
                color: ShadcnColors.mutedForeground,
              ),
            ),
            Text(
              '$avgRemainingMonths months left',
              style: const TextStyle(
                fontSize: 9,
                color: ShadcnColors.mutedForeground,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

