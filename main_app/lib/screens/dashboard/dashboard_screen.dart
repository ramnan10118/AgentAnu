import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:file_picker/file_picker.dart';
import 'dart:typed_data';
import '../../providers/auth_provider.dart';
import '../../providers/assets_provider.dart';
import '../../providers/nok_provider.dart';
import '../../services/socket_service.dart';
import '../../services/api_service.dart';
import '../../utils/constants.dart';
import '../../models/asset_model.dart';
import '../../widgets/asset_pie_chart.dart';
import '../nok/nok_designation_screen.dart';
import '../auth/mobile_entry_screen.dart';

class DashboardScreen extends ConsumerStatefulWidget {
  const DashboardScreen({super.key});

  @override
  ConsumerState<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends ConsumerState<DashboardScreen> {
  final SocketService _socketService = SocketService();
  bool _hasLoadedData = false;
  final Map<String, bool> _expandedSections = {};
  final Map<String, bool> _flippedCards = {};
  final ScrollController _scrollController = ScrollController();

  // ShadCN color palette
  static const Color _shadcnBackground = Color(0xFFFFFFFF);
  static const Color _shadcnForeground = Color(0xFF0F172A);
  static const Color _shadcnCard = Color(0xFFFFFFFF);
  static const Color _shadcnMuted = Color(0xFFF1F5F9);
  static const Color _shadcnMutedForeground = Color(0xFF64748B);
  static const Color _shadcnBorder = Color(0xFFE2E8F0);
  static const Color _shadcnPrimary = Color(0xFF0F172A);
  static const Color _shadcnPrimaryForeground = Color(0xFFF8FAFC);

  @override
  void initState() {
    super.initState();
    _initializeSocket();
    Future.delayed(const Duration(milliseconds: 300), () {
      if (mounted && !_hasLoadedData) {
        _hasLoadedData = true;
        _loadData();
      }
    });
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
        Future.delayed(const Duration(milliseconds: 100), () {
          if (mounted) {
            ref.read(nokProvider.notifier).getNokStatus();
          }
        });
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
        Future.delayed(const Duration(milliseconds: 100), () {
          if (mounted) {
            ref.read(nokProvider.notifier).getNokStatus();
          }
        });
      }
    };

