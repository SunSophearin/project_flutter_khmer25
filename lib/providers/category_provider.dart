import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

import 'package:project_flutter_khmer25/core/api_config.dart';
import 'package:project_flutter_khmer25/models/category_model.dart';

class CategoryProvider extends ChangeNotifier {
  List<CategoryModel> _categories = [];
  bool _isLoading = false;
  String? _error;

  // =========================
  // Getters
  // =========================
  List<CategoryModel> get categories => _categories;
  bool get isLoading => _isLoading;
  String? get error => _error;

  // =========================
  // Load categories
  // =========================
  Future<void> loadCategories({String? accessToken}) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final uri = Uri.parse(
        '${ApiConfig.api}/categories/?parent=null',
      );

      final headers = <String, String>{
        "Content-Type": "application/json",
        if (accessToken != null && accessToken.isNotEmpty)
          "Authorization": "Bearer $accessToken",
      };

      final response = await http
          .get(uri, headers: headers)
          .timeout(const Duration(seconds: 12));

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        _categories = CategoryModel.fromJsonList(data);
      } else {
        _error =
            'Failed to load categories (${response.statusCode})\n${response.body}';
      }
    } catch (e) {
      _error = e.toString();
      if (kDebugMode) {
        print('CategoryProvider error: $e');
      }
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // =========================
  // Refresh
  // =========================
  Future<void> refresh({String? accessToken}) async {
    await loadCategories(accessToken: accessToken);
  }

  // =========================
  // Clear state (optional)
  // =========================
  void clear() {
    _categories = [];
    _error = null;
    notifyListeners();
  }
}
