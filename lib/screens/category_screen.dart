import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:project_flutter_khmer25/providers/category_provider.dart';
import 'package:project_flutter_khmer25/models/category_model.dart';

/// 📱 Category Screen – Search + Total + Grid 2 cards per row
class CategoryScreen extends StatefulWidget {
  const CategoryScreen({super.key});

  @override
  State<CategoryScreen> createState() => _CategoryScreenState();
}

class _CategoryScreenState extends State<CategoryScreen> {
  String _searchQuery = '';

  @override
  Widget build(BuildContext context) {
    final categoryProvider = context.watch<CategoryProvider>();

    final isLoading = categoryProvider.isLoading;
    final error = categoryProvider.error;
    final allCategories = categoryProvider.categories;

    // 🔎 Filter categories by search
    final List<CategoryModel> filteredCategories = _searchQuery.isEmpty
        ? allCategories
        : allCategories
              .where(
                (c) =>
                    c.name.toLowerCase().contains(_searchQuery.toLowerCase()),
              )
              .toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'ប្រភេទទំនិញ',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(8),
        child: Builder(
          builder: (context) {
            if (isLoading) {
              return const Center(child: CircularProgressIndicator());
            }

            if (error != null) {
              return Center(
                child: Text(
                  'កំហុសក្នុងការផ្ទុកទិន្នន័យ\n$error',
                  textAlign: TextAlign.center,
                ),
              );
            }

            if (allCategories.isEmpty) {
              return const Center(child: Text('មិនមានប្រភេទទំនិញទេ'));
            }

            return Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // 🔎 Search box
                TextField(
                  decoration: InputDecoration(
                    hintText: 'ស្វែងរកប្រភេទ...',
                    prefixIcon: const Icon(Icons.search),
                    filled: true,
                    fillColor: Colors.grey.shade100,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 0,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: Colors.grey.shade300),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: Colors.grey.shade300),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(
                        color: Theme.of(context).primaryColor,
                      ),
                    ),
                  ),
                  onChanged: (value) {
                    setState(() {
                      _searchQuery = value;
                    });
                  },
                ),

                const SizedBox(height: 8),

                // 🔢 Total category text
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'សរុប: ${filteredCategories.length} ប្រភេទ',
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    if (_searchQuery.isNotEmpty)
                      Text(
                        'ពីសរុប ${allCategories.length}',
                        style: const TextStyle(
                          fontSize: 11,
                          color: Colors.grey,
                        ),
                      ),
                  ],
                ),

                const SizedBox(height: 8),

                // 🔽 Grid cards
                Expanded(
                  child: filteredCategories.isEmpty
                      ? const Center(
                          child: Text('រកមិនឃើញប្រភេទតាមពាក្យស្វែងរក'),
                        )
                      : GridView.builder(
                          itemCount: filteredCategories.length,
                          gridDelegate:
                              const SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 2, // 👉 2 cards per row
                                mainAxisSpacing: 8,
                                crossAxisSpacing: 8,
                                childAspectRatio: 3 / 4,
                              ),
                          itemBuilder: (context, index) {
                            final category = filteredCategories[index];
                            return _CategoryCard(category: category);
                          },
                        ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

/// 📦 Card សម្រាប់បង្ហាញ Category មួយ
class _CategoryCard extends StatefulWidget {
  final CategoryModel category;

  const _CategoryCard({required this.category});

  @override
  State<_CategoryCard> createState() => _CategoryCardState();
}

class _CategoryCardState extends State<_CategoryCard> {
  bool _isFavorite = false;

  @override
  Widget build(BuildContext context) {
    final category = widget.category;
    final totalSub = category.subcategories.length;

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () {
          // 👉 whole card tap (you can navigate same as Explore)
        },
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // 1️⃣ Image top
            Expanded(
              child: Image.network(
                category.imageUrl,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => Container(
                  color: Colors.grey.shade200,
                  child: const Icon(Icons.image_not_supported),
                ),
              ),
            ),

            // 2️⃣ Name (under image)
            Padding(
              padding: const EdgeInsets.only(left: 8, right: 8, top: 6),
              child: Text(
                category.name,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),

            const SizedBox(height: 4),

            // 3️⃣ Total subcategory (under name)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: Text(
                '$totalSub ប្រភេទរង',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 11, color: Colors.black87),
              ),
            ),

            const SizedBox(height: 4),

            // 4️⃣ Bottom row: Explore button + Favorite button (same row)
            Padding(
              padding: const EdgeInsets.only(left: 8, right: 4, bottom: 6),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // 🔍 Explore button (small)
                  TextButton.icon(
                    style: TextButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      minimumSize: Size.zero,
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                    onPressed: () {
                      // 👉 go to subcategory screen
                    },
                    icon: const Icon(Icons.travel_explore, size: 14),
                    label: const Text(
                      'Explore',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),

                  // ❤️ Favorite icon
                  IconButton(
                    icon: Icon(
                      _isFavorite ? Icons.favorite : Icons.favorite_border,
                      size: 18,
                      color: _isFavorite ? Colors.red : Colors.grey,
                    ),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                    onPressed: () {
                      setState(() {
                        _isFavorite = !_isFavorite;
                      });
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