    _socketService.connect();
  }

  Future<void> _loadData() async {
    if (!mounted) return;
    await Future.delayed(const Duration(milliseconds: 50));
    if (!mounted) return;
    
    try {
      final assetsState = ref.read(assetsProvider);
      if (assetsState.assets.isEmpty && !assetsState.isLoading) {
        print('📦 No assets found, fetching...');
        Future.microtask(() async {
          if (mounted) {
            await ref.read(assetsProvider.notifier).getAssets();
          }
        });
      } else {
        print('📦 Using existing assets: ${assetsState.assets.length} items');
      }
      
      if (mounted) {
        Future.microtask(() async {
          if (mounted) {
            await ref.read(nokProvider.notifier).getNokStatus();
          }
        });
      }
    } catch (e) {
      print('❌ Error loading data: $e');
    }
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
  Map<String, List<AssetModel>> _groupAssetsByCategory(List<AssetModel> assets) {
    final grouped = <String, List<AssetModel>>{};
    for (var asset in assets) {
      final category = _getAssetCategory(asset.type);
      grouped.putIfAbsent(category, () => []).add(asset);
    }
    return grouped;
  }

  String _getAssetCategory(String type) {
    switch (type) {
      case 'bank_account':
      case 'fd':
        return 'Bank Savings';
      case 'mutual_fund':
        return 'Mutual Funds';
      case 'securities':
      case 'stocks':
        return 'Stocks';
      case 'insurance':
        return 'Insurance';
      case 'nps':
        return 'NPS';
      case 'property':
      case 'real_estate':
        return 'Assets Acquired';
      default:
        return 'Other Assets';
    }
  }

  // Calculate totals
  double _calculateTotalAssets(List<AssetModel> assets) {
    return assets.fold(0.0, (sum, asset) => sum + asset.value);
  }

  double _calculateTotalLiabilities(List<AssetModel> assets) {
    return 0.0;
  }

  void _toggleFlip(String cardKey) {
    setState(() {
      _flippedCards[cardKey] = !(_flippedCards[cardKey] ?? false);
    });
  }

  void _toggleSection(String sectionKey) {
    setState(() {
      final isExpanded = _expandedSections[sectionKey] ?? false;
      if (!isExpanded) {
        _expandedSections.clear();
        _expandedSections[sectionKey] = true;
      } else {
        _expandedSections[sectionKey] = false;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final assetsState = ref.watch(assetsProvider);
    final authState = ref.watch(authProvider);
    final nokState = ref.watch(nokProvider);
    
    final groupedAssets = _groupAssetsByCategory(assetsState.assets);
    final totalAssets = _calculateTotalAssets(assetsState.assets);
    final totalLiabilities = _calculateTotalLiabilities(assetsState.assets);
    final netWorth = totalAssets - totalLiabilities;

    return Scaffold(
      backgroundColor: _shadcnBackground,
      body: RefreshIndicator(
        onRefresh: _loadData,
        child: CustomScrollView(
          controller: _scrollController,
          slivers: [
          // Sticky App Bar
          SliverAppBar(
            title: const Text(
              'Your Wealth Portfolio',
              style: TextStyle(
                color: _shadcnPrimaryForeground,
                fontWeight: FontWeight.w600,
              ),
            ),
            backgroundColor: _shadcnPrimary,
            foregroundColor: _shadcnPrimaryForeground,
            elevation: 0,
            pinned: true,
            floating: false,
            actions: [
              IconButton(
                icon: const Icon(Icons.logout, color: _shadcnPrimaryForeground),
                onPressed: _logout,
              ),
            ],
          ),

          // Sticky Net Worth Card - Using SliverPersistentHeader for proper sticking
          SliverPersistentHeader(
            pinned: true,
            delegate: _NetWorthHeaderDelegate(
              netWorth: netWorth,
              totalAssets: totalAssets,
              totalLiabilities: totalLiabilities,
              minHeight: 70,
              maxHeight: 180,
            ),
          ),

          // Assets Overview Section
          if (assetsState.assets.isNotEmpty && !assetsState.isLoading) ...[
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 4, 16, 8),
                child: Row(
                  children: [
                    Icon(Icons.pie_chart, color: _shadcnPrimary, size: 18),
                    const SizedBox(width: 8),
                    const Text(
                      'Assets Overview',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: _shadcnForeground,
                      ),
                    ),
                    const Spacer(),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: _shadcnMuted,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Text(
                        'Just now',
                        style: TextStyle(fontSize: 11, color: _shadcnMutedForeground),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Pie Chart
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: AssetPieChart(assets: assetsState.assets),
              ),
            ),

            // Flip Cards Grid
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
                child: _buildFlipCardsGrid(groupedAssets),
              ),
            ),
          ],

          // Detailed Asset Breakdown
          if (assetsState.assets.isNotEmpty && !assetsState.isLoading) ...[
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 4, 16, 8),
                child: Row(
                  children: [
                    Icon(Icons.description, color: _shadcnPrimary, size: 20),
                    const SizedBox(width: 8),
                    const Text(
                      'Detailed Asset Breakdown',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: _shadcnForeground,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: _buildCollapsibleSections(groupedAssets),
              ),
            ),
          ],

          // Loading State
          if (assetsState.isLoading && assetsState.assets.isEmpty)
            const SliverFillRemaining(
              hasScrollBody: false,
              child: Center(child: CircularProgressIndicator()),
            ),

          // Error State
          if (assetsState.error != null && assetsState.assets.isEmpty)
            SliverFillRemaining(
              hasScrollBody: false,
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.error_outline, size: 48, color: Colors.red),
                    const SizedBox(height: 16),
                    Text(
                      'Error: ${assetsState.error}',
                      textAlign: TextAlign.center,
                      style: const TextStyle(color: Colors.red),
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: _loadData,
                      child: const Text('Retry'),
                    ),
                  ],
                ),
              ),
            ),

          // Empty State
          if (assetsState.assets.isEmpty && !assetsState.isLoading && assetsState.error == null)
            SliverFillRemaining(
              hasScrollBody: false,
              child: const Center(child: Text('No assets found')),
            ),

          // OCR Upload Section - Only show when not loading and have assets or error
          if (!assetsState.isLoading)
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
                child: _buildOcrUploadSection(),
              ),
            ),

          // NOK Status - Only show when not loading
          if (!assetsState.isLoading)
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                child: _buildNokStatus(nokState),
              ),
            ),

          // Bottom padding
          const SliverToBoxAdapter(
            child: SizedBox(height: 16),
          ),
        ],
        ),
      ),
    );
  }

  Widget _buildFlipCardsGrid(Map<String, List<AssetModel>> groupedAssets) {
    final categories = ['Bank Savings', 'Mutual Funds', 'Stocks', 'Assets Acquired', 'Insurance', 'NPS'];
    final categoryColors = {
      'Bank Savings': const Color(0xFF3B82F6),
      'Mutual Funds': const Color(0xFFA855F7),
      'Stocks': const Color(0xFFF97316),
      'Assets Acquired': const Color(0xFF22C55E),
      'Insurance': const Color(0xFFEF4444),
      'NPS': const Color(0xFF14B8A6),
    };
    final categoryIcons = {
      'Bank Savings': Icons.account_balance,
      'Mutual Funds': Icons.trending_up,
      'Stocks': Icons.show_chart,
      'Assets Acquired': Icons.home,
      'Insurance': Icons.security,
      'NPS': Icons.account_balance_wallet,
    };

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 1.15,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
      ),
      itemCount: categories.length,
      itemBuilder: (context, index) {
        final category = categories[index];
        final assets = groupedAssets[category] ?? [];
        final total = assets.fold(0.0, (sum, asset) => sum + asset.value);
        final isFlipped = _flippedCards[category] ?? false;
        final color = categoryColors[category] ?? Colors.grey;
        final icon = categoryIcons[category] ?? Icons.category;

        return GestureDetector(
          onTap: () => _toggleFlip(category),
          child: TweenAnimationBuilder<double>(
            tween: Tween(begin: 0.0, end: isFlipped ? 1.0 : 0.0),
            duration: const Duration(milliseconds: 400),
            curve: Curves.easeInOut,
            builder: (context, value, child) {
              return Transform(
                alignment: Alignment.center,
                transform: Matrix4.identity()
                  ..setEntry(3, 2, 0.001)
                  ..rotateY(value * 3.14159),
                child: value < 0.5
                    ? _FlipCardFront(
                        key: ValueKey('$category-front'),
                        category: category,
                        total: total,
                        count: assets.length,
                        color: color,
                        icon: icon,
                      )
                    : Transform(
                        alignment: Alignment.center,
                        transform: Matrix4.identity()..rotateY(3.14159),
                        child: _FlipCardBack(
                          key: ValueKey('$category-back'),
                          category: category,
                          count: assets.length,
                          color: color,
                        ),
                      ),
              );
            },
          ),
        );
      },
    );
  }

  void _initializeExpandedSections(Map<String, List<AssetModel>> groupedAssets) {
    if (_expandedSections.isEmpty) {
      final categories = groupedAssets.keys.toList()..sort();
      if (categories.isNotEmpty) {
        _expandedSections[categories[0]] = true;
      }
    }
  }

  Widget _buildCollapsibleSections(Map<String, List<AssetModel>> groupedAssets) {
    final categories = groupedAssets.keys.toList()..sort();
    if (categories.isEmpty) return const SizedBox.shrink();

    _initializeExpandedSections(groupedAssets);

    return Column(
      children: categories.map((category) {
        final assets = groupedAssets[category] ?? [];
        final isExpanded = _expandedSections[category] ?? false;
        final color = _getCategoryColor(category);
        final icon = _getCategoryIcon(category);

        return Container(
          margin: const EdgeInsets.only(bottom: 8),
          decoration: BoxDecoration(
            color: _shadcnCard,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: _shadcnBorder, width: 1),
          ),
          child: Column(
            children: [
              InkWell(
                onTap: () => _toggleSection(category),
                borderRadius: BorderRadius.circular(8),
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: color.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Icon(icon, color: color, size: 18),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          category,
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                            color: _shadcnForeground,
                          ),
                        ),
                      ),
                      Icon(
                        isExpanded ? Icons.expand_less : Icons.expand_more,
                        color: _shadcnMutedForeground,
                        size: 20,
                      ),
                    ],
                  ),
                ),
              ),
              AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                curve: Curves.easeInOut,
                height: isExpanded ? null : 0,
                child: isExpanded
                    ? Padding(
                        padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
                        child: Column(
                          children: assets.map((asset) => _AssetListItem(asset: asset)).toList(),
                        ),
                      )
                    : const SizedBox.shrink(),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  Widget _buildOcrUploadSection() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: _shadcnMuted.withOpacity(0.5),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: _shadcnBorder, width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.upload_file, color: _shadcnPrimary, size: 18),
              const SizedBox(width: 8),
              const Text(
                'Don\'t see your asset?',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: _shadcnForeground,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          const Text(
            'Upload a document to add to your portfolio',
            style: TextStyle(
              fontSize: 12,
              color: _shadcnMutedForeground,
            ),
          ),
          const SizedBox(height: 8),
          OutlinedButton.icon(
            onPressed: () => _handleDocumentUpload(),
            icon: const Icon(Icons.upload, size: 16),
            label: const Text('Upload Document'),
            style: OutlinedButton.styleFrom(
              foregroundColor: _shadcnPrimary,
              side: BorderSide(color: _shadcnBorder),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
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
      );

      if (result != null && result.files.single.bytes != null) {
        final fileBytes = result.files.single.bytes!;
        final fileName = result.files.single.name;
        
        // Show loading
        if (!mounted) return;
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (context) => const Center(child: CircularProgressIndicator()),
        );

        try {
          // Call OCR API
          final apiService = ApiService();
          final response = await apiService.extractAssetFromBytes(
            fileBytes,
            fileName,
          );

          if (mounted) {
            Navigator.pop(context); // Close loading
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
            Navigator.pop(context); // Close loading
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Error: ${e.toString()}')),
            );
          }
        }
      } else if (result != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please select a valid file')),
        );
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

  Widget _buildNokStatus(NokState nokState) {
    if (!nokState.hasDesignation) {
      return Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AppConstants.secondaryColor.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: AppConstants.secondaryColor.withOpacity(0.3)),
        ),
        child: Row(
          children: [
            const Icon(Icons.warning, color: AppConstants.secondaryColor, size: 20),
            const SizedBox(width: 12),
            const Expanded(
              child: Text(
                'No Next of Kin designated yet',
                style: TextStyle(fontSize: 14, color: _shadcnForeground),
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
                backgroundColor: AppConstants.secondaryColor,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              ),
              child: const Text('Designate', style: TextStyle(fontSize: 13)),
            ),
          ],
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: nokState.designation?.isAccepted == true
            ? AppConstants.successColor.withOpacity(0.1)
            : AppConstants.secondaryColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: nokState.designation?.isAccepted == true
              ? AppConstants.successColor.withOpacity(0.3)
              : AppConstants.secondaryColor.withOpacity(0.3),
        ),
      ),
      child: Row(
        children: [
          Icon(
            nokState.designation?.isAccepted == true
                ? Icons.check_circle
                : Icons.pending,
            color: nokState.designation?.isAccepted == true
                ? AppConstants.successColor
                : AppConstants.secondaryColor,
            size: 20,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'NOK: ${nokState.designation?.nokName ?? 'Unknown'}',
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                    color: _shadcnForeground,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  nokState.designation?.isAccepted == true
                      ? 'Accepted'
                      : 'Pending acceptance',
                  style: const TextStyle(fontSize: 12, color: _shadcnMutedForeground),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Color _getCategoryColor(String category) {
    switch (category) {
      case 'Bank Savings':
        return const Color(0xFF3B82F6);
      case 'Mutual Funds':
        return const Color(0xFFA855F7);
      case 'Stocks':
        return const Color(0xFFF97316);
      case 'Assets Acquired':
        return const Color(0xFF22C55E);
      case 'Insurance':
        return const Color(0xFFEF4444);
      case 'NPS':
        return const Color(0xFF14B8A6);
      default:
        return Colors.grey;
    }
  }

  IconData _getCategoryIcon(String category) {
    switch (category) {
      case 'Bank Savings':
        return Icons.account_balance;
      case 'Mutual Funds':
        return Icons.trending_up;
      case 'Stocks':
        return Icons.show_chart;
      case 'Assets Acquired':
        return Icons.home;
      case 'Insurance':
        return Icons.security;
      case 'NPS':
        return Icons.account_balance_wallet;
      default:
        return Icons.category;
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _socketService.disconnect();
    super.dispose();
  }
}

// SliverPersistentHeader delegate for sticky net worth card
class _NetWorthHeaderDelegate extends SliverPersistentHeaderDelegate {
  final double netWorth;
  final double totalAssets;
  final double totalLiabilities;
  final double minHeight;
  final double maxHeight;

  _NetWorthHeaderDelegate({
    required this.netWorth,
    required this.totalAssets,
    required this.totalLiabilities,
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

    return SizedBox(
      height: actualHeight,
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              _DashboardScreenState._shadcnPrimary,
              _DashboardScreenState._shadcnPrimary.withOpacity(0.85),
            ],
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
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
                  ),
                  Container(width: 1, height: 30, color: Colors.white.withOpacity(0.2)),
                  _StickySummaryItem(
                    label: 'Assets',
                    value: totalAssets,
                  ),
                  Container(width: 1, height: 30, color: Colors.white.withOpacity(0.2)),
                  _StickySummaryItem(
                    label: 'Liabilities',
                    value: totalLiabilities,
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
                        'Your Legacy Value',
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.9),
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: _SummaryItem(
                          label: 'Total Net Worth',
                          value: netWorth,
                          subtext: 'What you\'re leaving behind',
                        ),
                      ),
                      Container(width: 1, height: 50, color: Colors.white.withOpacity(0.2)),
                      Expanded(
                        child: _SummaryItem(
                          label: 'Total Assets',
                          value: totalAssets,
                          subtext: 'All your investments & savings',
                        ),
                      ),
                      Container(width: 1, height: 50, color: Colors.white.withOpacity(0.2)),
                      Expanded(
                        child: _SummaryItem(
                          label: 'Total Liabilities',
                          value: totalLiabilities,
                          subtext: 'Outstanding loans & debts',
                        ),
                      ),
                    ],
                  ),
                ],
              ),
        ),
      ),
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

  const _StickySummaryItem({
    required this.label,
    required this.value,
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
          '₹${value.toStringAsFixed(0).replaceAllMapped(
            RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
            (Match m) => '${m[1]},',
          )}',
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

