// lib/app/controllers/weather_controller.dart

import 'package:get/get.dart';

import '../models/weather_models.dart';
import '../services/secure_storage_service.dart';
import '../services/weather_service.dart';
import '../utils/app_strings.dart';
import 'error_controller.dart';
import 'login_controller.dart';

class WeatherController extends GetxController {
  final WeatherService _weatherService;
  final LoginController _loginController;
  final SecureStorageService _secureStorageService;

  WeatherController(
      this._weatherService,
      this._loginController,
      this._secureStorageService,
      );

  ErrorController get _errorController => Get.find<ErrorController>();

  final Rx<WeatherResponseDto?> weatherData = Rx<WeatherResponseDto?>(null);
  final RxBool isLoading = false.obs;

  static const String _defaultCityName = "서울특별시";
  final RxString selectedCityName = _defaultCityName.obs;

  // 새로운 LocationConfig 기준으로 도시 리스트 업데이트
  final List<String> availableCities = [
    "서울특별시",
    "인천광역시",
    "경기도",
    "강원도",
    "충청북도",
    "충청남도",
    "전라북도",
    "전라남도",
    "경상북도",
    "경상남도",
    "부산광역시",
    "대구광역시",
    "광주광역시",
    "대전광역시",
    "울산광역시",
    "세종특별자치시",
    "제주특별자치도",
  ];

  // 새로운 LocationConfig 기준으로 좌표 정보 업데이트
  final Map<String, Map<String, double>> _cityCoordinates = {
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

  @override
  void onInit() {
    super.onInit();
    _loadSavedCityAndFetchWeather();

    ever(_loginController.isLoggedIn, (bool isLoggedIn) {
      if (isLoggedIn) {
        fetchWeather(selectedCityName.value);
      } else {
        weatherData.value = null;
      }
    });
  }

  Future<void> _loadSavedCityAndFetchWeather() async {
    String? savedCity = await _secureStorageService.getSelectedCity();
    // 저장된 도시가 새로운 리스트에 없으면 기본값으로 설정
    if (savedCity != null && availableCities.contains(savedCity)) {
      selectedCityName.value = savedCity;
    } else {
      selectedCityName.value = _defaultCityName;
    }

    if (_loginController.isLoggedIn.value) {
      fetchWeather(selectedCityName.value);
    }
  }

  Future<void> fetchWeather(String cityName) async {
    isLoading.value = true;
    final coordinates = _cityCoordinates[cityName];
    if (coordinates == null) {
      isLoading.value = false;
      _errorController.handleError(
        "선택된 도시에 대한 좌표 정보가 없습니다.",
        userFriendlyMessage: "날씨 정보를 조회할 수 없는 도시입니다.",
      );
      return;
    }

    try {
      final fetchedData = await _weatherService.getWeather(
        lat: coordinates['lat']!,
        lon: coordinates['lon']!,
      );
      weatherData.value = fetchedData;
    } catch (e) {
      weatherData.value = null;
      _errorController.handleError(
        e,
        userFriendlyMessage: AppStrings.weatherInfoError,
      );
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> changeCity(String newCityName) async {
    if (availableCities.contains(newCityName) &&
        selectedCityName.value != newCityName) {
      selectedCityName.value = newCityName;
      await _secureStorageService.saveSelectedCity(newCityName);
      Get.back();
      await fetchWeather(newCityName);
    } else if (selectedCityName.value == newCityName) {
      Get.back();
    }
  }
}