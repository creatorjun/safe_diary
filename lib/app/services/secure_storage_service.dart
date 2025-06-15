// lib/app/services/secure_storage_service.dart

import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class SecureStorageService {
  final FlutterSecureStorage _storage = const FlutterSecureStorage();

  static const String keyRefreshToken = 'refreshToken';
  static const String keySelectedCity = 'selectedCity';
  static const String keySelectedZodiac = 'selectedZodiac';
  static const String keyFailedAttemptCount = 'failedAttemptCount';

  String _holidayDataKey(int year) => 'holiday_data_$year';
  String _holidayETagKey(int year) => 'holiday_etag_$year';

  Future<void> saveRefreshToken({required String refreshToken}) async {
    await _storage.write(key: keyRefreshToken, value: refreshToken);
  }

  Future<String?> getRefreshToken() async {
    return await _storage.read(key: keyRefreshToken);
  }

  Future<void> clearRefreshToken() async {
    await _storage.delete(key: keyRefreshToken);
    if (kDebugMode) print('[SecureStorageService] Refresh token cleared.');
  }

  Future<void> saveSelectedCity(String cityName) async {
    await _storage.write(key: keySelectedCity, value: cityName);
  }

  Future<String?> getSelectedCity() async {
    return await _storage.read(key: keySelectedCity);
  }

  Future<void> saveSelectedZodiac(String zodiacName) async {
    await _storage.write(key: keySelectedZodiac, value: zodiacName);
  }

  Future<String?> getSelectedZodiac() async {
    return await _storage.read(key: keySelectedZodiac);
  }

  Future<void> saveFailedAttemptCount(int count) async {
    await _storage.write(key: keyFailedAttemptCount, value: count.toString());
  }

  Future<int> getFailedAttemptCount() async {
    final String? countStr = await _storage.read(key: keyFailedAttemptCount);
    return countStr != null ? (int.tryParse(countStr) ?? 0) : 0;
  }

  Future<void> clearFailedAttemptCount() async {
    await _storage.write(key: keyFailedAttemptCount, value: '0');
  }

  Future<void> saveHolidays(int year, String holidaysJson) async {
    await _storage.write(key: _holidayDataKey(year), value: holidaysJson);
  }

  Future<String?> getHolidays(int year) async {
    return await _storage.read(key: _holidayDataKey(year));
  }

  Future<void> saveHolidayETag(int year, String etag) async {
    await _storage.write(key: _holidayETagKey(year), value: etag);
  }

  Future<String?> getHolidayETag(int year) async {
    return await _storage.read(key: _holidayETagKey(year));
  }

  Future<void> clearAllUserData() async {
    await _storage.deleteAll();
    if (kDebugMode) {
      print('[SecureStorageService] All user data cleared.');
    }
  }
}