class _SummaryItem extends StatelessWidget {
  final String label;
  final double value;
  final String subtext;

  const _SummaryItem({
    required this.label,
    required this.value,
    required this.subtext,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              color: Colors.white.withOpacity(0.75),
              fontSize: 11,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            '₹${value.toStringAsFixed(0).replaceAllMapped(
              RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
              (Match m) => '${m[1]},',
            )}',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            subtext,
            style: TextStyle(
              color: Colors.white.withOpacity(0.7),
              fontSize: 10,
            ),
          ),
        ],
      ),
    );
  }
}

class _FlipCardFront extends StatelessWidget {
  final String category;
  final double total;
  final int count;
  final Color color;
  final IconData icon;

  const _FlipCardFront({
    super.key,
    required this.category,
    required this.total,
    required this.count,
    required this.color,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: _DashboardScreenState._shadcnCard,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: _DashboardScreenState._shadcnBorder, width: 1),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    category,
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: _DashboardScreenState._shadcnMutedForeground,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.all(5),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(5),
                  ),
                  child: Icon(icon, color: color, size: 14),
                ),
              ],
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '₹${total.toStringAsFixed(0).replaceAllMapped(
                    RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
                    (Match m) => '${m[1]},',
                  )}',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: _DashboardScreenState._shadcnForeground,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '$count ${count == 1 ? 'item' : 'items'}',
                  style: const TextStyle(
                    fontSize: 11,
                    color: _DashboardScreenState._shadcnMutedForeground,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _FlipCardBack extends StatelessWidget {
  final String category;
  final int count;
  final Color color;

  const _FlipCardBack({
    super.key,
    required this.category,
    required this.count,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: _DashboardScreenState._shadcnCard,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: _DashboardScreenState._shadcnBorder, width: 1),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              category,
              style: const TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: _DashboardScreenState._shadcnForeground,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              '$count',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            Text(
              count == 1 ? 'item' : 'items',
              style: const TextStyle(
                fontSize: 11,
                color: _DashboardScreenState._shadcnMutedForeground,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _AssetListItem extends StatelessWidget {
  final AssetModel asset;

  const _AssetListItem({required this.asset});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: _DashboardScreenState._shadcnMuted,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: _DashboardScreenState._shadcnBorder, width: 0.5),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: AppConstants.primaryColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Icon(
              AppConstants.assetIcons[asset.type] ?? Icons.account_balance,
              color: AppConstants.primaryColor,
              size: 16,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  asset.provider,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 13,
                    color: _DashboardScreenState._shadcnForeground,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  asset.assetTypeLabel,
                  style: const TextStyle(
                    fontSize: 11,
                    color: _DashboardScreenState._shadcnMutedForeground,
                  ),
                ),
              ],
            ),
          ),
          Text(
            asset.formattedValue,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.bold,
              color: AppConstants.primaryColor,
            ),
          ),
        ],
      ),
    );
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

    return Container(
      decoration: const BoxDecoration(
        color: _DashboardScreenState._shadcnCard,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      padding: const EdgeInsets.all(20),
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
                color: _DashboardScreenState._shadcnMutedForeground.withOpacity(0.3),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 20),
          
          // Title
          const Text(
            'Extracted Asset Details',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: _DashboardScreenState._shadcnForeground,
            ),
          ),
          const SizedBox(height: 20),

          // Asset details
          _DetailRow(label: 'Asset Type', value: type),
          const SizedBox(height: 12),
          _DetailRow(label: 'Name', value: name),
          if (location != null) ...[
            const SizedBox(height: 12),
            _DetailRow(label: 'Location', value: location),
          ],
          const SizedBox(height: 16),
          
          // Value highlight
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: _DashboardScreenState._shadcnMuted.withOpacity(0.5),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: AppConstants.primaryColor.withOpacity(0.3),
                width: 2,
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Extracted Value',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: _DashboardScreenState._shadcnForeground,
                  ),
                ),
                Text(
                  '₹${value.toStringAsFixed(0).replaceAllMapped(
                    RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
                    (Match m) => '${m[1]},',
                  )}',
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: AppConstants.primaryColor,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Action buttons
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () => Navigator.pop(context),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    side: BorderSide(color: _DashboardScreenState._shadcnBorder),
                  ),
                  child: const Text('Dismiss'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                flex: 2,
                child: ElevatedButton(
                  onPressed: onAdd,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppConstants.primaryColor,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                  child: const Text('Add to Portfolio'),
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
            label,
            style: const TextStyle(
              fontSize: 13,
              color: _DashboardScreenState._shadcnMutedForeground,
            ),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: _DashboardScreenState._shadcnForeground,
            ),
          ),
        ),
      ],
    );
  }
}
