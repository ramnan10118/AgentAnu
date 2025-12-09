import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../models/designation_model.dart';
import '../../models/asset_model.dart';
import '../../providers/assets_provider.dart';
import '../../utils/constants.dart';
import '../../utils/shadcn_colors.dart';
import '../../widgets/net_worth_card.dart';
import '../../widgets/asset_category_card.dart';
import '../../widgets/asset_pie_chart.dart';
import '../../widgets/collapsible_section.dart';
import '../../widgets/legacy_info_card.dart';
import '../../widgets/transfer_help_card.dart';

class AssetsRevealedScreen extends ConsumerWidget {
  final DesignationModel designation;

  const AssetsRevealedScreen({
    super.key,
    required this.designation,
  });

  // Group assets by category
  Map<AssetCategory, List<AssetModel>> _groupAssetsByCategory(List<AssetModel> assets) {
    final Map<AssetCategory, List<AssetModel>> grouped = {};
    
    for (final asset in assets) {
      final category = _getAssetCategory(asset.type);
      grouped.putIfAbsent(category, () => []);
      grouped[category]!.add(asset);
    }
    
    return grouped;
  }

  AssetCategory _getAssetCategory(String type) {
    final typeLower = type.toLowerCase();
    
    // Bank accounts and deposits
    if (typeLower.contains('bank') || 
        typeLower.contains('account') ||
        typeLower == 'deposit' ||
        typeLower == 'savings' ||
        typeLower == 'current' ||
        typeLower == 'bank_account') {
      return AssetCategory.bankSavings;
    }
    
    // Loans
    if (typeLower == 'loan' || typeLower.contains('loan')) {
      return AssetCategory.loans;
    }
    
    // Mutual funds
    if (typeLower.contains('mutual') || 
        typeLower.contains('fund') ||
        typeLower == 'mf' ||
        typeLower == 'mutual_fund') {
      return AssetCategory.mutualFunds;
    }
    
    // Stocks and securities
    if (typeLower.contains('stock') ||
        typeLower.contains('equity') ||
        typeLower.contains('share') ||
        typeLower.contains('securities') ||
        typeLower.contains('demat') ||
        typeLower == 'securities') {
      return AssetCategory.stocks;
    }
    
    // Digital gold
    if (typeLower.contains('gold') || 
        typeLower == 'digital_gold') {
      return AssetCategory.digitalGold;
    }
    
    // Insurance
    if (typeLower.contains('insurance')) {
      return AssetCategory.insurance;
    }
    
    // Fixed deposits, PPF, NPS, RD, EPF, etc.
    if (typeLower == 'fd' ||
        typeLower == 'fixed_deposit' ||
        typeLower.contains('fixed') ||
        typeLower == 'ppf' ||
        typeLower == 'nps' ||
        typeLower == 'rd' ||
        typeLower == 'recurring' ||
        typeLower.contains('epf') ||
        typeLower.contains('provident')) {
      return AssetCategory.assets;
    }
    
    // Property and real estate
    if (typeLower.contains('property') ||
        typeLower.contains('house') ||
        typeLower.contains('land') ||
        typeLower.contains('apartment') ||
        typeLower.contains('real_estate') ||
        typeLower.contains('registration')) {
      return AssetCategory.assets;
    }
    
    // Default to other only if truly unknown
    return AssetCategory.other;
  }

  String _formatCurrency(double amount) {
    final formatter = NumberFormat.currency(
      locale: 'en_IN',
      symbol: '₹',
      decimalDigits: 0,
    );
    return formatter.format(amount);
  }

  String _getCountLabel(AssetCategory category) {
    switch (category) {
      case AssetCategory.bankSavings:
        return 'accounts';
      case AssetCategory.loans:
        return 'loans';
      case AssetCategory.mutualFunds:
        return 'funds';
      case AssetCategory.stocks:
        return 'holdings';
      case AssetCategory.digitalGold:
        return 'units';
      case AssetCategory.insurance:
        return 'policies';
      case AssetCategory.assets:
        return 'assets';
      case AssetCategory.other:
        return 'items';
    }
  }

