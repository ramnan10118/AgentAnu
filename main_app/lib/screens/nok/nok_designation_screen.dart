import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/nok_provider.dart';
import '../../services/socket_service.dart';
import '../../utils/validators.dart';
import '../../utils/constants.dart';

class NokDesignationScreen extends ConsumerStatefulWidget {
  const NokDesignationScreen({super.key});

  @override
  ConsumerState<NokDesignationScreen> createState() => _NokDesignationScreenState();
}

class _NokDesignationScreenState extends ConsumerState<NokDesignationScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _mobileController = TextEditingController();
  String _selectedRelationship = 'spouse';
  bool _isLoading = false;

  @override
  void dispose() {
    _nameController.dispose();
    _mobileController.dispose();
    super.dispose();
  }

  Future<void> _designateNok() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    final success = await ref.read(nokProvider.notifier).designateNok(
      nokMobile: _mobileController.text.trim(),
      nokName: _nameController.text.trim(),
      relationship: _selectedRelationship,
    );

    if (mounted) {
      setState(() => _isLoading = false);
      
      if (success) {
        final designation = ref.read(nokProvider).designation;
        if (designation != null) {
          // Emit socket event to notify NOK
          SocketService().emitNokDesignate(designation.id);
        }

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('NOK designated successfully!'),
            backgroundColor: AppConstants.successColor,
          ),
        );
        Navigator.pop(context);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(ref.read(nokProvider).error ?? 'Failed to designate NOK'),
            backgroundColor: AppConstants.errorColor,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Designate Next of Kin'),
        backgroundColor: AppConstants.primaryColor,
        foregroundColor: Colors.white,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppConstants.spacingLG),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
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
                          'Your Next of Kin will be able to access your assets after verification of your demise.',
                          style: TextStyle(fontSize: 12),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: AppConstants.spacingXL),
                
                // NOK Name
                const Text(
                  'Full Name',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: AppConstants.spacingSM),
                TextFormField(
                  controller: _nameController,
                  validator: Validators.validateName,
                  decoration: InputDecoration(
                    hintText: 'Enter full name',
                    prefixIcon: const Icon(Icons.person),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(AppConstants.radiusMD),
                    ),
                    filled: true,
                    fillColor: Colors.white,
                  ),
                ),
                const SizedBox(height: AppConstants.spacingLG),
                
                // NOK Mobile
                const Text(
                  'Mobile Number',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: AppConstants.spacingSM),
                TextFormField(
                  controller: _mobileController,
                  keyboardType: TextInputType.phone,
                  validator: Validators.validateMobile,
                  decoration: InputDecoration(
                    hintText: '+919123456789',
                    prefixIcon: const Icon(Icons.phone),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(AppConstants.radiusMD),
                    ),
                    filled: true,
                    fillColor: Colors.white,
                  ),
                ),
                const SizedBox(height: AppConstants.spacingLG),
                
                // Relationship
                const Text(
                  'Relationship',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: AppConstants.spacingSM),
                DropdownButtonFormField<String>(
                  value: _selectedRelationship,
                  decoration: InputDecoration(
                    prefixIcon: const Icon(Icons.family_restroom),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(AppConstants.radiusMD),
                    ),
                    filled: true,
                    fillColor: Colors.white,
                  ),
                  items: AppConstants.relationships.map((relationship) {
                    return DropdownMenuItem(
                      value: relationship,
                      child: Text(
                        relationship[0].toUpperCase() + relationship.substring(1),
                      ),
                    );
                  }).toList(),
                  onChanged: (value) {
                    if (value != null) {
                      setState(() => _selectedRelationship = value);
                    }
                  },
                ),
                const SizedBox(height: AppConstants.spacingXL),
                
                // Submit button
                ElevatedButton(
                  onPressed: _isLoading ? null : _designateNok,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppConstants.primaryColor,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                      vertical: AppConstants.spacingMD,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(AppConstants.radiusMD),
                    ),
                  ),
                  child: _isLoading
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                          ),
                        )
                      : const Text(
                          'Designate NOK',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

