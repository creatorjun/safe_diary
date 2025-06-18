// lib/app/services/anniversary_service.dart

import 'package:safe_diary/app/models/anniversary_dtos.dart';
import 'package:safe_diary/app/services/api_service.dart';

class AnniversaryService {
  final ApiService _apiService;

  AnniversaryService(this._apiService);

  /// 모든 기념일 목록을 조회합니다.
  Future<List<AnniversaryResponseDto>> getAnniversaries() async {
    return await _apiService.get<List<AnniversaryResponseDto>>(
      '/api/v1/anniversaries',
      parser: (data) => (data as List<dynamic>)
          .map((item) =>
          AnniversaryResponseDto.fromJson(item as Map<String, dynamic>))
          .toList(),
    );
  }

  /// 새로운 기념일을 생성합니다.
  Future<AnniversaryResponseDto> createAnniversary(
      AnniversaryCreateRequestDto request) async {
    return await _apiService.post<AnniversaryResponseDto>(
      '/api/v1/anniversaries',
      body: request.toJson(),
      parser: (data) =>
          AnniversaryResponseDto.fromJson(data as Map<String, dynamic>),
    );
  }

  /// 기존 기념일을 수정합니다.
  Future<AnniversaryResponseDto> updateAnniversary(
      String anniversaryId, AnniversaryUpdateRequestDto request) async {
    return await _apiService.put<AnniversaryResponseDto>(
      '/api/v1/anniversaries/$anniversaryId',
      body: request.toJson(),
      parser: (data) =>
          AnniversaryResponseDto.fromJson(data as Map<String, dynamic>),
    );
  }

  /// 특정 기념일을 삭제합니다.
  Future<void> deleteAnniversary(String anniversaryId) async {
    await _apiService.delete<void>(
      '/api/v1/anniversaries/$anniversaryId',
    );
  }
}