import 'package:flutter/material.dart';
import 'package:project_flutter_khmer25/components/home/home_banner.dart';
import 'package:project_flutter_khmer25/components/home/home_category_navbar.dart';
import 'package:project_flutter_khmer25/components/home/home_list_product_horizontal_card.dart';
import 'package:project_flutter_khmer25/components/home/home_searchbar.dart';
import 'package:project_flutter_khmer25/providers/product_provider.dart';
import 'package:provider/provider.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  Widget build(BuildContext context) {
    final productProvider = context.watch<ProductProvider>();
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(12.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ---------------- Search Bar ----------------
                // _buildSearchBar(),
                HomeSearchbar(),

                const SizedBox(height: 16),

                // ---------------- Banner Carousel ----------------
                HomeBanner(),

                const SizedBox(height: 16),

                // ---------------- Category ----------------
                _buildSectionTitle('ប្រភេទ'),
                const SizedBox(height: 8),
                HomeCategoryNavbar(),

                const SizedBox(height: 16),

                // ---------------- New Products ----------------
                _buildSectionHeader(
                  title: 'ផលិតផលថ្មីៗ',
                  onSeeAll: () {
                    // TODO: navigate to page all products
                  },
                ),
                const SizedBox(height: 8),
                if (productProvider.isLoading)
                  const Center(child: CircularProgressIndicator())
                else
                  ProductHorizontalList(products: productProvider.newProducts),

                // ---------------- Discount Products ----------------
                _buildSectionHeader(
                  title: 'ផលិតផលបញ្ចុះតម្លៃ (%)',
                  onSeeAll: () {},
                ),
                const SizedBox(height: 8),
                const SizedBox(height: 16),
                if (productProvider.isLoading)
                  const Center(child: CircularProgressIndicator())
                else
                  ProductHorizontalList(
                    products: productProvider.discountProducts,
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// ចំណងជើង Section តែអក្សរ
  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
    );
  }

  /// ចំណងជើង មាន "មើលទាំងអស់"
  Widget _buildSectionHeader({
    required String title,
    required VoidCallback onSeeAll,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        _buildSectionTitle(title),
        TextButton(onPressed: onSeeAll, child: const Text('មើលទាំងអស់')),
      ],
    );
  }
}
