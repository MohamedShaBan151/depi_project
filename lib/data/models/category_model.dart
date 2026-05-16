// lib/data/models/category_model.dart
// ─────────────────────────────────────────────────────────────────────────────
// Maps /categories/{categoryId} — see Firestore Integration Plan §1.2
// ─────────────────────────────────────────────────────────────────────────────

import 'package:cloud_firestore/cloud_firestore.dart';
import 'firestore_helpers.dart';

class CategoryModel {
  final String id;
  final String name;
  final String slug;
  final String? imgUrl;
  final String? parentId; // empty string = root category
  final String? productCount; // denormalised, updated by Cloud Function
  final DateTime createdAt;

  const CategoryModel({
    required this.id,
    required this.name,
    required this.slug,
    this.imgUrl,
    this.parentId,
    this.productCount,
    required this.createdAt,
  });

  bool get isRoot => parentId == null || parentId!.isEmpty;

  factory CategoryModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return CategoryModel(
      id: doc.id,
      name: data['name'] as String? ?? '',
      slug: data['slug'] as String? ?? '',
      imgUrl: data['imgUrl'] as String?,
      parentId: data['parentId'] as String?,
      productCount: data['productCount'] as String?,
      createdAt: tsToDate(data['createdAt']),
    );
  }

  Map<String, dynamic> toFirestore() => {
        'name': name,
        'slug': slug,
        'imgUrl': imgUrl,
        'parentId': parentId ?? '',
        'productCount': productCount,
        'createdAt': FieldValue.serverTimestamp(),
      };
}
