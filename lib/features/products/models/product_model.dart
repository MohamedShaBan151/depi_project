import '../domain/entities/product.dart';

class ProductModel {
  final String id;
  final String name;
  final double price;
  final String category;
  final int stock;
  final String imageUrl;

  const ProductModel({
    required this.id,
    required this.name,
    required this.price,
    required this.category,
    required this.stock,
    required this.imageUrl,
  });

  /// Firestore factory – only used with live Firebase.
  // factory ProductModel.fromDoc(DocumentSnapshot doc) {
  //   final data = doc.data() as Map<String, dynamic>;
  //   return ProductModel(
  //     id: doc.id,
  //     name: data['name'] ?? '',
  //     price: (data['price'] ?? 0).toDouble(),
  //     category: data['category'] ?? '',
  //     stock: data['stock'] ?? 0,
  //     imageUrl: data['imageUrl'] ?? '',
  //   );
  // }

  Map<String, dynamic> toJson() => {
    'name': name,
    'price': price,
    'category': category,
    'stock': stock,
    'imageUrl': imageUrl,
  };

  Product toEntity() => Product(
    id: id,
    name: name,
    price: price,
    category: category,
    imageUrl: imageUrl,
  );
}
