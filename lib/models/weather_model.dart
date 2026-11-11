class WeatherData {
  const WeatherData({
    required this.cityName,
    required this.country,
    required this.timeZone,
    required this.current,
    required this.hourly,
    required this.daily,
  });

  final String cityName;
  final String country;
  final String timeZone;
  final CurrentWeather current;
  final List<HourlyWeather> hourly;
  final List<DailyWeather> daily;

  factory WeatherData.fromJson(
    Map<String, dynamic> json, {
    required String cityName,
    required String country,
  }) {
    final currentJson = _asMap(json['current']);
    if (currentJson == null) {
      throw const FormatException('Current weather data is unavailable.');
    }

    final hourlyJson = _asMap(json['hourly']);
    final dailyJson = _asMap(json['daily']);

    return WeatherData(
      cityName: cityName,
      country: country,
      timeZone: json['timezone'] as String? ?? '',
      current: CurrentWeather.fromJson(currentJson),
      hourly: _parseForecast<HourlyWeather>(
        hourlyJson,
        (item) => HourlyWeather.fromJson(item),
      ),
      daily: _parseForecast<DailyWeather>(
        dailyJson,
        (item) => DailyWeather.fromJson(item),
      ),
    );
  }
}

class CurrentWeather {
  const CurrentWeather({
    required this.time,
    required this.temperature,
    required this.feelsLike,
    required this.humidity,
    required this.windSpeed,
    required this.weatherCode,
    required this.isDay,
  });

  final DateTime? time;
  final double? temperature;
  final double? feelsLike;
  final int? humidity;
  final double? windSpeed;
  final int? weatherCode;
  final bool isDay;

  factory CurrentWeather.fromJson(Map<String, dynamic> json) {
    return CurrentWeather(
      time: DateTime.tryParse(json['time'] as String? ?? ''),
      temperature: _asDouble(json['temperature_2m']),
      feelsLike: _asDouble(json['apparent_temperature']),
      humidity: _asInt(json['relative_humidity_2m']),
      windSpeed: _asDouble(json['wind_speed_10m']),
      weatherCode: _asInt(json['weather_code']),
      isDay: _asInt(json['is_day']) == 1,
    );
  }
}

class HourlyWeather {
  const HourlyWeather({
    required this.time,
    required this.temperature,
    required this.humidity,
    required this.precipitationProbability,
    required this.weatherCode,
  });

  final DateTime? time;
  final double? temperature;
  final int? humidity;
  final int? precipitationProbability;
  final int? weatherCode;

  factory HourlyWeather.fromJson(Map<String, dynamic> json) {
    return HourlyWeather(
      time: DateTime.tryParse(json['time'] as String? ?? ''),
      temperature: _asDouble(json['temperature_2m']),
      humidity: _asInt(json['relative_humidity_2m']),
      precipitationProbability: _asInt(json['precipitation_probability']),
      weatherCode: _asInt(json['weather_code']),
    );
  }
}

class DailyWeather {
  const DailyWeather({
    required this.date,
    required this.weatherCode,
    required this.minimumTemperature,
    required this.maximumTemperature,
    required this.sunrise,
    required this.sunset,
  });

  final DateTime? date;
  final int? weatherCode;
  final double? minimumTemperature;
  final double? maximumTemperature;
  final DateTime? sunrise;
  final DateTime? sunset;

  factory DailyWeather.fromJson(Map<String, dynamic> json) {
    return DailyWeather(
      date: DateTime.tryParse(json['time'] as String? ?? ''),
      weatherCode: _asInt(json['weather_code']),
      minimumTemperature: _asDouble(json['temperature_2m_min']),
      maximumTemperature: _asDouble(json['temperature_2m_max']),
      sunrise: DateTime.tryParse(json['sunrise'] as String? ?? ''),
      sunset: DateTime.tryParse(json['sunset'] as String? ?? ''),
    );
  }
}

List<T> _parseForecast<T>(
  Map<String, dynamic>? json,
  T Function(Map<String, dynamic>) parse,
) {
  if (json == null) return const [];

  final times = json['time'];
  if (times is! List) return const [];

  return List<T>.generate(times.length, (index) {
    final item = <String, dynamic>{'time': times[index]};
    for (final entry in json.entries) {
      if (entry.key == 'time' || entry.value is! List) continue;
      final values = entry.value as List;
      if (index < values.length) item[entry.key] = values[index];
    }
    return parse(item);
  }, growable: false);
}

Map<String, dynamic>? _asMap(Object? value) {
  return value is Map<String, dynamic> ? value : null;
}

double? _asDouble(Object? value) {
  return value is num ? value.toDouble() : null;
}

int? _asInt(Object? value) {
  return value is num ? value.toInt() : null;
}
