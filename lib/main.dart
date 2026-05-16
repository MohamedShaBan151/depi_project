import 'package:flutter/material.dart';
import 'bootstrap.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await bootstrap();        // Firebase + offline cache + GetIt
  runApp(const ECommerceApp());
}

// ─── Color Palette ────────────────────────────────────────────────────────────
class AppColors {
  static const Color primaryBlue   = Color(0xFF1B4FD8);
  static const Color lightBlue     = Color(0xFFE8EFFE);
  static const Color primaryYellow = Color(0xFFFFCC00);
  static const Color lightYellow   = Color(0xFFFFF8D6);
  static const Color darkYellow    = Color(0xFFE6B800);
  static const Color darkText      = Color(0xFF1A1A2E);
  static const Color subText       = Color(0xFF6B7280);
  static const Color hintText      = Color(0xFFB0B8C9);
  static const Color background    = Color(0xFFF5F7FF);
  static const Color cardBg        = Color(0xFFFFFFFF);
  static const Color divider       = Color(0xFFEBF0FF);
  static const Color redHeart      = Color(0xFFE53935);
}

// ─── Data Models ─────────────────────────────────────────────────────────────

class Product {
  final String id;
  final String name;
  final double price;
  final double rating;
  final Color placeholderColor;
  final IconData placeholderIcon;

  const Product({
    required this.id,
    required this.name,
    required this.price,
    required this.rating,
    required this.placeholderColor,
    required this.placeholderIcon,
  });
}

class CartItem {
  final Product product;
  int quantity;
  CartItem({required this.product, this.quantity = 1});
}

// ─── Static Data ─────────────────────────────────────────────────────────────

const List<Product> allProducts = [
  Product(
    id: 'p1',
    name: 'Wireless Headphones Pro',
    price: 129.99,
    rating: 4.8,
    placeholderColor: Color(0xFF1B4FD8),
    placeholderIcon: Icons.headphones_rounded,
  ),
  Product(
    id: 'p2',
    name: 'Running Sneakers',
    price: 89.95,
    rating: 4.6,
    placeholderColor: Color(0xFFE6B800),
    placeholderIcon: Icons.directions_run_rounded,
  ),
  Product(
    id: 'p3',
    name: 'Smart Watch Ultra',
    price: 249.00,
    rating: 4.9,
    placeholderColor: Color(0xFF1B4FD8),
    placeholderIcon: Icons.watch_rounded,
  ),
  Product(
    id: 'p4',
    name: 'Leather Backpack',
    price: 64.50,
    rating: 4.5,
    placeholderColor: Color(0xFFE6B800),
    placeholderIcon: Icons.backpack_rounded,
  ),
  Product(
    id: 'p5',
    name: 'Sunglasses Classic',
    price: 44.99,
    rating: 4.3,
    placeholderColor: Color(0xFF1B4FD8),
    placeholderIcon: Icons.wb_sunny_rounded,
  ),
  Product(
    id: 'p6',
    name: 'Modern Desk Lamp',
    price: 35.00,
    rating: 4.7,
    placeholderColor: Color(0xFFE6B800),
    placeholderIcon: Icons.lightbulb_rounded,
  ),
];

final _categories = <_CategoryData>[
  _CategoryData("Women's\nFashion", Color(0xFFFFF8D6), Color(0xFFE6B800), Icons.checkroom_rounded),
  _CategoryData("Men's\nFashion",   Color(0xFFE8EFFE), Color(0xFF1B4FD8), Icons.person_rounded),
  _CategoryData("Laptops &\nElectronics", Color(0xFFFFF8D6), Color(0xFFE6B800), Icons.laptop_rounded),
  _CategoryData("Baby\nToys",       Color(0xFFE8EFFE), Color(0xFF1B4FD8), Icons.child_care_rounded),
  _CategoryData("Beauty",           Color(0xFFFFF8D6), Color(0xFFE6B800), Icons.face_retouching_natural_rounded),
  _CategoryData("Headphones",       Color(0xFFE8EFFE), Color(0xFF1B4FD8), Icons.headphones_rounded),
  _CategoryData("Skincare",         Color(0xFFFFF8D6), Color(0xFFE6B800), Icons.spa_rounded),
  _CategoryData("Cameras",          Color(0xFFE8EFFE), Color(0xFF1B4FD8), Icons.camera_alt_rounded),
];

