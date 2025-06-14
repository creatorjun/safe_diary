import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import '../controllers/weather_controller.dart';
import '../models/weather_models.dart';
import '../theme/app_theme.dart';

class WeatherView extends GetView<WeatherController> {
  const WeatherView({super.key});

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

  String _getWeatherIllustrationPath(String? conditionCode) {
    return 'assets/weather/weather_clear.png';
  }

  String _getMoreSevereWeather(String? weatherAm, String? weatherPm) {
    const weatherSeverity = {
      'heavyrain': 10,
      'rain': 9,
      'heavysnow': 8,
      'snow': 7,
      'sleet': 6,
      'drizzle': 5,
      'foggy': 4,
      'windy': 3,
      'cloudy': 2,
      'partlycloudy': 1,
      'mostlycloudy': 1,
      'clear': 0,
      'mostlyclear': 0,
    };

    final severityAm = weatherSeverity[weatherAm?.toLowerCase()] ?? -1;
    final severityPm = weatherSeverity[weatherPm?.toLowerCase()] ?? -1;

    if (severityAm >= severityPm) {
      return weatherAm ?? 'clear';
    } else {
      return weatherPm ?? 'clear';
    }
  }

  void _showCitySelectionBottomSheet(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final AppTextStyles textStyles = theme.extension<AppTextStyles>()!;

    int selectedIndex =
    controller.availableCities.indexOf(controller.selectedCityName.value);
    if (selectedIndex == -1) {
      selectedIndex = 0;
    }

    final FixedExtentScrollController scrollController =
    FixedExtentScrollController(initialItem: selectedIndex);

    Get.bottomSheet(
      Container(
        height: 320,
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(16.0),
            topRight: Radius.circular(16.0),
          ),
        ),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 16.0),
              child: Text("지역 선택", style: textStyles.bodyLarge),
            ),
            const Divider(height: 1),
            Expanded(
              child: CupertinoPicker(
                scrollController: scrollController,
                itemExtent: 40,
                onSelectedItemChanged: (index) {
                  selectedIndex = index;
                },
                children: controller.availableCities
                    .map((city) => Center(
                  child: Text(
                    city,
                    style: textStyles.bodyLarge.copyWith(
                      color: theme.colorScheme.onSurface,
                    ),
                  ),
                ))
                    .toList(),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
              child: FilledButton(
                style: FilledButton.styleFrom(
                  minimumSize: const Size(double.infinity, 50),
                ),
                onPressed: () {
                  final selectedCity =
                  controller.availableCities[selectedIndex];
                  controller.changeCity(selectedCity);
                },
                child: const Text("선택"),
              ),
            ),
          ],
        ),
      ),
      backgroundColor: Colors.transparent,
    );
  }

  @override
  Widget build(BuildContext context) {
    final AppSpacing spacing = Theme.of(context).extension<AppSpacing>()!;

    return Obx(() {
      if (controller.isLoading.value && controller.weatherData.value == null) {
        return const Center(child: CircularProgressIndicator());
      }

      if (controller.weatherData.value == null) {
        return _buildErrorView(context);
      }

      final weather = controller.weatherData.value!;
      final allDailyForecasts = weather.dailyForecast;

      final now = DateTime.now();
      DailyWeatherForecastResponseDto? todayForecast;

      try {
        todayForecast = allDailyForecasts.firstWhere((f) {
          final forecastDate = DateTime.parse(f.date);
          return forecastDate.year == now.year &&
              forecastDate.month == now.month &&
              forecastDate.day == now.day;
        });
      } catch (e) {
        todayForecast =
        allDailyForecasts.isNotEmpty ? allDailyForecasts.first : null;
      }

      final futureForecasts = allDailyForecasts
          .where((f) => f.date != todayForecast?.date)
          .toList();

      return SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0),
          child: Column(
            children: [
              SizedBox(height: spacing.small),
              _buildCitySelectorHeader(context),
              if (weather.currentWeather != null && todayForecast != null)
                _buildModernCurrentWeather(
                    context, weather.currentWeather!, todayForecast),
              SizedBox(height: spacing.large),
              Expanded(
                child: RefreshIndicator(
                  onRefresh: () =>
                      controller.fetchWeather(controller.selectedCityName.value),
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.only(bottom: 80),
                    child: Column(
                      children: [
                        if (weather.hourlyForecast != null)
                          _buildHourlyForecast(context, weather.hourlyForecast!),
                        ...futureForecasts.map(
                                (forecast) => _buildDailyForecastCard(context, forecast))
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    });
  }

  Widget _buildCitySelectorHeader(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final ColorScheme colorScheme = theme.colorScheme;
    final AppTextStyles textStyles = theme.extension<AppTextStyles>()!;
    final AppSpacing spacing = theme.extension<AppSpacing>()!;

    return Center(
      child: InkWell(
        onTap: () => _showCitySelectionBottomSheet(context),
        borderRadius: BorderRadius.circular(8.0),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                controller.selectedCityName.value,
                style: textStyles.titleMedium.copyWith(color: colorScheme.onSurface),
              ),
              SizedBox(width: spacing.small),
              Icon(
                Icons.location_on_outlined,
                size: 20,
                color: colorScheme.onSurface.withAlpha(179),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildModernCurrentWeather(
      BuildContext context,
      CurrentWeatherResponseDto current,
      DailyWeatherForecastResponseDto today,
      ) {
    final ThemeData theme = Theme.of(context);
    final ColorScheme colorScheme = theme.colorScheme;
    final AppTextStyles textStyles = theme.extension<AppTextStyles>()!;
    final AppSpacing spacing = theme.extension<AppSpacing>()!;

    final String highTemp = today.maxTemp?.toStringAsFixed(0) ?? '--';
    final String lowTemp = today.minTemp?.toStringAsFixed(0) ?? '--';
    final String illustrationPath =
    _getWeatherIllustrationPath(current.conditionCode);

    return Opacity(
      opacity: 0.85,
      child: Container(
        width: double.infinity,
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/weather/card_back.png'),
            fit: BoxFit.fill,
          ),
        ),
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            Positioned(
              top: -30,
              right: -20,
              child: SizedBox(
                width: 180,
                height: 180,
                child: Image.asset(illustrationPath, fit: BoxFit.contain),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 20, 24, 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${current.temperature.toStringAsFixed(0)}°',
                    style: textStyles.titleLarge.copyWith(
                      fontSize: 64,
                      fontWeight: FontWeight.w300,
                      color: colorScheme.onPrimary,
                      height: 1.1,
                    ),
                  ),
                  SizedBox(height: spacing.small),
                  RichText(
                    text: TextSpan(
                      style: textStyles.bodyLarge
                          .copyWith(color: colorScheme.onPrimary.withAlpha(204)),
                      children: <TextSpan>[
                        const TextSpan(text: '최고 : '),
                        TextSpan(
                          text: '$highTemp°',
                          style: TextStyle(color: colorScheme.error),
                        ),
                        const TextSpan(text: '  최저 : '),
                        TextSpan(
                          text: '$lowTemp°',
                          style: TextStyle(color: colorScheme.primary.withRed(150).withGreen(150)),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.thermostat_outlined,
                        color: colorScheme.onPrimary.withAlpha(204),
                        size: 20,
                      ),
                      SizedBox(width: spacing.small),
                      Text(
                        '체감 온도 : ${current.apparentTemperature.toStringAsFixed(0)}°',
                        style: textStyles.bodyLarge
                            .copyWith(color: colorScheme.onPrimary),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Divider(color: colorScheme.onPrimary.withAlpha(77)),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _buildDetailItem(
                        context,
                        icon: Icons.air,
                        value: '${current.windSpeed.toStringAsFixed(1)}km/h',
                        label: '풍속',
                      ),
                      _buildDetailItem(
                        context,
                        icon: Icons.wb_sunny_outlined,
                        value: current.uvIndex.toString(),
                        label: '자외선',
                      ),
                      _buildDetailItem(
                        context,
                        icon: Icons.water_drop_outlined,
                        value: '${(current.humidity * 100).toInt()}%',
                        label: '습도',
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailItem(
      BuildContext context, {
        required IconData icon,
        required String value,
        required String label,
      }) {
    final ThemeData theme = Theme.of(context);
    final ColorScheme colorScheme = theme.colorScheme;
    final AppTextStyles textStyles = theme.extension<AppTextStyles>()!;

    return Column(
      children: [
        Icon(icon, color: colorScheme.onPrimary.withAlpha(230), size: 20),
        const SizedBox(height: 6),
        Text(
          value,
          style: textStyles.bodyMedium.copyWith(color: colorScheme.onPrimary),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: textStyles.bodyMedium.copyWith(
            fontSize: 12,
            color: colorScheme.onPrimary.withAlpha(179),
          ),
        ),
      ],
    );
  }

  Widget _buildHourlyForecast(
      BuildContext context,
      HourlyForecastResponseDto hourly,
      ) {
    final ThemeData theme = Theme.of(context);
    final ColorScheme colorScheme = theme.colorScheme;
    final AppTextStyles textStyles = theme.extension<AppTextStyles>()!;
    final AppSpacing spacing = theme.extension<AppSpacing>()!;

    if (hourly.summary == null || hourly.summary!.isEmpty) {
      return const SizedBox.shrink();
    }
    return Card(
      color: colorScheme.secondary.withAlpha(51),
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.hourglass_bottom,
                    color: colorScheme.onSurfaceVariant, size: 18),
                SizedBox(width: spacing.small),
                Text("시간별 예보 요약", style: textStyles.bodyLarge),
              ],
            ),
            SizedBox(height: spacing.small),
            Text(
              hourly.summary!,
              style: textStyles.bodyMedium
                  .copyWith(color: colorScheme.onSurfaceVariant, height: 1.5),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDailyForecastCard(
      BuildContext context,
      DailyWeatherForecastResponseDto day,
      ) {
    final ThemeData theme = Theme.of(context);
    final ColorScheme colorScheme = theme.colorScheme;
    final AppTextStyles textStyles = theme.extension<AppTextStyles>()!;
    final AppSpacing spacing = theme.extension<AppSpacing>()!;

    final String highTemp = day.maxTemp?.toStringAsFixed(0) ?? '--';
    final String lowTemp = day.minTemp?.toStringAsFixed(0) ?? '--';
    final String severeWeather =
    _getMoreSevereWeather(day.weatherAm, day.weatherPm);
    final String illustrationPath = _getWeatherIllustrationPath(severeWeather);

    DateTime date;
    String displayDate = "정보 없음";
    try {
      date = DateTime.parse(day.date);
      displayDate = DateFormat('M월 d일 EEEE', 'ko_KR').format(date);
    } catch (e) {
      //
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Opacity(
        opacity: 0.85,
        child: Card(
          child: SizedBox(
            width: double.infinity,
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                Positioned(
                  top: -20,
                  right: -15,
                  child: SizedBox(
                    width: 140,
                    height: 140,
                    child: Image.asset(illustrationPath, fit: BoxFit.contain),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(24, 20, 24, 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(displayDate, style: textStyles.bodyLarge),
                      SizedBox(height: spacing.small),
                      RichText(
                        text: TextSpan(
                          style: textStyles.titleMedium
                              .copyWith(color: colorScheme.onSurface),
                          children: <TextSpan>[
                            const TextSpan(text: 'H : '),
                            TextSpan(
                              text: '$highTemp°',
                              style: TextStyle(color: colorScheme.error),
                            ),
                            const TextSpan(text: '  L : '),
                            TextSpan(
                              text: '$lowTemp°',
                              style: TextStyle(color: colorScheme.primary.withRed(150).withGreen(150)),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: spacing.medium),
                      Text(
                        _getWeatherDescription(severeWeather),
                        style: textStyles.bodyLarge,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildErrorView(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final ColorScheme colorScheme = theme.colorScheme;
    final AppTextStyles textStyles = theme.extension<AppTextStyles>()!;
    final AppSpacing spacing = theme.extension<AppSpacing>()!;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.cloud_off_outlined,
                color: colorScheme.onSurfaceVariant, size: 48),
            SizedBox(height: spacing.medium),
            Text(
              "날씨 정보를 불러오는 데 실패했습니다.",
              style: textStyles.bodyLarge,
              textAlign: TextAlign.center,
            ),
            SizedBox(height: spacing.medium),
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