import 'package:get/get.dart';
import 'package:safe_diary/app/controllers/home_controller.dart';
import 'package:safe_diary/app/controllers/luck_controller.dart';
import 'package:safe_diary/app/controllers/weather_controller.dart';
import 'package:safe_diary/app/services/event_service.dart';
import 'package:safe_diary/app/services/holiday_service.dart';
import 'package:safe_diary/app/services/luck_service.dart';
import 'package:safe_diary/app/services/weather_service.dart';

class HomeBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<EventService>(() => EventService(Get.find()));
    Get.lazyPut<WeatherService>(() => WeatherService(Get.find()));
    Get.lazyPut<LuckService>(() => LuckService(Get.find()));
    Get.lazyPut<HolidayService>(() => HolidayService(Get.find(), Get.find()));

    Get.lazyPut<HomeController>(
          () => HomeController(Get.find(), Get.find(), Get.find(), Get.find()),
    );
    Get.lazyPut<WeatherController>(
          () => WeatherController(Get.find(), Get.find(), Get.find()),
    );
    Get.lazyPut<LuckController>(
          () => LuckController(Get.find(), Get.find(), Get.find()),
    );
  }
}