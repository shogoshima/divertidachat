import 'package:shared_preferences/shared_preferences.dart';

class DateTimeStorage {
  static Future<void> saveLastUpdatedTimestamp() async {
    final SharedPreferencesWithCache prefs =
        await SharedPreferencesWithCache.create(
            cacheOptions: const SharedPreferencesWithCacheOptions(
                allowList: <String>{'last_updated'}));
    DateTime datetime = DateTime.now().toUtc();
    await prefs.setString('last_updated', datetime.toIso8601String());
  }

  static Future<DateTime?> getLastUpdatedTimestamp() async {
    final SharedPreferencesWithCache prefs =
        await SharedPreferencesWithCache.create(
            cacheOptions: const SharedPreferencesWithCacheOptions(
                allowList: <String>{'last_updated'}));

    String? dateTimeString = prefs.getString('last_updated');
    if (dateTimeString != null) {
      return DateTime.parse(dateTimeString);
    }
    return null;
  }

  static Future<void> clear() async {
    final SharedPreferencesWithCache prefs =
        await SharedPreferencesWithCache.create(
            cacheOptions: const SharedPreferencesWithCacheOptions(
                allowList: <String>{'last_updated'}));
    await prefs.remove('last_updated');
  }
}
