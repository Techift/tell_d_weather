import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../models/weather_model.dart';
import '../utils/weather_icons.dart';

class HourlyForecast extends StatelessWidget {
  const HourlyForecast({super.key, required this.forecast, this.now});

  final List<HourlyWeather> forecast;
  final DateTime? now;

  @override
  Widget build(BuildContext context) {
    final referenceTime = now ?? DateTime.now();
    final upcoming = forecast
        .where(
          (hour) =>
              hour.time != null && !hour.time!.isBefore(referenceTime),
        )
        .take(24)
        .toList();

    if (upcoming.isEmpty) {
      return const _EmptyForecast(message: 'Hourly forecast is unavailable.');
    }

    return SizedBox(
      height: 126,
      child: ListView.separated(
        key: const Key('hourly-forecast-list'),
        scrollDirection: Axis.horizontal,
        itemCount: upcoming.length,
        separatorBuilder: (context, index) => const SizedBox(width: 12),
        itemBuilder: (context, index) {
          final hour = upcoming[index];
          final time = hour.time!;
          return SizedBox(
            width: 76,
            child: Card(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 12),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      index == 0 ? 'Now' : DateFormat('ha').format(time),
                      style: Theme.of(context).textTheme.labelMedium?.copyWith(
                        color: const Color(0xFF778397),
                      ),
                    ),
                    Icon(
                      weatherDescription(hour.weatherCode).icon,
                      size: 22,
                      color: const Color(0xFF2563EB),
                    ),
                    Text(
                      hour.temperature == null
                          ? '--°'
                          : '${hour.temperature!.round()}°',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class _EmptyForecast extends StatelessWidget {
  const _EmptyForecast({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Text(message, style: const TextStyle(color: Color(0xFF778397))),
      ),
    );
  }
}
