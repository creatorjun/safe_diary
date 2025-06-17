// lib/app/config/data_constants.dart

class DataConstants {
  // private constructor
  DataConstants._();

  // WeatherController에서 사용할 도시 정보
  static const Map<String, Map<String, double>> cityCoordinates = {
    "서울특별시": {"lat": 37.56, "lon": 127.00},
    "인천광역시": {"lat": 37.45, "lon": 126.70},
    "경기도": {"lat": 37.29, "lon": 127.06},
    "강원도": {"lat": 37.99, "lon": 128.02},
    "충청북도": {"lat": 36.74, "lon": 127.83},
    "충청남도": {"lat": 36.36, "lon": 126.97},
    "전라북도": {"lat": 35.85, "lon": 127.05},
    "전라남도": {"lat": 34.95, "lon": 126.79},
    "경상북도": {"lat": 36.43, "lon": 128.58},
    "경상남도": {"lat": 35.50, "lon": 128.30},
    "부산광역시": {"lat": 35.10, "lon": 129.03},
    "대구광역시": {"lat": 35.82, "lon": 128.58},
    "광주광역시": {"lat": 35.16, "lon": 126.89},
    "대전광역시": {"lat": 36.33, "lon": 127.36},
    "울산광역시": {"lat": 35.53, "lon": 129.33},
    "세종특별자치시": {"lat": 36.48, "lon": 127.26},
    "제주특별자치도": {"lat": 33.36, "lon": 126.56},
  };

  static final List<String> availableCities = cityCoordinates.keys.toList();

  // LuckController에서 사용할 띠 정보
  static const Map<String, String> zodiacNameMap = {
    "자(쥐)": "쥐띠",
    "축(소)": "소띠",
    "인(호랑이)": "호랑이띠",
    "묘(토끼)": "토끼띠",
    "진(용)": "용띠",
    "사(뱀)": "뱀띠",
    "오(말)": "말띠",
    "미(양)": "양띠",
    "신(원숭이)": "원숭이띠",
    "유(닭)": "닭띠",
    "술(개)": "개띠",
    "해(돼지)": "돼지띠",
  };

  static final List<String> availableZodiacsForDisplay =
  zodiacNameMap.keys.toList();
}