import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../models/weather_model.dart';
import '../utils/weather_icons.dart';

class WeeklyForecast extends StatelessWidget {
  const WeeklyForecast({super.key, required this.forecast});

  final List<DailyWeather> forecast;

  @override
  Widget build(BuildContext context) {
    if (forecast.isEmpty) {
      return const Card(
        child: Padding(
          padding: EdgeInsets.all(18),
          child: Text(
            '7-day forecast is unavailable.',
            style: TextStyle(color: Color(0xFF778397)),
          ),
        ),
      );
    }

    return Card(
      child: Column(
        children: [
          for (var index = 0; index < forecast.length; index++) ...[
            _ForecastRow(day: forecast[index], isToday: index == 0),
            if (index < forecast.length - 1)
              const Divider(height: 1, indent: 16, endIndent: 16),
          ],
        ],
      ),
    );
  }
}

class _ForecastRow extends StatelessWidget {
  const _ForecastRow({required this.day, required this.isToday});

  final DailyWeather day;
  final bool isToday;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
      child: Row(
        children: [
          Expanded(
            flex: 3,
            child: Text(
              isToday
                  ? 'Today'
                  : day.date == null
                  ? '—'
                  : DateFormat('EEEE').format(day.date!),
              style: Theme.of(
                context,
              ).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600),
            ),
          ),
          Expanded(
            flex: 2,
            child: Icon(
              weatherDescription(day.weatherCode).icon,
              size: 21,
              color: const Color(0xFF2563EB),
            ),
          ),
          Expanded(
            child: Text(
              _temperature(day.minimumTemperature),
              textAlign: TextAlign.right,
              style: const TextStyle(color: Color(0xFF778397)),
            ),
          ),
          const SizedBox(width: 18),
          Expanded(
            child: Text(
              _temperature(day.maximumTemperature),
              textAlign: TextAlign.right,
              style: const TextStyle(
                color: Color(0xFF172033),
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _temperature(double? temperature) =>
      temperature == null ? '--°' : '${temperature.round()}°';
}
