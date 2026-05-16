import 'package:equatable/equatable.dart';

enum ReturnStatus { pending, approved, shipped, received, refunded, rejected }

enum RefundStatus { pending, processing, completed, failed }

enum ReturnReason {
  defective,
  notAsDescribed,
  wrongItem,
  changed_mind,
  damaged_in_shipping,
  other,
}

extension ReturnReasonDisplay on ReturnReason {
  String get displayName {
    switch (this) {
      case ReturnReason.defective:
        return 'Defective/Not Working';
      case ReturnReason.notAsDescribed:
        return 'Not as Described';
      case ReturnReason.wrongItem:
        return 'Wrong Item Received';
      case ReturnReason.changed_mind:
        return 'Changed Mind';
      case ReturnReason.damaged_in_shipping:
        return 'Damaged in Shipping';
      case ReturnReason.other:
        return 'Other';
    }
  }
}

/// Return request model
class ReturnRequestModel extends Equatable {
  final String id;
  final String orderId;
  final String productId;
  final String userId;
  final ReturnReason reason;
  final String? comment;
  final List<String> imageUrls;
  final ReturnStatus returnStatus;
  final RefundStatus refundStatus;
  final double refundAmount;
  final DateTime createdAt;
  final DateTime? approvedAt;
  final DateTime? shippedAt;
  final DateTime? receivedAt;
  final DateTime? refundedAt;
  final String? trackingNumber;

  const ReturnRequestModel({
    required this.id,
    required this.orderId,
    required this.productId,
    required this.userId,
    required this.reason,
    this.comment,
    this.imageUrls = const [],
    this.returnStatus = ReturnStatus.pending,
    this.refundStatus = RefundStatus.pending,
    required this.refundAmount,
    required this.createdAt,
    this.approvedAt,
    this.shippedAt,
    this.receivedAt,
    this.refundedAt,
    this.trackingNumber,
  });

  bool get isPending => returnStatus == ReturnStatus.pending;
  bool get isApproved => returnStatus == ReturnStatus.approved;
  bool get isShipped => returnStatus == ReturnStatus.shipped;
  bool get isReceived => returnStatus == ReturnStatus.received;
  bool get isRefunded => returnStatus == ReturnStatus.refunded;
  bool get isRejected => returnStatus == ReturnStatus.rejected;

  factory ReturnRequestModel.fromJson(Map<String, dynamic> json) {
    return ReturnRequestModel(
      id: json['id'] as String,
      orderId: json['orderId'] as String,
      productId: json['productId'] as String,
      userId: json['userId'] as String,
      reason: ReturnReason.values.byName(json['reason'] as String? ?? 'other'),
      comment: json['comment'] as String?,
      imageUrls: List<String>.from(json['imageUrls'] as List? ?? []),
      returnStatus:
          ReturnStatus.values.byName(json['returnStatus'] as String? ?? 'pending'),
      refundStatus:
          RefundStatus.values.byName(json['refundStatus'] as String? ?? 'pending'),
      refundAmount: (json['refundAmount'] as num).toDouble(),
      createdAt: json['createdAt'] is DateTime
          ? json['createdAt'] as DateTime
          : DateTime.parse(json['createdAt'] as String),
      approvedAt: json['approvedAt'] != null
          ? json['approvedAt'] is DateTime
              ? json['approvedAt'] as DateTime
              : DateTime.parse(json['approvedAt'] as String)
          : null,
      shippedAt: json['shippedAt'] != null
          ? json['shippedAt'] is DateTime
              ? json['shippedAt'] as DateTime
              : DateTime.parse(json['shippedAt'] as String)
          : null,
      receivedAt: json['receivedAt'] != null
          ? json['receivedAt'] is DateTime
              ? json['receivedAt'] as DateTime
              : DateTime.parse(json['receivedAt'] as String)
          : null,
      refundedAt: json['refundedAt'] != null
          ? json['refundedAt'] is DateTime
              ? json['refundedAt'] as DateTime
              : DateTime.parse(json['refundedAt'] as String)
          : null,
      trackingNumber: json['trackingNumber'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'orderId': orderId,
        'productId': productId,
        'userId': userId,
        'reason': reason.name,
        'comment': comment,
        'imageUrls': imageUrls,
        'returnStatus': returnStatus.name,
        'refundStatus': refundStatus.name,
        'refundAmount': refundAmount,
        'createdAt': createdAt.toIso8601String(),
        'approvedAt': approvedAt?.toIso8601String(),
        'shippedAt': shippedAt?.toIso8601String(),
        'receivedAt': receivedAt?.toIso8601String(),
        'refundedAt': refundedAt?.toIso8601String(),
        'trackingNumber': trackingNumber,
      };

  ReturnRequestModel copyWith({
    String? id,
    String? orderId,
    String? productId,
    String? userId,
    ReturnReason? reason,
    String? comment,
    List<String>? imageUrls,
    ReturnStatus? returnStatus,
    RefundStatus? refundStatus,
    double? refundAmount,
    DateTime? createdAt,
    DateTime? approvedAt,
    DateTime? shippedAt,
    DateTime? receivedAt,
    DateTime? refundedAt,
    String? trackingNumber,
  }) {
    return ReturnRequestModel(
      id: id ?? this.id,
      orderId: orderId ?? this.orderId,
      productId: productId ?? this.productId,
      userId: userId ?? this.userId,
      reason: reason ?? this.reason,
      comment: comment ?? this.comment,
      imageUrls: imageUrls ?? this.imageUrls,
      returnStatus: returnStatus ?? this.returnStatus,
      refundStatus: refundStatus ?? this.refundStatus,
      refundAmount: refundAmount ?? this.refundAmount,
      createdAt: createdAt ?? this.createdAt,
      approvedAt: approvedAt ?? this.approvedAt,
      shippedAt: shippedAt ?? this.shippedAt,
      receivedAt: receivedAt ?? this.receivedAt,
      refundedAt: refundedAt ?? this.refundedAt,
      trackingNumber: trackingNumber ?? this.trackingNumber,
    );
  }

  @override
  List<Object?> get props => [id, orderId, userId, createdAt];
}
