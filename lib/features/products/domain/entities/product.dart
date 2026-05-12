class Product {
  final String id;
  final String name;
  final double price;
  final String category;
  final String imageUrl;
  final int stock;
  final double? originalPrice; // null → no discount badge
  final double rating;         // 0–5
  final int reviewCount;
  final bool isFeatured;

  const Product({
    required this.id,
    required this.name,
    required this.price,
    required this.category,
    this.imageUrl = '',
    this.stock = 0,
    this.originalPrice,
    this.rating = 4.0,
    this.reviewCount = 0,
    this.isFeatured = false,
  });

  bool get hasDiscount => originalPrice != null && originalPrice! > price;

  int get discountPercent {
    if (!hasDiscount) return 0;
    return (((originalPrice! - price) / originalPrice!) * 100).round();
  }
}