  String _getCategoryName(AssetCategory category) {
    switch (category) {
      case AssetCategory.bankSavings:
        return 'Bank Savings';
      case AssetCategory.loans:
        return 'Loans';
      case AssetCategory.mutualFunds:
        return 'Mutual Funds';
      case AssetCategory.stocks:
        return 'Stocks';
      case AssetCategory.digitalGold:
        return 'Digital Gold';
      case AssetCategory.insurance:
        return 'Insurance';
      case AssetCategory.assets:
        return 'Fixed Assets';
      case AssetCategory.other:
        return 'Miscellaneous';
    }
  }

  Color _getCategoryIconBg(AssetCategory category) {
    switch (category) {
      case AssetCategory.bankSavings:
        return const Color(0xFFDBE4FF);
      case AssetCategory.loans:
        return const Color(0xFFFFE3E3);
      case AssetCategory.mutualFunds:
        return const Color(0xFFE5DBFF);
      case AssetCategory.stocks:
        return const Color(0xFFFFE8CC);
      case AssetCategory.digitalGold:
        return const Color(0xFFFFF3BF);
      case AssetCategory.insurance:
        return const Color(0xFFD0EBFF);
      case AssetCategory.assets:
        return const Color(0xFFD3F9D8);
      case AssetCategory.other:
        return const Color(0xFFE9ECEF);
    }
  }

  Color _getCategoryIconColor(AssetCategory category) {
    switch (category) {
      case AssetCategory.bankSavings:
        return const Color(0xFF4263EB);
      case AssetCategory.loans:
        return const Color(0xFFFA5252);
      case AssetCategory.mutualFunds:
        return const Color(0xFF7950F2);
      case AssetCategory.stocks:
        return const Color(0xFFFD7E14);
      case AssetCategory.digitalGold:
        return const Color(0xFFFAB005);
      case AssetCategory.insurance:
        return const Color(0xFF228BE6);
      case AssetCategory.assets:
        return const Color(0xFF40C057);
      case AssetCategory.other:
        return const Color(0xFF868E96);
    }
  }

