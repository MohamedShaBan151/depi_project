# noon KSA Clone — Flutter

A pixel-faithful Flutter conversion of the Noon Saudi Arabia e-commerce UI,
rebuilt from React → Flutter using **Clean Architecture**, **BLoC/Cubit**, and **flutter_animate**.

![Flutter](https://img.shields.io/badge/Flutter-3.22-blue?logo=flutter)
![Dart](https://img.shields.io/badge/Dart-3.4-blue?logo=dart)
![License](https://img.shields.io/badge/License-MIT-green)

---

## Table of Contents

- [Screenshots](#screenshots)
- [Features](#features)
- [Project Structure](#project-structure)
- [Setup](#setup)
- [Dependencies](#dependencies)
- [Swapping Mock Data → Firebase](#swapping-mock-data--firebase)
- [Contributing](#contributing)
- [License](#license)

---

## Screenshots

| Home Screen | Product Card Hover | Cart Sidebar | Product Detail Modal |
|---|---|---|---|
| ![Home](docs/screenshots/home.png) | ![Card](docs/screenshots/product_card.png) | ![Cart](docs/screenshots/cart_sidebar.png) | ![Modal](docs/screenshots/product_modal.png) |
| *Hero banner carousel, category pills, product grid* | *Parallax emoji lift, Add to Cart CTA* | *Slide-in drawer, free-shipping progress bar* | *Full detail view with qty selector* |

> **Note:** Add screenshots to `docs/screenshots/` and update the paths above.
> Run `flutter screenshots` or capture manually from the emulator.

---

## Features

| React Original | Flutter Equivalent |
|---|---|
| `useMagnetic` hook | `MouseRegion` + `AnimatedScale` |
| `IntersectionObserver` stagger | `flutter_animate` `FadeEffect` + `SlideEffect` with `delay` |
| `CSS transform: translateY / scale` on hover | `AnimatedContainer` with `Matrix4` transform |
| `setInterval` countdown | `dart:async` `Timer.periodic` |
| `useState` for cart | `CartCubit` + `BlocBuilder` |
| RTL toggle (`dir="rtl"`) | `Directionality` widget + `LocaleCubit` |
| Cart drawer `translateX` animation | `AnimatedPositioned` + `Stack` |
| Banner auto-slide | `Timer` in `HeroBannerCarousel` → `ProductCubit.nextBanner()` |
| Free shipping progress bar | `LinearProgressIndicator` driven by `CartState` |
| Product modal `slideUp` animation | `showDialog` + `flutter_animate` |
| Price formatting (`SAR / ر.س`) | `PriceFormatter` util using `intl` |

---

## Project Structure

```
noon_flutter/
├── lib/
│   ├── core/                          # App-wide constants, theme, utilities
│   │   ├── constants/
│   │   │   ├── app_colors.dart        # Brand palette — noon yellow #FEF200, green #006C35
│   │   │   ├── app_dimens.dart        # Spacing scale, border radii, card sizes
│   │   │   └── app_strings.dart       # Bilingual EN / AR string keys
│   │   ├── theme/
│   │   │   └── app_theme.dart         # MaterialApp ThemeData (Space Grotesk font)
│   │   └── utils/
│   │       └── price_formatter.dart   # SAR / ر.س formatting via intl
│   │
│   ├── data/                          # Data layer — models, sources, repositories
│   │   ├── models/
│   │   │   ├── product_model.dart     # ProductModel + ProductBadge enum
│   │   │   ├── cart_item_model.dart   # CartItemModel (product reference + quantity)
│   │   │   ├── category_model.dart    # CategoryModel
│   │   │   └── banner_model.dart      # BannerModel (gradient, emoji, bilingual labels)
│   │   ├── data_sources/
│   │   │   └── local_data_source.dart # Static mock data — swap for Firestore (see below)
│   │   └── repositories/
│   │       ├── product_repository.dart # getProducts / getCategories / getBanners / search
│   │       └── cart_repository.dart    # add / remove / updateQuantity / clear
│   │
│   ├── logic/                         # BLoC/Cubit state management
│   │   ├── cart/
│   │   │   ├── cart_cubit.dart        # addProduct, removeProduct, updateQuantity
│   │   │   └── cart_state.dart        # items, total, itemCount, freeShippingProgress
│   │   ├── product/
│   │   │   ├── product_cubit.dart     # loadAll, searchProducts, setBannerIndex, nextBanner
│   │   │   └── product_state.dart     # ProductStatus enum, products, banners, categories
│   │   └── locale_cubit.dart          # toggleLocale() → Locale('en') ↔ Locale('ar')
│   │
│   ├── presentation/                  # UI layer — screens and reusable widgets
│   │   ├── screens/
│   │   │   └── home_screen.dart       # Root screen composing all sections
│   │   └── widgets/
│   │       ├── noon_navbar.dart            # Floating navbar with scroll-aware pill morph
│   │       ├── hero_banner_carousel.dart   # Auto-sliding banners with dot indicators
│   │       ├── category_item.dart          # Animated circle category pill
│   │       ├── product_card.dart           # Hover lift, parallax emoji, Add to Cart
│   │       ├── cart_sidebar.dart           # Slide-in drawer, free shipping progress bar
│   │       ├── product_detail_modal.dart   # Full modal with qty selector
│   │       ├── countdown_timer.dart        # Live HH:MM:SS countdown
│   │       ├── star_rating.dart            # 5-star rating row
│   │       └── promo_strip.dart            # 3-column express / returns / secure strip
│   │
│   └── main.dart                      # MultiRepositoryProvider + MultiBlocProvider entry
│
├── test/                              # Unit and widget tests
│   ├── logic/                         # Cubit unit tests
│   └── widgets/                       # Widget tests
│
├── docs/
│   └── screenshots/                   # README screenshot assets
│
├── pubspec.yaml                        # Flutter dependencies and assets
└── README.md
```

---

## Setup

### Prerequisites

| Requirement | Minimum Version | Check |
|---|---|---|
| Flutter SDK | 3.22.0 | `flutter --version` |
| Dart SDK | 3.4.0 (bundled with Flutter) | `dart --version` |
| Android Studio / Xcode | Latest stable | For emulator/simulator |
| VS Code or IntelliJ | Any | Recommended IDEs |

Install Flutter by following the [official guide](https://docs.flutter.dev/get-started/install) for your OS.

---

### 1. Clone the repository

```bash
git clone https://github.com/your-org/noon-flutter.git
cd noon-flutter
```

### 2. Install dependencies

```bash
flutter pub get
```

### 3. Verify your environment

```bash
flutter doctor
```

Resolve any issues flagged before continuing.

### 4. Run the app

```bash
# Android emulator or connected device
flutter run

# Specific device
flutter run -d <device-id>

# List available devices
flutter devices

# Web (Chrome)
flutter run -d chrome

# macOS desktop
flutter run -d macos
```

### 5. Run tests

```bash
# All tests
flutter test

# With coverage report
flutter test --coverage
genhtml coverage/lcov.info -o coverage/html
open coverage/html/index.html
```

### 6. Build a release

```bash
# Android APK
flutter build apk --release

# Android App Bundle
flutter build appbundle --release

# iOS (requires macOS + Xcode)
flutter build ios --release

# Web
flutter build web --release
```

---

## Dependencies

All dependencies are declared in `pubspec.yaml`. Run `flutter pub get` to install them.

### Runtime Dependencies

| Package | Version | Purpose |
|---|---|---|
| `flutter_bloc` | ^8.1.5 | BLoC/Cubit state management |
| `equatable` | ^2.0.5 | Value equality for states and models |
| `google_fonts` | ^6.2.1 | Space Grotesk typeface |
| `flutter_animate` | ^4.5.0 | Staggered entrance animations (fade, slide, scale) |
| `intl` | ^0.19.0 | SAR price and number formatting |
| `shimmer` | ^3.0.0 | Skeleton loading screens (wired up per-widget) |
| `go_router` | ^13.2.0 | Declarative routing (ready to extend) |

### Dev Dependencies

| Package | Version | Purpose |
|---|---|---|
| `bloc_test` | ^9.1.7 | Cubit/BLoC unit testing utilities |
| `mocktail` | ^1.0.3 | Mock objects for unit tests |
| `flutter_test` | SDK | Widget and integration testing |

### Updating dependencies

```bash
# Check for outdated packages
flutter pub outdated

# Upgrade all to latest compatible versions
flutter pub upgrade

# Upgrade a specific package
flutter pub upgrade flutter_animate
```

---

## Swapping Mock Data → Firebase

The app ships with static mock data in `local_data_source.dart`. To connect to Firestore:

**1. Add Firebase dependencies to `pubspec.yaml`:**

```yaml
dependencies:
  firebase_core: ^2.31.1
  cloud_firestore: ^4.17.2
```

**2. Initialise Firebase in `main.dart`:**

```dart
await Firebase.initializeApp(
  options: DefaultFirebaseOptions.currentPlatform,
);
```

**3. Replace the data source in `ProductRepository`:**

```dart
Future<List<ProductModel>> getProducts() async {
  final snap = await FirebaseFirestore.instance.collection('products').get();
  return snap.docs.map((d) => ProductModel.fromJson(d.data())).toList();
}
```

**4. Add `fromJson` / `toJson` to each model** — the constructor signatures are already aligned to accept a `Map<String, dynamic>`.

---

## Contributing

Contributions are welcome! Please follow the steps below.

### 1. Fork and branch

```bash
# Fork the repo on GitHub, then:
git clone https://github.com/your-username/noon-flutter.git
cd noon-flutter
git checkout -b feature/your-feature-name
```

Use the branch naming convention:
- `feature/` — new features
- `fix/` — bug fixes
- `docs/` — documentation changes
- `refactor/` — code refactoring with no behaviour change

### 2. Code style

This project follows the official [Dart style guide](https://dart.dev/guides/language/effective-dart/style) and uses `flutter_lints`.

```bash
# Check for lint issues
flutter analyze

# Auto-format all Dart files
dart format lib/ test/
```

- Keep widgets small and single-responsibility.
- Name Cubits and States descriptively: `CartCubit`, `CartLoaded`, `CartError`.
- All public APIs must have doc comments (`///`).
- No hard-coded strings — add keys to `app_strings.dart`.

### 3. Write tests

Every new feature or bug fix must include tests:

```bash
# Run all tests before opening a PR
flutter test
```

- **Unit tests** for Cubits go in `test/logic/`.
- **Widget tests** go in `test/widgets/`.
- Aim to keep test coverage ≥ 80% on modified files.

### 4. Open a Pull Request

1. Push your branch: `git push origin feature/your-feature-name`
2. Open a PR against `main` on GitHub.
3. Fill in the PR template: describe what changed and why, link any relevant issues.
4. A maintainer will review within 48 hours.
5. Squash-merge is used — keep your commit history clean.

### 5. Reporting issues

Use GitHub Issues. Include:
- Flutter/Dart version (`flutter --version`)
- Target platform (Android / iOS / Web / Desktop)
- Steps to reproduce
- Expected vs. actual behaviour

---

## License

This project is licensed under the **MIT License**.

```
MIT License

Copyright (c) 2026 noon Flutter Contributors

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.
```
