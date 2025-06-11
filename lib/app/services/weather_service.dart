// lib/app/services/weather_service.dart

import 'package:flutter/foundation.dart';
import 'package:get/get.dart';

import '../models/weather_models.dart';
import 'api_service.dart';

class WeatherService extends GetxService {
  final ApiService _apiService;

  WeatherService(this._apiService);

  /// 위도와 경도를 기준으로 종합적인 날씨 정보를 가져옵니다.
  Future<WeatherResponseDto> getWeather({
    required double lat,
    required double lon,
  }) async {
    final queryParams = <String, String>{
      'lat': lat.toString(),
      'lon': lon.toString(),
    };

    try {
      final response = await _apiService.get<WeatherResponseDto>(
        '/api/v1/weather', // 변경된 엔드포인트
        queryParams: queryParams,
        parser:
            (data) => WeatherResponseDto.fromJson(data as Map<String, dynamic>),
      );
      return response;
    } on ApiException catch (e) {
      if (kDebugMode) {
        print('[WeatherService] getWeather Error: $e');
      }
      rethrow;
    }
  }
}
