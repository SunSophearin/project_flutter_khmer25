import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart' show rootBundle;
import '../models/banner_model.dart';

class BannerProvider extends ChangeNotifier {
  List<BannerModel> _banners = [];
  bool _isLoading = false;
  String? _error;

  List<BannerModel> get banners => _banners;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> loadBanners() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      // Read JSON file
      final jsonString =
          await rootBundle.loadString('assets/data/bannerImages.json');

      // Decode JSON as a List<dynamic>
      final List<dynamic> data = jsonDecode(jsonString);

      // Convert to List<BannerModel>
      _banners = BannerModel.fromJsonList(data);
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
