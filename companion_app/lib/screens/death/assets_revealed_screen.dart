import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../models/designation_model.dart';
import '../../models/asset_model.dart';
import '../../providers/assets_provider.dart';
import '../../utils/constants.dart';
import '../../widgets/net_worth_card.dart';
import '../../widgets/asset_category_card.dart';
import '../../widgets/asset_pie_chart.dart';
import '../../widgets/collapsible_section.dart';
import '../../widgets/legacy_info_card.dart';

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
    switch (type.toLowerCase()) {
      case 'deposit':
      case 'savings':
      case 'current':
        return AssetCategory.bankSavings;
      case 'loan':
        return AssetCategory.loans;
      case 'mutual_fund':
      case 'mf':
        return AssetCategory.mutualFunds;
      case 'equity':
      case 'stock':
      case 'shares':
        return AssetCategory.stocks;
      case 'gold':
      case 'digital_gold':
        return AssetCategory.digitalGold;
      case 'insurance':
        return AssetCategory.insurance;
      case 'ppf':
      case 'nps':
      case 'fd':
      case 'rd':
        return AssetCategory.assets;
      default:
        return AssetCategory.other;
    }
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
        return 'Other Assets';
      case AssetCategory.other:
        return 'Other';
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
      if (asset.type.toLowerCase() == 'loan') {
        totalLiabilities += asset.value;
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
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        title: const Text('Assets Revealed'),
        backgroundColor: const Color(0xFF40C057),
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Legacy Info Card (for NOK)
            const LegacyInfoCard(isForNok: true),
            const SizedBox(height: 20),

            // Net Worth Card
            NetWorthCard(
              totalNetWorth: totalNetWorth,
              totalAssets: totalAssets,
              totalLiabilities: totalLiabilities,
              userName: designation.accountHolderName,
            ),
            const SizedBox(height: 20),

            // Account Holder Info Card
            Container(
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
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: const Color(0xFF40C057).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      Icons.person_outline,
                      color: Color(0xFF40C057),
                      size: 28,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Account Holder',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          designation.accountHolderName ?? 'Unknown',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: const Color(0xFF40C057).withOpacity(0.1),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                designation.relationship,
                                style: const TextStyle(
                                  fontSize: 11,
                                  color: Color(0xFF2B8A3E),
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            const Icon(
                              Icons.verified,
                              size: 16,
                              color: Color(0xFF40C057),
                            ),
                            const SizedBox(width: 4),
                            const Text(
                              'Verified',
                              style: TextStyle(
                                fontSize: 11,
                                color: Color(0xFF2B8A3E),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Assets Overview Header
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: const Color(0xFF40C057).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(
                    Icons.bar_chart,
                    size: 18,
                    color: Color(0xFF40C057),
                  ),
                ),
                const SizedBox(width: 8),
                const Text(
                  'Assets Overview',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade200,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '${assetsState.assets.length} items',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey.shade600,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Pie Chart
            if (pieData.isNotEmpty) ...[
              AssetPieChart(distributions: pieData),
              const SizedBox(height: 16),
            ],

            // Asset Category Cards Grid
            if (assetsState.isLoading)
              const Center(
                child: Padding(
                  padding: EdgeInsets.all(32),
                  child: CircularProgressIndicator(),
                ),
              )
            else ...[
              GridView.count(
                crossAxisCount: 2,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                childAspectRatio: 1.3,
                children: [
                  _buildCategoryCard(AssetCategory.bankSavings, groupedAssets),
                  _buildCategoryCard(AssetCategory.loans, groupedAssets),
                  _buildCategoryCard(AssetCategory.mutualFunds, groupedAssets),
                  _buildCategoryCard(AssetCategory.stocks, groupedAssets),
                  _buildCategoryCard(AssetCategory.insurance, groupedAssets),
                  _buildCategoryCard(AssetCategory.assets, groupedAssets),
                ],
              ),
              const SizedBox(height: 24),

              // Claims Info Card
              Container(
                decoration: BoxDecoration(
                  color: const Color(0xFFDBE4FF).withOpacity(0.5),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: const Color(0xFF4263EB).withOpacity(0.3),
                  ),
                ),
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: const Color(0xFF4263EB).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(
                        Icons.info_outline,
                        size: 24,
                        color: Color(0xFF4263EB),
                      ),
                    ),
                    const SizedBox(width: 12),
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Claims Guidance',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF364FC7),
                            ),
                          ),
                          SizedBox(height: 4),
                          Text(
                            'Tap on any asset in the breakdown below for detailed claims guidance.',
                            style: TextStyle(
                              fontSize: 12,
                              color: Color(0xFF364FC7),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Detailed Breakdown Header
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: const Color(0xFF40C057).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(
                      Icons.list_alt,
                      size: 18,
                      color: Color(0xFF40C057),
                    ),
                  ),
                  const SizedBox(width: 8),
                  const Text(
                    'Detailed Breakdown',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Collapsible Sections for each category
              ...groupedAssets.entries.map((entry) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: _buildCollapsibleSection(context, entry.key, entry.value),
                );
              }),
              const SizedBox(height: 24),
            ],
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
    final total = assets.fold<double>(0, (sum, a) => sum + a.value);
    
    return AssetCategoryCard(
      category: category,
      amount: total,
      count: assets.length,
      countLabel: _getCountLabel(category),
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
          return _AssetItemWithClaim(
            asset: asset,
            isNegative: category == AssetCategory.loans,
          );
        }).toList(),
      ),
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
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
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
                  color: Colors.grey.shade300,
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
                    color: const Color(0xFF4263EB).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(
                    Icons.help_outline,
                    color: Color(0xFF4263EB),
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
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),
                ),
                Text(
                  _formatCurrency(asset.value),
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF40C057),
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
                  backgroundColor: const Color(0xFF4263EB),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
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
              color: const Color(0xFF4263EB).withOpacity(0.1),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Center(
              child: Text(
                '$number',
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF4263EB),
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
                    color: Colors.grey.shade600,
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
