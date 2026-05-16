// lib/bootstrap.dart
// ─────────────────────────────────────────────────────────────────────────────
// Firebase + Firestore offline cache + GetIt DI — call before runApp().
// Import this in main.dart: await bootstrap();
// ─────────────────────────────────────────────────────────────────────────────

import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'firebase_options.dart';
import 'core/di/injection_container.dart' as di;

Future<void> bootstrap() async {
  // 1. Firebase
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // 2. Firestore offline persistence — unlimited cache for product-heavy app
  FirebaseFirestore.instance.settings = const Settings(
    persistenceEnabled: true,
    cacheSizeBytes: Settings.CACHE_SIZE_UNLIMITED,
  );

  // 3. GetIt DI
  await di.init();
}
