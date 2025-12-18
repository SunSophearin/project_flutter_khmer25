import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

import 'package:project_flutter_khmer25/core/api_config.dart';
import 'package:project_flutter_khmer25/models/cart_model.dart';

class CartProvider extends ChangeNotifier {
  Cart? _cart;
  bool _isLoading = false;
  String? _error;

  // =========================
  // Getters
  // =========================
  Cart? get cart => _cart;
  bool get isLoading => _isLoading;
  String? get error => _error;

  int get totalQty => _cart?.totalQty ?? 0;
  double get totalPrice => _cart?.total ?? 0;

  Map<String, String> _headers(String? accessToken) => {
    "Content-Type": "application/json",
    if (accessToken != null && accessToken.isNotEmpty)
      "Authorization": "Bearer $accessToken",
  };

  // =========================
  // GET /api/cart/
  // =========================
  Future<void> fetchCart({required String? accessToken}) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final uri = Uri.parse("${ApiConfig.api}/cart/");

      final res = await http
          .get(uri, headers: _headers(accessToken))
          .timeout(const Duration(seconds: 12));

      if (res.statusCode == 200) {
        _cart = Cart.fromJson(jsonDecode(res.body));
      } else {
        _error = 'Failed to load cart (${res.statusCode})\n${res.body}';
      }
    } catch (e) {
      _error = e.toString();
      if (kDebugMode) {
        print("CartProvider fetchCart error: $e");
      }
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // =========================
  // POST /api/cart/items/
  // body: {product_id, qty}
  // return: cart json
  // =========================
  Future<bool> addToCart({
    required int productId,
    int qty = 1,
    required String? accessToken,
  }) async {
    _error = null;
    notifyListeners();

    try {
      final uri = Uri.parse("${ApiConfig.api}/cart/items/");

      final res = await http
          .post(
            uri,
            headers: _headers(accessToken),
            body: jsonEncode({"product_id": productId, "qty": qty}),
          )
          .timeout(const Duration(seconds: 12));

      if (res.statusCode == 200) {
        _cart = Cart.fromJson(jsonDecode(res.body));
        notifyListeners();
        return true;
      } else {
        _error = 'Add to cart failed (${res.statusCode})\n${res.body}';
        notifyListeners();
        return false;
      }
    } catch (e) {
      _error = e.toString();
      if (kDebugMode) {
        print("CartProvider addToCart error: $e");
      }
      notifyListeners();
      return false;
    }
  }

  // =========================
  // PATCH /api/cart/items/<id>/
  // body: {qty}
  // =========================
  Future<bool> updateQty({
    required int cartItemId,
    required int qty,
    required String? accessToken,
  }) async {
    _error = null;
    notifyListeners();

    try {
      final uri = Uri.parse("${ApiConfig.api}/cart/items/$cartItemId/");

      final res = await http
          .patch(
            uri,
            headers: _headers(accessToken),
            body: jsonEncode({"qty": qty}),
          )
          .timeout(const Duration(seconds: 12));

      if (res.statusCode == 200) {
        _cart = Cart.fromJson(jsonDecode(res.body));
        notifyListeners();
        return true;
      } else {
        _error = 'Update qty failed (${res.statusCode})\n${res.body}';
        notifyListeners();
        return false;
      }
    } catch (e) {
      _error = e.toString();
      if (kDebugMode) {
        print("CartProvider updateQty error: $e");
      }
      notifyListeners();
      return false;
    }
  }

  // =========================
  // DELETE /api/cart/items/<id>/delete/
  // =========================
  Future<bool> removeItem({
    required int cartItemId,
    required String? accessToken,
  }) async {
    _error = null;
    notifyListeners();

    try {
      final uri = Uri.parse("${ApiConfig.api}/cart/items/$cartItemId/");

      final res = await http
          .delete(uri, headers: _headers(accessToken))
          .timeout(const Duration(seconds: 12));

      if (res.statusCode == 200) {
        _cart = Cart.fromJson(jsonDecode(res.body));
        notifyListeners();
        return true;
      } else {
        _error = 'Remove item failed (${res.statusCode})\n${res.body}';
        notifyListeners();
        return false;
      }
    } catch (e) {
      _error = e.toString();
      if (kDebugMode) {
        print("CartProvider removeItem error: $e");
      }
      notifyListeners();
      return false;
    }
  }

  // =========================
  // Refresh
  // =========================
  Future<void> refresh({required String? accessToken}) async {
    await fetchCart(accessToken: accessToken);
  }

  // =========================
  // Clear
  // =========================
  void clear() {
    _cart = null;
    _error = null;
    notifyListeners();
  }
}
