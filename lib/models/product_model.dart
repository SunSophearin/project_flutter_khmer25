import 'category_model.dart';

class Product {
  final int id;
  final String name;
  final String? sku;
  final String? image;

  final double price;
  final int discountPercent;
  final double finalPrice;
  final String priceText;

  final int stock;
  final bool isInStock;
  final bool isNew;
  final bool isFeatured;
  final bool isActive;

  final String? description;
  final String? unit;

  // ✅ nested category object
  final CategoryModel? category;

  // ✅ ADD: related products from /api/products/<id>/
  final List<Product> relatedProducts;

  Product({
    required this.id,
    required this.name,
    this.sku,
    this.image,
    required this.price,
    required this.discountPercent,
    required this.finalPrice,
    required this.priceText,
    required this.stock,
    required this.isInStock,
    required this.isNew,
    required this.isFeatured,
    required this.isActive,
    this.description,
    this.unit,
    this.category,

    // ✅ default empty
    this.relatedProducts = const [],
  });

  /// ✅ Helper for related logic
  int? get categoryId => category?.id;

  static double _toDouble(dynamic v) {
    if (v == null) return 0.0;
    if (v is num) return v.toDouble();
    return double.tryParse(v.toString()) ?? 0.0;
  }

  static int _toInt(dynamic v) {
    if (v == null) return 0;
    if (v is num) return v.toInt();
    return int.tryParse(v.toString()) ?? 0;
  }

  factory Product.fromJson(Map<String, dynamic> json) {
    // ✅ safe parse list
    final rel = (json['related_products'] as List?) ?? const [];

    return Product(
      id: _toInt(json['id']),
      name: json['name'] ?? '',
      sku: json['sku']?.toString(),
      image: json['image']?.toString(),

      price: _toDouble(json['price']),
      discountPercent: _toInt(json['discount_percent']),
      finalPrice: _toDouble(json['final_price']),
      priceText: json['price_text'] ?? '',

      stock: _toInt(json['stock']),
      isInStock: json['is_in_stock'] == true,
      isNew: json['is_new'] == true,
      isFeatured: json['is_featured'] == true,
      isActive: json['is_active'] == true,

      description: json['description']?.toString(),
      unit: json['unit']?.toString(),

      // ✅ parse nested category object
      category: json['category'] != null
          ? CategoryModel.fromJson(json['category'] as Map<String, dynamic>)
          : null,

      // ✅ parse related products
      relatedProducts: rel
          .whereType<Map<String, dynamic>>() // extra safety
          .map((e) => Product.fromJson(e))
          .toList(),
    );
  }
}
