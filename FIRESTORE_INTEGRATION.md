# Noon Clone — Firestore Integration Layer

## What was added in this integration pass

This delivery wires the existing Flutter codebase to live Firestore data, replacing
every mock/static data source with real repository classes backed by the five
Firestore collections described in the Integration Plan.

---

## New file map

```
lib/
├── bootstrap.dart                          ← Firebase init + offline cache + DI
├── data/
│   ├── models/
│   │   ├── firestore_helpers.dart          ← tsToDate / tsToDateNullable helpers
│   │   ├── category_model.dart             ← /categories/{id}
│   │   ├── product_firestore_full.dart     ← /product/{id} + inventory/reviews/variants
│   │   ├── cart_item_model.dart            ← /users/{uid}/cart/{itemId}
│   │   ├── order_firestore_model.dart      ← /orders/{id}
│   │   └── user_firestore_model.dart       ← /users/{uid} + addresses subcollection
│   └── repositories/
│       ├── category_repository.dart        ← fetchAll, fetchChildren
│       ├── product_repository.dart         ← paginated fetch, search, subcollections
│       ├── cart_repository.dart            ← real-time stream, CRUD, guest merge
│       ├── order_repository.dart           ← atomic create (transaction), stream
│       └── user_repository.dart            ← profile stream, address CRUD
├── core/di/injection_container.dart        ← GetIt: all repos + cubits registered
└── features/products/presentation/cubit/
    ├── cart_cubit.dart                     ← NEW: guest + authenticated cart state
    ├── product_cubit.dart                  ← UPDATED: real ProductRepository
    └── order_cubit.dart                    ← UPDATED: real OrderRepository
firestore.rules                             ← Production security rules
test/data/repositories/
    ├── cart_cubit_test.dart
    └── firestore_helpers_test.dart
```

---

## Setup

### 1. Prerequisites

| Tool | Version |
|------|---------|
| Flutter SDK | ≥ 3.0.0 |
| Dart | ≥ 3.0.0 |
| Firebase CLI | ≥ 13.x |
| FlutterFire CLI | ≥ 1.x |

### 2. Configure Firebase

```bash
# Install FlutterFire CLI if not already present
dart pub global activate flutterfire_cli

# Inside the project root
flutterfire configure
```

This regenerates `lib/firebase_options.dart` for your Firebase project.

### 3. Install dependencies

```bash
flutter pub get
```

### 4. Hook `bootstrap()` into `main()`

In `lib/main.dart`, change:

```dart
void main() {
  runApp(const ECommerceApp());
}
```

to:

```dart
import 'bootstrap.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await bootstrap();        // Firebase + offline cache + GetIt
  runApp(const ECommerceApp());
}
```

### 5. Provide cubits via BlocProvider

In your root widget (or per-screen), resolve from GetIt:

```dart
import 'core/di/injection_container.dart';

BlocProvider<CartCubit>(
  create: (_) => sl<CartCubit>(),
  child: ...,
)
```

### 6. Deploy security rules

```bash
firebase deploy --only firestore:rules
```

---

## Key architecture decisions (aligned with Integration Plan)

### Fetching strategies

| Collection | Strategy | Why |
|---|---|---|
| Cart | `snapshots()` stream | Real-time sync across devices |
| Order status | `snapshots()` stream | Live tracking updates |
| Product listing | `get()` + cursor pagination | Reduce reads; catalogue doesn't change mid-browse |
| Product detail | `get()` once | Variants/inventory loaded lazily |
| Categories | `get()` once | Rarely changes; cached after first load |
| Reviews | `get()` + pagination | Load-more on scroll |
| User profile | `snapshots()` stream | Role/avatar changes propagate instantly |

### Timestamp mapping

All `fromFirestore` factories call `tsToDate()` / `tsToDateNullable()` from
`firestore_helpers.dart`. This handles the three cases that previously caused
runtime crashes:

- `Timestamp` objects returned by Firestore SDK
- ISO-8601 `String` values from seeded data or legacy documents  
- `null` (missing field)

All writes use `FieldValue.serverTimestamp()` — never `DateTime.now().toIso8601String()`.

### Inventory atomicity

`OrderRepositoryImpl.createOrder()` runs inside `FirebaseFirestore.runTransaction()`.
Within the transaction it:
1. Reads the inventory document for each cart item.
2. Checks `quantityAvailable >= qty` (throws if insufficient and `trackInventory = true`).
3. Decrements `quantityAvailable` with `FieldValue.increment(-qty)`.
4. Writes the order document.

This prevents overselling without a server-side Cloud Function.

### Offline persistence

Set in `bootstrap.dart`:

```dart
FirebaseFirestore.instance.settings = const Settings(
  persistenceEnabled: true,
  cacheSizeBytes: Settings.CACHE_SIZE_UNLIMITED,
);
```

Offline writes are queued and replayed automatically. Inventory decrements use
transactions so the local cache cannot serve stale stock counts when offline.

### Guest cart merge

When a guest user adds items (stored in cubit local state), then signs in:

```dart
cartCubit.onUserSignedIn(uid, guestItems: currentLocalItems);
```

`CartRepositoryImpl.mergeGuestCart()` writes all guest items to Firestore in a
single batch write, then the stream takes over.

---

## Running tests

```bash
# All tests
flutter test

# Specific file
flutter test test/data/repositories/cart_cubit_test.dart

# With coverage
flutter test --coverage
genhtml coverage/lcov.info -o coverage/html
```

Tests use `bloc_test` + `mocktail` — no Firebase emulator needed for unit tests.

---

## Enhancement roadmap (post-MVP)

### Enhancement 1 — Algolia full-text search

The current `searchProducts()` uses `array-contains` on the `tags` field, which only
matches whole tags. Replace with Algolia (or Typesense):

1. Add `algolia_helper_flutter` to `pubspec.yaml`.
2. Mirror the `product` collection to Algolia via a Firebase Extension.
3. Swap `ProductRepositoryImpl.searchProducts()` to call the Algolia API.
4. Keep `tags` fallback for offline mode.

### Enhancement 2 — Pagination cursor tracking

`ProductRepositoryImpl.fetchByCategory()` accepts a `startAfter` cursor but the cubit
currently drops it. To implement infinite scroll:

1. Store `List<DocumentSnapshot> _rawDocs` alongside state in `ProductCubit`.
2. On `fetchNextPage()`, pass `_rawDocs.last` as `startAfter`.
3. Merge new results into existing `ProductLoaded.products`.
4. Use a `ScrollController` listener in the product list screen.

### Enhancement 3 — Payment webhook receiver (Cloud Functions)

`PaymentRepository` currently only creates records. Wire up:

1. A Firebase Cloud Function that receives the Moyasar webhook.
2. The function verifies the HMAC signature, then updates
   `/payments/{paymentId}/status` and `/orders/{orderId}/paymentStatus`.
3. The `OrderCubit` stream reflects the change instantly in the UI.

---

## pubspec.yaml (unchanged — all dependencies already present)

```yaml
dependencies:
  flutter_bloc: ^9.1.1
  equatable: ^2.0.5
  firebase_core: ^4.8.0
  firebase_auth: ^6.5.0
  cloud_firestore: ^6.4.0
  firebase_storage: ^13.4.0
  get_it: ^9.2.1
  go_router: ^17.2.3
  ...

dev_dependencies:
  bloc_test: ^10.0.0
  mocktail: ^1.0.3
```

No new packages are needed — everything required was already in `pubspec.yaml`.
