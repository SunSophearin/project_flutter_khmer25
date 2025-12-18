class SubcategoryModel {
  final int id;
  final String name;
  final String slug;
  final String? image;
  final int? parent; // parent id

  SubcategoryModel({
    required this.id,
    required this.name,
    required this.slug,
    this.image,
    this.parent,
  });

  factory SubcategoryModel.fromJson(Map<String, dynamic> json) {
    return SubcategoryModel(
      id: (json['id'] ?? 0) as int,
      name: (json['name'] ?? '') as String,
      slug: (json['slug'] ?? '') as String,
      image: json['image'] as String?,
      parent: (json['parent'] ?? json['parent_id']) as int?,
    );
  }
}

class CategoryModel {
  final int id;
  final String name;
  final String slug;
  final String? image;
  final int? parent; // null = parent category
  final List<SubcategoryModel> subcategories;

  CategoryModel({
    required this.id,
    required this.name,
    required this.slug,
    this.image,
    this.parent,
    this.subcategories = const [],
  });

  factory CategoryModel.fromJson(Map<String, dynamic> json) {
    final rawSubs =
        json['subcategories'] ??
        json['children'] ??
        json['sub_categories'] ??
        json['subs'];

    final List subsList = rawSubs is List ? rawSubs : const [];

    return CategoryModel(
      id: (json['id'] ?? 0) as int,
      name: (json['name'] ?? '') as String,
      slug: (json['slug'] ?? '') as String,
      image: json['image'] as String?,
      parent: (json['parent'] ?? json['parent_id']) as int?,
      subcategories: subsList
          .whereType<Map<String, dynamic>>()
          .map(SubcategoryModel.fromJson)
          .toList(),
    );
  }

  static List<CategoryModel> fromJsonList(List<dynamic> list) {
    return list
        .whereType<Map<String, dynamic>>()
        .map(CategoryModel.fromJson)
        .toList();
  }
}
