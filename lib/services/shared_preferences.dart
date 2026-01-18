import 'package:shared_preferences/shared_preferences.dart';

class SharedPref {
  static SharedPreferences? _prefs;

  static Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  // ====== Simpan data ======
  static Future<void> saveUser(String userId, String token) async {
    await _prefs?.setString('userId', userId);
    await _prefs?.setString('token', token);
  }

  static Future<void> saveString(String key, String value) async {
    await _prefs?.setString(key, value);
  }

  static Future<void> saveBool(String key, bool value) async {
    await _prefs?.setBool(key, value);
  }

  // ====== Ambil data ======
  static String? getUserId() => _prefs?.getString('userId');
  static String? getToken() => _prefs?.getString('token');
  static String? getString(String key) => _prefs?.getString(key);
  static bool? getBool(String key) => _prefs?.getBool(key);

  // ====== Hapus data ======
  static Future<void> clearUser() async {
    await _prefs?.remove('userId');
    await _prefs?.remove('token');
  }

  static Future<void> remove(String key) async {
    await _prefs?.remove(key);
  }

  static Future<void> clearAll() async {
    await _prefs?.clear();
  }
}
