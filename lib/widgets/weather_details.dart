import 'package:flutter/material.dart';

import '../models/weather_model.dart';

class WeatherDetails extends StatelessWidget {
  const WeatherDetails({super.key, required this.current});

  final CurrentWeather current;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _DetailCard(
            icon: Icons.device_thermostat_rounded,
            label: 'Feels like',
            value: _temperature(current.feelsLike),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _DetailCard(
            icon: Icons.water_drop_outlined,
            label: 'Humidity',
            value: current.humidity == null ? '--' : '${current.humidity}%',
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _DetailCard(
            icon: Icons.air_rounded,
            label: 'Wind',
            value: current.windSpeed == null
                ? '--'
                : '${current.windSpeed!.round()} km/h',
          ),
        ),
      ],
    );
  }

  String _temperature(double? temperature) =>
      temperature == null ? '--°' : '${temperature.round()}°';
}

class _DetailCard extends StatelessWidget {
  const _DetailCard({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, size: 20, color: const Color(0xFF2563EB)),
            const SizedBox(height: 12),
            Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(
                context,
              ).textTheme.bodySmall?.copyWith(color: const Color(0xFF778397)),
            ),
            const SizedBox(height: 4),
            FittedBox(
              fit: BoxFit.scaleDown,
              alignment: Alignment.centerLeft,
              child: Text(
                value,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFF172033),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
