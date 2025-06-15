// lib/app/models/weather_models.dart

class WeatherResponseDto {
  final CurrentWeatherResponseDto? currentWeather;
  final HourlyForecastResponseDto? hourlyForecast;
  final List<DailyWeatherForecastResponseDto> dailyForecast;

  WeatherResponseDto({
    this.currentWeather,
    this.hourlyForecast,
    required this.dailyForecast,
  });

  factory WeatherResponseDto.fromJson(Map<String, dynamic> json) {
    return WeatherResponseDto(
      currentWeather:
          json['currentWeather'] != null
              ? CurrentWeatherResponseDto.fromJson(
                json['currentWeather'] as Map<String, dynamic>,
              )
              : null,
      hourlyForecast:
          json['hourlyForecast'] != null
              ? HourlyForecastResponseDto.fromJson(
                json['hourlyForecast'] as Map<String, dynamic>,
              )
              : null,
      dailyForecast:
          (json['dailyForecast'] as List<dynamic>?)
              ?.map(
                (e) => DailyWeatherForecastResponseDto.fromJson(
                  e as Map<String, dynamic>,
                ),
              )
              .toList() ??
          [],
    );
  }

  @override
  String toString() {
    return 'WeatherResponseDto(currentWeather: $currentWeather, hourlyForecast: $hourlyForecast, dailyForecast: $dailyForecast)';
  }
}

class CurrentWeatherResponseDto {
  final String measuredAt;
  final double temperature;
  final double apparentTemperature;
  final String conditionCode;
  final double humidity;
  final double windSpeed;
  final int uvIndex;
  final String? pm10Grade;
  final String? pm25Grade;

  CurrentWeatherResponseDto({
    required this.measuredAt,
    required this.temperature,
    required this.apparentTemperature,
    required this.conditionCode,
    required this.humidity,
    required this.windSpeed,
    required this.uvIndex,
    this.pm10Grade,
    this.pm25Grade,
  });

  factory CurrentWeatherResponseDto.fromJson(Map<String, dynamic> json) {
    return CurrentWeatherResponseDto(
      measuredAt: json['measuredAt'] as String? ?? '',
      temperature: (json['temperature'] as num?)?.toDouble() ?? 0.0,
      apparentTemperature:
          (json['apparentTemperature'] as num?)?.toDouble() ?? 0.0,
      conditionCode: json['conditionCode'] as String? ?? 'Unknown',
      humidity: (json['humidity'] as num?)?.toDouble() ?? 0.0,
      windSpeed: (json['windSpeed'] as num?)?.toDouble() ?? 0.0,
      uvIndex: json['uvIndex'] as int? ?? 0,
      pm10Grade: json['pm10Grade'] as String?,
      pm25Grade: json['pm25Grade'] as String?,
    );
  }
}

class HourlyForecastResponseDto {
  final String? summary;
  final String forecastExpireTime;
  final List<MinuteForecastDto> minutes;

  HourlyForecastResponseDto({
    this.summary,
    required this.forecastExpireTime,
    required this.minutes,
  });

  factory HourlyForecastResponseDto.fromJson(Map<String, dynamic> json) {
    return HourlyForecastResponseDto(
      summary: json['summary'] as String?,
      forecastExpireTime: json['forecastExpireTime'] as String? ?? '',
      minutes:
          (json['minutes'] as List<dynamic>?)
              ?.map(
                (e) => MinuteForecastDto.fromJson(e as Map<String, dynamic>),
              )
              .toList() ??
          [],
    );
  }
}

class MinuteForecastDto {
  final String startTime;
  final double precipitationChance;
  final double precipitationIntensity;

  MinuteForecastDto({
    required this.startTime,
    required this.precipitationChance,
    required this.precipitationIntensity,
  });

  factory MinuteForecastDto.fromJson(Map<String, dynamic> json) {
    return MinuteForecastDto(
      startTime: json['startTime'] as String? ?? '',
      precipitationChance:
          (json['precipitationChance'] as num?)?.toDouble() ?? 0.0,
      precipitationIntensity:
          (json['precipitationIntensity'] as num?)?.toDouble() ?? 0.0,
    );
  }
}

class DailyWeatherForecastResponseDto {
  final String date;
  final double? minTemp;
  final double? maxTemp;
  final String? weatherAm;
  final String? weatherPm;
  final double? rainProb;
  final double? humidity;
  final double? windSpeed;
  final int? uvIndex;
  final String? sunrise;
  final String? sunset;

  DailyWeatherForecastResponseDto({
    required this.date,
    this.minTemp,
    this.maxTemp,
    this.weatherAm,
    this.weatherPm,
    this.rainProb,
    this.humidity,
    this.windSpeed,
    this.uvIndex,
    this.sunrise,
    this.sunset,
  });

  factory DailyWeatherForecastResponseDto.fromJson(Map<String, dynamic> json) {
    return DailyWeatherForecastResponseDto(
      date: json['date'] as String? ?? '',
      minTemp: (json['minTemp'] as num?)?.toDouble(),
      maxTemp: (json['maxTemp'] as num?)?.toDouble(),
      weatherAm: json['weatherAm'] as String?,
      weatherPm: json['weatherPm'] as String?,
      rainProb: (json['rainProb'] as num?)?.toDouble(),
      humidity: (json['humidity'] as num?)?.toDouble(),
      windSpeed: (json['windSpeed'] as num?)?.toDouble(),
      uvIndex: json['uvIndex'] as int?,
      sunrise: json['sunrise'] as String?,
      sunset: json['sunset'] as String?,
    );
  }
}
