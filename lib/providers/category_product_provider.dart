import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

import '../core/api_config.dart';
import '../models/category_model.dart';
import '../models/product_model.dart';

class CategoryProductProvider extends ChangeNotifier {
  // states
  bool loadingCats = false;
  bool loadingProducts = false;
  String? error;

  // data
  List<CategoryModel> parents = [];
  List<SubcategoryModel> subs = [];
  List<Product> products = [];

  int? selectedParentId;
  int? selectedSubId;

  // keep all categories if API is flat
  List<CategoryModel> _allCats = [];

  Future<void> initWithInitial(
    CategoryModel initialParent, {
    String? accessToken,
  }) async {
    error = null;
    selectedParentId = initialParent.id;
    selectedSubId = null;
    notifyListeners();

    await fetchCategories(accessToken: accessToken);

    // select initial parent from loaded list (if exists)
    final found = parents.where((e) => e.id == initialParent.id).toList();
    if (found.isNotEmpty) {
      await selectParent(found.first, accessToken: accessToken);
    } else {
      // fallback: show subs from passed in initial
      _setSubsFromParent(initialParent);
      await fetchProducts(accessToken: accessToken);
    }
  }

  Future<void> fetchCategories({String? accessToken}) async {
    loadingCats = true;
    error = null;
    notifyListeners();

    try {
      final uri = Uri.parse('${ApiConfig.host}/api/categories/');
      final res = await http.get(
        uri,
        headers: {
          "Content-Type": "application/json",
          if (accessToken != null && accessToken.isNotEmpty)
            "Authorization": "Bearer $accessToken",
        },
      );

      if (res.statusCode != 200) {
        throw Exception("HTTP ${res.statusCode}: ${res.body}");
      }

      final data = jsonDecode(res.body);

      // adjust if your API returns {"results": [...]}
      final List list = data is List
          ? data
          : (data is Map && data['results'] is List
                ? data['results']
                : const []);

      _allCats = CategoryModel.fromJsonList(list);

      // parents = where parent == null OR parent == 0
      parents = _allCats
          .where((c) => (c.parent == null || c.parent == 0))
          .toList();

      // if API returns nested subcategories, we can use them directly later
      // if API returns flat, we'll build subs by filtering parent id

      // if selectedParentId is already set, refresh subs for it
      if (selectedParentId != null) {
        final parentObj = parents
            .where((p) => p.id == selectedParentId)
            .toList();
        if (parentObj.isNotEmpty) {
          _setSubsFromParent(parentObj.first);
        } else {
          subs = [];
        }
      }

      loadingCats = false;
      notifyListeners();
    } catch (e) {
      loadingCats = false;
      error = e.toString();
      notifyListeners();
    }
  }

  Future<void> selectParent(CategoryModel parent, {String? accessToken}) async {
    selectedParentId = parent.id;
    selectedSubId = null;

    _setSubsFromParent(parent);
    notifyListeners();

    // load products for parent (or first sub if you want)
    await fetchProducts(accessToken: accessToken);
  }

  Future<void> selectSub(SubcategoryModel sub, {String? accessToken}) async {
    selectedSubId = sub.id;
    notifyListeners();
    await fetchProducts(accessToken: accessToken);
  }

  void _setSubsFromParent(CategoryModel parent) {
    // 1) if backend gives nested subs
    if (parent.subcategories.isNotEmpty) {
      subs = parent.subcategories;
      return;
    }

    // 2) otherwise, build from flat list by parent id
    subs = _allCats
        .where((c) => c.parent == parent.id)
        .map(
          (c) => SubcategoryModel(
            id: c.id,
            name: c.name,
            slug: c.slug,
            image: c.image,
            parent: c.parent,
          ),
        )
        .toList();
  }

  Future<void> fetchProducts({String? accessToken}) async {
    loadingProducts = true;
    error = null;
    notifyListeners();

    try {
      final parentId = selectedParentId;
      final subId = selectedSubId;

      if (parentId == null) {
        products = [];
        loadingProducts = false;
        notifyListeners();
        return;
      }

      // ✅ IMPORTANT: parent uses parent_category, sub uses category
      final params = <String, String>{};
      if (subId != null) {
        params['category'] = '$subId';
      } else {
        params['parent_category'] = '$parentId';
      }

      final uri = Uri.parse(
        '${ApiConfig.host}/api/products/',
      ).replace(queryParameters: params);

      final res = await http.get(
        uri,
        headers: {
          "Content-Type": "application/json",
          if (accessToken != null && accessToken.isNotEmpty)
            "Authorization": "Bearer $accessToken",
        },
      );

      if (res.statusCode != 200) {
        throw Exception("HTTP ${res.statusCode}: ${res.body}");
      }

      final data = jsonDecode(res.body);

      // supports list or paginated {results:[]}
      final List list = data is List
          ? data
          : (data is Map && data['results'] is List
                ? data['results']
                : const []);

      products = list
          .whereType<Map<String, dynamic>>()
          .map((e) => Product.fromJson(e))
          .toList();

      loadingProducts = false;
      notifyListeners();
    } catch (e) {
      loadingProducts = false;
      error = e.toString();
      notifyListeners();
    }
  }
}
