import 'package:shared_preferences/shared_preferences.dart';

class CountryStorage {
  static const String _keySelectedIso2 = 'country_iso2';

  Future<void> saveIso2(String iso2) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keySelectedIso2, iso2);
  }

  Future<String?> loadIso2() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString(_keySelectedIso2);
  }

  Future<void> clear() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.remove(_keySelectedIso2);
  }
}
