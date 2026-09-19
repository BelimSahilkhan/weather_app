import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/weather_provider.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<WeatherProvider>().loadWeather(
            latitude: 23.0225,
            longitude: 72.5714,
            city: 'Ahmedabad',
            country: 'India',
          );
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _searchCity() async {
    final city = _searchController.text.trim();

    if (city.isEmpty) return;

    final provider = context.read<WeatherProvider>();

    try {
      final results = await provider.searchCity(city);

      if (!mounted) return;

      if (results.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('City not found. Please try another city.'),
          ),
        );
        return;
      }

      final selectedCity = await showModalBottomSheet<Map<String, dynamic>>(
        context: context,
        showDragHandle: true,
        builder: (sheetContext) {
          return SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Select a city',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Flexible(
                    child: ListView.separated(
                      shrinkWrap: true,
                      itemCount: results.length,
                      separatorBuilder: (_, _) => const Divider(height: 1),
                      itemBuilder: (_, index) {
                        final result = results[index];

                        final name = result['name'] as String? ?? 'Unknown';
                        final country =
                            result['country'] as String? ?? '';
                        final admin =
                            result['admin1'] as String? ?? '';

                        final subtitle = [
                          if (admin.isNotEmpty) admin,
                          if (country.isNotEmpty) country,
                        ].join(', ');

                        return ListTile(
                          leading: const CircleAvatar(
                            child: Icon(Icons.location_city),
                          ),
                          title: Text(
                            name,
                            style: const TextStyle(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          subtitle: Text(
                            subtitle.isEmpty
                                ? 'Location'
                                : subtitle,
                          ),
                          onTap: () {
                            Navigator.pop(sheetContext, result);
                          },
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      );

      if (!mounted || selectedCity == null) return;

      final latitude = (selectedCity['latitude'] as num).toDouble();
      final longitude = (selectedCity['longitude'] as num).toDouble();

      final cityName = selectedCity['name'] as String? ?? city;
      final country = selectedCity['country'] as String? ?? '';

      await provider.loadWeather(
        latitude: latitude,
        longitude: longitude,
        city: cityName,
        country: country,
      );
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            e.toString().replaceFirst('Exception: ', ''),
          ),
        ),
      );
    }
  }

  Future<void> _refreshWeather() async {
    final provider = context.read<WeatherProvider>();
    final weather = provider.weather;

    if (weather == null) return;

    try {
      final results = await provider.searchCity(weather.city);

      if (results.isEmpty) return;

      final city = results.first;

      await provider.loadWeather(
        latitude: (city['latitude'] as num).toDouble(),
        longitude: (city['longitude'] as num).toDouble(),
        city: city['name'] as String? ?? weather.city,
        country: city['country'] as String? ?? weather.country,
      );
    } catch (_) {
      // Previous successful weather data remains visible.
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<WeatherProvider>(
      builder: (context, provider, child) {
        final weather = provider.weather;

        return Scaffold(
          appBar: AppBar(
            title: const Text(
              'Weather',
              style: TextStyle(
                fontWeight: FontWeight.bold,
              ),
            ),
            centerTitle: true,
          ),
          body: RefreshIndicator(
            onRefresh: _refreshWeather,
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  _buildSearchBar(),

                  const SizedBox(height: 25),

                  if (provider.isLoading && weather == null)
                    const Padding(
                      padding: EdgeInsets.only(top: 80),
                      child: CircularProgressIndicator(),
                    )
                  else if (weather != null)
                    _buildWeatherContent(weather, provider)
                  else
                    _buildErrorState(provider.errorMessage),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildSearchBar() {
    return TextField(
      controller: _searchController,
      textInputAction: TextInputAction.search,
      onSubmitted: (_) => _searchCity(),
      decoration: InputDecoration(
        hintText: 'Search city',
        prefixIcon: const Icon(Icons.search),
        suffixIcon: IconButton(
          onPressed: _searchCity,
          icon: const Icon(Icons.arrow_forward),
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
        ),
      ),
    );
  }

  Widget _buildWeatherContent(
    dynamic weather,
    WeatherProvider provider,
  ) {
    return Column(
      children: [
        if (provider.errorMessage != null)
          Container(
            width: double.infinity,
            margin: const EdgeInsets.only(bottom: 16),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.orange.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              provider.errorMessage!,
              style: const TextStyle(
                fontSize: 13,
              ),
            ),
          ),

        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [
                Color(0xFF2563EB),
                Color(0xFF38BDF8),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(28),
          ),
          child: Column(
            children: [
              Text(
                weather.city,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 5),

              Text(
                weather.country,
                style: const TextStyle(
                  color: Colors.white70,
                  fontSize: 15,
                ),
              ),

              const SizedBox(height: 18),

              Text(
                weather.icon,
                style: const TextStyle(
                  fontSize: 70,
                ),
              ),

              const SizedBox(height: 8),

              Text(
                '${weather.temperature.round()}°C',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 54,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 5),

              Text(
                weather.condition,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 19,
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 20),

        Row(
          children: [
            Expanded(
              child: _WeatherInfoCard(
                icon: Icons.water_drop,
                title: 'Humidity',
                value: '${weather.humidity}%',
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _WeatherInfoCard(
                icon: Icons.air,
                title: 'Wind',
                value: '${weather.windSpeed.round()} km/h',
              ),
            ),
          ],
        ),

        const SizedBox(height: 12),

        Row(
          children: [
            Expanded(
              child: _WeatherInfoCard(
                icon: Icons.thermostat,
                title: 'Feels Like',
                value: '${weather.feelsLike.round()}°C',
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _WeatherInfoCard(
                icon: Icons.compress,
                title: 'Pressure',
                value: '${weather.pressure} hPa',
              ),
            ),
          ],
        ),

        const SizedBox(height: 25),

        SizedBox(
          width: double.infinity,
          height: 52,
          child: ElevatedButton.icon(
            onPressed: provider.isLoading ? null : _refreshWeather,
            icon: provider.isLoading
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                    ),
                  )
                : const Icon(Icons.refresh),
            label: Text(
              provider.isLoading
                  ? 'Refreshing...'
                  : 'Refresh Weather',
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildErrorState(String? message) {
    return Padding(
      padding: const EdgeInsets.only(top: 70),
      child: Column(
        children: [
          const Icon(
            Icons.cloud_off,
            size: 70,
          ),
          const SizedBox(height: 15),
          Text(
            message ?? 'Unable to load weather.',
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

class _WeatherInfoCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String value;

  const _WeatherInfoCard({
    required this.icon,
    required this.title,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        vertical: 20,
        horizontal: 12,
      ),
      decoration: BoxDecoration(
        color: Theme.of(context)
            .colorScheme
            .surfaceContainerHighest,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        children: [
          Icon(icon, size: 30),
          const SizedBox(height: 10),
          Text(
            title,
            style: const TextStyle(fontSize: 13),
          ),
          const SizedBox(height: 5),
          Text(
            value,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}