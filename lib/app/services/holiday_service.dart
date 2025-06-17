// lib/app/services/holiday_service.dart

import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:safe_diary/app/models/holiday_dto.dart';
import 'package:safe_diary/app/services/api_service.dart';
import 'package:safe_diary/app/services/secure_storage_service.dart';

class HolidayService extends GetxService {
  final ApiService _apiService;
  final SecureStorageService _storageService;

  HolidayService(this._apiService, this._storageService);

  Future<List<HolidayDto>> getHolidays(int year) async {
    final String? eTag = await _storageService.getHolidayETag(year);
    final String? cachedData = await _storageService.getHolidays(year);

    final response = await _apiService.getWithETag<List<HolidayDto>>(
      '/api/v1/holidays/$year',
      eTag: eTag,
      parser: (data) {
        final List<dynamic> list = data as List<dynamic>;
        return list
            .map((item) => HolidayDto.fromJson(item as Map<String, dynamic>))
            .toList();
      },
    );

    if (response.statusCode == 200 && response.body != null) {
      if (kDebugMode) print("Fetching new holiday data for $year from server.");
      final newETag = response.headers['etag'];
      if (newETag != null) {
        final holidaysJson = json.encode(
          response.body!.map((h) => h.toJson()).toList(),
        );
        await _storageService.saveHolidayETag(year, newETag);
        await _storageService.saveHolidays(year, holidaysJson);
      }
      return response.body!;
    } else if (response.statusCode == 304 && cachedData != null) {
      if (kDebugMode) {
        print("Holiday data for $year is up to date. Using cache.");
      }
      final List<dynamic> decodedData = json.decode(cachedData);
      return decodedData.map((item) => HolidayDto.fromJson(item)).toList();
    } else if (cachedData != null) {
      if (kDebugMode) print("API error, using stale holiday data for $year.");
      final List<dynamic> decodedData = json.decode(cachedData);
      return decodedData.map((item) => HolidayDto.fromJson(item)).toList();
    }

    return [];
  }
}
