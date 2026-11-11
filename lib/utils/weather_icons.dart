import 'package:flutter/material.dart';

class WeatherDescription {
  const WeatherDescription(this.label, this.icon);

  final String label;
  final IconData icon;
}

WeatherDescription weatherDescription(int? code, {bool isDay = true}) {
  return switch (code) {
    0 => WeatherDescription(
      'Clear sky',
      isDay ? Icons.wb_sunny_rounded : Icons.nightlight_round,
    ),
    1 => WeatherDescription(
      'Mainly clear',
      isDay ? Icons.wb_sunny_outlined : Icons.nightlight_round,
    ),
    2 => WeatherDescription('Partly cloudy', Icons.cloud_queue_rounded),
    3 => WeatherDescription('Overcast', Icons.cloud_rounded),
    45 || 48 => WeatherDescription('Foggy', Icons.foggy),
    51 || 53 || 55 || 56 || 57 => WeatherDescription(
      'Drizzle',
      Icons.grain_rounded,
    ),
    61 || 63 || 65 || 66 || 67 => WeatherDescription(
      'Rain',
      Icons.water_drop_rounded,
    ),
    71 || 73 || 75 || 77 || 85 || 86 => WeatherDescription(
      'Snow',
      Icons.ac_unit_rounded,
    ),
    80 || 81 || 82 => WeatherDescription('Rain showers', Icons.beach_access),
    95 || 96 || 99 => WeatherDescription(
      'Thunderstorm',
      Icons.thunderstorm_rounded,
    ),
    _ => WeatherDescription('Weather unavailable', Icons.cloud_queue_rounded),
  };
}
