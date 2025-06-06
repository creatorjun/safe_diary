// lib/app/services/luck_service.dart

import 'package:flutter/foundation.dart';
import 'package:get/get.dart';

import '../models/luck_models.dart';
import 'api_service.dart';

class LuckService extends GetxService {
  final ApiService _apiService;
  LuckService(this._apiService);

  /// 오늘의 띠별 운세를 가져옵니다.
  Future<ZodiacLuckData> getTodaysLuck(String zodiacName) async {
    try {
      final response = await _apiService.get<ZodiacLuckData>(
        '/api/v1/luck/today/$zodiacName',
        parser: (data) =>
            ZodiacLuckData.fromJson(data as Map<String, dynamic>),
      );
      return response;
    } on ApiException catch (e) {
      if (kDebugMode) {
        print('[LuckService] getTodaysLuck Error: $e');
      }
      rethrow;
    }
  }
}