import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/assets_provider.dart';
import '../../utils/constants.dart';
import '../dashboard/dashboard_screen.dart';

class AssetLoadingScreen extends ConsumerStatefulWidget {
  const AssetLoadingScreen({super.key});

  @override
  ConsumerState<AssetLoadingScreen> createState() => _AssetLoadingScreenState();
}

class _AssetLoadingScreenState extends ConsumerState<AssetLoadingScreen> {
  bool _hasStartedFetch = false;

  @override
  void initState() {
    super.initState();
    // Use longer delay to ensure we're completely outside the build phase
    Future.delayed(const Duration(milliseconds: 300), () {
      if (mounted && !_hasStartedFetch) {
        _hasStartedFetch = true;
        _fetchAssets();
      }
    });
  }

  Future<void> _fetchAssets() async {
    if (!mounted) return;
    
    // Simulate minimum loading time for better UX
    await Future.delayed(const Duration(seconds: 2));
    if (!mounted) return;
    
    // Ensure we're not in build phase before modifying provider
    await Future.delayed(const Duration(milliseconds: 100));
    if (!mounted) return;
    
    try {
      final success = await ref.read(assetsProvider.notifier).fetchAssets();
      
      if (mounted) {
        if (success) {
          // Verify assets were actually fetched
          await Future.delayed(const Duration(milliseconds: 100));
          if (!mounted) return;
          
          final assetsState = ref.read(assetsProvider);
          print('📦 Assets fetched: ${assetsState.assets.length} items');
          
          if (assetsState.assets.isEmpty) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('No assets found. Please try again.'),
                backgroundColor: AppConstants.errorColor,
              ),
            );
            return;
          }
          
          // Navigate to dashboard after successful fetch
          await Future.delayed(const Duration(milliseconds: 500));
          if (mounted) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) => const DashboardScreen(),
              ),
            );
          }
        } else {
          final assetsState = ref.read(assetsProvider);
          final errorMsg = assetsState.error ?? 'Failed to fetch assets';
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(errorMsg),
              backgroundColor: AppConstants.errorColor,
              duration: const Duration(seconds: 5),
            ),
          );
        }
      }
    } catch (e) {
      print('❌ Error fetching assets: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: AppConstants.errorColor,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(AppConstants.spacingXL),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Loading animation
                Container(
                  width: 120,
                  height: 120,
                  decoration: BoxDecoration(
                    color: AppConstants.primaryColor.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const Padding(
                    padding: EdgeInsets.all(30.0),
                    child: CircularProgressIndicator(
                      strokeWidth: 4,
                      valueColor: AlwaysStoppedAnimation<Color>(AppConstants.primaryColor),
                    ),
                  ),
                ),
                const SizedBox(height: AppConstants.spacingXL),
                
                const Text(
                  'Fetching Your Assets',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: AppConstants.spacingMD),
                
                const Text(
                  'Please wait while we securely retrieve your financial information...',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey,
                  ),
                ),
                const SizedBox(height: AppConstants.spacingXL * 2),
                
                // Loading steps
                const Column(
                  children: [
                    _LoadingStep(
                      icon: Icons.lock_open,
                      text: 'Connecting to Account Aggregator',
                    ),
                    SizedBox(height: AppConstants.spacingMD),
                    _LoadingStep(
                      icon: Icons.cloud_download,
                      text: 'Fetching financial data',
                    ),
                    SizedBox(height: AppConstants.spacingMD),
                    _LoadingStep(
                      icon: Icons.calculate,
                      text: 'Calculating total net worth',
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _LoadingStep extends StatelessWidget {
  final IconData icon;
  final String text;

  const _LoadingStep({
    required this.icon,
    required this.text,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(icon, color: AppConstants.primaryColor, size: 20),
        const SizedBox(width: AppConstants.spacingMD),
        Text(
          text,
          style: const TextStyle(fontSize: 14),
        ),
      ],
    );
  }
}