class _CategoryData {
  final String name;
  final Color bgColor;
  final Color iconColor;
  final IconData icon;
  const _CategoryData(this.name, this.bgColor, this.iconColor, this.icon);
}

// ─── App State (InheritedWidget) ─────────────────────────────────────────────

class AppState extends ChangeNotifier {
  final Map<String, CartItem> _cart = {};
  final Set<String> _wishlist = {};

  List<CartItem> get cartItems => _cart.values.toList();
  Set<String> get wishlist => _wishlist;

  int get cartCount => _cart.values.fold(0, (sum, item) => sum + item.quantity);

  double get cartTotal =>
      _cart.values.fold(0.0, (sum, item) => sum + item.product.price * item.quantity);

  bool isInWishlist(String id) => _wishlist.contains(id);
  bool isInCart(String id) => _cart.containsKey(id);

  void addToCart(Product p) {
    if (_cart.containsKey(p.id)) {
      _cart[p.id]!.quantity++;
    } else {
      _cart[p.id] = CartItem(product: p);
    }
    notifyListeners();
  }

  void removeFromCart(String id) {
    _cart.remove(id);
    notifyListeners();
  }

  void incrementQty(String id) {
    if (_cart.containsKey(id)) {
      _cart[id]!.quantity++;
      notifyListeners();
    }
  }

  void decrementQty(String id) {
    if (_cart.containsKey(id)) {
      if (_cart[id]!.quantity > 1) {
        _cart[id]!.quantity--;
      } else {
        _cart.remove(id);
      }
      notifyListeners();
    }
  }

  void toggleWishlist(String id) {
    if (_wishlist.contains(id)) {
      _wishlist.remove(id);
    } else {
      _wishlist.add(id);
    }
    notifyListeners();
  }
}

// ─── App Root ─────────────────────────────────────────────────────────────────

class ECommerceApp extends StatelessWidget {
  const ECommerceApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: _appState,
      builder: (context, _) {
        return MaterialApp(
          title: 'E-commerce',
          debugShowCheckedModeBanner: false,
          theme: ThemeData(
            colorScheme: ColorScheme.fromSeed(
              seedColor: AppColors.primaryBlue,
              brightness: Brightness.light,
            ),
            useMaterial3: true,
          ),
          home: const MainShell(),
        );
      },
    );
  }
}

final AppState _appState = AppState();

// ─── Main Shell with Bottom Nav ───────────────────────────────────────────────

class MainShell extends StatefulWidget {
  const MainShell({super.key});

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  int _currentIndex = 0;

  void _onNavTap(int index) => setState(() => _currentIndex = index);

  @override
  Widget build(BuildContext context) {
    final screens = [
      const HomeScreen(),
      const HomeScreen(), // categories placeholder
      const WishlistScreen(),
      const HomeScreen(), // profile placeholder
    ];

    return Scaffold(
      body: screens[_currentIndex],
      bottomNavigationBar: ListenableBuilder(
        listenable: _appState,
        builder: (context, _) => _BottomNav(
          currentIndex: _currentIndex,
          onTap: _onNavTap,
          cartCount: _appState.cartCount,
        ),
      ),
    );
  }
}

// ─── Bottom Navigation Bar ────────────────────────────────────────────────────

