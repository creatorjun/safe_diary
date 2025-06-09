// lib/app/controllers/weather_controller.dart

import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart'; // 날짜 포맷팅을 위해 추가
import '../models/weather_models.dart';
import '../services/weather_service.dart';
import '../services/secure_storage_service.dart';
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

  final Rx<WeeklyForecastResponseDto?> weeklyForecast =
      Rx<WeeklyForecastResponseDto?>(null);
  final RxBool isLoading = false.obs;
  final RxString errorMessage = ''.obs;

  static const String _defaultCityName = "서울";
  final RxString selectedCityName = _defaultCityName.obs;

  final List<String> availableCities = [
    "서울",
    "부산",
    "대구",
    "인천",
    "광주",
    "대전",
    "울산",
    "수원",
    "춘천",
    "강릉",
    "청주",
    "전주",
    "포항",
    "제주",
  ];

  @override
  void onInit() {
    super.onInit();
    _loadSavedCityAndFetchWeather();

    ever(_loginController.isLoggedIn, (bool isLoggedIn) {
      if (isLoggedIn) {
        fetchWeeklyForecast(selectedCityName.value);
      } else {
        weeklyForecast.value = null;
        errorMessage.value = '';
      }
    });
  }

  Future<void> _loadSavedCityAndFetchWeather() async {
    String? savedCity = await _secureStorageService.getSelectedCity();
    selectedCityName.value = savedCity ?? _defaultCityName;

    if (_loginController.isLoggedIn.value) {
      fetchWeeklyForecast(selectedCityName.value);
    }
  }

  // 날짜 요청 로직 수정
  Future<void> fetchWeeklyForecast(String cityName, {String? date}) async {
    isLoading.value = true;
    errorMessage.value = '';
    try {
      String targetDate;

      // date 파라미터가 명시적으로 주어지지 않은 경우에만 시간 기반으로 날짜 계산
      if (date == null) {
        final now = DateTime.now();
        // 현재 시간이 오전 7시 이전이면, 어제 날짜를 기준으로 요청
        final dateToRequest =
            (now.hour < 7) ? now.subtract(const Duration(days: 1)) : now;
        targetDate = DateFormat('yyyy-MM-dd').format(dateToRequest);
      } else {
        targetDate = date;
      }

      if (kDebugMode) {
        print(
          '[WeatherController] Requesting weather for $cityName on date: $targetDate',
        );
      }

      final forecastData = await _weatherService.getWeeklyForecastByCityName(
        cityName,
        targetDate,
      );
      weeklyForecast.value = forecastData;
    } catch (e) {
      errorMessage.value = e.toString();
      if (kDebugMode) {
        print(
          '[WeatherController] Error fetching weekly forecast for $cityName: $e',
        );
      }
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> changeCity(String newCityName) async {
    if (availableCities.contains(newCityName) &&
        selectedCityName.value != newCityName) {
      selectedCityName.value = newCityName;
      await _secureStorageService.saveSelectedCity(newCityName);
      // 도시 변경 시에도 수정된 날짜 로직에 따라 날씨 정보 요청
      fetchWeeklyForecast(newCityName);
      Get.back();
    } else if (selectedCityName.value == newCityName) {
      Get.back();
    }
  }
}
