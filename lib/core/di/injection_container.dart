// lib/core/di/injection_container.dart
// ─────────────────────────────────────────────────────────────────────────────
// GetIt dependency injection — singletons for repositories, factories for
// cubits. Call `await init()` from main() before runApp().
// ─────────────────────────────────────────────────────────────────────────────

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get_it/get_it.dart';

import '../../data/repositories/category_repository.dart';
import '../../data/repositories/product_repository.dart';
import '../../data/repositories/cart_repository.dart';
import '../../data/repositories/order_repository.dart';
import '../../data/repositories/user_repository.dart';
import '../../features/auth/data/auth_repository_impl.dart';
import '../../features/auth/presentation/cubit/auth_cubit.dart';
import '../../features/products/presentation/cubit/product_cubit.dart';
import '../../features/products/presentation/cubit/order_cubit.dart';

final sl = GetIt.instance;

Future<void> init() async {
  // ── Firestore instance ──────────────────────────────────────────────────
  sl.registerLazySingleton<FirebaseFirestore>(
      () => FirebaseFirestore.instance);

  // ── Repositories (singletons) ───────────────────────────────────────────
  sl.registerLazySingleton<CategoryRepository>(
    () => CategoryRepositoryImpl(db: sl()),
  );
  sl.registerLazySingleton<ProductRepository>(
    () => ProductRepositoryImpl(db: sl()),
  );
  sl.registerLazySingleton<CartRepository>(
    () => CartRepositoryImpl(db: sl()),
  );
  sl.registerLazySingleton<OrderRepository>(
    () => OrderRepositoryImpl(db: sl()),
  );
  sl.registerLazySingleton<UserRepository>(
    () => UserRepositoryImpl(db: sl()),
  );
  sl.registerLazySingleton<AuthRepository>(
    () => AuthRepositoryImpl(),
  );

  // ── Cubits (factories — fresh instance per BlocProvider) ────────────────
  sl.registerFactory<AuthCubit>(() => AuthCubit(sl()));
  sl.registerFactory<ProductCubit>(() => ProductCubit(sl()));
  sl.registerFactory<OrderCubit>(() => OrderCubit(sl()));
}
