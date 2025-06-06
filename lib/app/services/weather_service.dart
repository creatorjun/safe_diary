// lib/app/services/weather_service.dart

import 'package:flutter/foundation.dart';
import 'package:get/get.dart';

import '../models/weather_models.dart';
import 'api_service.dart';

class WeatherService extends GetxService {
  final ApiService _apiService;
  WeatherService(this._apiService);

  /// 도시 이름으로 주간 날씨 예보를 가져옵니다.
  Future<WeeklyForecastResponseDto> getWeeklyForecastByCityName(
      String cityName, [String? date]) async {
    final queryParams = <String, String>{};
    if (date != null && date.isNotEmpty) {
      queryParams['date'] = date;
    }

    try {
      final response = await _apiService.get<WeeklyForecastResponseDto>(
        '/api/v1/weather/weekly/by-city-name/$cityName',
        queryParams: queryParams.isNotEmpty ? queryParams : null,
        parser: (data) =>
            WeeklyForecastResponseDto.fromJson(data as Map<String, dynamic>),
      );
      return response;
    } on ApiException catch (e) {
      if (kDebugMode) {
        print('[WeatherService] getWeeklyForecastByCityName Error: $e');
      }
      rethrow;
    }
  }
}