import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../models/weather_models.dart';
import '../services/weather_service.dart';
import '../services/secure_storage_service.dart';
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

  final Rx<WeeklyForecastResponseDto?> weeklyForecast =
      Rx<WeeklyForecastResponseDto?>(null);
  final RxBool isLoading = false.obs;

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

  Future<void> fetchWeeklyForecast(String cityName, {String? date}) async {
    isLoading.value = true;
    try {
      String targetDate;

      if (date == null) {
        targetDate = DateFormat('yyyy-MM-dd').format(DateTime.now());
      } else {
        targetDate = date;
      }

      final forecastData = await _weatherService.getWeeklyForecastByCityName(
        cityName,
        targetDate,
      );
      weeklyForecast.value = forecastData;
    } catch (e) {
      weeklyForecast.value = null;
      _errorController.handleError(
        e,
        userFriendlyMessage: '날씨 정보를 불러오는 데 실패했습니다.',
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
      fetchWeeklyForecast(newCityName);
      Get.back();
    } else if (selectedCityName.value == newCityName) {
      Get.back();
    }
  }
}
