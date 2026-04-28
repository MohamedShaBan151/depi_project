class FirestoreUser {
  final String id;
  final String name;
  final String email;
  final String? phone;
  final String? avatarUrl;
  final List<FirestoreAddress> addresses;
  final bool isEmailVerified;
  final DateTime createdAt;
  final DateTime? lastLoginAt;

  FirestoreUser({
    required this.id,
    required this.name,
    required this.email,
    this.phone,
    this.avatarUrl,
    this.addresses = const [],
    this.isEmailVerified = false,
    DateTime? createdAt,
    this.lastLoginAt,
  }) : createdAt = createdAt ?? DateTime.now();

  factory FirestoreUser.fromJson(Map<String, dynamic> json) {
    return FirestoreUser(
      id: json['id'] as String,
      name: json['name'] as String,
      email: json['email'] as String,
      phone: json['phone'] as String?,
      avatarUrl: json['avatarUrl'] as String?,
      addresses: (json['addresses'] as List<dynamic>?)
              ?.map((e) => FirestoreAddress.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      isEmailVerified: json['isEmailVerified'] as bool? ?? false,
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'] as String)
          : DateTime.now(),
      lastLoginAt: json['lastLoginAt'] != null
          ? DateTime.parse(json['lastLoginAt'] as String)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'phone': phone,
      'avatarUrl': avatarUrl,
      'addresses': addresses.map((e) => e.toJson()).toList(),
      'isEmailVerified': isEmailVerified,
      'createdAt': createdAt.toIso8601String(),
      'lastLoginAt': lastLoginAt?.toIso8601String(),
    };
  }
}

class FirestoreAddress {
  final String id;
  final String label;
  final String address;
  final String city;
  final String district;
  final String? building;
  final String? floor;
  final String? landmark;
  final String phone;
  final bool isDefault;

  FirestoreAddress({
    required this.id,
    required this.label,
    required this.address,
    required this.city,
    required this.district,
    this.building,
    this.floor,
    this.landmark,
    required this.phone,
    this.isDefault = false,
  });

  factory FirestoreAddress.fromJson(Map<String, dynamic> json) {
    return FirestoreAddress(
      id: json['id'] as String,
      label: json['label'] as String,
      address: json['address'] as String,
      city: json['city'] as String,
      district: json['district'] as String,
      building: json['building'] as String?,
      floor: json['floor'] as String?,
      landmark: json['landmark'] as String?,
      phone: json['phone'] as String,
      isDefault: json['isDefault'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'label': label,
      'address': address,
      'city': city,
      'district': district,
      'building': building,
      'floor': floor,
      'landmark': landmark,
      'phone': phone,
      'isDefault': isDefault,
    };
  }
}