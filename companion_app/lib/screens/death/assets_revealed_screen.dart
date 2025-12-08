import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../models/designation_model.dart';
import '../../models/asset_model.dart';
import '../../providers/assets_provider.dart';
import '../../utils/constants.dart';

class AssetsRevealedScreen extends ConsumerWidget {
  final DesignationModel designation;

  const AssetsRevealedScreen({
    super.key,
    required this.designation,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final assetsState = ref.watch(assetsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Assets Revealed'),
        backgroundColor: AppConstants.successColor,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppConstants.spacingMD),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Success card
            Card(
              color: AppConstants.successColor,
              child: Padding(
                padding: const EdgeInsets.all(AppConstants.spacingLG),
                child: Column(
                  children: [
                    const Icon(
                      Icons.check_circle,
                      size: 64,
                      color: Colors.white,
                    ),
                    const SizedBox(height: AppConstants.spacingMD),
                    const Text(
                      'Verification Complete',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: AppConstants.spacingSM),
                    Text(
                      'Assets of ${designation.accountHolderName} are now accessible',
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 14,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: AppConstants.spacingLG),
            
            // Total Net Worth
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
                        fontSize: 36,
                        fontWeight: FontWeight.bold,
                        color: AppConstants.successColor,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: AppConstants.spacingLG),
            
            // Info card
            Container(
              padding: const EdgeInsets.all(AppConstants.spacingMD),
              decoration: BoxDecoration(
                color: AppConstants.primaryColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(AppConstants.radiusMD),
              ),
              child: const Row(
                children: [
                  Icon(Icons.info, color: AppConstants.primaryColor),
                  SizedBox(width: AppConstants.spacingMD),
                  Expanded(
                    child: Text(
                      'You can now proceed to claim these assets. Tap on any asset for claims guidance.',
                      style: TextStyle(fontSize: 12),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppConstants.spacingLG),
            
            // Assets section
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Assets',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  '${assetsState.assets.length} items',
                  style: const TextStyle(color: Colors.grey),
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
    );
  }
}

class _AssetCard extends StatelessWidget {
  final AssetModel asset;

  const _AssetCard({required this.asset});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: AppConstants.spacingMD),
      child: ExpansionTile(
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
            color: AppConstants.successColor,
          ),
        ),
        children: [
          Padding(
            padding: const EdgeInsets.all(AppConstants.spacingMD),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Divider(),
                const SizedBox(height: AppConstants.spacingMD),
                _DetailRow(
                  label: 'Account Number',
                  value: asset.accountNumber,
                ),
                ...asset.details.entries.map((entry) {
                  return _DetailRow(
                    label: entry.key.toString().replaceAll('_', ' ').toUpperCase(),
                    value: entry.value.toString(),
                  );
                }),
                const SizedBox(height: AppConstants.spacingMD),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    onPressed: () {
                      _showClaimsGuidance(context, asset.type);
                    },
                    icon: const Icon(Icons.help_outline),
                    label: const Text('How to Claim'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppConstants.primaryColor,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showClaimsGuidance(BuildContext context, String assetType) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Claims Guidance'),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('How to claim ${asset.assetTypeLabel}:'),
              const SizedBox(height: AppConstants.spacingMD),
              const Text(
                '1. Collect necessary documents:\n'
                '   • Death certificate\n'
                '   • Proof of relationship\n'
                '   • Identity proof\n'
                '   • Claimant bank details\n\n'
                '2. Contact the provider directly\n\n'
                '3. Submit claim form with documents\n\n'
                '4. Wait for verification\n\n'
                '5. Receive assets transfer',
                style: TextStyle(fontSize: 14),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
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
    return Padding(
      padding: const EdgeInsets.only(bottom: AppConstants.spacingSM),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: const TextStyle(
                fontSize: 12,
                color: Colors.grey,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontSize: 12),
            ),
          ),
        ],
      ),
    );
  }
}

