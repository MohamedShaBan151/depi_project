# noon KSA Clone — Flutter

A pixel-faithful Flutter conversion of the Noon Saudi Arabia e-commerce UI (React → Flutter),
built with Clean Architecture, BLoC/Cubit, and flutter_animate.

---

## Project Structure

```
lib/
├── core/
│   ├── constants/
│   │   ├── app_colors.dart       # Brand palette (noon yellow #FEF200, green #006C35)
│   │   ├── app_dimens.dart       # Spacing, radii, card sizes
│   │   └── app_strings.dart      # Bilingual EN/AR strings
│   ├── theme/
│   │   └── app_theme.dart        # MaterialApp ThemeData (Space Grotesk)
│   └── utils/
│       └── price_formatter.dart  # SAR / ر.س formatting with intl
│
├── data/
│   ├── models/
│   │   ├── product_model.dart    # ProductModel + ProductBadge enum
│   │   ├── cart_item_model.dart  # CartItemModel (product + qty)
│   │   ├── category_model.dart   # CategoryModel
│   │   └── banner_model.dart     # BannerModel (gradient, emoji, bilingual)
│   ├── data_sources/
│   │   └── local_data_source.dart  # Static mock data (swap → Firestore)
│   └── repositories/
│       ├── product_repository.dart  # getProducts / getCategories / getBanners / search
│       └── cart_repository.dart     # add / remove / update / clear
│
├── logic/
│   ├── cart/
│   │   ├── cart_cubit.dart       # addProduct, removeProduct, updateQuantity
│   │   └── cart_state.dart       # items, total, itemCount, freeShippingProgress
│   ├── product/
│   │   ├── product_cubit.dart    # loadAll, searchProducts, setBannerIndex, nextBanner
│   │   └── product_state.dart    # ProductStatus enum, products, banners, categories
│   └── locale_cubit.dart         # toggleLocale() → Locale('en') ↔ Locale('ar')
│
├── presentation/
│   ├── screens/
│   │   └── home_screen.dart      # Main screen composing all sections
│   └── widgets/
│       ├── noon_navbar.dart           # Floating navbar, scroll-aware pill morph
│       ├── hero_banner_carousel.dart  # Auto-sliding banners with dot indicators
│       ├── category_item.dart         # Animated circle category pill
│       ├── product_card.dart          # Hover lift, parallax emoji, Add to Cart
│       ├── cart_sidebar.dart          # Slide-in drawer, free shipping progress bar
│       ├── product_detail_modal.dart  # Full modal with qty selector
│       ├── countdown_timer.dart       # Live HH:MM:SS countdown
│       ├── star_rating.dart           # 5-star rating row
│       └── promo_strip.dart           # 3-column express / returns / secure row
│
└── main.dart   # MultiRepositoryProvider + MultiBlocProvider entry point
```

---

## Features Converted

| React Feature | Flutter Equivalent |
|---|---|
| `useMagnetic` hook | `MouseRegion` + `AnimatedScale` |
| `IntersectionObserver` stagger | `flutter_animate` `FadeEffect` + `SlideEffect` with `delay` |
| CSS `transform: translateY(-10px) scale(1.02)` on hover | `AnimatedContainer` with `Matrix4` transform |
| `setInterval` countdown | `dart:async` `Timer.periodic` |
| `useState` for cart | `CartCubit` + `BlocBuilder` |
| RTL toggle (`dir="rtl"`) | `Directionality` widget + `LocaleCubit` |
| Cart drawer with `translateX` | `AnimatedPositioned` + `Stack` |
| Banner auto-slide | `Timer` in `HeroBannerCarousel` → `ProductCubit.nextBanner()` |
| Free shipping progress bar | `LinearProgressIndicator` driven by `CartState` |
| Product modal (`slideUp` animation) | `showDialog` + `flutter_animate` |
| Price formatting (`SAR / ر.س`) | `PriceFormatter` util using `intl` |

---

## Setup

```bash
flutter pub get
flutter run
```

### Dependencies
- `flutter_bloc` — state management (Cubit)
- `equatable` — value equality for states/models
- `google_fonts` — Space Grotesk typeface
- `flutter_animate` — staggered entrance animations
- `intl` — number/price formatting
- `shimmer` — skeleton loading (ready to wire up)
- `go_router` — routing (ready to extend)

---

## Swapping Mock Data → Firebase / Firestore

In `ProductRepository`, replace the `LocalDataSource` calls with Firestore queries:

```dart
Future<List<ProductModel>> getProducts() async {
  final snap = await FirebaseFirestore.instance.collection('products').get();
  return snap.docs.map((d) => ProductModel.fromJson(d.data())).toList();
}
```

Add `fromJson` / `toJson` to each model and you're production-ready.
