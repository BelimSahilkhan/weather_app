import 'dart:convert';

import 'package:http/http.dart' as http;

class ReverseGeocodingService {
  Future<Map<String, String>> getLocationName({
    required double latitude,
    required double longitude,
  }) async {
    final uri = Uri.https(
      'nominatim.openstreetmap.org',
      '/reverse',
      {
        'lat': latitude.toString(),
        'lon': longitude.toString(),
        'format': 'json',
      },
    );

    final response = await http.get(
      uri,
      headers: {
        'User-Agent': 'WeatherApp/1.0',
      },
    ).timeout(const Duration(seconds: 10));

    if (response.statusCode != 200) {
      throw Exception('Unable to determine your city.');
    }

    final data = jsonDecode(response.body) as Map<String, dynamic>;
    final address = data['address'] as Map<String, dynamic>?;

    if (address == null) {
      throw Exception('Unable to determine your city.');
    }

    return {
      'city': address['city'] as String? ??
          address['town'] as String? ??
          address['village'] as String? ??
          'Current Location',
      'country': address['country'] as String? ?? '',
    };
  }
}
