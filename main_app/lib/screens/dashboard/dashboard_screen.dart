import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:file_picker/file_picker.dart';
import '../../providers/auth_provider.dart';
import '../../providers/assets_provider.dart';
import '../../providers/nok_provider.dart';
import '../../services/socket_service.dart';
import '../../services/api_service.dart';
import '../../utils/constants.dart';
import '../../utils/shadcn_colors.dart';
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
    print('📱 [DASHBOARD] Initializing socket callbacks');
    print('📱 [DASHBOARD] Socket connected: ${_socketService.isConnected}');

    _socketService.onNokAccepted = (data) {
      print('📱 [DASHBOARD] onNokAccepted callback triggered!');
      print('📱 [DASHBOARD] Data: $data');
      print('📱 [DASHBOARD] Mounted: $mounted');

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${data['nokName']} accepted your designation!'),
            backgroundColor: AppConstants.successColor,
            duration: const Duration(seconds: 5),
          ),
        );
        ref.read(nokProvider.notifier).getNokStatus();
        print('📱 [DASHBOARD] Snackbar shown and NOK status refreshed');
      }
    };

    _socketService.onNokRejected = (data) {
      print('📱 [DASHBOARD] onNokRejected callback triggered!');
      print('📱 [DASHBOARD] Data: $data');

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

    print('📱 [DASHBOARD] Callbacks registered. Connecting socket...');
    _socketService.connect();
    print('📱 [DASHBOARD] Socket connection requested');
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

  @override
  Widget build(BuildContext context) {
    final assetsState = ref.watch(assetsProvider);
    final authState = ref.watch(authProvider);
    final nokState = ref.watch(nokProvider);

    return Scaffold(
      backgroundColor: ShadcnColors.background,
      appBar: AppBar(
        title: const Text(
          'Your Wealth Portfolio',
          style: TextStyle(
            color: ShadcnColors.primaryForeground,
            fontWeight: FontWeight.w600,
          ),
        ),
        backgroundColor: ShadcnColors.primary,
        foregroundColor: ShadcnColors.primaryForeground,
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
                        Container(
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [
                                Color(0xFFFF9575),
                                Color(0xFFE87B5A),
                              ],
                            ),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: ElevatedButton.icon(
                            onPressed: _loadData,
                            icon: const Icon(Icons.refresh),
                            label: const Text('Retry'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.transparent,
                              foregroundColor: Colors.white,
                              shadowColor: Colors.transparent,
                              elevation: 0,
                            ),
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

    return CustomScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      slivers: [
        // Sticky Net Worth Card
        SliverPersistentHeader(
          pinned: true,
          delegate: _NetWorthHeaderDelegate(
            netWorth: totalNetWorth,
            totalAssets: totalAssets,
            totalLiabilities: totalLiabilities,
            userName: authState.user?.name ?? authState.user?.mobile,
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

          // NOK Status Card
          _buildNokStatusCard(nokState),
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
              crossAxisCount: 3, // 3 columns for compact layout
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisSpacing: 8,
              mainAxisSpacing: 8,
              childAspectRatio: 1.5, // Wider, shorter cards
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
          const LegacyInfoCard(),
          const SizedBox(height: 24),

          // OCR Upload Section
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: _buildOcrUploadSection(),
          ),
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

          // Collapsible Sections for each category (in specific order, excluding empty categories)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              children: [
                // Show categories in a specific order
                if (groupedAssets[AssetCategory.bankSavings] != null && groupedAssets[AssetCategory.bankSavings]!.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: _buildCollapsibleSection(AssetCategory.bankSavings, groupedAssets[AssetCategory.bankSavings]!),
                  ),
                if (groupedAssets[AssetCategory.loans] != null && groupedAssets[AssetCategory.loans]!.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: _buildCollapsibleSection(AssetCategory.loans, groupedAssets[AssetCategory.loans]!),
                  ),
                if (groupedAssets[AssetCategory.mutualFunds] != null && groupedAssets[AssetCategory.mutualFunds]!.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: _buildCollapsibleSection(AssetCategory.mutualFunds, groupedAssets[AssetCategory.mutualFunds]!),
                  ),
                if (groupedAssets[AssetCategory.stocks] != null && groupedAssets[AssetCategory.stocks]!.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: _buildCollapsibleSection(AssetCategory.stocks, groupedAssets[AssetCategory.stocks]!),
                  ),
                if (groupedAssets[AssetCategory.insurance] != null && groupedAssets[AssetCategory.insurance]!.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: _buildCollapsibleSection(AssetCategory.insurance, groupedAssets[AssetCategory.insurance]!),
                  ),
                if (groupedAssets[AssetCategory.digitalGold] != null && groupedAssets[AssetCategory.digitalGold]!.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: _buildCollapsibleSection(AssetCategory.digitalGold, groupedAssets[AssetCategory.digitalGold]!),
                  ),
                if (groupedAssets[AssetCategory.assets] != null && groupedAssets[AssetCategory.assets]!.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: _buildCollapsibleSection(AssetCategory.assets, groupedAssets[AssetCategory.assets]!),
                  ),
                // Show "Miscellaneous" only if it has items
                if (groupedAssets[AssetCategory.other] != null && groupedAssets[AssetCategory.other]!.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: _buildCollapsibleSection(AssetCategory.other, groupedAssets[AssetCategory.other]!),
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
                        Container(
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [
                                Color(0xFFFF9575),
                                Color(0xFFE87B5A),
                              ],
                            ),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: ElevatedButton(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => const NokDesignationScreen(),
                                ),
                              );
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.transparent,
                              foregroundColor: Colors.white,
                              shadowColor: Colors.transparent,
                              elevation: 0,
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            child: const Text('Designate'),
                          ),
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

  Widget _buildCollapsibleSection(AssetCategory category, List<AssetModel> assets) {
    return CollapsibleSection(
      title: _getCategoryName(category),
      icon: _getCategoryIcon(category),
      iconBackgroundColor: _getCategoryIconBg(category),
      iconColor: _getCategoryIconColor(category),
      child: Column(
        children: assets.map((asset) {
          // Special handling for loans - show detailed loan card
          if (category == AssetCategory.loans) {
            return LoanDetailCard(loan: asset);
          }
          // Regular asset items
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

  Widget _buildOcrUploadSection() {
    return Container(
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
              Icon(Icons.upload_file, color: ShadcnColors.primary, size: 18),
              const SizedBox(width: 8),
              const Text(
                'Don\'t see your asset?',
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
            'Upload a document to add to your portfolio',
            style: TextStyle(
              fontSize: 12,
              color: ShadcnColors.mutedForeground,
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: _handleDocumentUpload,
              icon: const Icon(Icons.upload, size: 16),
              label: const Text('Upload Document'),
              style: OutlinedButton.styleFrom(
                foregroundColor: ShadcnColors.foreground,
                side: BorderSide(color: ShadcnColors.border, width: 1),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(ShadcnColors.radius),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _handleDocumentUpload() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf', 'jpg', 'jpeg', 'png'],
        withData: true,
      );

      if (result != null && result.files.single.bytes != null) {
        final fileBytes = result.files.single.bytes!;
        final fileName = result.files.single.name;
        
        if (!mounted) return;
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (context) => const Center(child: CircularProgressIndicator()),
        );

        try {
          final apiService = ApiService();
          final response = await apiService.extractAssetFromBytes(
            fileBytes,
            fileName,
          );

          if (mounted) {
            Navigator.pop(context);
            if (response['success'] == true && response['data'] != null) {
              _showAssetBottomSheet(response['data']);
            } else {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(response['message'] ?? 'Failed to extract asset')),
              );
            }
          }
        } catch (e) {
          if (mounted) {
            Navigator.pop(context);
            String errorMessage = 'Error uploading document';
            if (e.toString().contains('401')) {
              errorMessage = 'Authentication failed. Please log in again.';
            } else if (e.toString().contains('400')) {
              errorMessage = 'Invalid file format. Please upload PDF, JPEG, or PNG.';
            } else if (e.toString().contains('500')) {
              errorMessage = 'Server error. Please try again later.';
            } else {
              errorMessage = 'Error: ${e.toString()}';
            }
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(errorMessage),
                backgroundColor: Colors.red,
                duration: const Duration(seconds: 4),
              ),
            );
          }
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error selecting file: ${e.toString()}')),
        );
      }
    }
  }

  void _showAssetBottomSheet(Map<String, dynamic> assetData) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _AssetBottomSheet(
        assetData: assetData,
        onAdd: () async {
          try {
            final apiService = ApiService();
            await apiService.addManualAsset(
              type: assetData['type'] ?? 'Other',
              name: assetData['name'] ?? 'Asset',
              location: assetData['location'],
              value: (assetData['value'] as num).toDouble(),
            );
            
            if (mounted) {
              Navigator.pop(context);
              await ref.read(assetsProvider.notifier).getAssets();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Asset added successfully!')),
              );
            }
          } catch (e) {
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Error adding asset: ${e.toString()}')),
              );
            }
          }
        },
      ),
    );
  }

  @override
  void dispose() {
    // Don't disconnect socket here - it should stay connected for the entire session
    // Only disconnect on actual logout (which happens in _logout() method)
    super.dispose();
  }
}

// Asset Bottom Sheet for OCR results
class _AssetBottomSheet extends StatelessWidget {
  final Map<String, dynamic> assetData;
  final VoidCallback onAdd;

  const _AssetBottomSheet({
    required this.assetData,
    required this.onAdd,
  });

  @override
  Widget build(BuildContext context) {
    final value = (assetData['value'] as num?)?.toDouble() ?? 0.0;
    final type = assetData['type'] ?? 'Other';
    final name = assetData['name'] ?? 'Asset';
    final location = assetData['location'];

    String _formatCurrency(double amount) {
      return '₹${amount.toStringAsFixed(0).replaceAllMapped(
        RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
        (Match m) => '${m[1]},',
      )}';
    }

    return Container(
      decoration: BoxDecoration(
        color: ShadcnColors.card,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
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
          const Text(
            'Extracted Asset Details',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: ShadcnColors.foreground,
            ),
          ),
          const SizedBox(height: 20),
          _DetailRow(label: 'Asset Type', value: type),
          const SizedBox(height: 12),
          _DetailRow(label: 'Name', value: name),
          if (location != null) ...[
            const SizedBox(height: 12),
            _DetailRow(label: 'Location', value: location),
          ],
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: ShadcnColors.muted.withOpacity(0.5),
              borderRadius: BorderRadius.circular(ShadcnColors.radius),
              border: Border.all(color: ShadcnColors.border),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Extracted Value',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: ShadcnColors.foreground,
                  ),
                ),
                Text(
                  _formatCurrency(value),
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: ShadcnColors.primary,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () => Navigator.pop(context),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    side: BorderSide(color: ShadcnColors.border, width: 1),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(ShadcnColors.radius),
                    ),
                  ),
                  child: const Text('Dismiss'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                flex: 2,
                child: Container(
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Color(0xFFFF9575),
                        Color(0xFFE87B5A),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(ShadcnColors.radius),
                  ),
                  child: ElevatedButton(
                    onPressed: onAdd,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.transparent,
                      foregroundColor: ShadcnColors.primaryForeground,
                      shadowColor: Colors.transparent,
                      elevation: 0,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(ShadcnColors.radius),
                      ),
                    ),
                    child: const Text('Add to Portfolio'),
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: MediaQuery.of(context).viewInsets.bottom),
        ],
      ),
    );
  }
}

