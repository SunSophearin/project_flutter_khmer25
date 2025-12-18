import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:project_flutter_khmer25/models/category_model.dart';

import 'package:project_flutter_khmer25/components/home/home_banner.dart';
import 'package:project_flutter_khmer25/components/home/home_category_navbar.dart';
import 'package:project_flutter_khmer25/components/home/home_list_product_horizontal_card.dart';
import 'package:project_flutter_khmer25/components/home/home_searchbar.dart';

import 'package:project_flutter_khmer25/providers/product_provider.dart';

class HomeScreen extends StatelessWidget {
  final VoidCallback onOpenNew;
  final VoidCallback onOpenDiscount;

  // ✅ add this
  final void Function(CategoryModel cat) onOpenCategory;

  const HomeScreen({
    super.key,
    required this.onOpenNew,
    required this.onOpenDiscount,
    required this.onOpenCategory,
  });

  @override
  Widget build(BuildContext context) {
    final productProvider = context.watch<ProductProvider>();

    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const HomeSearchbar(),
            const SizedBox(height: 16),

            const HomeBanner(),
            const SizedBox(height: 16),

            _title('ប្រភេទ'),
            const SizedBox(height: 8),

            // ✅ NOW it opens inside HomePage (navbar + bottom bar stay)
            HomeCategoryNavbar(onOpenCategory: onOpenCategory),

            const SizedBox(height: 16),

            _header(title: 'ផលិតផលថ្មីៗ', onSeeAll: onOpenNew),
            const SizedBox(height: 8),
            _productBlock(
              productProvider.isLoading,
              productProvider.newProducts,
            ),

            const SizedBox(height: 16),

            _header(title: 'ផលិតផលបញ្ចុះតម្លៃ (%)', onSeeAll: onOpenDiscount),
            const SizedBox(height: 8),
            _productBlock(
              productProvider.isLoading,
              productProvider.discountProducts,
            ),
          ],
        ),
      ),
    );
  }

  Widget _productBlock(bool loading, List products) {
    if (loading) {
      return const SizedBox(
        height: 250,
        child: Center(child: CircularProgressIndicator()),
      );
    }
    if (products.isEmpty) {
      return const SizedBox(
        height: 80,
        child: Center(child: Text('No products')),
      );
    }
    return ProductHorizontalList(products: products.cast());
  }

  Widget _title(String t) => Text(
    t,
    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
  );

  Widget _header({required String title, required VoidCallback onSeeAll}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        _title(title),
        TextButton(onPressed: onSeeAll, child: const Text('មើលទាំងអស់')),
      ],
    );
  }
}
