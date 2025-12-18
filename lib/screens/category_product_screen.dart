import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:project_flutter_khmer25/screens/product_detail_screen.dart';

import '../core/api_config.dart';
import '../models/category_model.dart';
import '../models/product_model.dart';
import '../providers/category_product_provider.dart';

class CategoryProductScreen extends StatefulWidget {
  final CategoryModel initialParent;
  final String? accessToken;

  const CategoryProductScreen({
    super.key,
    required this.initialParent,
    this.accessToken,
  });

  @override
  State<CategoryProductScreen> createState() => _CategoryProductScreenState();
}

class _CategoryProductScreenState extends State<CategoryProductScreen> {
  bool _inited = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_inited) {
      _inited = true;
      Future.microtask(() {
        context.read<CategoryProductProvider>().initWithInitial(
          widget.initialParent,
          accessToken: widget.accessToken,
        );
      });
    }
  }

  Future<void> _onRefresh() async {
    final p = context.read<CategoryProductProvider>();
    await p.fetchCategories(accessToken: widget.accessToken);
    await p.fetchProducts(accessToken: widget.accessToken);
  }

  @override
  Widget build(BuildContext context) {
    final p = context.watch<CategoryProductProvider>();

    return Scaffold(
      body: RefreshIndicator(
        onRefresh: _onRefresh,
        child: Column(
          children: [
            const SizedBox(height: 10),

            // ==================== PARENTS ====================
            SizedBox(
              height: 110,
              child: p.loadingCats
                  ? const Center(child: CircularProgressIndicator())
                  : p.parents.isEmpty
                  ? _stateBox(const Text('No categories'))
                  : ListView.separated(
                      scrollDirection: Axis.horizontal,
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      itemCount: p.parents.length,
                      separatorBuilder: (_, __) => const SizedBox(width: 10),
                      itemBuilder: (_, i) {
                        final cat = p.parents[i];
                        final selected = cat.id == p.selectedParentId;

                        return _CategoryTile(
                          name: cat.name,
                          imageUrl: cat.image,
                          selected: selected,
                          onTap: () => p.selectParent(
                            cat,
                            accessToken: widget.accessToken,
                          ),
                        );
                      },
                    ),
            ),

            const SizedBox(height: 6),

            // ==================== SUBS ====================
            SizedBox(
              height: 110,
              child: p.loadingCats
                  ? const SizedBox.shrink()
                  : p.subs.isEmpty
                  ? _stateBox(
                      Text(
                        'No subcategories',
                        style: TextStyle(color: Colors.grey.shade600),
                      ),
                    )
                  : ListView.separated(
                      scrollDirection: Axis.horizontal,
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      itemCount: p.subs.length,
                      separatorBuilder: (_, __) => const SizedBox(width: 10),
                      itemBuilder: (_, i) {
                        final s = p.subs[i];
                        final selected = s.id == p.selectedSubId;

                        return _CategoryTile(
                          name: s.name,
                          imageUrl: s.image,
                          selected: selected,
                          onTap: () =>
                              p.selectSub(s, accessToken: widget.accessToken),
                        );
                      },
                    ),
            ),

            // -------------------- ERROR --------------------
            if (p.error != null)
              Padding(
                padding: const EdgeInsets.all(12),
                child: Text(
                  p.error!,
                  style: const TextStyle(color: Colors.red),
                ),
              ),

            const SizedBox(height: 6),

            // ==================== PRODUCTS (3 in a row) ====================
            Expanded(
              child: p.loadingProducts
                  ? const Center(child: CircularProgressIndicator())
                  : p.products.isEmpty
                  ? const Center(child: Text('No products'))
                  : GridView.builder(
                      padding: const EdgeInsets.all(12),
                      physics: const AlwaysScrollableScrollPhysics(),
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 3, // ✅ 3 items per row
                            crossAxisSpacing: 10,
                            mainAxisSpacing: 10,
                            mainAxisExtent: 230, // ✅ taller/shorter card height
                          ),
                      itemCount: p.products.length,
                      itemBuilder: (_, i) =>
                          _ProductCard(product: p.products[i]),
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _stateBox(Widget child) {
    return SizedBox(height: 110, child: Center(child: child));
  }
}

// ==================== TILE ====================
class _CategoryTile extends StatelessWidget {
  final String name;
  final String? imageUrl;
  final bool selected;
  final VoidCallback onTap;

  const _CategoryTile({
    required this.name,
    required this.imageUrl,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final border = selected
        ? Border.all(color: Theme.of(context).colorScheme.primary, width: 2)
        : Border.all(color: Colors.transparent);

    final bg = selected ? Colors.green.shade100 : Colors.green.shade50;

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        GestureDetector(
          onTap: onTap,
          child: Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              color: bg,
              borderRadius: BorderRadius.circular(16),
              border: border,
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: _CategoryImage(imageUrl),
            ),
          ),
        ),
        const SizedBox(height: 6),
        SizedBox(
          width: 72,
          child: Text(
            name,
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 12,
              fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }
}

// ==================== IMAGE helper ====================
class _CategoryImage extends StatelessWidget {
  final String? url;
  const _CategoryImage(this.url);

  @override
  Widget build(BuildContext context) {
    final full = ApiConfig.toUrl(url);

    if (full.isEmpty) {
      return const Center(child: Icon(Icons.image_not_supported));
    }

    return Image.network(
      full,
      fit: BoxFit.cover,
      errorBuilder: (_, __, ___) =>
          const Center(child: Icon(Icons.broken_image)),
      loadingBuilder: (context, child, progress) {
        if (progress == null) return child;
        return const Center(child: CircularProgressIndicator(strokeWidth: 2));
      },
    );
  }
}

// ==================== PRODUCT CARD ====================
class _ProductCard extends StatelessWidget {
  final Product product;
  const _ProductCard({required this.product});

  @override
  Widget build(BuildContext context) {
    final p = product;

    return Card(
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => ProductDetailScreen(productId: p.id),
            ),
          );
        },
        child: Column(
          children: [
            // ✅ image height
            SizedBox(
              height: 120,
              child: Stack(
                children: [
                  Positioned.fill(child: _NetImage(p.image)),
                  if (p.discountPercent > 0)
                    Positioned(
                      top: 8,
                      left: 8,
                      child: _DiscountBadge(p.discountPercent),
                    ),
                ],
              ),
            ),

            Padding(
              padding: const EdgeInsets.all(8),
              child: Column(
                children: [
                  Text(
                    p.name,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontSize: 13),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        '${_fmt(p.finalPrice)}៛',
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.primary,
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
                        ),
                      ),
                      if (p.discountPercent > 0) ...[
                        const SizedBox(width: 6),
                        Text(
                          '${_fmt(p.price)}៛',
                          style: const TextStyle(
                            color: Colors.grey,
                            decoration: TextDecoration.lineThrough,
                            fontSize: 11,
                          ),
                        ),
                      ],
                    ],
                  ),
                  if (p.unit != null && p.unit!.isNotEmpty) ...[
                    const SizedBox(height: 2),
                    Text(
                      '/ ${p.unit}',
                      style: const TextStyle(color: Colors.grey, fontSize: 11),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DiscountBadge extends StatelessWidget {
  final int percent;
  const _DiscountBadge(this.percent);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.redAccent,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        '-$percent%',
        style: const TextStyle(
          color: Colors.white,
          fontSize: 11,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}

class _NetImage extends StatelessWidget {
  final String? url;
  const _NetImage(this.url);

  @override
  Widget build(BuildContext context) {
    final full = ApiConfig.toUrl(url);

    if (full.isEmpty) {
      return const Center(child: Icon(Icons.image_not_supported_outlined));
    }

    return Image.network(
      full,
      fit: BoxFit.cover,
      errorBuilder: (_, __, ___) =>
          const Center(child: Icon(Icons.broken_image_outlined)),
      loadingBuilder: (context, child, progress) {
        if (progress == null) return child;
        return const Center(child: CircularProgressIndicator(strokeWidth: 2));
      },
    );
  }
}

String _fmt(double v) => v < 1 ? v.toStringAsFixed(2) : v.toStringAsFixed(0);