class _BottomNav extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;
  final int cartCount;

  const _BottomNav({
    required this.currentIndex,
    required this.onTap,
    required this.cartCount,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.primaryBlue,
        boxShadow: [BoxShadow(color: Colors.black26, blurRadius: 8)],
      ),
      padding: EdgeInsets.only(
        top: 10,
        bottom: MediaQuery.of(context).padding.bottom + 8,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _navItem(Icons.home_rounded, 0),
          _cartNavItem(),
          _navItem(Icons.favorite_rounded, 2),
          _navItem(Icons.person_outline_rounded, 3),
        ],
      ),
    );
  }

  Widget _navItem(IconData icon, int index) {
    final active = currentIndex == index;
    return GestureDetector(
      onTap: () => onTap(index),
      behavior: HitTestBehavior.opaque,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 26,
              color: active ? AppColors.primaryYellow : Colors.white54,
            ),
            const SizedBox(height: 4),
            Container(
              width: 5,
              height: 5,
              decoration: BoxDecoration(
                color: active ? AppColors.primaryYellow : Colors.transparent,
                shape: BoxShape.circle,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _cartNavItem() {
    final active = currentIndex == 1;
    return GestureDetector(
      onTap: () => onTap(1),
      behavior: HitTestBehavior.opaque,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Stack(
              clipBehavior: Clip.none,
              children: [
                Icon(
                  Icons.shopping_cart_rounded,
                  size: 26,
                  color: active ? AppColors.primaryYellow : Colors.white54,
                ),
                if (cartCount > 0)
                  Positioned(
                    top: -6,
                    right: -8,
                    child: Container(
                      width: 16,
                      height: 16,
                      decoration: const BoxDecoration(
                        color: AppColors.primaryYellow,
                        shape: BoxShape.circle,
                      ),
                      child: Center(
                        child: Text(
                          '$cartCount',
                          style: const TextStyle(
                            fontSize: 9,
                            fontWeight: FontWeight.w800,
                            color: AppColors.darkText,
                          ),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 4),
            Container(
              width: 5,
              height: 5,
              decoration: BoxDecoration(
                color: active ? AppColors.primaryYellow : Colors.transparent,
                shape: BoxShape.circle,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Home Screen ─────────────────────────────────────────────────────────────

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            _buildTopBar(context),
            _buildSearchBar(),
            Expanded(
              child: CustomScrollView(
                physics: const BouncingScrollPhysics(),
                slivers: [
                  SliverToBoxAdapter(child: _buildBanner()),
                  SliverToBoxAdapter(child: _buildBannerDots()),
                  SliverToBoxAdapter(child: _buildSectionHeader('Categories', 'view all')),
                  SliverToBoxAdapter(child: _buildCategories()),
                  SliverToBoxAdapter(child: _buildSectionHeader('Popular Products', 'See all')),
                  _buildProductGrid(),
                  const SliverToBoxAdapter(child: SizedBox(height: 20)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTopBar(BuildContext context) {
    return Container(
      color: AppColors.cardBg,
      padding: const EdgeInsets.fromLTRB(20, 14, 20, 10),
      child: Row(
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: AppColors.primaryBlue,
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(Icons.shopping_bag_rounded, color: AppColors.primaryYellow, size: 22),
          ),
          const SizedBox(width: 10),
          const Text(
            'E-commerce',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w900,
              color: AppColors.primaryBlue,
              letterSpacing: -0.5,
              fontStyle: FontStyle.italic,
            ),
          ),
          const Spacer(),
          // Cart shortcut button in top bar
          GestureDetector(
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const CartScreen()),
            ),
            child: ListenableBuilder(
              listenable: _appState,
              builder: (context, _) => Stack(
                clipBehavior: Clip.none,
                children: [
                  Container(
                    width: 42,
                    height: 42,
                    decoration: BoxDecoration(
                      color: AppColors.lightBlue,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(Icons.shopping_cart_outlined, color: AppColors.primaryBlue, size: 22),
                  ),
                  if (_appState.cartCount > 0)
                    Positioned(
                      top: -4,
                      right: -4,
                      child: Container(
                        width: 18,
                        height: 18,
                        decoration: const BoxDecoration(
                          color: AppColors.primaryYellow,
                          shape: BoxShape.circle,
                        ),
                        child: Center(
                          child: Text(
                            '${_appState.cartCount}',
                            style: const TextStyle(
                              color: AppColors.darkText,
                              fontSize: 10,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Container(
      color: AppColors.cardBg,
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 14),
      child: Container(
        height: 48,
        decoration: BoxDecoration(
          color: AppColors.background,
          borderRadius: BorderRadius.circular(30),
          border: Border.all(color: AppColors.divider, width: 1.5),
        ),
        child: const Row(
          children: [
            SizedBox(width: 14),
            Icon(Icons.search_rounded, color: AppColors.subText, size: 20),
            SizedBox(width: 10),
            Expanded(
              child: Text(
                'What do you search for?',
                style: TextStyle(fontSize: 14, color: AppColors.hintText),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBanner() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
      child: Container(
        height: 165,
        decoration: BoxDecoration(
          color: AppColors.lightYellow,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AppColors.darkYellow.withValues(alpha: 0.25), width: 1.2),
        ),
        child: Stack(
          children: [
            Positioned(
              right: -22, top: -22,
              child: Container(width: 130, height: 130, decoration: BoxDecoration(shape: BoxShape.circle, color: AppColors.primaryYellow.withValues(alpha: 0.35))),
            ),
            Positioned(
              right: 28, bottom: -38,
              child: Container(width: 90, height: 90, decoration: BoxDecoration(shape: BoxShape.circle, color: AppColors.primaryYellow.withValues(alpha: 0.2))),
            ),
            Positioned(
              right: 20, top: 0, bottom: 0,
              child: Center(child: Icon(Icons.laptop_mac_rounded, size: 80, color: AppColors.primaryBlue.withValues(alpha: 0.15))),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: FittedBox(
                fit: BoxFit.scaleDown,
                alignment: Alignment.centerLeft,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text('UP TO', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.darkText, letterSpacing: 0.5)),
                    const Text('20% OFF', style: TextStyle(fontSize: 30, fontWeight: FontWeight.w900, color: AppColors.primaryBlue, letterSpacing: -0.5, height: 1.05)),
                    const SizedBox(height: 4),
                    const Text('For Laptops\n& Mobiles', style: TextStyle(fontSize: 13, color: AppColors.subText, height: 1.4)),
                    const SizedBox(height: 10),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 7),
                      decoration: BoxDecoration(color: AppColors.primaryBlue, borderRadius: BorderRadius.circular(22)),
                      child: const Text('Shop Now', style: TextStyle(color: AppColors.primaryYellow, fontSize: 12, fontWeight: FontWeight.w700)),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBannerDots() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _dot(false), const SizedBox(width: 5),
          _dot(true),  const SizedBox(width: 5),
          _dot(false),
        ],
      ),
    );
  }

  Widget _dot(bool active) => Container(
    width: active ? 22 : 8,
    height: 8,
    decoration: BoxDecoration(
      color: active ? AppColors.primaryBlue : AppColors.divider,
      borderRadius: BorderRadius.circular(4),
    ),
  );

  Widget _buildSectionHeader(String title, String action) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 4, 20, 14),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: AppColors.darkText, letterSpacing: -0.3)),
          Text(action, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.primaryBlue)),
        ],
      ),
    );
  }

  Widget _buildCategories() {
    return SizedBox(
      height: 106,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 20),
        itemCount: _categories.length,
        itemBuilder: (context, index) {
          final cat = _categories[index];
          return Padding(
            padding: const EdgeInsets.only(right: 16),
            child: Column(
              children: [
                Container(
                  width: 64,
                  height: 64,
                  decoration: BoxDecoration(
                    color: cat.bgColor,
                    shape: BoxShape.circle,
                    border: Border.all(color: cat.iconColor.withValues(alpha: 0.3), width: 1.5),
                  ),
                  child: Icon(cat.icon, color: cat.iconColor, size: 28),
                ),
                const SizedBox(height: 6),
                Text(cat.name, textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 10.5, fontWeight: FontWeight.w600, color: AppColors.darkText, height: 1.25)),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildProductGrid() {
    return SliverPadding(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 0),
      sliver: SliverGrid(
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 14,
          mainAxisSpacing: 14,
          childAspectRatio: 0.62,
        ),
        delegate: SliverChildBuilderDelegate(
          (context, index) => ListenableBuilder(
            listenable: _appState,
            builder: (context, _) => ProductCard(product: allProducts[index]),
          ),
          childCount: allProducts.length,
        ),
      ),
    );
  }
}

// ─── Product Card ─────────────────────────────────────────────────────────────

class ProductCard extends StatelessWidget {
  final Product product;
  const ProductCard({super.key, required this.product});

  @override
  Widget build(BuildContext context) {
    final inWishlist = _appState.isInWishlist(product.id);
    final inCart = _appState.isInCart(product.id);

    return Container(
      decoration: BoxDecoration(
        color: AppColors.cardBg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.divider, width: 1),
        boxShadow: [
          BoxShadow(color: AppColors.primaryBlue.withValues(alpha: 0.06), blurRadius: 12, offset: const Offset(0, 4)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Image area ──
          Stack(
            children: [
              Container(
                height: 120,
                decoration: BoxDecoration(
                  color: product.placeholderColor.withValues(alpha: 0.08),
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(15)),
                ),
                child: Center(
                  child: Icon(product.placeholderIcon, size: 52, color: product.placeholderColor.withValues(alpha: 0.35)),
                ),
              ),
              // Heart / wishlist button
              Positioned(
                top: 8, right: 8,
                child: GestureDetector(
                  onTap: () => _appState.toggleWishlist(product.id),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    width: 30,
                    height: 30,
                    decoration: BoxDecoration(
                      color: inWishlist ? AppColors.redHeart.withValues(alpha: 0.1) : AppColors.lightYellow,
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: inWishlist ? AppColors.redHeart.withValues(alpha: 0.4) : AppColors.primaryYellow.withValues(alpha: 0.5),
                      ),
                    ),
                    child: Icon(
                      inWishlist ? Icons.favorite_rounded : Icons.favorite_border_rounded,
                      size: 15,
                      color: inWishlist ? AppColors.redHeart : AppColors.darkYellow,
                    ),
                  ),
                ),
              ),
            ],
          ),

          // ── Product info ──
          Padding(
            padding: const EdgeInsets.fromLTRB(10, 8, 10, 0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  product.name,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.w700, color: AppColors.darkText, height: 1.3),
                ),
                const SizedBox(height: 5),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '\$${product.price.toStringAsFixed(2)}',
                      style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w900, color: AppColors.primaryBlue, letterSpacing: -0.3),
                    ),
                    Row(
                      children: [
                        const Icon(Icons.star_rounded, size: 12, color: AppColors.primaryYellow),
                        const SizedBox(width: 2),
                        Text(product.rating.toString(),
                          style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: AppColors.subText)),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                // ── Add to Cart button ──
                SizedBox(
                  width: double.infinity,
                  height: 34,
                  child: ElevatedButton.icon(
                    onPressed: () {
                      _appState.addToCart(product);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('${product.name} added to cart'),
                          duration: const Duration(seconds: 1),
                          backgroundColor: AppColors.primaryBlue,
                          behavior: SnackBarBehavior.floating,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        ),
                      );
                    },
                    icon: Icon(
                      inCart ? Icons.check_circle_rounded : Icons.add_shopping_cart_rounded,
                      size: 15,
                    ),
                    label: Text(
                      inCart ? 'In Cart' : 'Add',
                      style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: inCart ? AppColors.primaryBlue.withValues(alpha: 0.75) : AppColors.primaryBlue,
                      foregroundColor: AppColors.primaryYellow,
                      elevation: 0,
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                  ),
                ),
                const SizedBox(height: 10),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Cart Screen ──────────────────────────────────────────────────────────────

class CartScreen extends StatelessWidget {
  const CartScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.primaryBlue,
        foregroundColor: Colors.white,
        title: const Text('My Cart', style: TextStyle(fontWeight: FontWeight.w800, color: Colors.white)),
        centerTitle: true,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: ListenableBuilder(
        listenable: _appState,
        builder: (context, _) {
          final items = _appState.cartItems;
          if (items.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.shopping_cart_outlined, size: 80, color: AppColors.primaryBlue.withValues(alpha: 0.25)),
                  const SizedBox(height: 16),
                  const Text('Your cart is empty', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: AppColors.subText)),
                ],
              ),
            );
          }
          return Column(
            children: [
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: items.length,
                  itemBuilder: (context, index) => _CartItemCard(item: items[index]),
                ),
              ),
              _buildCartSummary(context),
            ],
          );
        },
      ),
    );
  }

  Widget _buildCartSummary(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
      decoration: const BoxDecoration(
        color: AppColors.cardBg,
        boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 12, offset: Offset(0, -4))],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Total', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: AppColors.darkText)),
              Text(
                '\$${_appState.cartTotal.toStringAsFixed(2)}',
                style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w900, color: AppColors.primaryBlue),
              ),
            ],
          ),
          const SizedBox(height: 14),
          SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton(
              onPressed: () {},
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryBlue,
                foregroundColor: AppColors.primaryYellow,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                elevation: 0,
              ),
              child: const Text('Checkout', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800)),
            ),
          ),
        ],
      ),
    );
  }
}

class _CartItemCard extends StatelessWidget {
  final CartItem item;
  const _CartItemCard({required this.item});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.cardBg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.divider),
        boxShadow: [
          BoxShadow(color: AppColors.primaryBlue.withValues(alpha: 0.05), blurRadius: 8, offset: const Offset(0, 3)),
        ],
      ),
      child: Row(
        children: [
          // Image placeholder
          Container(
            width: 70,
            height: 70,
            decoration: BoxDecoration(
              color: item.product.placeholderColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(item.product.placeholderIcon, size: 34, color: item.product.placeholderColor.withValues(alpha: 0.5)),
          ),
          const SizedBox(width: 12),
          // Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(item.product.name,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontSize: 13.5, fontWeight: FontWeight.w700, color: AppColors.darkText)),
                const SizedBox(height: 4),
                Text('\$${item.product.price.toStringAsFixed(2)}',
                  style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w900, color: AppColors.primaryBlue)),
              ],
            ),
          ),
          const SizedBox(width: 8),
          // Quantity controls
          Column(
            children: [
              // Delete button
              GestureDetector(
                onTap: () => _appState.removeFromCart(item.product.id),
                child: const Icon(Icons.delete_outline_rounded, color: AppColors.redHeart, size: 20),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  _qtyBtn(Icons.remove, () => _appState.decrementQty(item.product.id)),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                    child: Text('${item.quantity}',
                      style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w800, color: AppColors.darkText)),
                  ),
                  _qtyBtn(Icons.add, () => _appState.incrementQty(item.product.id)),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _qtyBtn(IconData icon, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 28,
        height: 28,
        decoration: BoxDecoration(
          color: AppColors.lightBlue,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(icon, size: 16, color: AppColors.primaryBlue),
      ),
    );
  }
}

