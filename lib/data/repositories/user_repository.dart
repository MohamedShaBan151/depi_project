// lib/data/repositories/user_repository.dart
// ─────────────────────────────────────────────────────────────────────────────
// /users/{userId} and /users/{userId}/addresses/{addressId}
// Strategy: snapshots() stream for profile (role/avatar changes propagate
// instantly); on-demand for addresses (plan §2.4)
// ─────────────────────────────────────────────────────────────────────────────

import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user_firestore_model.dart';

abstract class UserRepository {
  Stream<UserFirestoreModel?> watchProfile(String userId);
  Future<UserFirestoreModel?> fetchProfile(String userId);
  Future<void> createProfile(UserFirestoreModel user);
  Future<void> updateProfile(String userId, Map<String, dynamic> fields);

  Future<List<AddressModel>> fetchAddresses(String userId);
  Future<void> addAddress(String userId, AddressModel address);
  Future<void> deleteAddress(String userId, String addressId);
  Future<void> setDefaultAddress(String userId, String addressId);
}

class UserRepositoryImpl implements UserRepository {
  UserRepositoryImpl({FirebaseFirestore? db})
      : _db = db ?? FirebaseFirestore.instance;

  final FirebaseFirestore _db;

  DocumentReference<Map<String, dynamic>> _userDoc(String uid) =>
      _db.collection('users').doc(uid);

  CollectionReference<Map<String, dynamic>> _addrCol(String uid) =>
      _userDoc(uid).collection('addresses');

  @override
  Stream<UserFirestoreModel?> watchProfile(String userId) {
    return _userDoc(userId).snapshots().map((doc) {
      if (!doc.exists) return null;
      return UserFirestoreModel.fromFirestore(doc);
    });
  }

  @override
  Future<UserFirestoreModel?> fetchProfile(String userId) async {
    final doc = await _userDoc(userId).get();
    if (!doc.exists) return null;
    return UserFirestoreModel.fromFirestore(doc);
  }

  @override
  Future<void> createProfile(UserFirestoreModel user) async {
    await _userDoc(user.id).set(user.toFirestore(), SetOptions(merge: true));
  }

  @override
  Future<void> updateProfile(
      String userId, Map<String, dynamic> fields) async {
    await _userDoc(userId).update({
      ...fields,
      'lastLoginAt': FieldValue.serverTimestamp(),
    });
  }

  @override
  Future<List<AddressModel>> fetchAddresses(String userId) async {
    final snap = await _addrCol(userId)
        .orderBy('isDefault', descending: true)
        .get();
    return snap.docs.map(AddressModel.fromFirestore).toList();
  }

  @override
  Future<void> addAddress(String userId, AddressModel address) async {
    // If this is the default address, unset all others first.
    if (address.isDefault) {
      await _unsetDefaultAddresses(userId);
    }
    await _addrCol(userId).add(address.toFirestore());
  }

  @override
  Future<void> deleteAddress(String userId, String addressId) async {
    await _addrCol(userId).doc(addressId).delete();
  }

  @override
  Future<void> setDefaultAddress(String userId, String addressId) async {
    await _unsetDefaultAddresses(userId);
    await _addrCol(userId).doc(addressId).update({'isDefault': true});
  }

  Future<void> _unsetDefaultAddresses(String userId) async {
    final snap = await _addrCol(userId)
        .where('isDefault', isEqualTo: true)
        .get();
    final batch = _db.batch();
    for (final doc in snap.docs) {
      batch.update(doc.reference, {'isDefault': false});
    }
    await batch.commit();
  }
}
