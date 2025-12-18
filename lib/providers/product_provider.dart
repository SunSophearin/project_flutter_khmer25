import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

import 'package:project_flutter_khmer25/core/api_config.dart';
import 'package:project_flutter_khmer25/models/product_model.dart';

class ProductProvider extends ChangeNotifier {
  List<Product> _allProducts = [];
  bool _isLoading = false;
  String? _error;

  // ✅ DETAIL STATE (for ProductDetailScreen)
  Product? _detailProduct;
  bool _isLoadingDetail = false;
  String? _detailError;

  List<Product> get allProducts => _allProducts;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Product? get detailProduct => _detailProduct;
  bool get isLoadingDetail => _isLoadingDetail;
  String? get detailError => _detailError;

  /// ✅ If you have "createdAt", sort by newest. (Your current logic is ok)
  List<Product> get newProducts =>
      _allProducts.where((p) => p.discountPercent == 0).toList();

  List<Product> get discountProducts =>
      _allProducts.where((p) => p.discountPercent > 0).toList();

  /// Optional helper
  Product? byId(dynamic id) {
    for (final p in _allProducts) {
      if (p.id == id) return p;
    }
    return null;
  }

  Map<String, String> _headers(String? accessToken) => {
    "Content-Type": "application/json",
    if (accessToken != null && accessToken.isNotEmpty)
      "Authorization": "Bearer $accessToken",
  };

  // -----------------------
  // LIST: /api/products/
  // -----------------------
  Future<void> fetchProducts({String? accessToken}) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final uri = Uri.parse("${ApiConfig.api}/products/");
      final res = await http
          .get(uri, headers: _headers(accessToken))
          .timeout(const Duration(seconds: 15));

      if (res.statusCode != 200) {
        _error = "HTTP ${res.statusCode}: ${res.body}";
        _allProducts = [];
        return;
      }

      final decoded = jsonDecode(res.body);

      // ✅ support both list and pagination
      final List<dynamic> list;
      if (decoded is List) {
        list = decoded;
      } else if (decoded is Map<String, dynamic> &&
          decoded["results"] is List) {
        list = decoded["results"] as List<dynamic>;
      } else {
        _error = "Invalid response format: ${decoded.runtimeType}";
        _allProducts = [];
        return;
      }

      _allProducts = list
          .whereType<Map<String, dynamic>>()
          .map(Product.fromJson)
          .toList();
    } catch (e) {
      _error = e.toString();
      if (kDebugMode) debugPrint('fetchProducts error: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // -----------------------
  // DETAIL: /api/products/<id>/
  // ✅ this is where related_products comes from
  // -----------------------
  Future<void> fetchProductDetail(int id, {String? accessToken}) async {
    _isLoadingDetail = true;
    _detailError = null;
    notifyListeners();

    try {
      final uri = Uri.parse("${ApiConfig.api}/products/$id/");
      final res = await http
          .get(uri, headers: _headers(accessToken))
          .timeout(const Duration(seconds: 15));

      if (res.statusCode != 200) {
        _detailError = "HTTP ${res.statusCode}: ${res.body}";
        _detailProduct = null;
        return;
      }

      final decoded = jsonDecode(res.body);
      if (decoded is! Map<String, dynamic>) {
        _detailError = "Invalid detail format: ${decoded.runtimeType}";
        _detailProduct = null;
        return;
      }

      _detailProduct = Product.fromJson(decoded);
    } catch (e) {
      _detailError = e.toString();
      _detailProduct = null;
      if (kDebugMode) debugPrint('fetchProductDetail error: $e');
    } finally {
      _isLoadingDetail = false;
      notifyListeners();
    }
  }

  Future<void> refresh({String? accessToken}) =>
      fetchProducts(accessToken: accessToken);

  void clear() {
    _allProducts = [];
    _error = null;

    _detailProduct = null;
    _detailError = null;

    notifyListeners();
  }
}
