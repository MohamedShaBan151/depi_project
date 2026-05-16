// lib/data/models/firestore_helpers.dart
// ─────────────────────────────────────────────────────────────────────────────
// Timestamp conversion helpers — used by every fromFirestore factory.
// Always use FieldValue.serverTimestamp() when WRITING timestamps to Firestore.
// ─────────────────────────────────────────────────────────────────────────────

import 'package:cloud_firestore/cloud_firestore.dart';

/// Converts a Firestore [Timestamp], ISO-8601 [String], or [null] to [DateTime].
/// Falls back to [DateTime.now()] when the value is absent or unrecognised.
DateTime tsToDate(dynamic value) {
  if (value == null) return DateTime.now();
  if (value is Timestamp) return value.toDate();
  if (value is String) return DateTime.parse(value);
  return DateTime.now();
}

/// Nullable variant — returns [null] when the field is absent.
DateTime? tsToDateNullable(dynamic value) {
  if (value == null) return null;
  if (value is Timestamp) return value.toDate();
  if (value is String) return DateTime.parse(value);
  return null;
}
