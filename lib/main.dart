import 'package:flutter/material.dart';
import 'package:project_flutter_khmer25/screens/cart_screen.dart';
import 'package:provider/provider.dart';

import 'package:project_flutter_khmer25/models/category_model.dart';

import 'package:project_flutter_khmer25/providers/auth_provider.dart';
import 'package:project_flutter_khmer25/providers/banner_provider.dart';
import 'package:project_flutter_khmer25/providers/category_provider.dart';
import 'package:project_flutter_khmer25/providers/product_provider.dart';
import 'package:project_flutter_khmer25/providers/category_product_provider.dart';
import 'package:project_flutter_khmer25/providers/cart_provider.dart'; // ✅ ADD

import 'package:project_flutter_khmer25/screens/home_screen.dart';
import 'package:project_flutter_khmer25/screens/category_screen.dart';
import 'package:project_flutter_khmer25/screens/order_history_screen.dart';
import 'package:project_flutter_khmer25/screens/profile_screen.dart';
import 'package:project_flutter_khmer25/screens/product_list_screen.dart';
import 'package:project_flutter_khmer25/screens/category_product_screen.dart';

import 'package:project_flutter_khmer25/screens/favorite_screen.dart';
import 'package:project_flutter_khmer25/screens/order_screen.dart';

void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => BannerProvider()..loadBanners()),

        // ✅ Category load (no token needed)
        ChangeNotifierProvider(
          create: (_) => CategoryProvider()..loadCategories(),
        ),

        ChangeNotifierProvider(
          create: (_) => ProductProvider()..fetchProducts(),
        ),

        // ✅ Auth (Djoser JWT)
        ChangeNotifierProvider(
          create: (_) => AuthProvider()..loadFromStorageAndMe(),
        ),

        ChangeNotifierProvider(create: (_) => CategoryProductProvider()),

        // ✅ CART: depends on AuthProvider (need access token)
        // We create CartProvider once, then we call fetchCart when logged in.
        ChangeNotifierProxyProvider<AuthProvider, CartProvider>(
          create: (_) => CartProvider(),
          update: (_, auth, cart) {
            // keep same instance
            cart ??= CartProvider();

            // ✅ auto load cart after login
            if (auth.isLoggedIn) {
              // don't await inside update; just fire and forget
              Future.microtask(() => cart!.fetchCart(accessToken: auth.access));
            } else {
              cart!.clear();
            }
            return cart!;
          },
        ),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Khmer25',
      theme: ThemeData(
        primaryColor: const Color(0xff2ecc71),
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xff2ecc71)),
        fontFamily: 'Khmer',
      ),
      home: const HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedIndex = 0;
  CategoryModel? _openCategory;

  // tabs
  static const int tabHome = 0;
  static const int tabCategory = 1;
  static const int tabHistory = 2;
  static const int tabProfile = 3;
  static const int tabNewProducts = 4;
  static const int tabDiscountProducts = 5;
  static const int tabCategoryProducts = 6;

  void _setTab(int index) {
    setState(() => _selectedIndex = index);
    Navigator.of(context).maybePop();
  }

  void _openCategoryProducts(CategoryModel cat) {
    setState(() {
      _openCategory = cat;
      _selectedIndex = tabCategoryProducts;
    });
  }

  AppBar _buildAppBar({required bool showBack}) {
    final cartQty = context.watch<CartProvider>().totalQty; // ✅ badge qty

    return AppBar(
      elevation: 0,
      centerTitle: false,
      titleSpacing: 0,
      leading: showBack
          ? IconButton(
              icon: const Icon(Icons.arrow_back),
              onPressed: () => _setTab(tabHome),
            )
          : null,
      title: Row(
        children: [
          const SizedBox(width: 8),
          SizedBox(
            height: 32,
            child: Image.network(
              'https://khmer25.com/_nuxt/logo-mart.BD1f-q70.png',
              fit: BoxFit.contain,
            ),
          ),
        ],
      ),
      actions: [
        IconButton(
          onPressed: () => Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const FavoriteScreen()),
          ),
          icon: const Icon(Icons.favorite_border),
        ),

        // ✅ Cart Icon + Badge
        IconButton(
          onPressed: () => Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const CartScreen()),
          ),
          icon: _CartBadgeIcon(qty: cartQty),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final screens = <Widget>[
      HomeScreen(
        onOpenCategory: (cat) => _openCategoryProducts(cat),
        onOpenNew: () => _setTab(tabNewProducts),
        onOpenDiscount: () => _setTab(tabDiscountProducts),
      ),
      CategoryScreen(onOpenCategory: (cat) => _openCategoryProducts(cat)),
      const OrderHistoryScreen(),
      const ProfileTab(),
      ProductListScreen(
        type: ProductFilterType.newProducts,
        onBack: () => _setTab(tabHome),
      ),
      ProductListScreen(
        type: ProductFilterType.discountProducts,
        onBack: () => _setTab(tabHome),
      ),
      (_openCategory == null)
          ? const Center(child: Text("No category selected"))
          : CategoryProductScreen(initialParent: _openCategory!),
    ];

    final bool isCategoryProducts = _selectedIndex == tabCategoryProducts;

    return Scaffold(
      appBar: _buildAppBar(showBack: isCategoryProducts),
      body: screens[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: (_selectedIndex > 3) ? 0 : _selectedIndex,
        onTap: (index) => _setTab(index),
        type: BottomNavigationBarType.fixed,
        selectedItemColor: const Color(0xff2ecc71),
        unselectedItemColor: Colors.grey.shade600,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined),
            activeIcon: Icon(Icons.home),
            label: 'ទំព័រដើម',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.category_outlined),
            activeIcon: Icon(Icons.category),
            label: 'ប្រភេទ',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.history_outlined),
            activeIcon: Icon(Icons.history),
            label: 'ប្រវត្តិការកម្មង់',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline),
            activeIcon: Icon(Icons.person),
            label: 'គណនី',
          ),
        ],
      ),
    );
  }
}

// ✅ Badge widget
class _CartBadgeIcon extends StatelessWidget {
  final int qty;
  const _CartBadgeIcon({required this.qty});

  @override
  Widget build(BuildContext context) {
    if (qty <= 0) return const Icon(Icons.shopping_cart_outlined);

    return Stack(
      clipBehavior: Clip.none,
      children: [
        const Icon(Icons.shopping_cart_outlined),
        Positioned(
          right: -2,
          top: -2,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
            decoration: BoxDecoration(
              color: Colors.redAccent,
              borderRadius: BorderRadius.circular(999),
            ),
            child: Text(
              "$qty",
              style: const TextStyle(
                color: Colors.white,
                fontSize: 11,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
