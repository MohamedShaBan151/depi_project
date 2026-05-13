import 'package:flutter/material.dart';

import '../../../../core/theme/saudi_theme.dart';
import '../../../auth/data/models/user_model.dart';
import '../../data/address_service.dart';

class AddressesScreen extends StatefulWidget {
  const AddressesScreen({super.key});

  @override
  State<AddressesScreen> createState() => _AddressesScreenState();
}

class _AddressesScreenState extends State<AddressesScreen> {
  List<FirestoreAddress> _addresses = [];

  @override
  void initState() {
    super.initState();
    _loadAddresses();
  }

  void _loadAddresses() {
    setState(() {
      _addresses = AddressService.loadAddresses();
    });
  }

  void _deleteAddress(FirestoreAddress address) {
    AddressService.deleteAddress(address.id);
    _loadAddresses();
  }

  void _showAddEditDialog({FirestoreAddress? existing}) {
    final labelController = TextEditingController(text: existing?.label ?? '');
    final addressController = TextEditingController(text: existing?.address ?? '');
    final cityController = TextEditingController(text: existing?.city ?? '');
    final districtController = TextEditingController(text: existing?.district ?? '');
    final phoneController = TextEditingController(text: existing?.phone ?? '');
    final buildingController = TextEditingController(text: existing?.building ?? '');
    final floorController = TextEditingController(text: existing?.floor ?? '');

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(existing != null ? 'Edit Address' : 'Add Address'),
        content: SingleChildScrollView(
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            TextField(
              controller: labelController,
              decoration: const InputDecoration(labelText: 'Label (Home/Work)', prefixIcon: Icon(Icons.label)),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: addressController,
              decoration: const InputDecoration(labelText: 'Address', prefixIcon: Icon(Icons.location_on)),
            ),
            const SizedBox(height: 12),
            Row(children: [
              Expanded(
                child: TextField(
                  controller: cityController,
                  decoration: const InputDecoration(labelText: 'City', prefixIcon: Icon(Icons.location_city)),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: TextField(
                  controller: districtController,
                  decoration: const InputDecoration(labelText: 'District'),
                ),
              ),
            ]),
            const SizedBox(height: 12),
            TextField(
              controller: phoneController,
              decoration: const InputDecoration(labelText: 'Phone', prefixIcon: Icon(Icons.phone), hintText: '+9665XXXXXXXX'),
              keyboardType: TextInputType.phone,
            ),
            const SizedBox(height: 12),
            Row(children: [
              Expanded(
                child: TextField(
                  controller: buildingController,
                  decoration: const InputDecoration(labelText: 'Building'),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: TextField(
                  controller: floorController,
                  decoration: const InputDecoration(labelText: 'Floor'),
                ),
              ),
            ]),
          ]),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () async {
              if (existing != null) {
                await AddressService.updateAddress(FirestoreAddress(
                  id: existing.id,
                  label: labelController.text,
                  address: addressController.text,
                  city: cityController.text,
                  district: districtController.text,
                  building: buildingController.text,
                  floor: floorController.text,
                  phone: phoneController.text,
                  isDefault: existing.isDefault,
                ));
              } else {
                await AddressService.addAddress(FirestoreAddress(
                  id: 'addr_${DateTime.now().millisecondsSinceEpoch}',
                  label: labelController.text,
                  address: addressController.text,
                  city: cityController.text,
                  district: districtController.text,
                  building: buildingController.text,
                  floor: floorController.text,
                  phone: phoneController.text,
                ));
              }
              if (ctx.mounted) Navigator.pop(ctx);
              _loadAddresses();
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.darkGreen),
            child: const Text('Save', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surface,
      appBar: AppBar(
        backgroundColor: AppColors.darkGreen,
        foregroundColor: Colors.white,
        title: const Text('عناويني'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => _showAddEditDialog(),
          ),
        ],
      ),
      body: _addresses.isEmpty
          ? _buildEmptyState()
          : RefreshIndicator(
              onRefresh: () async => _loadAddresses(),
              child: ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: _addresses.length,
                itemBuilder: (context, index) => _buildAddressCard(_addresses[index]),
              ),
            ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        Icon(Icons.location_off, size: 64, color: AppColors.darkGreen.withValues(alpha: 0.3)),
        const SizedBox(height: 16),
        const Text('No addresses saved',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
        const SizedBox(height: 24),
        ElevatedButton.icon(
          onPressed: () => _showAddEditDialog(),
          icon: const Icon(Icons.add),
          label: const Text('Add New Address'),
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.darkGreen,
            foregroundColor: Colors.white,
          ),
        ),
      ]),
    );
  }

  Widget _buildAddressCard(FirestoreAddress address) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.all(16),
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: AppColors.darkGreen.withValues(alpha: 0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(
            address.label.contains('منزل') || address.label.contains('Home')
                ? Icons.home
                : Icons.work,
            color: AppColors.darkGreen,
          ),
        ),
        title: Row(children: [
          Text(address.label, style: const TextStyle(fontWeight: FontWeight.w600)),
          if (address.isDefault) ...[
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: AppColors.primary,
                borderRadius: BorderRadius.circular(4),
              ),
              child: const Text('Default', style: TextStyle(fontSize: 9, fontWeight: FontWeight.w600)),
            ),
          ],
        ]),
        subtitle: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(address.address, style: const TextStyle(fontSize: 13)),
          Text('${address.city}, ${address.district}',
              style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
          Text(address.phone, style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
        ]),
        trailing: Row(mainAxisSize: MainAxisSize.min, children: [
          IconButton(
            icon: const Icon(Icons.edit, size: 20, color: AppColors.darkGreen),
            onPressed: () => _showAddEditDialog(existing: address),
          ),
          IconButton(
            icon: const Icon(Icons.delete, size: 20, color: AppColors.error),
            onPressed: () => _deleteAddress(address),
          ),
        ]),
      ),
    );
  }
}
