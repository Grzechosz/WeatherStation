import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:weather/weather.dart';
import 'package:weather_station/screen/variables/curiosity_page.dart';
import 'package:weather_station/screen/variables/readings_page.dart';
import 'package:weather_station/service/forecast_service.dart';

import '../../model/reading.dart';

class ReadingCard extends HookWidget {
  final Reading reading;

  const ReadingCard({super.key, required this.reading});

  @override
  Widget build(BuildContext context) {
    final currentWeather = useState<Weather?>(null);
    final forecastService = useMemoized(() => ForecastService());
    final future = useMemoized(() => forecastService.getCurrentWeather(), []);
    final snapshot = useFuture(future);

    useEffect(() {
      if (snapshot.connectionState == ConnectionState.done &&
          snapshot.hasData) {
        currentWeather.value = snapshot.data!;
      }
      return null;
    }, [snapshot.connectionState]);

    return SingleChildScrollView(
      child: Column(
        children: [
          _buildMainTile(
            currentWeather,
            'Temperatura na zewnątrz',
            '${reading.temperatureOutside.toStringAsFixed(0)}°C',
            () => _navigateToSensor(
                context, ReadingChartPage(
                dataType: 'temperatureOutside',
                title: 'Temperatura na zewnątrz',
              styleColor: Colors.white,
              unit: '°C',)
            ),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: _buildTile(
                    'assets/icons/house.png',
                    '${reading.temperatureInside.toStringAsFixed(0)}°C',
                    const Color.fromARGB(255, 255, 220, 210),
                    () => _navigateToSensor(
                        context, ReadingChartPage(
                      dataType: 'temperatureInside',
                      title: 'Temperatura w środku',
                      styleColor: const Color.fromARGB(255, 255, 220, 210),
                    unit: '°C',))
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _buildTile(
                    'assets/icons/balloon.png',
                    '${(reading.pressure / 100).toStringAsFixed(0)}\nhPa',
                    const Color.fromARGB(255, 215, 240, 240),
                    () => _navigateToSensor(
                        context, ReadingChartPage(
                        dataType: 'pressure',
                        title: 'Ciśnienie atmosferyczne',
                        styleColor: const Color.fromARGB(255, 215, 240, 240),
                      unit: 'hPa'))
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: _buildTile(
                    'assets/icons/glass-of-water.png',
                    '${reading.humidity.toStringAsFixed(0)}%',
                    const Color.fromARGB(255, 210, 245, 215),
                    () => _navigateToSensor(
                        context, ReadingChartPage(
                        dataType: 'humidity',
                        title: 'Wilgotność powietrza',
                        styleColor: Color.fromARGB(255, 210, 245, 215),
                        unit: '%'))),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _buildTile(
                    'assets/icons/light-bulb.png',
                    '${reading.light.toStringAsFixed(0)}%',
                    const Color.fromARGB(255, 255, 240, 190),
                    () => _navigateToSensor(
                        context, ReadingChartPage(
                        dataType: 'light',
                        title: 'Natężenie światła',
                        styleColor: const Color.fromARGB(255, 255, 240, 190),
                        unit: '%'))),
              ),
            ],
          ),
          const SizedBox(height: 10),
          _buildHorizontalTile(
              'assets/icons/carbon-monoxide.png',
              '${reading.co.toStringAsFixed(0)}ppm',
              const Color.fromARGB(255, 250, 245, 230),
              () => _navigateToSensor(context, ReadingChartPage(
                  dataType: 'co',
                  title: 'Stężenie tlenku węgla',
                  styleColor: const Color.fromARGB(255, 250, 245, 230),
                  unit: 'ppm'
              ))),
          const SizedBox(height: 10),
          _buildHorizontalTile(
              'assets/icons/mental-health.png',
              'Dowiedz się czegoś ciekawego!',
              const Color.fromARGB(255, 250, 245, 230),
              () => _navigateToSensor(context, CuriosityPage())),
        ],
      ),
    );
  }

