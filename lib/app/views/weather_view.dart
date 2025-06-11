// lib/app/views/weather_view.dart

import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import '../controllers/weather_controller.dart';
import '../models/weather_models.dart';
import '../theme/app_spacing.dart';
import '../theme/app_text_styles.dart';

class WeatherView extends GetView<WeatherController> {
  const WeatherView({super.key});

  // 날씨 코드에 따른 한글 설명 매핑
  String _getWeatherDescription(String conditionCode) {
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
      default:
        return conditionCode;
    }
  }

  // 날씨 코드에 따른 아이콘 매핑
  IconData _getWeatherIcon(String conditionCode) {
    switch (conditionCode.toLowerCase()) {
      case 'clear':
      case 'mostlyclear':
        return Icons.wb_sunny_outlined;
      case 'partlycloudy':
      case 'mostlycloudy':
        return Icons.cloud_outlined;
      case 'cloudy':
        return Icons.wb_cloudy_outlined;
      case 'rain':
      case 'heavyrain':
      case 'drizzle':
        return Icons.umbrella_outlined;
      case 'snow':
      case 'heavysnow':
      case 'sleet':
        return Icons.ac_unit_outlined;
      case 'windy':
        return Icons.air_outlined;
      case 'foggy':
        return Icons.dehaze_rounded;
      default:
        return Icons.help_outline_rounded;
    }
  }

  // 날씨 상태에 따른 배경 이미지 선택
  String _getBackgroundImagePath(String? conditionCode) {
    switch (conditionCode?.toLowerCase()) {
      case 'rain':
      case 'heavyrain':
      case 'sleet':
      case 'drizzle':
        return 'assets/weather/weather5.png'; // 비
      case 'snow':
      case 'heavysnow':
        return 'assets/weather/weather6.png'; // 눈
      case 'cloudy':
        return 'assets/weather/weather3.png'; // 흐림
      case 'partlycloudy':
      case 'mostlycloudy':
        return 'assets/weather/weather2.png'; // 구름 많음
      case 'clear':
      case 'mostlyclear':
        return 'assets/weather/weather1.png'; // 맑음
      default:
        return 'assets/weather/weather1.png'; // 기본 맑음
    }
  }

  // 도시 선택 BottomSheet
  void _showCitySelectionBottomSheet(BuildContext context) {
    Get.bottomSheet(
      Container(
        decoration: BoxDecoration(
          color: Theme.of(context).canvasColor,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(16.0),
            topRight: Radius.circular(16.0),
          ),
        ),
        child: SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 16.0),
                child: Text(
                  "지역 선택",
                  style: textStyleMedium.copyWith(fontWeight: FontWeight.bold),
                ),
              ),
              const Divider(height: 1),
              LimitedBox(
                maxHeight: MediaQuery.of(context).size.height * 0.5,
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: controller.availableCities.length,
                  itemBuilder: (BuildContext context, int index) {
                    final String city = controller.availableCities[index];
                    bool isSelected = city == controller.selectedCityName.value;
                    return ListTile(
                      title: Text(
                        city,
                        style: textStyleSmall.copyWith(
                          fontWeight:
                              isSelected ? FontWeight.w600 : FontWeight.normal,
                        ),
                      ),
                      trailing:
                          isSelected
                              ? Icon(
                                Icons.check_circle_outline_rounded,
                                color: Theme.of(context).primaryColor,
                                size: 22,
                              )
                              : null,
                      onTap: () => controller.changeCity(city),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 24.0,
                        vertical: 4.0,
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
      isScrollControlled: true,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: const SizedBox.shrink(),
        // AppBar의 기본 타이틀 공간을 없애기 위해 추가
        flexibleSpace: FlexibleSpaceBar(
          title: GestureDetector(
            onTap: () => _showCitySelectionBottomSheet(context),
            child: Obx(
              () => Row(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    controller.selectedCityName.value,
                    style: textStyleLarge.copyWith(
                      color: Colors.white,
                      shadows: [
                        const Shadow(
                          blurRadius: 4.0,
                          color: Colors.black54,
                          offset: Offset(1, 1),
                        ),
                      ],
                    ),
                  ),
                  horizontalSpaceSmall,
                  const Icon(
                    Icons.edit_location_alt_outlined,
                    color: Colors.white70,
                    size: 20,
                  ),
                ],
              ),
            ),
          ),
          centerTitle: true,
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.white, size: 28),
            tooltip: "새로고침",
            onPressed:
                () =>
                    controller.fetchWeather(controller.selectedCityName.value),
          ),
        ],
      ),
      body: Obx(() {
        if (controller.isLoading.value &&
            controller.weatherData.value == null) {
          return const Center(child: CircularProgressIndicator());
        }

        if (controller.weatherData.value == null) {
          return _buildErrorView(context);
        }

        final weather = controller.weatherData.value!;
        final String backgroundImagePath = _getBackgroundImagePath(
          weather.currentWeather?.conditionCode,
        );

        return Stack(
          fit: StackFit.expand,
          children: [
            Image.asset(backgroundImagePath, fit: BoxFit.cover),
            Container(color: Colors.black.withOpacity(0.25)), // 어두운 오버레이
            SafeArea(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20.0),
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      const SizedBox(height: 60), // AppBar 공간 확보
                      if (weather.currentWeather != null)
                        _buildCurrentWeather(context, weather.currentWeather!),
                      if (weather.hourlyForecast != null)
                        _buildHourlyForecast(context, weather.hourlyForecast!),
                      if (weather.dailyForecast.isNotEmpty)
                        _buildDailyForecastSection(
                          context,
                          weather.dailyForecast,
                        ),
                      const SizedBox(height: 20),
                    ],
                  ),
                ),
              ),
            ),
          ],
        );
      }),
    );
  }

  // 현재 날씨 정보 위젯
  Widget _buildCurrentWeather(
    BuildContext context,
    CurrentWeatherResponseDto current,
  ) {
    return Column(
      children: [
        verticalSpaceLarge,
        Text(
          _getWeatherDescription(current.conditionCode),
          style: textStyleLarge.copyWith(color: Colors.white, fontSize: 24),
        ),
        Text(
          '${current.temperature.toStringAsFixed(1)}°',
          style: const TextStyle(
            fontSize: 80,
            fontWeight: FontWeight.bold,
            color: Colors.white,
            shadows: [
              Shadow(
                blurRadius: 6.0,
                color: Colors.black54,
                offset: Offset(2, 2),
              ),
            ],
          ),
        ),
        Text(
          '체감온도 ${current.apparentTemperature.toStringAsFixed(1)}°',
          style: textStyleSmall.copyWith(color: Colors.white70),
        ),
        verticalSpaceMedium,
        _buildWeatherDetailRow(context, [
          DetailItem(
            icon: Icons.water_drop_outlined,
            label: "습도",
            value: "${(current.humidity * 100).toInt()}%",
          ),
          DetailItem(
            icon: Icons.air,
            label: "풍속",
            value: "${current.windSpeed.toStringAsFixed(1)} km/h",
          ),
          DetailItem(
            icon: Icons.wb_sunny,
            label: "자외선",
            value: "${current.uvIndex}",
          ),
        ]),
        verticalSpaceMedium,
      ],
    );
  }

  // 시간별 예보 위젯
  Widget _buildHourlyForecast(
    BuildContext context,
    HourlyForecastResponseDto hourly,
  ) {
    if (hourly.summary == null || hourly.summary!.isEmpty) {
      return const SizedBox.shrink();
    }
    return ClipRRect(
      borderRadius: BorderRadius.circular(12.0),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
        child: Container(
          padding: const EdgeInsets.all(16.0),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.15),
            borderRadius: BorderRadius.circular(12.0),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(
                    Icons.hourglass_bottom,
                    color: Colors.white70,
                    size: 18,
                  ),
                  horizontalSpaceSmall,
                  Text(
                    "시간별 예보 요약",
                    style: textStyleMedium.copyWith(color: Colors.white),
                  ),
                ],
              ),
              verticalSpaceSmall,
              Text(
                hourly.summary!,
                style: textStyleSmall.copyWith(
                  color: Colors.white.withOpacity(0.9),
                  height: 1.5,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // 일일 예보 섹션 (PageView)
  Widget _buildDailyForecastSection(
    BuildContext context,
    List<DailyWeatherForecastResponseDto> daily,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        verticalSpaceLarge,
        Padding(
          padding: const EdgeInsets.only(left: 4.0, bottom: 8.0),
          child: Text(
            '일일 예보',
            style: textStyleMedium.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        SizedBox(
          height: 180, // PageView 높이 고정
          child: PageView.builder(
            itemCount: daily.length,
            controller: PageController(viewportFraction: 0.9), // 양 옆 살짝 보이게
            itemBuilder: (context, index) {
              return _buildDailyForecastCard(context, daily[index]);
            },
          ),
        ),
      ],
    );
  }

  // 일일 예보 카드
  Widget _buildDailyForecastCard(
    BuildContext context,
    DailyWeatherForecastResponseDto day,
  ) {
    DateTime date;
    String displayDate = "정보 없음";
    try {
      date = DateTime.parse(day.date);
      displayDate = DateFormat('M월 d일 (E)', 'ko_KR').format(date);
    } catch (e) {
      // 파싱 실패
    }

    return Card(
      color: Colors.white.withOpacity(0.2),
      elevation: 0,
      margin: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15.0)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              displayDate,
              style: textStyleMedium.copyWith(color: Colors.white),
            ),
            verticalSpaceMedium,
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _tempColumn('최저', day.minTemp, Colors.lightBlueAccent),
                _tempColumn('최고', day.maxTemp, Colors.orangeAccent),
              ],
            ),
            const Spacer(),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _weatherCondition(
                  '오전',
                  day.weatherAm,
                  _getWeatherIcon(day.weatherAm ?? ''),
                ),
                _weatherCondition(
                  '오후',
                  day.weatherPm,
                  _getWeatherIcon(day.weatherPm ?? ''),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _tempColumn(String label, double? temp, Color color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: textStyleSmall.copyWith(color: Colors.white70)),
        Text(
          temp != null ? '${temp.toStringAsFixed(1)}°' : '-',
          style: textStyleLarge.copyWith(color: color, fontSize: 22),
        ),
      ],
    );
  }

  Widget _weatherCondition(String label, String? condition, IconData icon) {
    return Column(
      children: [
        Icon(icon, color: Colors.white),
        verticalSpaceSmall,
        Text(
          _getWeatherDescription(condition ?? ''),
          style: textStyleSmall.copyWith(color: Colors.white70),
        ),
      ],
    );
  }

  // 세부 날씨 정보 행 위젯
  Widget _buildWeatherDetailRow(BuildContext context, List<DetailItem> items) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(12.0),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12.0),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.15),
            borderRadius: BorderRadius.circular(12.0),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children:
                items.map((item) {
                  return Column(
                    children: [
                      Icon(item.icon, color: Colors.white70, size: 24),
                      verticalSpaceSmall,
                      Text(
                        item.value,
                        style: textStyleMedium.copyWith(color: Colors.white),
                      ),
                      Text(
                        item.label,
                        style: textStyleSmall.copyWith(color: Colors.white70),
                      ),
                    ],
                  );
                }).toList(),
          ),
        ),
      ),
    );
  }

  Widget _buildErrorView(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.cloud_off_outlined,
              color: Colors.white70,
              size: 48,
            ),
            verticalSpaceMedium,
            Text(
              "날씨 정보를 불러오는 데 실패했습니다.",
              style: textStyleMedium.copyWith(color: Colors.white),
              textAlign: TextAlign.center,
            ),
            verticalSpaceMedium,
            ElevatedButton.icon(
              icon: const Icon(Icons.refresh),
              label: const Text("다시 시도"),
              onPressed: () {
                controller.fetchWeather(controller.selectedCityName.value);
              },
            ),
          ],
        ),
      ),
    );
  }
}

// 세부 날씨 항목 데이터 클래스
class DetailItem {
  final IconData icon;
  final String label;
  final String value;

  DetailItem({required this.icon, required this.label, required this.value});
}
