// lib/app/services/api_service.dart

import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:safe_diary/app/config/app_config.dart';

// API 통신 과정에서 발생할 수 있는 커스텀 예외를 정의합니다.
class ApiException implements Exception {
  final String message;
  final int? statusCode;

  ApiException(this.message, {this.statusCode});

  @override
  String toString() => "ApiException: $message (Status code: $statusCode)";
}

// 401 Unauthorized 에러를 위한 특정 예외 클래스
class UnauthorizedException extends ApiException {
  UnauthorizedException(super.message) : super(statusCode: 401);
}

class ApiService extends GetxService {
  // LoginController에 대한 직접적인 의존성을 제거합니다.
  // final LoginController _loginController = Get.find<LoginController>();

  // 토큰을 제공하는 함수를 저장할 변수입니다.
  String? Function()? _tokenProvider;

  /// LoginController가 생성된 후, 토큰을 가져올 수 있는 함수를 등록합니다.
  void setTokenProvider(String? Function() provider) {
    _tokenProvider = provider;
  }

  String get _baseUrl {
    final url = AppConfig.apiUrl;
    if (url == null) {
      throw ApiException("API URL이 설정되지 않았습니다.");
    }
    return url;
  }

  Future<Map<String, String>> _getHeaders() async {
    final headers = {
      'Content-Type': 'application/json; charset=UTF-8',
      'Accept': 'application/json',
    };

    // 등록된 tokenProvider 함수를 호출하여 토큰을 가져옵니다.
    if (_tokenProvider != null) {
      final token = _tokenProvider!();
      if (token != null && token.isNotEmpty) {
        headers['Authorization'] = 'Bearer $token';
      }
    }
    return headers;
  }

  Future<T> get<T>(
    String endpoint, {
    Map<String, String>? queryParams,
    T Function(dynamic data)? parser,
  }) async {
    final url = Uri.parse(
      '$_baseUrl$endpoint',
    ).replace(queryParameters: queryParams);
    final headers = await _getHeaders();

    if (kDebugMode) print('ApiService GET: $url');

    final response = await http.get(url, headers: headers);
    return _handleResponse(response, parser: parser);
  }

  Future<T> post<T>(
    String endpoint, {
    dynamic body,
    Map<String, String>? queryParams,
    T Function(dynamic data)? parser,
  }) async {
    final url = Uri.parse(
      '$_baseUrl$endpoint',
    ).replace(queryParameters: queryParams);
    final headers = await _getHeaders();
    final encodedBody = json.encode(body);

    if (kDebugMode) print('ApiService POST: $url, Body: $encodedBody');

    final response = await http.post(url, headers: headers, body: encodedBody);
    return _handleResponse(response, parser: parser);
  }

  Future<T> put<T>(
    String endpoint, {
    dynamic body,
    Map<String, String>? queryParams,
    T Function(dynamic data)? parser,
  }) async {
    final url = Uri.parse(
      '$_baseUrl$endpoint',
    ).replace(queryParameters: queryParams);
    final headers = await _getHeaders();
    final encodedBody = json.encode(body);

    if (kDebugMode) print('ApiService PUT: $url, Body: $encodedBody');

    final response = await http.put(url, headers: headers, body: encodedBody);
    return _handleResponse(response, parser: parser);
  }

  Future<T> patch<T>(
    String endpoint, {
    dynamic body,
    Map<String, String>? queryParams,
    T Function(dynamic data)? parser,
  }) async {
    final url = Uri.parse(
      '$_baseUrl$endpoint',
    ).replace(queryParameters: queryParams);
    final headers = await _getHeaders();
    final encodedBody = json.encode(body);

    if (kDebugMode) print('ApiService PATCH: $url, Body: $encodedBody');

    final response = await http.patch(url, headers: headers, body: encodedBody);
    return _handleResponse(response, parser: parser);
  }

  Future<T> delete<T>(
    String endpoint, {
    dynamic body,
    Map<String, String>? queryParams,
    T Function(dynamic data)? parser,
  }) async {
    final url = Uri.parse(
      '$_baseUrl$endpoint',
    ).replace(queryParameters: queryParams);
    final headers = await _getHeaders();
    final request = http.Request('DELETE', url);
    request.headers.addAll(headers);

    if (body != null) {
      final encodedBody = json.encode(body);
      if (kDebugMode) print('ApiService DELETE: $url, Body: $encodedBody');
      request.body = encodedBody;
    } else {
      if (kDebugMode) print('ApiService DELETE: $url');
    }

    final streamedResponse = await request.send();
    final response = await http.Response.fromStream(streamedResponse);
    return _handleResponse(response, parser: parser);
  }

  T _handleResponse<T>(
    http.Response response, {
    T Function(dynamic data)? parser,
  }) {
    if (kDebugMode) {
      print(
        'ApiService Response: ${response.request?.method} ${response.request?.url}',
      );
      print('Status Code: ${response.statusCode}');
      try {
        print('Body: ${utf8.decode(response.bodyBytes)}');
      } catch (e) {
        print('Could not decode response body as UTF-8.');
      }
    }

    final dynamic decodedBody =
        (response.body.isNotEmpty)
            ? json.decode(utf8.decode(response.bodyBytes))
            : null;

    switch (response.statusCode) {
      case 200:
      case 201:
      case 204:
        return parser != null ? parser(decodedBody) : decodedBody as T;
      case 401:
        throw UnauthorizedException(
          decodedBody?['message'] ?? '인증에 실패했습니다. 다시 로그인해주세요.',
        );
      case 400:
      case 403:
      case 404:
      case 409:
        throw ApiException(
          decodedBody?['message'] ?? '잘못된 요청입니다.',
          statusCode: response.statusCode,
        );
      default:
        throw ApiException(
          '서버 오류가 발생했습니다. 잠시 후 다시 시도해주세요.',
          statusCode: response.statusCode,
        );
    }
  }
}
