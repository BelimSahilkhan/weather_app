import '../services/weather_service.dart';

class WeatherRepository {
  final WeatherService _weatherService;

  WeatherRepository({
    WeatherService? weatherService,
  }) : _weatherService = weatherService ?? WeatherService();

  Future<Map<String, dynamic>> getWeather({
    required double latitude,
    required double longitude,
  }) {
    return _weatherService.getWeather(
      latitude: latitude,
      longitude: longitude,
    );
  }
}