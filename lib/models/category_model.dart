class SubcategoryModel {
  final String name;
  final String slug;
  final String imageUrl; // from "image_url" in JSON

  SubcategoryModel({
    required this.name,
    required this.slug,
    required this.imageUrl,
  });

  factory SubcategoryModel.fromJson(Map<String, dynamic> json) {
    return SubcategoryModel(
      name: json['name'] ?? '',
      slug: json['slug'] ?? '',
      imageUrl: json['image_url'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'slug': slug,
      'image_url': imageUrl,
    };
  }
}

class CategoryModel {
  final String name;
  final String slug;
  final String imageUrl; // from "image_url" in JSON
  final List<SubcategoryModel> subcategories;

  CategoryModel({
    required this.name,
    required this.slug,
    required this.imageUrl,
    required this.subcategories,
  });

  factory CategoryModel.fromJson(Map<String, dynamic> json) {
    final subs = json['subcategories'] as List<dynamic>? ?? [];

    return CategoryModel(
      name: json['name'] ?? '',
      slug: json['slug'] ?? '',
      imageUrl: json['image_url'] ?? '',
      subcategories: subs
          .map((e) => SubcategoryModel.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'slug': slug,
      'image_url': imageUrl,
      'subcategories': subcategories.map((e) => e.toJson()).toList(),
    };
  }

  /// Helper សម្រាប់ Provider
  static List<CategoryModel> fromJsonList(List<dynamic> list) {
    return list
        .map((e) => CategoryModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }
}