  IconData _getCategoryIcon(AssetCategory category) {
    switch (category) {
      case AssetCategory.bankSavings:
        return Icons.account_balance;
      case AssetCategory.loans:
        return Icons.payments_outlined;
      case AssetCategory.mutualFunds:
        return Icons.pie_chart_outline;
      case AssetCategory.stocks:
        return Icons.trending_up;
      case AssetCategory.digitalGold:
        return Icons.monetization_on_outlined;
      case AssetCategory.insurance:
        return Icons.health_and_safety_outlined;
      case AssetCategory.assets:
        return Icons.home_work_outlined;
      case AssetCategory.other:
        return Icons.folder_outlined;
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final assetsState = ref.watch(assetsProvider);

    final groupedAssets = _groupAssetsByCategory(assetsState.assets);
    
    // Calculate totals
    double totalAssets = 0;
    double totalLiabilities = 0;
    
    for (final asset in assetsState.assets) {
      if (asset.type.toLowerCase() == 'loan' || asset.isLiability) {
        totalLiabilities += asset.value < 0 ? -asset.value : asset.value;
      } else {
        totalAssets += asset.value;
      }
    }
    
    final totalNetWorth = totalAssets - totalLiabilities;

    // Build pie chart data
    final pieData = <AssetDistribution>[];
    final colors = [
      const Color(0xFF4263EB), // Bank Savings
      const Color(0xFF40C057), // Assets
      const Color(0xFF7950F2), // Mutual Funds
      const Color(0xFFFD7E14), // Stocks
      const Color(0xFFFAB005), // Digital Gold
      const Color(0xFF228BE6), // Insurance
      const Color(0xFF868E96), // Other
    ];
    
    int colorIndex = 0;
    groupedAssets.forEach((category, assets) {
      if (category != AssetCategory.loans) {
        final total = assets.fold<double>(0, (sum, a) => sum + a.value);
        if (total > 0) {
          pieData.add(AssetDistribution(
            name: _getCategoryName(category),
            value: total,
            color: colors[colorIndex % colors.length],
          ));
          colorIndex++;
        }
      }
    });

    return Scaffold(
      backgroundColor: ShadcnColors.background,
      appBar: AppBar(
        title: const Text(
          'Sunset',
          style: TextStyle(
            color: ShadcnColors.primaryForeground,
            fontWeight: FontWeight.w600,
          ),
        ),
        backgroundColor: ShadcnColors.primary,
        foregroundColor: ShadcnColors.primaryForeground,
        elevation: 0,
      ),
      body: assetsState.isLoading
          ? const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text('Loading assets...'),
                ],
              ),
            )
          : assetsState.error != null
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.error_outline,
                        size: 64,
                        color: AppConstants.errorColor,
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        'Error loading assets',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        assetsState.error!,
                        textAlign: TextAlign.center,
                        style: const TextStyle(color: Colors.grey),
                      ),
                    ],
                  ),
                )
              : CustomScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  slivers: [
                    // Sticky Net Worth Card
                    SliverPersistentHeader(
                      pinned: true,
                      delegate: _NetWorthHeaderDelegate(
                        netWorth: totalNetWorth,
                        totalAssets: totalAssets,
                        totalLiabilities: totalLiabilities,
                        userName: designation.nokName,
                        minHeight: 70,
                        maxHeight: 200,
                      ),
                    ),
                    
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            // Account Holder Info Card - shows whose assets these are
                            _buildAccountHolderCard(),
                            const SizedBox(height: 20),

                            // Assets Overview Header
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                              child: Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(6),
                                    decoration: BoxDecoration(
                                      color: ShadcnColors.muted,
                                      borderRadius: BorderRadius.circular(6),
                                    ),
                                    child: Icon(
                                      Icons.bar_chart,
                                      size: 18,
                                      color: ShadcnColors.primary,
                                    ),
                                  ),
                                  const SizedBox(width: 10),
                                  const Text(
                                    'Assets Overview',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                      color: ShadcnColors.foreground,
                                    ),
                                  ),
                                  const Spacer(),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                    decoration: BoxDecoration(
                                      color: ShadcnColors.muted,
                                      borderRadius: BorderRadius.circular(6),
                                    ),
                                    child: Text(
                                      'Just now',
                                      style: TextStyle(
                                        fontSize: 11,
                                        color: ShadcnColors.mutedForeground,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 4),

                            // Pie Chart
                            if (pieData.isNotEmpty) ...[
                              Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 16),
                                child: Container(
                                  padding: const EdgeInsets.all(16),
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
                                  child: AssetPieChart(distributions: pieData),
                                ),
                              ),
                              const SizedBox(height: 16),
                            ],

                            // Asset Category Cards Grid
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 16),
                              child: GridView.count(
                                crossAxisCount: 3,
                                shrinkWrap: true,
                                physics: const NeverScrollableScrollPhysics(),
                                crossAxisSpacing: 8,
                                mainAxisSpacing: 8,
                                childAspectRatio: 1.5,
                                children: [
                                  _buildCategoryCard(AssetCategory.bankSavings, groupedAssets),
                                  _buildCategoryCard(AssetCategory.loans, groupedAssets),
                                  _buildCategoryCard(AssetCategory.mutualFunds, groupedAssets),
                                  _buildCategoryCard(AssetCategory.stocks, groupedAssets),
                                  _buildCategoryCard(AssetCategory.insurance, groupedAssets),
                                  _buildCategoryCard(AssetCategory.assets, groupedAssets),
                                ],
                              ),
                            ),
                            const SizedBox(height: 24),

                            // Legacy Info Card
                            const LegacyInfoCard(isForNok: true),
                            const SizedBox(height: 24),

                            // Transfer Help Card - CTA for asset transfer assistance
                            const Padding(
                              padding: EdgeInsets.symmetric(horizontal: 16),
                              child: TransferHelpCard(),
                            ),
                            const SizedBox(height: 24),

                            // Claims Guidance Card
                            _buildClaimsGuidanceCard(),
                            const SizedBox(height: 24),

                            // Detailed Breakdown Header
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 16),
                              child: Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(6),
                                    decoration: BoxDecoration(
                                      color: ShadcnColors.muted,
                                      borderRadius: BorderRadius.circular(6),
                                    ),
                                    child: Icon(
                                      Icons.list_alt,
                                      size: 18,
                                      color: ShadcnColors.primary,
                                    ),
                                  ),
                                  const SizedBox(width: 10),
                                  const Text(
                                    'Detailed Asset Breakdown',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                      color: ShadcnColors.foreground,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 16),

                            // Collapsible Sections for each category
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 16),
                              child: Column(
                                children: [
                                  if (groupedAssets[AssetCategory.bankSavings] != null && groupedAssets[AssetCategory.bankSavings]!.isNotEmpty)
                                    Padding(
                                      padding: const EdgeInsets.only(bottom: 12),
                                      child: _buildCollapsibleSection(context, AssetCategory.bankSavings, groupedAssets[AssetCategory.bankSavings]!),
                                    ),
                                  if (groupedAssets[AssetCategory.loans] != null && groupedAssets[AssetCategory.loans]!.isNotEmpty)
                                    Padding(
                                      padding: const EdgeInsets.only(bottom: 12),
                                      child: _buildCollapsibleSection(context, AssetCategory.loans, groupedAssets[AssetCategory.loans]!),
                                    ),
                                  if (groupedAssets[AssetCategory.mutualFunds] != null && groupedAssets[AssetCategory.mutualFunds]!.isNotEmpty)
                                    Padding(
                                      padding: const EdgeInsets.only(bottom: 12),
                                      child: _buildCollapsibleSection(context, AssetCategory.mutualFunds, groupedAssets[AssetCategory.mutualFunds]!),
                                    ),
                                  if (groupedAssets[AssetCategory.stocks] != null && groupedAssets[AssetCategory.stocks]!.isNotEmpty)
                                    Padding(
                                      padding: const EdgeInsets.only(bottom: 12),
                                      child: _buildCollapsibleSection(context, AssetCategory.stocks, groupedAssets[AssetCategory.stocks]!),
                                    ),
                                  if (groupedAssets[AssetCategory.insurance] != null && groupedAssets[AssetCategory.insurance]!.isNotEmpty)
                                    Padding(
                                      padding: const EdgeInsets.only(bottom: 12),
                                      child: _buildCollapsibleSection(context, AssetCategory.insurance, groupedAssets[AssetCategory.insurance]!),
                                    ),
                                  if (groupedAssets[AssetCategory.digitalGold] != null && groupedAssets[AssetCategory.digitalGold]!.isNotEmpty)
                                    Padding(
                                      padding: const EdgeInsets.only(bottom: 12),
                                      child: _buildCollapsibleSection(context, AssetCategory.digitalGold, groupedAssets[AssetCategory.digitalGold]!),
                                    ),
                                  if (groupedAssets[AssetCategory.assets] != null && groupedAssets[AssetCategory.assets]!.isNotEmpty)
                                    Padding(
                                      padding: const EdgeInsets.only(bottom: 12),
                                      child: _buildCollapsibleSection(context, AssetCategory.assets, groupedAssets[AssetCategory.assets]!),
                                    ),
                                  if (groupedAssets[AssetCategory.other] != null && groupedAssets[AssetCategory.other]!.isNotEmpty)
                                    Padding(
                                      padding: const EdgeInsets.only(bottom: 12),
                                      child: _buildCollapsibleSection(context, AssetCategory.other, groupedAssets[AssetCategory.other]!),
                                    ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 24),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
    );
  }

  Widget _buildAccountHolderCard() {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFD3F9D8),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFF40C057).withOpacity(0.3)),
      ),
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: const Color(0xFF40C057).withOpacity(0.2),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(
              Icons.account_circle,
              color: Color(0xFF40C057),
              size: 24,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'This is ${designation.accountHolderName ?? "Unknown"}\'s Legacy',
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF2B8A3E),
                  ),
                ),
                const SizedBox(height: 2),
                const Text(
                  'Assets verified and ready for transfer',
                  style: TextStyle(
                    fontSize: 12,
                    color: Color(0xFF2B8A3E),
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: const Color(0xFF40C057),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              designation.relationship,
              style: const TextStyle(
                fontSize: 11,
                color: Colors.white,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildClaimsGuidanceCard() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Container(
        padding: const EdgeInsets.all(16),
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
            Row(
              children: [
                Icon(Icons.info_outline, color: ShadcnColors.primary, size: 18),
                const SizedBox(width: 8),
                const Text(
                  'Claims Guidance',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: ShadcnColors.foreground,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            const Text(
              'Tap on any asset in the breakdown below for detailed step-by-step claims guidance specific to each provider.',
              style: TextStyle(
                fontSize: 12,
                color: ShadcnColors.mutedForeground,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoryCard(
    AssetCategory category,
    Map<AssetCategory, List<AssetModel>> groupedAssets,
  ) {
    final assets = groupedAssets[category] ?? [];
    // For loans, use absolute value since they're negative
    final total = assets.fold<double>(0, (sum, a) => sum + (a.value < 0 ? -a.value : a.value));
    
    return AssetCategoryCard(
      category: category,
      amount: total,
      count: assets.length,
      countLabel: _getCountLabel(category),
      assets: category == AssetCategory.loans ? assets : null,
    );
  }

  Widget _buildCollapsibleSection(
    BuildContext context,
    AssetCategory category,
    List<AssetModel> assets,
  ) {
    return CollapsibleSection(
      title: _getCategoryName(category),
      icon: _getCategoryIcon(category),
      iconBackgroundColor: _getCategoryIconBg(category),
      iconColor: _getCategoryIconColor(category),
      child: Column(
        children: assets.map((asset) {
          // Special handling for loans
          if (category == AssetCategory.loans) {
            return LoanDetailCard(loan: asset);
          }
          // Regular asset items with claims
          return _AssetItemWithClaim(
            asset: asset,
            isNegative: category == AssetCategory.loans,
          );
        }).toList(),
      ),
    );
  }
}

// Sticky Net Worth Header Delegate (same as main app)
class _NetWorthHeaderDelegate extends SliverPersistentHeaderDelegate {
  final double netWorth;
  final double totalAssets;
  final double totalLiabilities;
  final String? userName;
  final double minHeight;
  final double maxHeight;

  _NetWorthHeaderDelegate({
    required this.netWorth,
    required this.totalAssets,
    required this.totalLiabilities,
    this.userName,
    required this.minHeight,
    required this.maxHeight,
  });

  @override
  double get minExtent => minHeight;

  @override
  double get maxExtent => maxHeight;

  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) {
    final heightDiff = maxHeight - minHeight;
    final progress = heightDiff > 0 ? (shrinkOffset / heightDiff).clamp(0.0, 1.0) : 0.0;
    final isCollapsed = progress > 0.5;
    final currentHeight = maxHeight - shrinkOffset;
    final actualHeight = currentHeight.clamp(minHeight, maxHeight);

    String formatCurrency(double amount) {
      final formatter = NumberFormat.currency(
        locale: 'en_IN',
        symbol: '₹',
        decimalDigits: 0,
      );
      return formatter.format(amount);
    }

    return StatefulBuilder(
      builder: (context, setState) {
        bool isHovered = false;

        return SizedBox(
          height: actualHeight,
          child: MouseRegion(
            onEnter: (_) => setState(() => isHovered = true),
            onExit: (_) => setState(() => isHovered = false),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              decoration: BoxDecoration(
                gradient: RadialGradient(
                  center: const Alignment(-0.8, -0.8),
                  radius: 1.5,
                  colors: [
                    isHovered ? const Color(0xFFE88B5F) : const Color(0xFFD97A4A),  // Warm orange-brown center glow (brightens on hover)
                    const Color(0xFFB8613A),  // Mid-tone brown
                    const Color(0xFF8B4A2F),  // Darker brown
                    const Color(0xFF3D2516),  // Very dark brown
                    const Color(0xFF1A1A1A),  // Near black edges
                  ],
                  stops: const [0.0, 0.25, 0.5, 0.75, 1.0],
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 16, vertical: isCollapsed ? 8 : 16),
          child: isCollapsed
            ? Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _StickySummaryItem(
                    label: 'Net Worth',
                    value: netWorth,
                    formatter: formatCurrency,
                  ),
                  Container(width: 1, height: 30, color: Colors.white.withOpacity(0.2)),
                  _StickySummaryItem(
                    label: 'Assets',
                    value: totalAssets,
                    formatter: formatCurrency,
                  ),
                  Container(width: 1, height: 30, color: Colors.white.withOpacity(0.2)),
                  _StickySummaryItem(
                    label: 'Liabilities',
                    value: totalLiabilities,
                    formatter: formatCurrency,
                  ),
                ],
              )
            : Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    children: [
                      Icon(Icons.account_balance_wallet, color: Colors.white.withOpacity(0.9), size: 18),
                      const SizedBox(width: 8),
                      Text(
                        userName != null ? 'Welcome, $userName' : 'Legacy Assets',
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.9),
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        flex: 2,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Total Net Worth',
                              style: TextStyle(
                                color: Colors.white.withOpacity(0.7),
                                fontSize: 12,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              formatCurrency(netWorth),
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 32,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Legacy assets to be transferred',
                              style: TextStyle(
                                color: Colors.white.withOpacity(0.6),
                                fontSize: 11,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Container(width: 1, height: 60, color: Colors.white.withOpacity(0.2)),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Total Assets',
                              style: TextStyle(
                                color: Colors.white.withOpacity(0.7),
                                fontSize: 11,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              formatCurrency(totalAssets),
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 12),
                            Text(
                              'Liabilities',
                              style: TextStyle(
                                color: Colors.white.withOpacity(0.7),
                                fontSize: 11,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              formatCurrency(totalLiabilities),
                              style: TextStyle(
                                color: Colors.red.shade200,
                                fontSize: 18,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
        ),
            ),
          ),
        );
      },
    );
  }

  @override
  bool shouldRebuild(_NetWorthHeaderDelegate oldDelegate) {
    return oldDelegate.netWorth != netWorth ||
        oldDelegate.totalAssets != totalAssets ||
        oldDelegate.totalLiabilities != totalLiabilities;
  }
}

class _StickySummaryItem extends StatelessWidget {
  final String label;
  final double value;
  final String Function(double) formatter;

  const _StickySummaryItem({
    required this.label,
    required this.value,
    required this.formatter,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          label,
          style: TextStyle(
            color: Colors.white.withOpacity(0.75),
            fontSize: 10,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          formatter(value),
          style: const TextStyle(
            color: Colors.white,
            fontSize: 14,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}

class _AssetItemWithClaim extends StatelessWidget {
  final AssetModel asset;
  final bool isNegative;

  const _AssetItemWithClaim({
    required this.asset,
    this.isNegative = false,
  });

  String _formatCurrency(double amount) {
    final formatter = NumberFormat.currency(
      locale: 'en_IN',
      symbol: '₹',
      decimalDigits: 0,
    );
    return formatter.format(amount);
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => _showClaimsGuidance(context),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    asset.provider,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    asset.accountNumber ?? asset.assetTypeLabel,
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey.shade600,
                    ),
                  ),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  _formatCurrency(asset.value),
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: isNegative ? const Color(0xFFFA5252) : Colors.black87,
                  ),
                ),
                const SizedBox(height: 2),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.help_outline,
                      size: 12,
                      color: Colors.grey.shade500,
                    ),
                    const SizedBox(width: 2),
                    Text(
                      'Tap for claims',
                      style: TextStyle(
                        fontSize: 10,
                        color: Colors.grey.shade500,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _showClaimsGuidance(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: BoxDecoration(
          color: ShadcnColors.card,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        ),
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Handle bar
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: ShadcnColors.mutedForeground.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 20),
            // Header
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: ShadcnColors.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    Icons.help_outline,
                    color: ShadcnColors.primary,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Claims Guidance',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Text(
                        asset.provider,
                        style: TextStyle(
                          fontSize: 13,
                          color: ShadcnColors.mutedForeground,
                        ),
                      ),
                    ],
                  ),
                ),
                Text(
                  _formatCurrency(asset.value),
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: ShadcnColors.primary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            // Steps
            _buildStep(1, 'Collect Documents', 
              'Death certificate, proof of relationship, identity proof, claimant bank details'),
            _buildStep(2, 'Contact Provider', 
              'Reach out to ${asset.provider} customer service or visit branch'),
            _buildStep(3, 'Submit Claim', 
              'Fill out claim form and submit with all required documents'),
            _buildStep(4, 'Verification', 
              'Wait for verification process (typically 15-30 days)'),
            _buildStep(5, 'Receive Assets', 
              'Assets will be transferred to your account after approval'),
            const SizedBox(height: 16),
            // Close button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => Navigator.pop(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: ShadcnColors.primary,
                  foregroundColor: ShadcnColors.primaryForeground,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(ShadcnColors.radius),
                  ),
                  elevation: 0,
                ),
                child: const Text('Got it'),
              ),
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  Widget _buildStep(int number, String title, String description) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 28,
            height: 28,
            decoration: BoxDecoration(
              color: ShadcnColors.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Center(
              child: Text(
                '$number',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: ShadcnColors.primary,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  description,
                  style: TextStyle(
                    fontSize: 12,
                    color: ShadcnColors.mutedForeground,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
