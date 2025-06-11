// lib/app/controllers/luck_controller.dart

import 'package:get/get.dart';

import '../models/luck_models.dart';
import '../services/luck_service.dart';
import '../services/secure_storage_service.dart';
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

  // API로부터 받은 모든 띠의 운세 정보를 저장하는 리스트
  final RxList<ZodiacLuckData> allZodiacLucks = <ZodiacLuckData>[].obs;

  // 현재 사용자가 선택한 띠의 운세 정보
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
        fetchTodaysLuck();
      } else {
        allZodiacLucks.clear();
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
      await fetchTodaysLuck();
    }
  }

  Future<void> fetchTodaysLuck() async {
    isLoading.value = true;
    try {
      final luckDataList = await _luckService.getTodaysLuck();
      allZodiacLucks.assignAll(luckDataList);
      _updateSelectedZodiac();
    } catch (e) {
      allZodiacLucks.clear();
      selectedZodiacLuck.value = null;
      _errorController.handleError(
        e,
        userFriendlyMessage: '운세 정보를 불러오는 데 실패했습니다.',
      );
    } finally {
      isLoading.value = false;
    }
  }

  void _updateSelectedZodiac() {
    if (allZodiacLucks.isEmpty) {
      selectedZodiacLuck.value = null;
      return;
    }
    try {
      selectedZodiacLuck.value = allZodiacLucks.firstWhere(
        (luck) => luck.zodiacName == selectedZodiacApiName.value,
      );
    } catch (e) {
      // 혹시 모를 예외 처리 (선택된 띠가 리스트에 없는 경우)
      selectedZodiacLuck.value = allZodiacLucks.first;
      selectedZodiacApiName.value = allZodiacLucks.first.zodiacName;
    }
  }

  Future<void> changeZodiacByDisplayName(String zodiacDisplayName) async {
    String? newApiName = zodiacNameMap[zodiacDisplayName];

    if (newApiName != null && selectedZodiacApiName.value != newApiName) {
      selectedZodiacApiName.value = newApiName;
      await _secureStorageService.saveSelectedZodiac(newApiName);
      _updateSelectedZodiac(); // API 호출 없이 내부 리스트에서 정보 업데이트
      Get.back();
    } else if (newApiName != null &&
        selectedZodiacApiName.value == newApiName) {
      Get.back();
    }
  }
}
