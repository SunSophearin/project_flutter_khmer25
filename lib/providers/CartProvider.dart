import 'package:flutter/foundation.dart';
import '../models/product_model.dart';

class CartItem {
  final Product product;
  int qty;
  CartItem({required this.product, required this.qty});
}

class CartProvider extends ChangeNotifier {
  final List<CartItem> _items = [];

  List<CartItem> get items => _items;

  void addToCart(Product p, {int qty = 1}) {
    final i = _items.indexWhere((e) => e.product.id == p.id);
    if (i >= 0) {
      _items[i].qty += qty;
    } else {
      _items.add(CartItem(product: p, qty: qty));
    }
    notifyListeners();
  }
}
