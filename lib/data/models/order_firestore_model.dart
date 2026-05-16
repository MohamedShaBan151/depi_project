// lib/data/models/order_firestore_model.dart
// ─────────────────────────────────────────────────────────────────────────────
// Maps /orders/{orderId} — see Integration Plan §1.3
// ─────────────────────────────────────────────────────────────────────────────

import 'package:cloud_firestore/cloud_firestore.dart';
import 'firestore_helpers.dart';

enum FsOrderStatus {
  pending,
  processing,
  shipped,
  delivered,
  cancelled;

  String get label {
    switch (this) {
      case FsOrderStatus.pending:
        return 'Pending';
      case FsOrderStatus.processing:
        return 'Processing';
      case FsOrderStatus.shipped:
        return 'Shipped';
      case FsOrderStatus.delivered:
        return 'Delivered';
      case FsOrderStatus.cancelled:
        return 'Cancelled';
    }
  }

  String get labelAr {
    switch (this) {
      case FsOrderStatus.pending:
        return 'قيد الانتظار';
      case FsOrderStatus.processing:
        return 'قيد التجهيز';
      case FsOrderStatus.shipped:
        return 'مشحون';
      case FsOrderStatus.delivered:
        return 'تم التسليم';
      case FsOrderStatus.cancelled:
        return 'ملغى';
    }
  }
}

enum FsPaymentStatus { pending, completed, failed, refunded }

class FsOrderItem {
  final String productId;
  final String title;
  final double price;
  final int qty;
  final String? variantId;

  const FsOrderItem({
    required this.productId,
    required this.title,
    required this.price,
    required this.qty,
    this.variantId,
  });

  double get subtotal => price * qty;

  factory FsOrderItem.fromMap(Map<String, dynamic> map) => FsOrderItem(
        productId: map['productId'] as String? ?? '',
        title: map['title'] as String? ?? '',
        price: (map['price'] as num?)?.toDouble() ?? 0.0,
        qty: map['qty'] as int? ?? 1,
        variantId: map['variantId'] as String?,
      );

  Map<String, dynamic> toMap() => {
        'productId': productId,
        'title': title,
        'price': price,
        'qty': qty,
        'variantId': variantId,
      };
}

class FsShippingAddress {
  final String address;
  final String city;
  final String? state;
  final String? postalCode;
  final String country;

  const FsShippingAddress({
    required this.address,
    required this.city,
    this.state,
    this.postalCode,
    this.country = 'SA',
  });

  factory FsShippingAddress.fromMap(Map<String, dynamic> map) =>
      FsShippingAddress(
        address: map['address'] as String? ?? '',
        city: map['city'] as String? ?? '',
        state: map['state'] as String?,
        postalCode: map['postalCode'] as String?,
        country: map['country'] as String? ?? 'SA',
      );

  Map<String, dynamic> toMap() => {
        'address': address,
        'city': city,
        'state': state,
        'postalCode': postalCode,
        'country': country,
      };
}

class OrderFirestoreModel {
  final String id;
  final String userId;
  final String userEmail;
  final List<FsOrderItem> items;
  final double subtotal;
  final double shippingCost;
  final double tax;
  final double discount;
  final double total;
  final FsOrderStatus status;
  final FsPaymentStatus paymentStatus;
  final String? paymentId;
  final FsShippingAddress shippingAddress;
  final String currencyCode;
  final String? trackingNumber;
  final String? notes;
  final bool isDeleted;
  final DateTime createdAt;
  final DateTime updatedAt;

  const OrderFirestoreModel({
    required this.id,
    required this.userId,
    required this.userEmail,
    required this.items,
    required this.subtotal,
    this.shippingCost = 0.0,
    this.tax = 0.0,
    this.discount = 0.0,
    required this.total,
    this.status = FsOrderStatus.pending,
    this.paymentStatus = FsPaymentStatus.pending,
    this.paymentId,
    required this.shippingAddress,
    this.currencyCode = 'SAR',
    this.trackingNumber,
    this.notes,
    this.isDeleted = false,
    required this.createdAt,
    required this.updatedAt,
  });

  int get itemCount => items.fold(0, (sum, i) => sum + i.qty);

  factory OrderFirestoreModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return OrderFirestoreModel(
      id: doc.id,
      userId: data['userId'] as String? ?? '',
      userEmail: data['userEmail'] as String? ?? '',
      items: (data['items'] as List<dynamic>?)
              ?.map((e) => FsOrderItem.fromMap(e as Map<String, dynamic>))
              .toList() ??
          [],
      subtotal: (data['subtotal'] as num?)?.toDouble() ?? 0.0,
      shippingCost: (data['shippingCost'] as num?)?.toDouble() ?? 0.0,
      tax: (data['tax'] as num?)?.toDouble() ?? 0.0,
      discount: (data['discount'] as num?)?.toDouble() ?? 0.0,
      total: (data['total'] as num?)?.toDouble() ?? 0.0,
      status: FsOrderStatus.values.firstWhere(
        (e) => e.name == (data['status'] as String?),
        orElse: () => FsOrderStatus.pending,
      ),
      paymentStatus: FsPaymentStatus.values.firstWhere(
        (e) => e.name == (data['paymentStatus'] as String?),
        orElse: () => FsPaymentStatus.pending,
      ),
      paymentId: data['paymentId'] as String?,
      shippingAddress: FsShippingAddress.fromMap(
          data['shippingAddress'] as Map<String, dynamic>? ?? {}),
      currencyCode: data['currencyCode'] as String? ?? 'SAR',
      trackingNumber: data['trackingNumber'] as String?,
      notes: data['notes'] as String?,
      isDeleted: data['isDeleted'] as bool? ?? false,
      createdAt: tsToDate(data['createdAt']),
      updatedAt: tsToDate(data['updatedAt']),
    );
  }

  Map<String, dynamic> toFirestore() => {
        'userId': userId,
        'userEmail': userEmail,
        'items': items.map((i) => i.toMap()).toList(),
        'subtotal': subtotal,
        'shippingCost': shippingCost,
        'tax': tax,
        'discount': discount,
        'total': total,
        'status': status.name,
        'paymentStatus': paymentStatus.name,
        'paymentId': paymentId,
        'shippingAddress': shippingAddress.toMap(),
        'currencyCode': currencyCode,
        'trackingNumber': trackingNumber,
        'notes': notes,
        'isDeleted': isDeleted,
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      };
}
