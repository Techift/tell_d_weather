import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;

import '../models/weather_model.dart';

class WeatherServiceException implements Exception {
  const WeatherServiceException(this.message);

  final String message;

  @override
  String toString() => message;
}

class WeatherService {
  WeatherService({http.Client? client})
    : _client = client ?? http.Client(),
      _ownsClient = client == null;

  static const _geocodingEndpoint =
      'https://geocoding-api.open-meteo.com/v1/search';
  static const _forecastEndpoint = 'https://api.open-meteo.com/v1/forecast';

  final http.Client _client;
  final bool _ownsClient;

  Future<WeatherData> fetchForCity(String query) async {
    final city = query.trim();
    if (city.isEmpty) {
      throw const WeatherServiceException('Enter a city name to search.');
    }

    try {
      final locationResponse = await _client
          .get(
            Uri.parse(_geocodingEndpoint).replace(
              queryParameters: {
                'name': city,
                'count': '1',
                'language': 'en',
                'format': 'json',
              },
            ),
          )
          .timeout(const Duration(seconds: 15));
      _ensureSuccess(locationResponse, 'Could not search for that city.');

      final locationJson = _decodeObject(locationResponse.body);
      final results = locationJson['results'];
      if (results is! List || results.isEmpty) {
        throw WeatherServiceException('No city found for "$city".');
      }

      final location = results.first;
      if (location is! Map<String, dynamic>) {
        throw const FormatException('The city search returned invalid data.');
      }

      final latitude = _asNumber(location['latitude']);
      final longitude = _asNumber(location['longitude']);
      final cityName = location['name'] as String? ?? city;
      final country = location['country'] as String? ?? '';
      if (latitude == null || longitude == null) {
        throw const FormatException('The city coordinates are unavailable.');
      }

      final weatherResponse = await _client
          .get(
            Uri.parse(_forecastEndpoint).replace(
              queryParameters: {
                'latitude': '$latitude',
                'longitude': '$longitude',
                'current':
                    'temperature_2m,relative_humidity_2m,apparent_temperature,is_day,precipitation,weather_code,wind_speed_10m',
                'hourly':
                    'temperature_2m,relative_humidity_2m,precipitation_probability,weather_code',
                'daily':
                    'weather_code,temperature_2m_max,temperature_2m_min,sunrise,sunset',
                'timezone': 'auto',
                'forecast_days': '7',
              },
            ),
          )
          .timeout(const Duration(seconds: 15));
      _ensureSuccess(weatherResponse, 'Could not load weather information.');

      return WeatherData.fromJson(
        _decodeObject(weatherResponse.body),
        cityName: cityName,
        country: country,
      );
    } on WeatherServiceException {
      rethrow;
    } on http.ClientException {
      throw const WeatherServiceException(
        'Could not connect to the weather service. Check your internet connection and try again.',
      );
    } on TimeoutException {
      throw const WeatherServiceException(
        'The weather request timed out. Please try again.',
      );
    }
  }

  void close() {
    if (_ownsClient) _client.close();
  }

  void _ensureSuccess(http.Response response, String message) {
    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw WeatherServiceException('$message (${response.statusCode})');
    }
  }

  Map<String, dynamic> _decodeObject(String body) {
    final decoded = jsonDecode(body);
    if (decoded is! Map<String, dynamic>) {
      throw const FormatException('The weather service returned invalid data.');
    }
    return decoded;
  }

  double? _asNumber(Object? value) => value is num ? value.toDouble() : null;
}
