import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart' show rootBundle;

import 'package:project_flutter_khmer25/models/category_model.dart';

class CategoryProvider extends ChangeNotifier {
  List<CategoryModel> _categories = [];
  bool _isLoading = false;
  String? _error;

  List<CategoryModel> get categories => _categories;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> loadCategories() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      // ⚠️ path JSON file របស់អ្នក
      final jsonString = await rootBundle.loadString(
        'assets/data/category.json',
      );

      final List<dynamic> data = jsonDecode(jsonString);

      _categories = CategoryModel.fromJsonList(data);
    } catch (e) {
      _error = e.toString();
      if (kDebugMode) {
        print('Error loading categories: $e');
      }
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
