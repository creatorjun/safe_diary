// lib/app/controllers/weather_controller.dart

import 'package:get/get.dart';
import 'package:safe_diary/app/config/data_constants.dart';

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

  List<String> get availableCities => DataConstants.availableCities;

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
    final coordinates = DataConstants.cityCoordinates[cityName];
    if (coordinates == null) {
      isLoading.value = false;
      _errorController.handleError(
        "선택된 도시에 대한 좌표 정보가 없습니다.",
        userFriendlyMessage: AppStrings.noCoordinatesForCityError,
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