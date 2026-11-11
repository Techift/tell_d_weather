import 'package:flutter/material.dart';

import '../models/weather_model.dart';
import '../services/weather_service.dart';
import '../widgets/current_weather.dart';
import '../widgets/hourly_forecast.dart';
import '../widgets/weather_details.dart';
import '../widgets/weekly_forecast.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key, this.weatherService});

  final WeatherService? weatherService;

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late final WeatherService _weatherService;
  final _searchController = TextEditingController();
  WeatherData? _weather;
  String? _errorMessage;
  bool _isLoading = true;
  int _requestId = 0;

  @override
  void initState() {
    super.initState();
    _weatherService = widget.weatherService ?? WeatherService();
    _loadWeather('London');
  }

  @override
  void dispose() {
    _searchController.dispose();
    if (widget.weatherService == null) _weatherService.close();
    super.dispose();
  }

  Future<void> _loadWeather(String city) async {
    final requestId = ++_requestId;
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final result = await _weatherService.fetchForCity(city);
      if (!mounted || requestId != _requestId) return;
      setState(() {
        _weather = result;
        _isLoading = false;
        _searchController.clear();
      });
    } on WeatherServiceException catch (error) {
      if (!mounted || requestId != _requestId) return;
      setState(() {
        _errorMessage = error.message;
        _isLoading = false;
      });
    } on FormatException catch (error) {
      if (!mounted || requestId != _requestId) return;
      setState(() {
        _errorMessage = 'Weather data could not be read: ${error.message}';
        _isLoading = false;
      });
    }
  }

  void _search() {
    final city = _searchController.text.trim();
    if (city.isNotEmpty) _loadWeather(city);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Row(
          children: [
            Icon(Icons.cloud_outlined, color: Color(0xFF2563EB)),
            SizedBox(width: 9),
            Text('Weather', style: TextStyle(fontWeight: FontWeight.w700)),
          ],
        ),
        actions: [
          IconButton(
            key: const Key('refresh-weather'),
            tooltip: 'Refresh weather',
            onPressed: _isLoading || _weather == null
                ? null
                : () => _loadWeather(_weather!.cityName),
            icon: const Icon(Icons.refresh_rounded),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: SafeArea(
        top: false,
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 760),
            child: Column(
              children: [
                if (_isLoading) const LinearProgressIndicator(minHeight: 2),
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.fromLTRB(20, 12, 20, 32),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildSearchField(),
                        if (_errorMessage != null) ...[
                          const SizedBox(height: 12),
                          _buildErrorBanner(),
                        ],
                        if (_weather == null && _isLoading) ...[
                          const SizedBox(height: 80),
                          const Center(
                            child: Column(
                              children: [
                                CircularProgressIndicator(),
                                SizedBox(height: 16),
                                Text('Loading weather...'),
                              ],
                            ),
                          ),
                        ] else if (_weather != null) ...[
                          const SizedBox(height: 20),
                          CurrentWeatherCard(weather: _weather!),
                          const SizedBox(height: 14),
                          WeatherDetails(current: _weather!.current),
                          const SizedBox(height: 26),
                          _SectionTitle(
                            title: 'Hourly forecast',
                            subtitle: 'Next 24 hours',
                          ),
                          const SizedBox(height: 12),
                          HourlyForecast(
                            forecast: _weather!.hourly,
                            now: _weather!.current.time,
                          ),
                          const SizedBox(height: 26),
                          const _SectionTitle(
                            title: '7-day forecast',
                            subtitle: 'Daily high and low',
                          ),
                          const SizedBox(height: 12),
                          WeeklyForecast(forecast: _weather!.daily),
                        ] else if (!_isLoading) ...[
                          const SizedBox(height: 64),
                          const Center(
                            child: Icon(
                              Icons.cloud_off_outlined,
                              size: 48,
                              color: Color(0xFF9AA6B6),
                            ),
                          ),
                          const SizedBox(height: 12),
                          const Center(
                            child: Text(
                              'Search for a city to see its weather.',
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSearchField() {
    return TextField(
      controller: _searchController,
      textInputAction: TextInputAction.search,
      onSubmitted: (_) => _search(),
      decoration: InputDecoration(
        hintText: 'Search for a city',
        prefixIcon: const Icon(Icons.search_rounded),
        suffixIcon: IconButton(
          key: const Key('search-city'),
          tooltip: 'Search city',
          onPressed: _isLoading ? null : _search,
          icon: const Icon(Icons.arrow_forward_rounded),
        ),
      ),
    );
  }

  Widget _buildErrorBanner() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF3F0),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFF3C7BE)),
      ),
      child: Row(
        children: [
          const Icon(Icons.info_outline, color: Color(0xFFB54735)),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              _errorMessage!,
              style: const TextStyle(color: Color(0xFF8F3022)),
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle({required this.title, required this.subtitle});

  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Text(
          title,
          style: Theme.of(
            context,
          ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700),
        ),
        Text(
          subtitle,
          style: Theme.of(
            context,
          ).textTheme.bodySmall?.copyWith(color: const Color(0xFF778397)),
        ),
      ],
    );
  }
}