// ─── Wishlist Screen ──────────────────────────────────────────────────────────

class WishlistScreen extends StatelessWidget {
  const WishlistScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.primaryBlue,
        title: const Text('My Wishlist', style: TextStyle(fontWeight: FontWeight.w800, color: Colors.white)),
        centerTitle: true,
        elevation: 0,
        automaticallyImplyLeading: false,
      ),
      body: ListenableBuilder(
        listenable: _appState,
        builder: (context, _) {
          final wished = allProducts.where((p) => _appState.isInWishlist(p.id)).toList();
          if (wished.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.favorite_border_rounded, size: 80, color: AppColors.redHeart.withValues(alpha: 0.25)),
                  const SizedBox(height: 16),
                  const Text('No saved items yet', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: AppColors.subText)),
                  const SizedBox(height: 6),
                  const Text('Tap the ♥ on any product to save it', style: TextStyle(fontSize: 13, color: AppColors.hintText)),
                ],
              ),
            );
          }
          return GridView.builder(
            padding: const EdgeInsets.all(16),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 14,
              mainAxisSpacing: 14,
              childAspectRatio: 0.62,
            ),
            itemCount: wished.length,
            itemBuilder: (context, index) => ProductCard(product: wished[index]),
          );
        },
      ),
    );
  }
}
