// lib/app/controllers/luck_controller.dart

import 'package:get/get.dart';

import '../models/luck_models.dart';
import '../services/luck_service.dart';
import '../services/secure_storage_service.dart';
import '../utils/app_strings.dart';
import 'error_controller.dart';
import 'login_controller.dart';

class LuckController extends GetxController {
  final LuckService _luckService;
  final LoginController _loginController;
  final SecureStorageService _secureStorageService;

  LuckController(
    this._luckService,
    this._loginController,
    this._secureStorageService,
  );

  ErrorController get _errorController => Get.find<ErrorController>();

  final Rx<ZodiacLuckData?> selectedZodiacLuck = Rx<ZodiacLuckData?>(null);
  final RxBool isLoading = false.obs;

  static const String _defaultZodiacApiName = "쥐띠";
  final RxString selectedZodiacApiName = _defaultZodiacApiName.obs;

  final Map<String, String> zodiacNameMap = {
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

  List<String> get availableZodiacsForDisplay => zodiacNameMap.keys.toList();

  String get currentSelectedZodiacDisplayName {
    return zodiacNameMap.entries
        .firstWhere(
          (entry) => entry.value == selectedZodiacApiName.value,
          orElse:
              () => MapEntry(
                availableZodiacsForDisplay.first,
                _defaultZodiacApiName,
              ),
        )
        .key;
  }

  @override
  void onInit() {
    super.onInit();
    _loadSavedZodiacAndFetchLuck();

    ever(_loginController.isLoggedIn, (bool isLoggedIn) {
      if (isLoggedIn) {
        fetchTodaysLuck(selectedZodiacApiName.value);
      } else {
        selectedZodiacLuck.value = null;
      }
    });
  }

  Future<void> _loadSavedZodiacAndFetchLuck() async {
    String? savedZodiacApiName =
        await _secureStorageService.getSelectedZodiac();
    if (savedZodiacApiName != null &&
        zodiacNameMap.containsValue(savedZodiacApiName)) {
      selectedZodiacApiName.value = savedZodiacApiName;
    } else {
      selectedZodiacApiName.value = _defaultZodiacApiName;
    }

    if (_loginController.isLoggedIn.value) {
      await fetchTodaysLuck(selectedZodiacApiName.value);
    }
  }

  Future<void> fetchTodaysLuck(String zodiacName) async {
    isLoading.value = true;
    try {
      final luckData = await _luckService.getTodaysLuck(zodiacName);
      selectedZodiacLuck.value = luckData;
    } catch (e) {
      selectedZodiacLuck.value = null;
      _errorController.handleError(
        e,
        userFriendlyMessage: AppStrings.luckInfoError,
      );
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> changeZodiacByDisplayName(String zodiacDisplayName) async {
    String? newApiName = zodiacNameMap[zodiacDisplayName];

    if (newApiName != null && selectedZodiacApiName.value != newApiName) {
      selectedZodiacApiName.value = newApiName;
      await _secureStorageService.saveSelectedZodiac(newApiName);
      Get.back();
      await fetchTodaysLuck(newApiName);
    } else if (selectedZodiacApiName.value == newApiName) {
      Get.back();
    }
  }
}
