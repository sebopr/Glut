import 'dart:convert';
import 'package:http/http.dart' as http;

class WeatherData {
  final double temperature;
  final double windSpeed;
  final int weatherCode;
  final int humidity;

  WeatherData({
    required this.temperature,
    required this.windSpeed,
    required this.weatherCode,
    required this.humidity,
  });

  String get description {
    if (weatherCode == 0) return 'Clear sky';
    if (weatherCode <= 3) return 'Partly cloudy';
    if (weatherCode <= 48) return 'Foggy';
    if (weatherCode <= 57) return 'Drizzle';
    if (weatherCode <= 67) return 'Rainy';
    if (weatherCode <= 77) return 'Snowy';
    if (weatherCode <= 82) return 'Rain showers';
    if (weatherCode <= 86) return 'Snow showers';
    if (weatherCode <= 99) return 'Thunderstorm';
    return 'Unknown';
  }

  String get emoji {
    if (weatherCode == 0) return '☀️';
    if (weatherCode <= 3) return '⛅';
    if (weatherCode <= 48) return '🌫️';
    if (weatherCode <= 57) return '🌦️';
    if (weatherCode <= 67) return '🌧️';
    if (weatherCode <= 77) return '❄️';
    if (weatherCode <= 82) return '🌧️';
    if (weatherCode <= 86) return '🌨️';
    if (weatherCode <= 99) return '⛈️';
    return '🌡️';
  }

  bool get goodForFire {
    // Good for fire: not raining, not too windy, not freezing
    final notRaining = weatherCode < 51;
    final notTooWindy = windSpeed < 30;
    final notFreezing = temperature > 0;
    return notRaining && notTooWindy && notFreezing;
  }

  String get fireAdvice {
    if (weatherCode >= 51) return 'Rain expected — check fire ban';
    if (windSpeed >= 30) return 'Too windy — fire risk high';
    if (temperature <= 0) return 'Freezing — dress warm';
    return 'Good conditions for a fire';
  }
}

class WeatherService {
  static Future<WeatherData?> getWeather(double lat, double lng) async {
    try {
      final uri = Uri.parse(
        'https://api.open-meteo.com/v1/forecast'
        '?latitude=$lat'
        '&longitude=$lng'
        '&current=temperature_2m,relative_humidity_2m,weather_code,wind_speed_10m'
        '&wind_speed_unit=kmh'
        '&forecast_days=1',
      );

      final response = await http.get(uri).timeout(const Duration(seconds: 8));

      if (response.statusCode != 200) return null;

      final data = jsonDecode(response.body) as Map<String, dynamic>;
      final current = data['current'] as Map<String, dynamic>;

      return WeatherData(
        temperature: (current['temperature_2m'] as num).toDouble(),
        windSpeed: (current['wind_speed_10m'] as num).toDouble(),
        weatherCode: (current['weather_code'] as num).toInt(),
        humidity: (current['relative_humidity_2m'] as num).toInt(),
      );
    } catch (e) {
      print('Weather error: $e');
      return null;
    }
  }
}
