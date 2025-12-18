import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/category_model.dart';
import '../providers/category_provider.dart';
import '../core/api_config.dart';

class CategoryScreen extends StatelessWidget {
  final void Function(CategoryModel cat) onOpenCategory;
  const CategoryScreen({super.key, required this.onOpenCategory});

  @override
  Widget build(BuildContext context) {
    final prov = context.watch<CategoryProvider>();

    if (prov.isLoading) return const Center(child: CircularProgressIndicator());
    if (prov.error != null) return Center(child: Text(prov.error!));
    if (prov.categories.isEmpty)
      return const Center(child: Text("No categories"));

    return GridView.builder(
      padding: const EdgeInsets.all(12),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: .85,
      ),
      itemCount: prov.categories.length,
      itemBuilder: (_, i) {
        final cat = prov.categories[i];

        return InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () => onOpenCategory(cat), // ✅ this keeps navbar + bottom bar
          child: Ink(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(.05),
                  blurRadius: 14,
                  offset: const Offset(0, 7),
                ),
              ],
            ),
            child: Padding(
              padding: const EdgeInsets.all(10),
              child: Column(
                children: [
                  Expanded(
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(14),
                      child: Image.network(
                        ApiConfig.toUrl(cat.image),
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => const Center(
                          child: Icon(Icons.broken_image_outlined),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    cat.name,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontWeight: FontWeight.w900,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
