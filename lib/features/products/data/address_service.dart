import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../../auth/data/models/user_model.dart';

class AddressService {
  static const String _key = 'noon_addresses_v1';
  static SharedPreferences? _prefs;

  static Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  static List<FirestoreAddress> loadAddresses() {
    try {
      if (_prefs == null) return _defaultAddresses;
      final raw = _prefs!.getString(_key);
      if (raw == null || raw.isEmpty) return _defaultAddresses;
      final List<dynamic> decoded = jsonDecode(raw) as List<dynamic>;
      final addresses = decoded
          .map((e) => FirestoreAddress.fromJson(e as Map<String, dynamic>))
          .toList();
      return addresses.isEmpty ? _defaultAddresses : addresses;
    } catch (_) {
      return _defaultAddresses;
    }
  }

  static List<FirestoreAddress> get _defaultAddresses => [
        FirestoreAddress(
          id: 'addr1',
          label: 'المنزل',
          address: 'الرياض، حي النرجس، شارع العلياء',
          city: 'الرياض',
          district: 'النرجس',
          phone: '+966500000000',
          isDefault: true,
        ),
        FirestoreAddress(
          id: 'addr2',
          label: 'العمل',
          address: 'الرياض، حي المالحة، برج الفهد',
          city: 'الرياض',
          district: 'المالحة',
          phone: '+966500000001',
          isDefault: false,
        ),
      ];

  static Future<void> saveAddresses(List<FirestoreAddress> addresses) async {
    if (_prefs == null) await init();
    final encoded = jsonEncode(addresses.map((a) => a.toJson()).toList());
    await _prefs!.setString(_key, encoded);
  }

  static Future<void> addAddress(FirestoreAddress address) async {
    final addresses = loadAddresses();
    addresses.add(address);
    await saveAddresses(addresses);
  }

  static Future<void> updateAddress(FirestoreAddress address) async {
    final addresses = loadAddresses();
    final idx = addresses.indexWhere((a) => a.id == address.id);
    if (idx != -1) {
      addresses[idx] = address;
      await saveAddresses(addresses);
    }
  }

  static Future<void> deleteAddress(String id) async {
    final addresses = loadAddresses().where((a) => a.id != id).toList();
    await saveAddresses(addresses);
  }
}
