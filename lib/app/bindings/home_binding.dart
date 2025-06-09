// lib/app/bindings/home_binding.dart

import 'package:get/get.dart';
import 'package:safe_diary/app/controllers/home_controller.dart';
import 'package:safe_diary/app/controllers/luck_controller.dart';
import 'package:safe_diary/app/controllers/weather_controller.dart';
import 'package:safe_diary/app/services/event_service.dart';
import 'package:safe_diary/app/services/luck_service.dart';
import 'package:safe_diary/app/services/weather_service.dart';

class HomeBinding extends Bindings {
  @override
  void dependencies() {
    // 1. 이 화면에서 필요한 서비스들을 등록하고, 필요한 의존성(ApiService)을 주입합니다.
    // lazyPut을 사용하여 이 화면에 진입할 때만 인스턴스가 생성되도록 합니다.
    Get.lazyPut<EventService>(() => EventService(Get.find()));
    Get.lazyPut<WeatherService>(() => WeatherService(Get.find()));
    Get.lazyPut<LuckService>(() => LuckService(Get.find()));

    // 2. 컨트롤러들을 등록하고, 필요한 서비스와 다른 컨트롤러를 주입합니다.
    Get.lazyPut<HomeController>(() => HomeController(Get.find(), Get.find()));
    Get.lazyPut<WeatherController>(
      () => WeatherController(Get.find(), Get.find(), Get.find()),
    );
    Get.lazyPut<LuckController>(
      () => LuckController(Get.find(), Get.find(), Get.find()),
    );
  }
}
