// test/data/repositories/firestore_helpers_test.dart
// ─────────────────────────────────────────────────────────────────────────────
// Pure unit tests — no Firebase emulator needed.
// ─────────────────────────────────────────────────────────────────────────────

import 'package:flutter_test/flutter_test.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:noon_clone/data/models/firestore_helpers.dart';

void main() {
  group('tsToDate', () {
    test('converts Timestamp correctly', () {
      final now = DateTime(2025, 5, 1, 12, 0, 0);
      final ts = Timestamp.fromDate(now);
      expect(tsToDate(ts), now);
    });

    test('parses ISO-8601 string', () {
      const iso = '2025-05-01T12:00:00.000';
      final result = tsToDate(iso);
      expect(result.year, 2025);
      expect(result.month, 5);
    });

    test('returns DateTime.now() equivalent when null', () {
      final before = DateTime.now().subtract(const Duration(seconds: 1));
      final result = tsToDate(null);
      expect(result.isAfter(before), isTrue);
    });
  });

  group('tsToDateNullable', () {
    test('returns null for null input', () {
      expect(tsToDateNullable(null), isNull);
    });

    test('converts Timestamp correctly', () {
      final date = DateTime(2024, 1, 15);
      expect(tsToDateNullable(Timestamp.fromDate(date)), date);
    });
  });
}
