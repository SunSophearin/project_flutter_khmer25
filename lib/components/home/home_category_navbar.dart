import 'package:flutter/material.dart';
import 'package:project_flutter_khmer25/models/category_model.dart';
import 'package:project_flutter_khmer25/providers/category_provider.dart';
import 'package:provider/provider.dart';

/// List Navigation ប្រភេទផលិតផល
class HomeCategoryNavbar extends StatefulWidget {
  const HomeCategoryNavbar({super.key});

  @override
  State<HomeCategoryNavbar> createState() => _HomeCategoryNavbarState();
}

class _HomeCategoryNavbarState extends State<HomeCategoryNavbar> {
  @override
  Widget build(BuildContext context) {
    final categoryProv = context.watch<CategoryProvider>();

    if (categoryProv.isLoading) {
      return const SizedBox(
        height: 90,
        child: Center(child: CircularProgressIndicator()),
      );
    }

    if (categoryProv.error != null) {
      return SizedBox(
        height: 90,
        child: Center(child: Text('Error: ${categoryProv.error}')),
      );
    }

    final List<CategoryModel> categories = categoryProv.categories;

    if (categories.isEmpty) {
      return const SizedBox(
        height: 90,
        child: Center(child: Text('No categories')),
      );
    }

    return SizedBox(
      height: 110,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: categories.length,
        separatorBuilder: (_, __) => const SizedBox(width: 10),
        itemBuilder: (context, index) {
          final cat = categories[index];

          return Column(
            children: [
              InkWell(
                onTap: () {
                  // TODO: open category page or filter by cat.slug
                  // e.g. print(cat.url);
                },
                borderRadius: BorderRadius.circular(16),
                child: Container(
                  width: 64,
                  height: 64,
                  decoration: BoxDecoration(
                    color: Colors.green.shade50,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: Image.network(
                      cat.imageUrl, // ⬅⬅ USE YOUR URL HERE
                      fit: BoxFit.cover, // fill container
                    ),
                  ),
                ),
              ),
              // const SizedBox(height: 4),
              SizedBox(
                width: 72,
                child: Text(
                  cat.name,
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontSize: 12),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
