double _toDouble(dynamic v) {
  if (v == null) return 0;
  if (v is num) return v.toDouble();
  if (v is String) return double.tryParse(v) ?? 0;
  return 0;
}

int _toInt(dynamic v) {
  if (v == null) return 0;
  if (v is int) return v;
  if (v is num) return v.toInt();
  if (v is String) return int.tryParse(v) ?? double.tryParse(v)?.toInt() ?? 0;
  return 0;
}

class Cart {
  final int id;
  final List<CartItem> items;
  final double total;

  Cart({required this.id, required this.items, required this.total});

  factory Cart.fromJson(Map<String, dynamic> json) {
    return Cart(
      id: _toInt(json["id"]),
      items: (json["items"] as List<dynamic>? ?? [])
          .map((e) => CartItem.fromJson(e as Map<String, dynamic>))
          .toList(),
      total: _toDouble(json["total"]), // ✅ can be "24000.00" or 24000
    );
  }

  int get totalQty => items.fold(0, (sum, item) => sum + item.qty);
}

class CartItem {
  final int id;
  final int qty;
  final double lineTotal;
  final CartProduct product;

  CartItem({
    required this.id,
    required this.qty,
    required this.lineTotal,
    required this.product,
  });

  factory CartItem.fromJson(Map<String, dynamic> json) {
    return CartItem(
      id: _toInt(json["id"]),
      qty: _toInt(json["qty"]),
      lineTotal: _toDouble(json["line_total"]), // ✅ can be string
      product: CartProduct.fromJson(json["product"] as Map<String, dynamic>),
    );
  }
}

class CartProduct {
  final int id;
  final String name;
  final String? image;
  final double price;
  final int discountPercent;
  final double finalPrice;
  final String priceText;
  final String? unit;
  final bool isInStock;

  CartProduct({
    required this.id,
    required this.name,
    this.image,
    required this.price,
    required this.discountPercent,
    required this.finalPrice,
    required this.priceText,
    this.unit,
    required this.isInStock,
  });

  factory CartProduct.fromJson(Map<String, dynamic> json) {
    return CartProduct(
      id: _toInt(json["id"]),
      name: (json["name"] ?? "").toString(),
      image: json["image"]?.toString(),
      price: _toDouble(json["price"]), // ✅ Decimal often string
      discountPercent: _toInt(json["discount_percent"]),
      finalPrice: _toDouble(json["final_price"]), // ✅ sometimes string
      priceText: (json["price_text"] ?? "").toString(),
      unit: json["unit"]?.toString(),
      isInStock: (json["is_in_stock"] ?? true) == true,
    );
  }
}
