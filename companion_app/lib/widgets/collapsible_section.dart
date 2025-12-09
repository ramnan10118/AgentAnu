import 'package:flutter/material.dart';
import '../utils/shadcn_colors.dart';

class CollapsibleSection extends StatefulWidget {
  final String title;
  final IconData icon;
  final Color iconBackgroundColor;
  final Color iconColor;
  final Widget child;
  final bool initiallyExpanded;

  const CollapsibleSection({
    super.key,
    required this.title,
    required this.icon,
    required this.iconBackgroundColor,
    required this.iconColor,
    required this.child,
    this.initiallyExpanded = false,
  });

  @override
  State<CollapsibleSection> createState() => _CollapsibleSectionState();
}

class _CollapsibleSectionState extends State<CollapsibleSection>
    with SingleTickerProviderStateMixin {
  late bool _isExpanded;
  late AnimationController _controller;
  late Animation<double> _iconTurns;
  late Animation<double> _heightFactor;

  @override
  void initState() {
    super.initState();
    _isExpanded = widget.initiallyExpanded;
    _controller = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    _iconTurns = Tween<double>(begin: 0.0, end: 0.5).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
    _heightFactor = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    );

    if (_isExpanded) {
      _controller.value = 1.0;
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _handleTap() {
    setState(() {
      _isExpanded = !_isExpanded;
      if (_isExpanded) {
        _controller.forward();
      } else {
        _controller.reverse();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
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
      clipBehavior: Clip.antiAlias,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Header
          InkWell(
            onTap: _handleTap,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: widget.iconBackgroundColor,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(
                      widget.icon,
                      size: 20,
                      color: widget.iconColor,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      widget.title,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: ShadcnColors.foreground,
                      ),
                    ),
                  ),
                  RotationTransition(
                    turns: _iconTurns,
                    child: const Icon(
                      Icons.keyboard_arrow_down,
                      color: ShadcnColors.mutedForeground,
                    ),
                  ),
                ],
              ),
            ),
          ),
          // Expandable content
          ClipRect(
            child: AnimatedBuilder(
              animation: _heightFactor,
              builder: (context, child) {
                return Align(
                  alignment: Alignment.topCenter,
                  heightFactor: _heightFactor.value,
                  child: child,
                );
              },
              child: Column(
                children: [
                  Divider(height: 1, color: ShadcnColors.border),
                  widget.child,
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// Helper widget for displaying asset items within collapsible section
class AssetItemTile extends StatelessWidget {
  final String title;
  final String subtitle;
  final String amount;
  final bool isNegative;

  const AssetItemTile({
    super.key,
    required this.title,
    required this.subtitle,
    required this.amount,
    this.isNegative = false,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: ShadcnColors.foreground,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: const TextStyle(
                    fontSize: 12,
                    color: ShadcnColors.mutedForeground,
                  ),
                ),
              ],
            ),
          ),
          Text(
            amount,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: isNegative ? ShadcnColors.destructive : ShadcnColors.foreground,
            ),
          ),
        ],
      ),
    );
  }
}

// Loan Detail Card with full loan information
class LoanDetailCard extends StatelessWidget {
  final dynamic loan; // AssetModel

  const LoanDetailCard({super.key, required this.loan});

  String _formatCurrency(double amount) {
    return '₹${amount.toStringAsFixed(0).replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (Match m) => '${m[1]},',
    )}';
  }

  @override
  Widget build(BuildContext context) {
    final details = loan.details;
    final loanType = details['loanType'] as String? ?? 'Loan';
    final purpose = details['purpose'] as String? ?? 'N/A';
    final outstanding = loan.value < 0 ? -loan.value : loan.value;
    final originalAmount = (details['originalAmount'] as num?)?.toDouble() ?? 0.0;
    final paidAmount = (details['paidAmount'] as num?)?.toDouble() ?? 0.0;
    final emi = (details['emi'] as num?)?.toDouble() ?? 0.0;
    final remainingMonths = (details['remainingMonths'] as num?)?.toInt() ?? 0;
    final tenure = (details['tenure'] as num?)?.toInt() ?? 0;
    
    final progressPercent = originalAmount > 0 ? (paidAmount / originalAmount * 100).clamp(0.0, 100.0) : 0.0;
    
    String purposeIcon = '💼';
    if (purpose.toLowerCase().contains('house') || purpose.toLowerCase().contains('home')) {
      purposeIcon = '🏠';
    } else if (purpose.toLowerCase().contains('car') || purpose.toLowerCase().contains('vehicle')) {
      purposeIcon = '🚗';
    }

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(14),
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          purposeIcon,
                          style: const TextStyle(fontSize: 18),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          loanType,
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                            color: ShadcnColors.foreground,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      loan.provider,
                      style: const TextStyle(
                        fontSize: 12,
                        color: ShadcnColors.mutedForeground,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: ShadcnColors.primary.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        purpose,
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w500,
                          color: ShadcnColors.primary,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    _formatCurrency(outstanding),
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: ShadcnColors.destructive,
                    ),
                  ),
                  const Text(
                    'Outstanding',
                    style: TextStyle(
                      fontSize: 11,
                      color: ShadcnColors.mutedForeground,
                    ),
                  ),
                ],
              ),
            ],
          ),
          
          const SizedBox(height: 12),
          Divider(height: 1, color: ShadcnColors.border),
          const SizedBox(height: 12),
          
          // Progress section
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Original Amount',
                    style: TextStyle(
                      fontSize: 11,
                      color: ShadcnColors.mutedForeground,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    _formatCurrency(originalAmount),
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: ShadcnColors.foreground,
                    ),
                  ),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  const Text(
                    'Amount Paid',
                    style: TextStyle(
                      fontSize: 11,
                      color: ShadcnColors.mutedForeground,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    _formatCurrency(paidAmount),
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF10B981),
                    ),
                  ),
                ],
              ),
            ],
          ),
          
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: progressPercent / 100,
              minHeight: 6,
              backgroundColor: ShadcnColors.muted,
              valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF10B981)),
            ),
          ),
          const SizedBox(height: 4),
          Center(
            child: Text(
              '${progressPercent.toStringAsFixed(1)}% paid',
              style: const TextStyle(
                fontSize: 10,
                color: ShadcnColors.mutedForeground,
              ),
            ),
          ),
          
          const SizedBox(height: 12),
          Divider(height: 1, color: ShadcnColors.border),
          const SizedBox(height: 12),
          
          // EMI details
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              Expanded(
                child: Column(
                  children: [
                    const Text(
                      'EMI',
                      style: TextStyle(
                        fontSize: 11,
                        color: ShadcnColors.mutedForeground,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _formatCurrency(emi),
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: ShadcnColors.foreground,
                      ),
                    ),
                  ],
                ),
              ),
              Container(width: 1, height: 30, color: ShadcnColors.border),
              Expanded(
                child: Column(
                  children: [
                    const Text(
                      'Remaining',
                      style: TextStyle(
                        fontSize: 11,
                        color: ShadcnColors.mutedForeground,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '$remainingMonths months',
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: ShadcnColors.foreground,
                      ),
                    ),
                  ],
                ),
              ),
              Container(width: 1, height: 30, color: ShadcnColors.border),
              Expanded(
                child: Column(
                  children: [
                    const Text(
                      'Total Tenure',
                      style: TextStyle(
                        fontSize: 11,
                        color: ShadcnColors.mutedForeground,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '$tenure months',
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: ShadcnColors.foreground,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

