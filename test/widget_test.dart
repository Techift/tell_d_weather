import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:flutter/material.dart';
import 'package:tell_d_weather/screens/home_screen.dart';
import 'package:tell_d_weather/services/weather_service.dart';
import 'package:tell_d_weather/utils/weather_icons.dart';

void main() {
  test('weather codes map to readable conditions', () {
    expect(weatherDescription(0).label, 'Clear sky');
    expect(weatherDescription(61).label, 'Rain');
    expect(weatherDescription(95).label, 'Thunderstorm');
  });

  testWidgets('loads current and forecast weather from the service', (
    tester,
  ) async {
    final service = WeatherService(
      client: MockClient((request) async {
        if (request.url.host == 'geocoding-api.open-meteo.com') {
          return http.Response(
            jsonEncode({
              'results': [
                {
                  'name': 'London',
                  'country': 'United Kingdom',
                  'latitude': 51.5,
                  'longitude': -0.1,
                },
              ],
            }),
            200,
          );
        }

        return http.Response(
          jsonEncode({
            'timezone': 'Europe/London',
            'current': {
              'time': '2026-11-11T12:00',
              'temperature_2m': 14.0,
              'relative_humidity_2m': 65,
              'apparent_temperature': 13.0,
              'is_day': 1,
              'weather_code': 2,
              'wind_speed_10m': 12.0,
            },
            'hourly': {
              'time': ['2026-11-11T12:00', '2026-11-11T13:00'],
              'temperature_2m': [14.0, 15.0],
              'relative_humidity_2m': [65, 60],
              'precipitation_probability': [10, 15],
              'weather_code': [2, 1],
            },
            'daily': {
              'time': ['2026-11-11', '2026-11-12'],
              'weather_code': [2, 1],
              'temperature_2m_max': [16.0, 17.0],
              'temperature_2m_min': [10.0, 11.0],
              'sunrise': ['2026-11-11T07:00', '2026-11-12T07:02'],
              'sunset': ['2026-11-11T16:30', '2026-11-12T16:28'],
            },
          }),
          200,
        );
      }),
    );

    await tester.pumpWidget(
      MaterialApp(home: HomeScreen(weatherService: service)),
    );
    await tester.pumpAndSettle();

    expect(find.text('London, United Kingdom'), findsOneWidget);
    expect(
      tester.widget<Text>(find.byKey(const Key('current-temperature'))).data,
      '14°',
    );
    expect(find.text('Hourly forecast'), findsOneWidget);
    expect(find.text('7-day forecast'), findsOneWidget);
  });
}
