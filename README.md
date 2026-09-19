cat > README.md <<'EOF'
# Weather App

A modern Flutter Weather App that provides current weather information for searched cities and the user's current location.

The app is built with Flutter and uses Open-Meteo for weather data and Nominatim for reverse geocoding.

## Features

- Splash screen with smooth transition
- Current weather information
- Temperature and weather condition
- Weather condition icon
- Humidity
- Wind speed
- Feels-like temperature
- Atmospheric pressure
- City search with location selection
- Current GPS location support
- Pull-to-refresh
- Manual weather refresh
- Loading states
- Error handling
- Invalid city handling
- Internet/API failure handling
- Previous successful weather data remains visible if refresh fails
- Responsive modern Material 3 UI
- Clean separation of UI, state management, services, repository, and models

## Tech Stack

- Flutter
- Dart
- Provider
- HTTP
- Geolocator
- Shared Preferences
- Open-Meteo Weather API
- Open-Meteo Geocoding API
- Nominatim Reverse Geocoding API

## API

### Weather API

Open-Meteo is used to retrieve current weather information.

Weather data includes:

- Temperature
- Apparent temperature
- Humidity
- Wind speed
- Surface pressure
- Weather code

### City Search

Open-Meteo Geocoding API is used to search and select cities.

### Current Location

The Geolocator package is used to obtain the user's GPS coordinates.

Nominatim is then used to convert the coordinates into a readable city and country name.

## Architecture

The project follows a layered structure to keep responsibilities separated.

```text
lib/
├── core/
│   └── constants/
│
├── data/
│   ├── models/
│   │   └── weather_model.dart
│   │
│   ├── repositories/
│   │   └── weather_repository.dart
│   │
│   └── services/
│       ├── weather_service.dart
│       ├── geocoding_service.dart
│       ├── location_service.dart
│       └── reverse_geocoding_service.dart
│
├── presentation/
│   ├── providers/
│   │   └── weather_provider.dart
│   │
│   ├── screens/
│   │   ├── splash_screen.dart
│   │   └── home_screen.dart
│   │
│   └── widgets/
│
└── main.dart
