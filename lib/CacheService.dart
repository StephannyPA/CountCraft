import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class CacheService {
  // Guardar datos en caché
  Future<void> cacheData(String key, Map<String, dynamic> data) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(key, jsonEncode(data));
  }

  // Obtener datos de caché
  Future<Map<String, dynamic>?> getCachedData(String key) async {
    final prefs = await SharedPreferences.getInstance();
    String? data = prefs.getString(key);
    return data != null ? jsonDecode(data) : null;
  }
}

