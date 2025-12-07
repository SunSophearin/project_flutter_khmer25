class Product {
  final String id;
  final String nameKm;
  final String imageUrl;
  final double price;
  final double? discountPercent; // null = គ្មានបញ្ចុះតម្លៃ

  Product({
    required this.id,
    required this.nameKm,
    required this.imageUrl,
    required this.price,
    this.discountPercent,
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: json['id'] as String,
      nameKm: json['name_km'] as String,
      imageUrl: json['image_url'] as String,
      price: (json['price'] as num).toDouble(),
      discountPercent: json['discount_percent'] == null
          ? null
          : (json['discount_percent'] as num).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name_km': nameKm,
      'image_url': imageUrl,
      'price': price,
      'discount_percent': discountPercent,
    };
  }
}
