import 'dart:convert';

import 'package:http/http.dart' as http;

class WeatherService {
  Future<Map<String, dynamic>> getWeather({
    required double latitude,
    required double longitude,
  }) async {
    final uri = Uri.parse(
      'https://api.open-meteo.com/v1/forecast'
      '?latitude=$latitude'
      '&longitude=$longitude'
      '&current=temperature_2m,relative_humidity_2m,apparent_temperature,'
      'weather_code,surface_pressure,wind_speed_10m'
      '&timezone=auto',
    );

    try {
      final response = await http
          .get(uri)
          .timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        return jsonDecode(response.body) as Map<String, dynamic>;
      }

      if (response.statusCode == 429) {
        throw Exception('Weather service rate limit reached.');
      }

      throw Exception(
        'Unable to fetch weather. Status: ${response.statusCode}',
      );
    } catch (e) {
      if (e is Exception && e.toString().contains('Weather service')) {
        rethrow;
      }

      throw Exception(
        'Unable to connect to weather service. Please check your internet connection.',
      );
    }
  }
}