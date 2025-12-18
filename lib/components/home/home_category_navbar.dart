import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:project_flutter_khmer25/models/category_model.dart';
import 'package:project_flutter_khmer25/providers/category_provider.dart';

class HomeCategoryNavbar extends StatelessWidget {
  final void Function(CategoryModel cat) onOpenCategory;

  const HomeCategoryNavbar({super.key, required this.onOpenCategory});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<CategoryProvider>();

    if (provider.isLoading) return _stateBox(const CircularProgressIndicator());
    if (provider.error != null) return _stateBox(Text(provider.error!));
    if (provider.categories.isEmpty)
      return _stateBox(const Text('No categories'));

    return SizedBox(
      height: 110,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        itemCount: provider.categories.length,
        separatorBuilder: (_, __) => const SizedBox(width: 10),
        itemBuilder: (_, i) {
          final cat = provider.categories[i];

          return Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              GestureDetector(
                onTap: () => onOpenCategory(cat), // ✅ keep navbar + bottom bar
                child: Container(
                  width: 64,
                  height: 64,
                  decoration: BoxDecoration(
                    color: Colors.green.shade50,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: _CategoryImage(cat.image),
                  ),
                ),
              ),
              const SizedBox(height: 6),
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

  Widget _stateBox(Widget child) =>
      SizedBox(height: 110, child: Center(child: child));
}

class _CategoryImage extends StatelessWidget {
  final String? url;
  const _CategoryImage(this.url);

  @override
  Widget build(BuildContext context) {
    if (url == null || url!.isEmpty) {
      return const Icon(Icons.image_not_supported);
    }

    return Image.network(
      url!,
      fit: BoxFit.cover,
      errorBuilder: (_, __, ___) => const Icon(Icons.broken_image),
    );
  }
}
