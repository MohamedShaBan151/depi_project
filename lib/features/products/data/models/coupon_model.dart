class Coupon {
  final String code;
  final String description;
  final double discountPercent;
  final double? maxDiscount;
  final double? minOrderAmount;
  final bool isActive;
  final DateTime? expiresAt;

  const Coupon({
    required this.code,
    required this.description,
    required this.discountPercent,
    this.maxDiscount,
    this.minOrderAmount,
    this.isActive = true,
    this.expiresAt,
  });

  bool get isValid {
    if (!isActive) return false;
    if (expiresAt != null && DateTime.now().isAfter(expiresAt!)) return false;
    return true;
  }

  double applyDiscount(double subtotal) {
    if (!isValid) return subtotal;
    if (minOrderAmount != null && subtotal < minOrderAmount!) return subtotal;
    final discount = subtotal * discountPercent / 100;
    if (maxDiscount != null && discount > maxDiscount!) {
      return subtotal - maxDiscount!;
    }
    return subtotal - discount;
  }

  double getDiscountAmount(double subtotal) {
    if (!isValid) return 0;
    if (minOrderAmount != null && subtotal < minOrderAmount!) return 0;
    final discount = subtotal * discountPercent / 100;
    if (maxDiscount != null && discount > maxDiscount!) return maxDiscount!;
    return discount;
  }

  factory Coupon.fromJson(Map<String, dynamic> json) {
    return Coupon(
      code: json['code'] as String,
      description: json['description'] as String? ?? '',
      discountPercent: (json['discountPercent'] as num).toDouble(),
      maxDiscount: (json['maxDiscount'] as num?)?.toDouble(),
      minOrderAmount: (json['minOrderAmount'] as num?)?.toDouble(),
      isActive: json['isActive'] as bool? ?? true,
      expiresAt: json['expiresAt'] != null
          ? DateTime.parse(json['expiresAt'] as String)
          : null,
    );
  }

  Map<String, dynamic> toJson() => {
        'code': code,
        'description': description,
        'discountPercent': discountPercent,
        'maxDiscount': maxDiscount,
        'minOrderAmount': minOrderAmount,
        'isActive': isActive,
        'expiresAt': expiresAt?.toIso8601String(),
      };
}

class CouponService {
  static const List<Coupon> _coupons = [
    Coupon(code: 'SAVE10', description: '10% off your order', discountPercent: 10, maxDiscount: 50, minOrderAmount: 100),
    Coupon(code: 'WELCOME20', description: '20% off for new users', discountPercent: 20, maxDiscount: 100, minOrderAmount: 200),
    Coupon(code: 'FREESHIP', description: 'Free shipping on orders over 50', discountPercent: 0, minOrderAmount: 50),
    Coupon(code: 'FLASH50', description: '50% off flash sale', discountPercent: 50, maxDiscount: 200, minOrderAmount: 300),
  ];

  static Coupon? validateCoupon(String code) {
    try {
      final coupon = _coupons.firstWhere(
        (c) => c.code.toLowerCase() == code.trim().toLowerCase(),
      );
      return coupon.isValid ? coupon : null;
    } catch (_) {
      return null;
    }
  }
}
