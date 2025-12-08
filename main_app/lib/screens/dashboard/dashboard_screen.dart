import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/auth_provider.dart';
import '../../providers/assets_provider.dart';
import '../../providers/nok_provider.dart';
import '../../services/socket_service.dart';
import '../../utils/constants.dart';
import '../../models/asset_model.dart';
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

  @override
  Widget build(BuildContext context) {
    final assetsState = ref.watch(assetsProvider);
    final authState = ref.watch(authProvider);
    final nokState = ref.watch(nokProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Assets'),
        backgroundColor: AppConstants.primaryColor,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: _logout,
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _loadData,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(AppConstants.spacingMD),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Welcome card
              Card(
                color: AppConstants.primaryColor,
                child: Padding(
                  padding: const EdgeInsets.all(AppConstants.spacingLG),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Welcome back!',
                        style: TextStyle(
                          color: Colors.white70,
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(height: AppConstants.spacingSM),
                      Text(
                        authState.user?.mobile ?? 'User',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: AppConstants.spacingLG),
              
              // Total Net Worth card
              Card(
                elevation: 4,
                child: Padding(
                  padding: const EdgeInsets.all(AppConstants.spacingLG),
                  child: Column(
                    children: [
                      const Text(
                        'Total Net Worth',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.grey,
                        ),
                      ),
                      const SizedBox(height: AppConstants.spacingSM),
                      Text(
                        '₹${assetsState.totalNetWorth.toStringAsFixed(0).replaceAllMapped(
                          RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
                          (Match m) => '${m[1]},',
                        )}',
                        style: const TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                          color: AppConstants.primaryColor,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: AppConstants.spacingLG),
              
              // NOK Status
              if (!nokState.hasDesignation)
                Card(
                  color: AppConstants.secondaryColor.withOpacity(0.1),
                  child: Padding(
                    padding: const EdgeInsets.all(AppConstants.spacingMD),
                    child: Row(
                      children: [
                        const Icon(Icons.warning, color: AppConstants.secondaryColor),
                        const SizedBox(width: AppConstants.spacingMD),
                        const Expanded(
                          child: Text('No Next of Kin designated yet'),
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
                          ),
                          child: const Text('Designate'),
                        ),
                      ],
                    ),
                  ),
                )
              else
                Card(
                  color: nokState.designation?.isAccepted == true
                      ? AppConstants.successColor.withOpacity(0.1)
                      : AppConstants.secondaryColor.withOpacity(0.1),
                  child: Padding(
                    padding: const EdgeInsets.all(AppConstants.spacingMD),
                    child: Row(
                      children: [
                        Icon(
                          nokState.designation?.isAccepted == true
                              ? Icons.check_circle
                              : Icons.pending,
                          color: nokState.designation?.isAccepted == true
                              ? AppConstants.successColor
                              : AppConstants.secondaryColor,
                        ),
                        const SizedBox(width: AppConstants.spacingMD),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'NOK: ${nokState.designation?.nokName ?? 'Unknown'}',
                                style: const TextStyle(fontWeight: FontWeight.bold),
                              ),
                              Text(
                                nokState.designation?.isAccepted == true
                                    ? 'Accepted'
                                    : 'Pending acceptance',
                                style: const TextStyle(fontSize: 12),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              const SizedBox(height: AppConstants.spacingLG),
              
              // Assets section
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'My Assets',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    '${assetsState.assets.length} items',
                    style: const TextStyle(
                      color: Colors.grey,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppConstants.spacingMD),
              
              // Assets list
              if (assetsState.isLoading)
                const Center(
                  child: Padding(
                    padding: EdgeInsets.all(AppConstants.spacingXL),
                    child: CircularProgressIndicator(),
                  ),
                )
              else if (assetsState.assets.isEmpty)
                const Center(
                  child: Padding(
                    padding: EdgeInsets.all(AppConstants.spacingXL),
                    child: Text('No assets found'),
                  ),
                )
              else
                ...assetsState.assets.map((asset) => _AssetCard(asset: asset)),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _socketService.disconnect();
    super.dispose();
  }
}

class _AssetCard extends StatelessWidget {
  final AssetModel asset;

  const _AssetCard({required this.asset});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: AppConstants.spacingMD),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: AppConstants.primaryColor.withOpacity(0.1),
          child: Icon(
            AppConstants.assetIcons[asset.type] ?? Icons.account_balance,
            color: AppConstants.primaryColor,
          ),
        ),
        title: Text(
          asset.provider,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Text(asset.assetTypeLabel),
        trailing: Text(
          asset.formattedValue,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: AppConstants.primaryColor,
          ),
        ),
      ),
    );
  }
}