  Widget _buildTile(String imagePath, String value, Color backgroundColor,
      VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(25),
          border: Border.all(color: Colors.teal.shade100),
        ),
        child: Row(
          children: [
            Image.asset(imagePath, height: 80, width: 80),
            const SizedBox(width: 5),
            Expanded(
              child: Text(
                value,
                style: const TextStyle(
                    fontSize: 22,
                    color: Color.fromARGB(255, 15, 65, 100),
                    fontWeight: FontWeight.bold),
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget _buildHorizontalTile(String imagePath, String value, Color backgroundColor,
      VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(25),
          border: Border.all(color: Colors.teal.shade100),
        ),
        child: Row(
          children: [
            Image.asset(imagePath, height: 60, width: 60),
            const SizedBox(width: 5),
            Expanded(
              child: Text(
                value,
                style: const TextStyle(
                    fontSize: 20,
                    color: Color.fromARGB(255, 15, 65, 100),
                    fontWeight: FontWeight.bold),
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget _buildMainTile(
      ValueNotifier<Weather?> weather, String title, String value, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
        decoration: BoxDecoration(
          color: const Color.fromARGB(255, 255, 245, 235),
          borderRadius: BorderRadius.circular(25),
          border: Border.all(color: const Color.fromARGB(255, 255, 245, 235)),
        ),
        child: Row(
          children: [
            Column(
              children: [
                Image.asset(_getIconById(weather), height: 150, width: 150),
              ],
            ),
            const SizedBox(width: 5),
            Expanded(
              child: Column(
                children: [
                  Text(
                    value,
                    style: const TextStyle(
                      fontSize: 70,
                      fontWeight: FontWeight.bold,
                      color: Colors.deepOrangeAccent,
                    ),
                  ),
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 25,
                      fontWeight: FontWeight.bold,
                      color: Color.fromARGB(255, 15, 65, 100),
                    ),
                  ),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }

  void _navigateToSensor(BuildContext context, Widget widget) {
    Navigator.push(
        context,
        PageRouteBuilder(
            pageBuilder: (q, w, e) => widget,
            transitionsBuilder:
                (context, animation, secondaryAnimation, child) =>
                    SlideTransition(
                      position: Tween(
                        begin: const Offset(1.0, 0.0),
                        end: const Offset(0.0, 0.0),
                      ).animate(animation),
                      child: child,
                    )));
  }

  String _getIconById(ValueNotifier<Weather?> weather) {
    final weatherData = weather.value;

    if (weatherData == null ||
        weatherData.weatherConditionCode == null ||
        weatherData.sunrise == null ||
        weatherData.sunset == null) {
      return 'assets/icons/sun.png';
    }

    final id = weatherData.weatherConditionCode!;
    final now = DateTime.now();
    final isDay = now.isAfter(weatherData.sunrise!) && now.isBefore(weatherData.sunset!);

    if (id == 800) {
      return isDay ? 'assets/icons/sun.png' : 'assets/icons/moon.png';
    } else if (id >= 200 && id < 300) {
      return 'assets/weather/thunder.png';
    } else if (id >= 300 && id < 400) {
      return isDay
          ? 'assets/weather/drizzle.png'
          : 'assets/weather/drizzle_moon.png';
    } else if (id >= 500 && id < 600) {
      return 'assets/weather/rain.png';
    } else if (id >= 600 && id < 700) {
      return 'assets/weather/snow.png';
    } else if (id >= 700 && id < 800) {
      return 'assets/weather/fog.png';
    } else if (id > 800) {
      switch (id) {
        case 801:
          return isDay
              ? 'assets/weather/clouds/sun_11-25.png'
              : 'assets/weather/clouds/moon_11-25.png';
        case 802:
          return isDay
              ? 'assets/weather/clouds/sun_25-50.png'
              : 'assets/weather/clouds/moon_25-50.png';
        case 803:
          return isDay
              ? 'assets/weather/clouds/sun_51-84.png'
              : 'assets/weather/clouds/moon_51-84.png';
        case 804:
          return 'assets/weather/clouds/clouds_85-100.png';
        default:
          return 'assets/images/blank.png';
      }
    }
    return 'assets/images/blank.png';
  }

}
