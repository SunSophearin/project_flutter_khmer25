import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:project_flutter_khmer25/core/api_config.dart';

class AuthProvider extends ChangeNotifier {
  bool isLoading = false;
  String? error;

  String? access;
  String? refresh;

  Map<String, dynamic>? me;

  bool get isLoggedIn => access != null && access!.isNotEmpty;

  // =========================
  // Storage
  // =========================
  Future<void> loadFromStorageAndMe() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      access = prefs.getString("access");
      refresh = prefs.getString("refresh");
      notifyListeners();

      if (isLoggedIn && me == null) {
        await getMe();
      }
    } catch (e) {
      error = "Storage error: $e";
      notifyListeners();
    }
  }

  Future<void> _saveTokens(String newAccess, String newRefresh) async {
    access = newAccess;
    refresh = newRefresh;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString("access", newAccess);
    await prefs.setString("refresh", newRefresh);
  }

  Future<void> _saveAccessOnly(String newAccess) async {
    access = newAccess;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString("access", newAccess);
  }

  Future<void> _clearSession() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove("access");
    await prefs.remove("refresh");
    access = null;
    refresh = null;
    me = null;
    error = null;
  }

  // =========================
  // Register
  // =========================
  Future<bool> register(
    String username,
    String password,
    String rePassword,
  ) async {
    isLoading = true;
    error = null;
    notifyListeners();

    try {
      final res = await http
          .post(
            Uri.parse("${ApiConfig.auth}/users/"),
            headers: {"Content-Type": "application/json"},
            body: jsonEncode({
              "username": username,
              "password": password,
              "re_password": rePassword,
            }),
          )
          .timeout(const Duration(seconds: 12));

      if (res.statusCode == 201) return true;

      error = _parseError(res);
      return false;
    } catch (e) {
      error = "Network error: $e";
      return false;
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  // =========================
  // Login
  // =========================
  Future<bool> login(String username, String password) async {
    isLoading = true;
    error = null;
    notifyListeners();

    try {
      final res = await http
          .post(
            Uri.parse("${ApiConfig.auth}/jwt/create/"),
            headers: {"Content-Type": "application/json"},
            body: jsonEncode({"username": username, "password": password}),
          )
          .timeout(const Duration(seconds: 12));

      if (res.statusCode != 200) {
        await _clearSession();
        error = _parseError(res);
        notifyListeners();
        return false;
      }

      final data = jsonDecode(res.body) as Map<String, dynamic>;
      final newAccess = data["access"] as String?;
      final newRefresh = data["refresh"] as String?;

      if (newAccess == null || newRefresh == null) {
        error = "Login success but token missing!";
        notifyListeners();
        return false;
      }

      await _saveTokens(newAccess, newRefresh);

      await getMe(); // load profile
      return true;
    } catch (e) {
      error = "Network error: $e";
      return false;
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  // =========================
  // Refresh Access Token
  // =========================
  Future<bool> refreshAccess() async {
    if (refresh == null || refresh!.isEmpty) return false;

    try {
      final res = await http
          .post(
            Uri.parse("${ApiConfig.auth}/jwt/refresh/"),
            headers: {"Content-Type": "application/json"},
            body: jsonEncode({"refresh": refresh}),
          )
          .timeout(const Duration(seconds: 12));

      if (res.statusCode != 200) return false;

      final data = jsonDecode(res.body) as Map<String, dynamic>;
      final newAccess = data["access"] as String?;

      if (newAccess == null || newAccess.isEmpty) return false;

      await _saveAccessOnly(newAccess);
      return true;
    } catch (_) {
      return false;
    }
  }

  // =========================
  // Me
  // =========================
  Map<String, String> _authHeaders() => {
    "Content-Type": "application/json",
    if (access != null && access!.isNotEmpty) "Authorization": "Bearer $access",
  };

  Future<bool> getMe() async {
    if (!isLoggedIn) return false;

    try {
      final res = await http
          .get(
            Uri.parse("${ApiConfig.auth}/users/me/"),
            headers: _authHeaders(),
          )
          .timeout(const Duration(seconds: 12));

      if (res.statusCode == 200) {
        me = jsonDecode(res.body) as Map<String, dynamic>;
        error = null;
        notifyListeners();
        return true;
      }

      // ✅ Access expired -> try refresh -> retry once
      if (res.statusCode == 401) {
        final ok = await refreshAccess();
        if (ok) return await getMe();

        await logout(); // refresh fail => logout
        return false;
      }

      me = null;
      error = _parseError(res);
      notifyListeners();
      return false;
    } catch (e) {
      error = "GetMe error: $e";
      notifyListeners();
      return false;
    }
  }

  // =========================
  // Logout
  // =========================
  Future<void> logout() async {
    await _clearSession();
    notifyListeners();
  }

  // =========================
  // Error parser
  // =========================
  String _parseError(http.Response res) {
    try {
      final data = jsonDecode(res.body);

      if (data is Map<String, dynamic>) {
        if (data["detail"] != null) return data["detail"].toString();

        return data.entries
            .map((e) {
              final v = e.value;
              if (v is List) return "${e.key}: ${v.join(", ")}";
              return "${e.key}: $v";
            })
            .join("\n");
      }

      return res.body;
    } catch (_) {
      return "Request failed (${res.statusCode})";
    }
  }
}