// SliverPersistentHeader delegate for sticky net worth card
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

    String _formatCurrency(double amount) {
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
                    formatter: _formatCurrency,
                  ),
                  Container(width: 1, height: 30, color: Colors.white.withOpacity(0.2)),
                  _StickySummaryItem(
                    label: 'Assets',
                    value: totalAssets,
                    formatter: _formatCurrency,
                  ),
                  Container(width: 1, height: 30, color: Colors.white.withOpacity(0.2)),
                  _StickySummaryItem(
                    label: 'Liabilities',
                    value: totalLiabilities,
                    formatter: _formatCurrency,
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
                        userName != null ? 'Welcome, $userName' : 'Your Digital Vault',
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
                              _formatCurrency(netWorth),
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 32,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'What you\'re leaving behind',
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
                              _formatCurrency(totalAssets),
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
                              _formatCurrency(totalLiabilities),
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

class _DetailRow extends StatelessWidget {
  final String label;
  final String value;

  const _DetailRow({
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 100,
          child: Text(
            '$label:',
            style: const TextStyle(
              fontWeight: FontWeight.w500,
              color: ShadcnColors.mutedForeground,
              fontSize: 13,
            ),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(
              color: ShadcnColors.foreground,
              fontSize: 13,
            ),
          ),
        ),
      ],
    );
  }
}
