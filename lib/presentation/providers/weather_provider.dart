import 'package:flutter/foundation.dart';

import '../../data/repositories/weather_repository.dart';
import '../../data/services/geocoding_service.dart';
import '../../data/services/location_service.dart';
import '../../data/services/reverse_geocoding_service.dart';
import '../../data/models/weather_model.dart';

class WeatherProvider extends ChangeNotifier {
  final WeatherRepository _weatherRepository;
  final GeocodingService _geocodingService;
  final LocationService _locationService;
  final ReverseGeocodingService _reverseGeocodingService;

  WeatherProvider({
    WeatherRepository? weatherRepository,
    GeocodingService? geocodingService,
  })  : _weatherRepository = weatherRepository ?? WeatherRepository(),
        _geocodingService = geocodingService ?? GeocodingService(),
        _locationService = LocationService(),
        _reverseGeocodingService = ReverseGeocodingService();

  WeatherModel? _weather;
  bool _isLoading = false;
  String? _errorMessage;

  WeatherModel? get weather => _weather;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  Future<void> loadWeather({
    required double latitude,
    required double longitude,
    required String city,
    required String country,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final data = await _weatherRepository.getWeather(
        latitude: latitude,
        longitude: longitude,
      );

      final current = data['current'] as Map<String, dynamic>;

      final weatherCode = current['weather_code'] as num;

      _weather = WeatherModel(
        city: city,
        country: country,
        temperature: (current['temperature_2m'] as num).toDouble(),
        feelsLike: (current['apparent_temperature'] as num).toDouble(),
        humidity: (current['relative_humidity_2m'] as num).toInt(),
        windSpeed: (current['wind_speed_10m'] as num).toDouble(),
        pressure: (current['surface_pressure'] as num).toInt(),
        condition: _getCondition(weatherCode.toInt()),
        icon: _getIcon(weatherCode.toInt()),
      );
    } catch (e) {
      // Important: existing weather data is NOT removed.
      // So if refresh fails, previous successful data stays visible.
      _errorMessage = e.toString().replaceFirst('Exception: ', '');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }


  Future<void> loadCurrentLocation() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final position = await _locationService.getCurrentLocation();

      final location = await _reverseGeocodingService.getLocationName(
        latitude: position.latitude,
        longitude: position.longitude,
      );

      final data = await _weatherRepository.getWeather(
        latitude: position.latitude,
        longitude: position.longitude,
      );

      final current = data['current'] as Map<String, dynamic>;
      final weatherCode = current['weather_code'] as num;

      _weather = WeatherModel(
        city: location['city'] ?? 'Current Location',
        country: location['country'] ?? '',
        temperature: (current['temperature_2m'] as num).toDouble(),
        feelsLike: (current['apparent_temperature'] as num).toDouble(),
        humidity: (current['relative_humidity_2m'] as num).toInt(),
        windSpeed: (current['wind_speed_10m'] as num).toDouble(),
        pressure: (current['surface_pressure'] as num).toInt(),
        condition: _getCondition(weatherCode.toInt()),
        icon: _getIcon(weatherCode.toInt()),
      );
    } catch (e) {
      _errorMessage = e.toString().replaceFirst('Exception: ', '');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<List<Map<String, dynamic>>> searchCity(String city) {
    return _geocodingService.searchCity(city);
  }

  String _getCondition(int code) {
    if (code == 0) return 'Clear Sky';

    if (code == 1 || code == 2 || code == 3) {
      return 'Partly Cloudy';
    }

    if (code == 45 || code == 48) {
      return 'Foggy';
    }

    if (code >= 51 && code <= 57) {
      return 'Drizzle';
    }

    if (code >= 61 && code <= 67) {
      return 'Rain';
    }

    if (code >= 71 && code <= 77) {
      return 'Snow';
    }

    if (code >= 80 && code <= 82) {
      return 'Rain Showers';
    }

    if (code >= 95) {
      return 'Thunderstorm';
    }

    return 'Unknown';
  }

  String _getIcon(int code) {
    if (code == 0) return '☀️';

    if (code == 1 || code == 2) return '🌤️';

    if (code == 3) return '☁️';

    if (code == 45 || code == 48) return '🌫️';

    if (code >= 51 && code <= 67) return '🌧️';

    if (code >= 71 && code <= 77) return '❄️';

    if (code >= 80 && code <= 82) return '🌦️';

    if (code >= 95) return '⛈️';

    return '🌤️';
  }
}