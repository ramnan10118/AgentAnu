import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../providers/auth_provider.dart';
import '../../providers/assets_provider.dart';
import '../../providers/nok_provider.dart';
import '../../services/socket_service.dart';
import '../../utils/constants.dart';
import '../../models/asset_model.dart';
import '../../widgets/net_worth_card.dart';
import '../../widgets/asset_category_card.dart';
import '../../widgets/asset_pie_chart.dart';
import '../../widgets/collapsible_section.dart';
import '../../widgets/legacy_info_card.dart';
import '../nok/nok_designation_screen.dart';
import '../auth/mobile_entry_screen.dart';

class DashboardScreen extends ConsumerStatefulWidget {
  const DashboardScreen({super.key});

  @override
  ConsumerState<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends ConsumerState<DashboardScreen> {
  final SocketService _socketService = SocketService();

  @override
  void initState() {
    super.initState();
    _initializeSocket();
    _loadData();
  }

  void _initializeSocket() {
    _socketService.onNokAccepted = (data) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${data['nokName']} accepted your designation!'),
            backgroundColor: AppConstants.successColor,
            duration: const Duration(seconds: 5),
          ),
        );
        ref.read(nokProvider.notifier).getNokStatus();
      }
    };

    _socketService.onNokRejected = (data) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${data['nokName']} rejected your designation'),
            backgroundColor: AppConstants.errorColor,
            duration: const Duration(seconds: 5),
          ),
        );
        ref.read(nokProvider.notifier).getNokStatus();
      }
    };

    _socketService.connect();
  }

  Future<void> _loadData() async {
    await ref.read(assetsProvider.notifier).getAssets();
    await ref.read(nokProvider.notifier).getNokStatus();
  }

  Future<void> _logout() async {
    await ref.read(authProvider.notifier).logout();
    _socketService.disconnect();
    if (mounted) {
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => const MobileEntryScreen()),
        (route) => false,
      );
    }
  }

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

  @override
  Widget build(BuildContext context) {
    final assetsState = ref.watch(assetsProvider);
    final authState = ref.watch(authProvider);
    final nokState = ref.watch(nokProvider);

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        title: const Text('Digital Vault'),
        backgroundColor: const Color(0xFF3B5BDB),
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: _logout,
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _loadData,
        child: assetsState.isLoading
            ? const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircularProgressIndicator(),
                    SizedBox(height: 16),
                    Text('Loading your assets...'),
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
                        Text(
                          'Error loading assets',
                          style: const TextStyle(
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
                        const SizedBox(height: 24),
                        ElevatedButton.icon(
                          onPressed: _loadData,
                          icon: const Icon(Icons.refresh),
                          label: const Text('Retry'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppConstants.primaryColor,
                          ),
                        ),
                      ],
                    ),
                  )
                : _buildDashboardContent(context, assetsState, authState, nokState),
      ),
    );
  }

  Widget _buildDashboardContent(
    BuildContext context,
    AssetsState assetsState,
    AuthState authState,
    NokState nokState,
  ) {
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

    return SingleChildScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Net Worth Card
          NetWorthCard(
            totalNetWorth: totalNetWorth,
            totalAssets: totalAssets,
            totalLiabilities: totalLiabilities,
            userName: authState.user?.name ?? authState.user?.mobile,
          ),
          const SizedBox(height: 20),

          // NOK Status Card
          _buildNokStatusCard(nokState),
          const SizedBox(height: 20),

          // Assets Overview Header
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: const Color(0xFF3B5BDB).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.bar_chart,
                  size: 18,
                  color: Color(0xFF3B5BDB),
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

          // Legacy Info Card
          const LegacyInfoCard(),
          const SizedBox(height: 24),

          // Detailed Breakdown Header
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: const Color(0xFF3B5BDB).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.list_alt,
                  size: 18,
                  color: Color(0xFF3B5BDB),
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
              child: _buildCollapsibleSection(entry.key, entry.value),
            );
          }),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _buildNokStatusCard(NokState nokState) {
    if (!nokState.hasDesignation) {
      return Container(
        decoration: BoxDecoration(
          color: const Color(0xFFFFF3BF),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFFFAB005).withOpacity(0.3)),
        ),
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: const Color(0xFFFAB005).withOpacity(0.2),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(
                Icons.warning_amber_rounded,
                color: Color(0xFFE67700),
                size: 24,
              ),
            ),
            const SizedBox(width: 12),
            const Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'No Next of Kin',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFFE67700),
                    ),
                  ),
                  SizedBox(height: 2),
                  Text(
                    'Designate someone to access your assets',
                    style: TextStyle(
                      fontSize: 12,
                      color: Color(0xFFE67700),
                    ),
                  ),
                ],
              ),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const NokDesignationScreen(),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFFAB005),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text('Designate'),
            ),
          ],
        ),
      );
    }

    final isAccepted = nokState.designation?.isAccepted == true;
    return Container(
      decoration: BoxDecoration(
        color: isAccepted 
            ? const Color(0xFFD3F9D8) 
            : const Color(0xFFDBE4FF),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isAccepted 
              ? const Color(0xFF40C057).withOpacity(0.3)
              : const Color(0xFF4263EB).withOpacity(0.3),
        ),
      ),
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: isAccepted 
                  ? const Color(0xFF40C057).withOpacity(0.2)
                  : const Color(0xFF4263EB).withOpacity(0.2),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              isAccepted ? Icons.check_circle : Icons.pending,
              color: isAccepted 
                  ? const Color(0xFF40C057)
                  : const Color(0xFF4263EB),
              size: 24,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'NOK: ${nokState.designation?.nokName ?? 'Unknown'}',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: isAccepted 
                        ? const Color(0xFF2B8A3E)
                        : const Color(0xFF364FC7),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  isAccepted ? 'Accepted' : 'Pending acceptance',
                  style: TextStyle(
                    fontSize: 12,
                    color: isAccepted 
                        ? const Color(0xFF2B8A3E)
                        : const Color(0xFF364FC7),
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: isAccepted 
                  ? const Color(0xFF40C057)
                  : const Color(0xFF4263EB),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              nokState.designation?.relationship ?? '',
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

  Widget _buildCollapsibleSection(AssetCategory category, List<AssetModel> assets) {
    return CollapsibleSection(
      title: _getCategoryName(category),
      icon: _getCategoryIcon(category),
      iconBackgroundColor: _getCategoryIconBg(category),
      iconColor: _getCategoryIconColor(category),
      child: Column(
        children: assets.map((asset) {
          return AssetItemTile(
            title: asset.provider,
            subtitle: asset.accountNumber ?? asset.assetTypeLabel,
            amount: _formatCurrency(asset.value),
            isNegative: category == AssetCategory.loans,
          );
        }).toList(),
      ),
    );
  }

  @override
  void dispose() {
    _socketService.disconnect();
    super.dispose();
  }
}
