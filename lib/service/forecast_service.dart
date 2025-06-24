import 'package:weather/weather.dart';

class ForecastService {
  final String _key = '13fa2419ae4cd6312846b1a8f6591c70';
  final String _cityName = 'Białystok';
  late final WeatherFactory _client = WeatherFactory(
      _key,
      language: Language.ENGLISH
  );

  Future<Weather> getCurrentWeather() async {
    return await _client.currentWeatherByCityName(_cityName);
  }

  Future<List<Weather>> getFiveDayForecast() async {
    return _client.fiveDayForecastByCityName(_cityName);
  }
}
