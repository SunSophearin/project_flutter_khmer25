import 'package:flutter/material.dart';
import 'package:project_flutter_khmer25/screens/favorite_screen.dart';
import 'package:project_flutter_khmer25/screens/order_screen.dart';
import 'package:provider/provider.dart';

import 'package:project_flutter_khmer25/providers/banner_provider.dart';
import 'package:project_flutter_khmer25/providers/category_provider.dart';
import 'package:project_flutter_khmer25/providers/product_provider.dart';

import 'package:project_flutter_khmer25/screens/home_screen.dart';
import 'package:project_flutter_khmer25/screens/category_screen.dart';
import 'package:project_flutter_khmer25/screens/order_history_screen.dart';
import 'package:project_flutter_khmer25/screens/profile_screen.dart';

void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => BannerProvider()..loadBanners()),
        ChangeNotifierProvider(
          create: (_) => CategoryProvider()..loadCategories(),
        ),
        ChangeNotifierProvider(
          create: (_) => ProductProvider()..loadProducts(),
        ),
      ],
      child: const MyApp(),
    ),
  );
}

/// App ចម្បង
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Khmer25 Clone',
      theme: ThemeData(
        primaryColor: const Color(0xff2ecc71), // បៃតងស្ទាយ Khmer25
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xff2ecc71)),
        fontFamily: 'Khmer', // បើអ្នកមាន font Khmer
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

  List<Widget> get _screens => const [
    HomeScreen(),
    CategoryScreen(),
    OrderHistoryScreen(),
    ProfileScreen(),
  ];

  /// 📌 Function សម្រាប់ប្ដូរ Tab (បាត + Drawer)
  void _setTab(int index, BuildContext context) {
    if (_selectedIndex == index) {
      // already on this tab
      Navigator.pop(context); // just close drawer
      return;
    }

    setState(() {
      _selectedIndex = index;
    });

    // Close drawer if opened
    if (Navigator.canPop(context)) {
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // 🔹 Slide menu drawer
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            DrawerHeader(
              decoration: BoxDecoration(color: Theme.of(context).primaryColor),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Logo in drawer header
                  SizedBox(
                    height: 48,
                    child: Image.network(
                      'https://khmer25.com/_nuxt/logo-mart.BD1f-q70.png',
                      fit: BoxFit.contain,
                    ),
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'Khmer25 Mart',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'សូមស្វាគមន៍មកកាន់ការទិញទំនិញ ក្នុងសម័យទំនើប',
                    style: TextStyle(color: Colors.white70, fontSize: 12),
                  ),
                ],
              ),
            ),

            // 👉 Drawer items (linked with _selectedIndex)
            ListTile(
              leading: const Icon(Icons.home_outlined),
              title: const Text('ទំព័រដើម'),
              selected: _selectedIndex == 0,
              selectedColor: Theme.of(context).primaryColor,
              onTap: () => _setTab(0, context),
            ),
            ListTile(
              leading: const Icon(Icons.category_outlined),
              title: const Text('ប្រភេទ'),
              selected: _selectedIndex == 1,
              selectedColor: Theme.of(context).primaryColor,
              onTap: () => _setTab(1, context),
            ),
            ListTile(
              leading: const Icon(Icons.history_outlined),
              title: const Text('ប្រវត្តិការកម្មង់'),
              selected: _selectedIndex == 2,
              selectedColor: Theme.of(context).primaryColor,
              onTap: () => _setTab(2, context),
            ),
            ListTile(
              leading: const Icon(Icons.person_outline),
              title: const Text('គណនី'),
              selected: _selectedIndex == 3,
              selectedColor: Theme.of(context).primaryColor,
              onTap: () => _setTab(3, context),
            ),
          ],
        ),
      ),

      appBar: AppBar(
        elevation: 0,

        // 👉 Let Scaffold automatically show menu icon (because drawer is set)
        // no custom leading needed
        centerTitle: false,
        titleSpacing: 0,
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
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const FavoriteScreen()),
              );
            },
            icon: const Icon(Icons.favorite_border),
          ),
          IconButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const OrderScreen()),
              );
            },
            icon: const Icon(Icons.shopping_cart_outlined),
          ),
        ],
      ),

      // Screen body
      body: _screens[_selectedIndex],

      // BottomNavigationBar
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: (index) => _setTab(index, context),
        type: BottomNavigationBarType.fixed,
        backgroundColor: Colors.white,
        selectedItemColor: const Color(0xff2ecc71),
        unselectedItemColor: Colors.grey.shade600,
        selectedLabelStyle: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.bold,
        ),
        unselectedLabelStyle: const TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w400,
        ),
        iconSize: 26,
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
