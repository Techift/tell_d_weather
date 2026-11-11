import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../models/weather_model.dart';
import '../utils/weather_icons.dart';

class CurrentWeatherCard extends StatelessWidget {
  const CurrentWeatherCard({super.key, required this.weather});

  final WeatherData weather;

  @override
  Widget build(BuildContext context) {
    final current = weather.current;
    final description = weatherDescription(
      current.weatherCode,
      isDay: current.isDay,
    );
    final updatedAt = current.time == null
        ? null
        : DateFormat('EEEE, h:mm a').format(current.time!);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.location_on_outlined, color: Color(0xFF2563EB)),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    weather.country.isEmpty
                        ? weather.cityName
                        : '${weather.cityName}, ${weather.country}',
                    key: const Key('selected-city'),
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w700,
                      color: const Color(0xFF172033),
                    ),
                  ),
                ),
              ],
            ),
            if (updatedAt != null) ...[
              const SizedBox(height: 4),
              Text(
                'Updated $updatedAt',
                style: Theme.of(
                  context,
                ).textTheme.bodySmall?.copyWith(color: const Color(0xFF778397)),
              ),
            ],
            const SizedBox(height: 20),
            LayoutBuilder(
              builder: (context, constraints) {
                final compact = constraints.maxWidth < 360;
                final weatherVisual = Column(
                  crossAxisAlignment: compact
                      ? CrossAxisAlignment.center
                      : CrossAxisAlignment.start,
                  children: [
                    Icon(
                      description.icon,
                      size: 64,
                      color: const Color(0xFF2563EB),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      description.label,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: const Color(0xFF475569),
                      ),
                    ),
                  ],
                );
                final temperature = Text(
                  current.temperature == null
                      ? '--°'
                      : '${current.temperature!.round()}°',
                  key: const Key('current-temperature'),
                  style: Theme.of(context).textTheme.displayLarge?.copyWith(
                    fontSize: 76,
                    height: 1,
                    fontWeight: FontWeight.w700,
                    letterSpacing: -4,
                    color: const Color(0xFF172033),
                  ),
                );

                if (compact) {
                  return Column(
                    children: [weatherVisual, const SizedBox(height: 16), temperature],
                  );
                }

                return Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    weatherVisual,
                    Flexible(child: temperature),
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
