import 'package:shared_preferences/shared_preferences.dart';

class ServiceSharedPreferences {
  static final Future<SharedPreferences> _prefs =
      SharedPreferences.getInstance();

  static void setSharedInt(String key, Object value) async {
    final SharedPreferences prefs = await _prefs;
    prefs.setInt(key, value as int);
  }

  static void setSharedBool(String key, Object value) async {
    final SharedPreferences prefs = await _prefs;
    prefs.setBool(key, value as bool);
  }

  static void setSharedString(String key, Object value) async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setString(key, value as String);
  }

  static void setSharedDouble(String key, Object value) async {
    final SharedPreferences prefs = await _prefs;
    prefs.setDouble(key, value as double);
  }

  static void setSharedListString(String key, Object value) async {
    final SharedPreferences prefs = await _prefs;
    prefs.setStringList(key, value as List<String>);
  }

  static Future<String?> getSharedString(String key) async {
    final prefs = await SharedPreferences.getInstance();
    var token = prefs.getString(key);
    return token;
  }
}
