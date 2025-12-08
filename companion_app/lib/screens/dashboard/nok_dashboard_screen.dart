import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/auth_provider.dart';
import '../../providers/nok_provider.dart';
import '../../providers/assets_provider.dart';
import '../../services/socket_service.dart';
import '../../utils/constants.dart';
import '../designation/designation_list_screen.dart';
import '../death/upload_death_certificate_screen.dart';
import '../auth/mobile_entry_screen.dart';

class NokDashboardScreen extends ConsumerStatefulWidget {
  const NokDashboardScreen({super.key});

  @override
  ConsumerState<NokDashboardScreen> createState() => _NokDashboardScreenState();
}

class _NokDashboardScreenState extends ConsumerState<NokDashboardScreen> {
  final SocketService _socketService = SocketService();

  @override
  void initState() {
    super.initState();
    _initializeSocket();
    _loadDesignations();
  }

  void _initializeSocket() {
    _socketService.onNokDesignated = (data) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('New designation from ${data['accountHolderName']}'),
            backgroundColor: AppConstants.primaryColor,
            duration: const Duration(seconds: 5),
            action: SnackBarAction(
              label: 'View',
              textColor: Colors.white,
              onPressed: () {
                ref.read(nokProvider.notifier).getDesignations();
              },
            ),
          ),
        );
        ref.read(nokProvider.notifier).getDesignations();
      }
    };

    _socketService.onDeathVerified = (data) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Death certificate verified! Assets are now visible.'),
            backgroundColor: AppConstants.successColor,
            duration: Duration(seconds: 5),
          ),
        );
      }
    };

    _socketService.connect();
  }

  Future<void> _loadDesignations() async {
    await ref.read(nokProvider.notifier).getDesignations();
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
    final authState = ref.watch(authProvider);
    final nokState = ref.watch(nokProvider);
    final assetsState = ref.watch(assetsProvider);

    // Find accepted designation
    final acceptedDesignation = nokState.designations
        .where((d) => d.isAccepted)
        .firstOrNull;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Next of Kin Dashboard'),
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
        onRefresh: _loadDesignations,
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
                        'Welcome',
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
              
              // Pending designations
              if (nokState.designations.where((d) => d.isPending).isNotEmpty)
                Card(
                  color: AppConstants.secondaryColor.withOpacity(0.1),
                  child: Padding(
                    padding: const EdgeInsets.all(AppConstants.spacingMD),
                    child: Row(
                      children: [
                        const Icon(Icons.notifications, color: AppConstants.secondaryColor),
                        const SizedBox(width: AppConstants.spacingMD),
                        Expanded(
                          child: Text(
                            '${nokState.designations.where((d) => d.isPending).length} pending designation(s)',
                          ),
                        ),
                        ElevatedButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const DesignationListScreen(),
                              ),
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppConstants.secondaryColor,
                          ),
                          child: const Text('Review'),
                        ),
                      ],
                    ),
                  ),
                ),
              
              // Accepted designation
              if (acceptedDesignation != null) ...[
                const SizedBox(height: AppConstants.spacingMD),
                Card(
                  color: AppConstants.successColor.withOpacity(0.1),
                  child: Padding(
                    padding: const EdgeInsets.all(AppConstants.spacingLG),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Row(
                          children: [
                            Icon(Icons.check_circle, color: AppConstants.successColor),
                            SizedBox(width: AppConstants.spacingSM),
                            Text(
                              'Active Designation',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: AppConstants.spacingMD),
                        Text(
                          'Account Holder: ${acceptedDesignation.accountHolderName ?? "Unknown"}',
                          style: const TextStyle(fontSize: 14),
                        ),
                        Text(
                          'Relationship: ${acceptedDesignation.relationshipLabel}',
                          style: const TextStyle(fontSize: 14),
                        ),
                        const SizedBox(height: AppConstants.spacingMD),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton.icon(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => UploadDeathCertificateScreen(
                                    designation: acceptedDesignation,
                                  ),
                                ),
                              );
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppConstants.primaryColor,
                            ),
                            icon: const Icon(Icons.upload_file),
                            label: const Text('Initiate Asset Retrieval'),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
              
              const SizedBox(height: AppConstants.spacingLG),
              
              // All designations
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'My Designations',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    '${nokState.designations.length} total',
                    style: const TextStyle(color: Colors.grey),
                  ),
                ],
              ),
              const SizedBox(height: AppConstants.spacingMD),
              
              if (nokState.isLoading)
                const Center(
                  child: Padding(
                    padding: EdgeInsets.all(AppConstants.spacingXL),
                    child: CircularProgressIndicator(),
                  ),
                )
              else if (nokState.designations.isEmpty)
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(AppConstants.spacingXL),
                    child: Column(
                      children: [
                        Icon(
                          Icons.inbox,
                          size: 64,
                          color: Colors.grey.shade400,
                        ),
                        const SizedBox(height: AppConstants.spacingMD),
                        const Text(
                          'No designations yet',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.grey,
                          ),
                        ),
                      ],
                    ),
                  ),
                )
              else
                ...nokState.designations.map((designation) {
                  return Card(
                    margin: const EdgeInsets.only(bottom: AppConstants.spacingMD),
                    child: ListTile(
                      leading: CircleAvatar(
                        backgroundColor: designation.isPending
                            ? AppConstants.secondaryColor.withOpacity(0.2)
                            : designation.isAccepted
                                ? AppConstants.successColor.withOpacity(0.2)
                                : AppConstants.errorColor.withOpacity(0.2),
                        child: Icon(
                          designation.isPending
                              ? Icons.pending
                              : designation.isAccepted
                                  ? Icons.check_circle
                                  : Icons.cancel,
                          color: designation.isPending
                              ? AppConstants.secondaryColor
                              : designation.isAccepted
                                  ? AppConstants.successColor
                                  : AppConstants.errorColor,
                        ),
                      ),
                      title: Text(
                        designation.accountHolderName ?? 'Unknown',
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      subtitle: Text(
                        '${designation.relationshipLabel} • ${designation.status}',
                      ),
                      trailing: designation.isPending
                          ? const Icon(Icons.arrow_forward_ios, size: 16)
                          : null,
                      onTap: designation.isPending
                          ? () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => const DesignationListScreen(),
                                ),
                              );
                            }
                          : null,
                    ),
                  );
                }),
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

