# 🌤️ Weather App

A modern and responsive Flutter Weather App that displays current weather information for searched cities and the user's current location.

The application is built using Flutter and Dart with Provider for state management and public weather/location APIs.

## ✨ Features

- 🚀 Splash screen before the main application
- 🌡️ Current temperature
- ☁️ Weather condition and weather icon
- 💧 Humidity
- 💨 Wind speed
- 🌡️ Feels-like temperature
- 📊 Atmospheric pressure
- 🔎 City search
- 📍 Current location weather using GPS
- 🔄 Pull-to-refresh
- 🔁 Manual refresh button
- ⏳ Loading states
- ⚠️ Error states
- 🌐 Network/timeout error handling
- 🚫 Invalid city handling
- 🔒 Location permission handling
- ♻️ Previous successful weather data remains visible if a refresh fails
- 📱 Responsive Material 3 UI
- 🏗️ Layered project architecture
- 🧩 Provider-based state management

---

## 🛠️ Tech Stack

- **Flutter**
- **Dart**
- **Provider** – State management
- **HTTP** – API requests
- **Geolocator** – Current device/browser location
- **Shared Preferences** – Local storage dependency
- **Open-Meteo Weather API**
- **Open-Meteo Geocoding API**
- **Nominatim Reverse Geocoding API**

---

## 🌐 APIs Used

### Open-Meteo Weather API

The Open-Meteo API is used to retrieve current weather information based on latitude and longitude.

The application uses:

- Temperature
- Apparent temperature
- Relative humidity
- Weather code
- Surface pressure
- Wind speed

No API key is required.

### Open-Meteo Geocoding API

Used for searching cities and obtaining their geographic coordinates.

### Nominatim Reverse Geocoding

Used to convert the user's GPS coordinates into a readable city and country name.

---

## 📍 Current Location Feature

The application supports weather based on the user's current location.

Flow:

1. User taps the current-location button.
2. The application requests location permission.
3. GPS coordinates are obtained.
4. Coordinates are converted into a city and country.
5. Weather data is requested for those coordinates.
6. The current weather is displayed.

If location permission is denied, an appropriate error message is displayed.

---

## 🔄 Refresh & Error Handling

The application supports both:

- Pull-to-refresh
- Manual refresh button

The application handles:

- Invalid city searches
- Network failures
- Request timeouts
- Weather API errors
- API rate limits
- Location permission errors

### Previous Data Preservation

If weather data has already loaded successfully and a refresh request fails, the previous successful weather data remains visible instead of replacing the screen with an empty error state.

---

## 🏗️ Project Architecture

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
