import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:noon_clone/core/constants/app_colors.dart';
import 'package:noon_clone/core/constants/app_dimens.dart';
import 'package:noon_clone/features/products/presentation/cubit/product_cubit.dart';
import 'package:noon_clone/features/products/data/product_service.dart';

void main() {
  group('Stub classes (Bug #1 / #5)', () {
    test('AppColors.darkGreen is a Color', () {
      expect(AppColors.darkGreen, isA<Color>());
    });

    test('AppColors.noonYellow / primary is a Color', () {
      expect(AppColors.primary, isA<Color>());
    });

    test('AppDimens.paddingMedium is a double', () {
      expect(AppDimens.paddingMedium, isA<double>());
    });

    test('AppDimens.radiusMedium is a double', () {
      expect(AppDimens.radiusMedium, isA<double>());
    });

    test('ProductCubit can be instantiated', () {
      expect(() => ProductCubit(ProductService()), returnsNormally);
    });
  });
}
