import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:project_flutter_khmer25/models/product_model.dart';

class ProductProvider extends ChangeNotifier {
  List<Product> _allProducts = [];
  bool _isLoading = false;

  List<Product> get allProducts => _allProducts;
  bool get isLoading => _isLoading;

  // ផលិតផលថ្មីៗ = គ្មាន discount
  List<Product> get newProducts =>
      _allProducts.where((p) => p.discountPercent == null).toList();

  // ផលិតផលបញ្ចុះតម្លៃ
  List<Product> get discountProducts =>
      _allProducts.where((p) => p.discountPercent != null).toList();

  Future<void> loadProducts() async {
    try {
      _isLoading = true;
      notifyListeners();

      final jsonString = await rootBundle.loadString(
        'assets/data/product.json',
      );

      final List<dynamic> list = json.decode(jsonString) as List<dynamic>;

      _allProducts = list
          .map((e) => Product.fromJson(e as Map<String, dynamic>))
          .toList();
    } catch (e) {
      debugPrint('Error loading products: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
