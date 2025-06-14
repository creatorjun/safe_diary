// lib/app/utils/weather_utils.dart

import 'package:flutter/material.dart';

class WeatherUtils {
  // 이 클래스는 인스턴스화할 필요가 없으므로 private 생성자를 만듭니다.
  WeatherUtils._();

  static String getWeatherDescription(String conditionCode) {
    switch (conditionCode.toLowerCase()) {
      case 'clear':
      case 'mostlyclear':
        return '맑음';
      case 'partlycloudy':
      case 'mostlycloudy':
        return '구름 많음';
      case 'cloudy':
        return '흐림';
      case 'rain':
      case 'heavyrain':
        return '비';
      case 'snow':
      case 'heavysnow':
        return '눈';
      case 'sleet':
        return '진눈깨비';
      case 'drizzle':
        return '이슬비';
      case 'windy':
        return '바람 강함';
      case 'foggy':
        return '안개';
      case 'thunderstorm':
        return '뇌우';
      default:
        return conditionCode;
    }
  }

  static String getWeatherIllustrationPath(
    String? conditionCode, {
    required bool isDay,
  }) {
    final basePath = 'assets/weather/';
    switch (conditionCode?.toLowerCase()) {
      case 'thunderstorm':
        return '${basePath}thunder.png';

      case 'clear':
      case 'mostlyclear':
        return isDay ? '${basePath}sun.png' : '${basePath}moon.png';

      case 'partlycloudy':
      case 'mostlycloudy':
      case 'cloudy':
      case 'windy':
      case 'foggy':
        return isDay ? '${basePath}sun_cloud.png' : '${basePath}moon_cloud.png';

      case 'drizzle':
        return isDay ? '${basePath}sun_rain.png' : '${basePath}moon_rain.png';

      case 'rain':
      case 'heavyrain':
      case 'snow':
      case 'heavysnow':
      case 'sleet':
        return '${basePath}rain.png';

      default:
        return isDay ? '${basePath}sun.png' : '${basePath}moon.png';
    }
  }

  static String getMoreSevereWeather(String? weatherAm, String? weatherPm) {
    const weatherSeverity = {
      'thunderstorm': 11,
      'heavyrain': 10,
      'rain': 9,
      'heavysnow': 8,
      'snow': 7,
      'sleet': 6,
      'drizzle': 5,
      'foggy': 4,
      'windy': 3,
      'cloudy': 2,
      'partlycloudy': 1,
      'mostlycloudy': 1,
      'clear': 0,
      'mostlyclear': 0,
    };

    final severityAm = weatherSeverity[weatherAm?.toLowerCase()] ?? -1;
    final severityPm = weatherSeverity[weatherPm?.toLowerCase()] ?? -1;

    if (severityAm >= severityPm) {
      return weatherAm ?? 'clear';
    } else {
      return weatherPm ?? 'clear';
    }
  }

  // === 대기질 관련 유틸리티 함수 ===

  static Color getColorForGrade(String? grade) {
    switch (grade) {
      case '좋음':
        return Colors.blue.shade400;
      case '보통':
        return Colors.green.shade400;
      case '나쁨':
        return Colors.orange.shade400;
      case '매우나쁨':
        return Colors.red.shade400;
      default:
        return Colors.grey.shade400;
    }
  }

  static IconData getIconForGrade(String? grade) {
    switch (grade) {
      case '좋음':
        return Icons.sentiment_very_satisfied_outlined;
      case '보통':
        return Icons.sentiment_satisfied_outlined;
      case '나쁨':
        return Icons.sentiment_dissatisfied_outlined;
      case '매우나쁨':
        return Icons.sentiment_very_dissatisfied_outlined;
      default:
        return Icons.sentiment_neutral_outlined;
    }
  }
}
