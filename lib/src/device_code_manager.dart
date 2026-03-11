import 'dart:math';
import 'package:shared_preferences/shared_preferences.dart';

class DeviceCodeManager {
  static const _key = 'curl_tracking_device_code';
  static const _chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';

  /// Returns existing code or generates a new one.
  static Future<String> getOrCreateCode() async {
    final prefs = await SharedPreferences.getInstance();
    final existing = prefs.getString(_key);
    if (existing != null && existing.isNotEmpty) {
      return existing;
    }
    final code = generateCode(Random());
    await prefs.setString(_key, code);
    return code;
  }

  /// Generates a 6-character uppercase alphanumeric code.
  static String generateCode(Random random) {
    return List.generate(6, (_) => _chars[random.nextInt(_chars.length)])
        .join();
  }
}
