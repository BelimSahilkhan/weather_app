import 'dart:convert';

import 'package:http/http.dart' as http;

class GeocodingService {
  Future<List<Map<String, dynamic>>> searchCity(String city) async {
    final uri = Uri.https(
      'geocoding-api.open-meteo.com',
      '/v1/search',
      {
        'name': city,
        'count': '5',
        'language': 'en',
        'format': 'json',
      },
    );

    try {
      final response = await http
          .get(uri)
          .timeout(const Duration(seconds: 10));

      if (response.statusCode != 200) {
        throw Exception('Unable to search city.');
      }

      final data = jsonDecode(response.body) as Map<String, dynamic>;

      final results = data['results'];

      if (results == null) {
        return [];
      }

      return List<Map<String, dynamic>>.from(results);
    } catch (e) {
      throw Exception(
        'Unable to search city. Please check your internet connection.',
      );
    }
  }
}