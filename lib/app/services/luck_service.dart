// lib/app/services/luck_service.dart

import 'package:flutter/foundation.dart';
import 'package:get/get.dart';

import '../models/luck_models.dart';
import 'api_service.dart';

class LuckService extends GetxService {
  final ApiService _apiService;

  LuckService(this._apiService);

  /// 오늘의 모든 띠별 운세를 리스트로 가져옵니다.
  Future<List<ZodiacLuckData>> getTodaysLuck() async {
    try {
      final response = await _apiService.get<List<ZodiacLuckData>>(
        '/api/v1/luck', // 변경된 엔드포인트
        parser:
            (data) =>
                (data as List<dynamic>)
                    .map(
                      (item) =>
                          ZodiacLuckData.fromJson(item as Map<String, dynamic>),
                    )
                    .toList(),
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
