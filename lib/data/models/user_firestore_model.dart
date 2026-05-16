// lib/data/models/user_firestore_model.dart
// ─────────────────────────────────────────────────────────────────────────────
// Maps /users/{userId} and /users/{userId}/addresses/{addressId}
// See Integration Plan §1.6
// ─────────────────────────────────────────────────────────────────────────────

import 'package:cloud_firestore/cloud_firestore.dart';
import 'firestore_helpers.dart';

class UserFirestoreModel {
  final String id;
  final String displayName;
  final String email;
  final String? phone;
  final String? avatarUrl;
  final String role; // customer | admin | vendor
  final bool isActive;
  final DateTime createdAt;
  final DateTime lastLoginAt;

  const UserFirestoreModel({
    required this.id,
    required this.displayName,
    required this.email,
    this.phone,
    this.avatarUrl,
    this.role = 'customer',
    this.isActive = true,
    required this.createdAt,
    required this.lastLoginAt,
  });

  bool get isAdmin => role == 'admin';

  factory UserFirestoreModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return UserFirestoreModel(
      id: doc.id,
      displayName: data['displayName'] as String? ?? '',
      email: data['email'] as String? ?? '',
      phone: data['phone'] as String?,
      avatarUrl: data['avatarUrl'] as String?,
      role: data['role'] as String? ?? 'customer',
      isActive: data['isActive'] as bool? ?? true,
      createdAt: tsToDate(data['createdAt']),
      lastLoginAt: tsToDate(data['lastLoginAt']),
    );
  }

  Map<String, dynamic> toFirestore() => {
        'displayName': displayName,
        'email': email,
        'phone': phone,
        'avatarUrl': avatarUrl,
        'role': role,
        'isActive': isActive,
        'createdAt': FieldValue.serverTimestamp(),
        'lastLoginAt': FieldValue.serverTimestamp(),
      };

  Map<String, dynamic> toUpdateMap() => {
        'displayName': displayName,
        'phone': phone,
        'avatarUrl': avatarUrl,
        'lastLoginAt': FieldValue.serverTimestamp(),
      };
}

class AddressModel {
  final String id;
  final String fullName;
  final String label; // Home | Work | Other
  final String line1;
  final String? line2;
  final String city;
  final String? state;
  final String country;
  final String? postalCode;
  final String phone;
  final bool isDefault;

  const AddressModel({
    required this.id,
    required this.fullName,
    required this.label,
    required this.line1,
    this.line2,
    required this.city,
    this.state,
    this.country = 'SA',
    this.postalCode,
    required this.phone,
    this.isDefault = false,
  });

  factory AddressModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return AddressModel(
      id: doc.id,
      fullName: data['fullName'] as String? ?? '',
      label: data['label'] as String? ?? 'Home',
      line1: data['line1'] as String? ?? '',
      line2: data['line2'] as String?,
      city: data['city'] as String? ?? '',
      state: data['state'] as String?,
      country: data['country'] as String? ?? 'SA',
      postalCode: data['postalCode'] as String?,
      phone: data['phone'] as String? ?? '',
      isDefault: data['isDefault'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toFirestore() => {
        'fullName': fullName,
        'label': label,
        'line1': line1,
        'line2': line2,
        'city': city,
        'state': state,
        'country': country,
        'postalCode': postalCode,
        'phone': phone,
        'isDefault': isDefault,
      };
}
