// lib/data/repositories/category_repository.dart
// ─────────────────────────────────────────────────────────────────────────────
// Reads /categories — public read, no auth required (plan §2.4)
// Categories are fetched once + cached locally (rarely changes).
// ─────────────────────────────────────────────────────────────────────────────

import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/category_model.dart';

abstract class CategoryRepository {
  Future<List<CategoryModel>> fetchAll();
  Future<List<CategoryModel>> fetchChildren(String parentId);
}

class CategoryRepositoryImpl implements CategoryRepository {
  CategoryRepositoryImpl({FirebaseFirestore? db})
      : _db = db ?? FirebaseFirestore.instance;

  final FirebaseFirestore _db;

  CollectionReference<Map<String, dynamic>> get _col =>
      _db.collection('categories');

  @override
  Future<List<CategoryModel>> fetchAll() async {
    final snap = await _col.get();
    return snap.docs.map(CategoryModel.fromFirestore).toList();
  }

  @override
  Future<List<CategoryModel>> fetchChildren(String parentId) async {
    final snap = await _col
        .where('parentId', isEqualTo: parentId)
        .get();
    return snap.docs.map(CategoryModel.fromFirestore).toList();
  }
}
