import 'package:shared_preferences/shared_preferences.dart';

class SharedPreferencesManager {
  static SharedPreferences? _prefs;

  // Initialize SharedPreferences (call this once, e.g., in the main method)
  static Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  // Save a dynamic value
  static Future<void> setValue(String key, dynamic value) async {
    if (value is String) {
      await _prefs?.setString(key, value);
    } else if (value is int) {
      await _prefs?.setInt(key, value);
    } else if (value is bool) {
      await _prefs?.setBool(key, value);
    } else if (value is double) {
      await _prefs?.setDouble(key, value);
    } else if (value is List<String>) {
      await _prefs?.setStringList(key, value);
    } else {
      throw ArgumentError('Unsupported value type: ${value.runtimeType}');
    }
  }

  // Retrieve a dynamic value
  static dynamic getValue(String key) {
    if (_prefs?.get(key) is String) {
      return _prefs?.getString(key);
    } else if (_prefs?.get(key) is int) {
      return _prefs?.getInt(key);
    } else if (_prefs?.get(key) is bool) {
      return _prefs?.getBool(key);
    } else if (_prefs?.get(key) is double) {
      return _prefs?.getDouble(key);
    } else if (_prefs?.get(key) is List<String>) {
      return _prefs?.getStringList(key);
    } else {
      return null; // Return null if the key doesn't exist or is unsupported
    }
  }

  // Remove a specific key
  static Future<void> remove(String key) async {
    await _prefs?.remove(key);
  }

  // Clear all stored data
  static Future<void> clear() async {
    await _prefs?.clear();
  }

  // Check if a key exists
  static bool containsKey(String key) {
    return _prefs?.containsKey(key) ?? false;
  }
}

