import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:weather/weather.dart';
import 'package:weather_station/service/forecast_service.dart';

import '../../model/reading.dart';
import '../../service/reading_service.dart';

class ForecastPage extends HookWidget {
  const ForecastPage({super.key});

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
    
    final forecastFuture =
        useMemoized(() => forecastService.getFiveDayForecast());

    return Scaffold(
      appBar: AppBar(
          title: Text(
            "Pogoda na zewnątrz",
            style: const TextStyle(
              fontWeight: FontWeight.w800,
              color: Color.fromARGB(255, 15, 65, 100),
            ),
          ),
          backgroundColor: const Color.fromARGB(255, 170, 220, 240)),
      body: StreamProvider<List<Reading>>.value(
        value: ReadingService().readings,
        initialData: const [],
        builder: (context, child) {
          return SingleChildScrollView(
            child: Column(
              children: [
                Container(
                  margin:
                      MediaQuery.of(context).orientation == Orientation.portrait
                          ? EdgeInsets.symmetric(horizontal: 10, vertical: 10)
                          : EdgeInsets.symmetric(horizontal: 30, vertical: 10),
                  padding: const EdgeInsets.all(15),
                  decoration: BoxDecoration(
                    color: const Color.fromARGB(150, 170, 220, 240),
                    borderRadius: BorderRadius.circular(35),
                    boxShadow: [
                      BoxShadow(
                        color: const Color.fromARGB(150, 170, 220, 240),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Container(
                    padding: EdgeInsetsGeometry.all(10),
                    decoration: BoxDecoration(
                      color: Color.fromARGB(200, 255, 255, 255),
                      borderRadius: BorderRadius.circular(35),
                      boxShadow: [
                        BoxShadow(
                          color: const Color.fromARGB(200, 255, 255, 255),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: AspectRatio(
                      aspectRatio: MediaQuery.of(context).orientation ==
                              Orientation.portrait
                          ? 1.2
                          : MediaQuery.of(context).devicePixelRatio,
                      child: _buildChart(context),
                    ),
                  ),
                ),
                Container(
                  margin:
                      MediaQuery.of(context).orientation == Orientation.portrait
                          ? EdgeInsets.symmetric(horizontal: 10, vertical: 10)
                          : EdgeInsets.symmetric(horizontal: 30, vertical: 10),
                  padding: const EdgeInsets.all(15),
                  decoration: BoxDecoration(
                    color: const Color.fromARGB(150, 170, 220, 240),
                    borderRadius: BorderRadius.circular(35),
                    boxShadow: [
                      BoxShadow(
                        color: const Color.fromARGB(150, 170, 220, 240),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Container(
                    padding: EdgeInsetsGeometry.all(20),
                    decoration: BoxDecoration(
                      color: Color.fromARGB(200, 255, 255, 255),
                      borderRadius: BorderRadius.circular(35),
                      boxShadow: [
                        BoxShadow(
                          color: Color.fromARGB(200, 255, 255, 255),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        Text(
                          'W tej chwili',
                          style: TextStyle(
                              fontSize: 40,
                              fontWeight: FontWeight.w600,
                              color: Color.fromARGB(255, 15, 65, 100)),
                        ),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                padding: EdgeInsetsGeometry.all(12),
                                child: Image.asset(_getIconByWeather(currentWeather),
                                    scale: 7)),
                            SizedBox(
                              width: 20,
                            ),
                            Text(
                              "${_formatWithSuffix(_getLastValue(context))}${"°C"}",
                              style: TextStyle(
                                  fontWeight: FontWeight.w800,
                                  fontSize: 70,
                                  color: Color.fromARGB(255, 15, 65, 100),
                                  height: 0.8),
                            )
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                Container(
                  margin:
                      MediaQuery.of(context).orientation == Orientation.portrait
                          ? EdgeInsets.symmetric(horizontal: 10, vertical: 10)
                          : EdgeInsets.symmetric(horizontal: 30, vertical: 10),
                  padding: const EdgeInsets.all(15),
                  decoration: BoxDecoration(
                    color: const Color.fromARGB(150, 170, 220, 240),
                    borderRadius: BorderRadius.circular(35),
                    boxShadow: [
                      BoxShadow(
                        color: const Color.fromARGB(150, 170, 220, 240),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Container(
                    padding: EdgeInsetsGeometry.all(10),
                    decoration: BoxDecoration(
                      color: Color.fromARGB(200, 255, 255, 255),
                      borderRadius: BorderRadius.circular(35),
                      boxShadow: [
                        BoxShadow(
                          color: const Color.fromARGB(200, 255, 255, 255),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        Text(
                          'Prognoza',
                          style: TextStyle(
                              fontSize: 40,
                              fontWeight: FontWeight.w600,
                              color: Color.fromARGB(255, 15, 65, 100)),
                        ),
                        SizedBox(height: 10),
                        AspectRatio(
                          aspectRatio: MediaQuery.of(context).orientation ==
                                  Orientation.portrait
                              ? 1.8
                              : 3.8,
                          child: _buildForecast(context, forecastFuture),
                        )
                      ],
                    ),
                  ),
                )
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildChart(BuildContext context) {
    final readings = Provider.of<List<Reading>>(context);

    if (!ReadingService.isLoaded) {
      return const Center(
        child: SpinKitWave(color: Color.fromARGB(255, 170, 220, 240), size: 50),
      );
    }
    if (readings.isEmpty) {
      return const Center(
        child: Text(
          "Brak danych",
          style: TextStyle(fontSize: 20),
        ),
      );
    }
    final now = DateTime.now();
    final fiveDaysAgo = now.subtract(const Duration(days: 5));

    final recentReadings =
        readings.where((e) => e.time.isAfter(fiveDaysAgo)).toList();

    final List<FlSpot> data = recentReadings.map((e) {
      final x = e.time.millisecondsSinceEpoch.toDouble();
      final y = e.temperatureOutside;
      return FlSpot(x, y);
    }).toList();

    double minY = data.map((spot) => spot.y).reduce((a, b) => a < b ? a : b);
    double maxY = data.map((spot) => spot.y).reduce((a, b) => a > b ? a : b);
    double yMargin = (maxY - minY) * 0.1;

    if (yMargin == 0) yMargin = maxY == 0 ? 1 : maxY * 0.1;

    minY -= yMargin;
    maxY += yMargin;

    return Padding(
      padding: const EdgeInsets.all(15),
      child: LineChart(LineChartData(
        minX: fiveDaysAgo.millisecondsSinceEpoch.toDouble(),
        maxX: now.millisecondsSinceEpoch.toDouble(),
        minY: minY,
        maxY: maxY,
        lineBarsData: [
          LineChartBarData(
            spots: data,
            isCurved: false,
            color: const Color.fromARGB(255, 15, 65, 100),
            barWidth: 1,
            belowBarData: BarAreaData(
                show: true, color: const Color.fromARGB(150, 170, 220, 240)),
            dotData: const FlDotData(show: false),
          )
        ],
        titlesData: FlTitlesData(
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              minIncluded: false,
              maxIncluded: false,
              interval: 86400000,
              showTitles: true,
              getTitlesWidget: (value, meta) {
                DateTime date =
                    DateTime.fromMillisecondsSinceEpoch(value.toInt());
                return SideTitleWidget(
                  space: 2,
                  meta: meta,
                  child: Text("${date.day}.${date.month}",
                      style: const TextStyle(fontSize: 14)),
                );
              },
            ),
          ),
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 40,
              minIncluded: false,
              maxIncluded: false,
              getTitlesWidget: (value, meta) {
                int xValue = value.toInt();
                return SideTitleWidget(
                  space: 3,
                  meta: meta,
                  child: Text("${_formatWithSuffix(xValue)}${'°C'}",
                      style: const TextStyle(fontSize: 14)),
                );
              },
            ),
          ),
          topTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          rightTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
        ),
        borderData: FlBorderData(show: true),
        gridData: const FlGridData(show: true),
      )),
    );
  }

  int _getLastValue(BuildContext context) {
    final readings = Provider.of<List<Reading>>(context);
    return readings.isNotEmpty ? readings.last.temperatureOutside.toInt() : 0;
  }

  String _formatWithSuffix(int value) {
    if (value >= 1000000) {
      return "${(value / 1000000).toInt().toStringAsFixed(1)}M";
    } else if (value >= 1000) {
      return "${(value / 1000).toInt().toStringAsFixed(1)}K";
    } else {
      return value.toString();
    }
  }

  Widget _buildForecastTile(Weather weather) {
    final temperature = weather.temperature?.celsius;
    final code = weather.weatherConditionCode;
    final date = weather.date;

    return SizedBox(
      width: 120,
      child: Card(
        color: const Color.fromARGB(255, 240, 252, 253),
        elevation: 4,
        margin: const EdgeInsets.all(8),
        child: Container(
          padding: EdgeInsets.all(10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              code == null
                  ? SpinKitSquareCircle(
                      color: Color.fromARGB(255, 15, 65, 100),
                      size: 30,
                    )
                  : Image.asset(
                      _getIconById(code),
                      width: 50,
                      height: 50,
                    ),
                date != null
                  ? Text(
                      DateFormat('dd.MM HH:mm').format(date),
                      style: const TextStyle(fontSize: 14, color: Color.fromARGB(255, 15, 65, 100)),
                    )
                  : SpinKitSquareCircle(
                      color: Color.fromARGB(255, 15, 65, 100),
                      size: 30,
                    ),
              temperature != null
                  ? Text('${temperature.toStringAsFixed(1)}°C', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color.fromARGB(255, 15, 65, 100)))
                  : const Text('—°C', style: TextStyle(fontSize: 20, color: Color.fromARGB(255, 15, 65, 100))),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildForecast(BuildContext context, forecast) {
    return FutureBuilder<List<Weather>>(
      future: forecast,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
              child: SpinKitSquareCircle(
            color: Color.fromARGB(255, 15, 65, 100),
            size: 50,
          ));
        } else if (snapshot.hasError) {
          return Center(
            child: Text('Brak danych',
            style: TextStyle(color: Color.fromARGB(255, 15, 65, 100), fontSize: 25, fontWeight: FontWeight.w500),),
          );
        } else {
          final weatherList = snapshot.data;
          return weatherList == null
              ? SpinKitSquareCircle(
                  color: Color.fromARGB(255, 15, 65, 100),
                  size: 50,
                )
              : SizedBox(
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: weatherList.length,
                    itemBuilder: (context, index) {
                      return _buildForecastTile(weatherList[index]);
                    },
                  ),
                );
        }
      },
    );
  }

  String _getIconById(int id) {
    if (id == 800) {
      return 'assets/icons/sun.png';
    } else if (id >= 200 && id < 300) {
      return 'assets/weather/thunder.png';
    } else if (id >= 300 && id < 400) {
      return 'assets/weather/drizzle.png';
    } else if (id >= 500 && id < 600) {
      return 'assets/weather/rain.png';
    } else if (id >= 600 && id < 700) {
      return 'assets/weather/snow.png';
    } else if (id >= 700 && id < 800) {
      return 'assets/weather/fog.png';
    } else if (id > 800) {
      switch (id) {
        case 801:
          return 'assets/weather/clouds/sun_11-25.png';
        case 802:
          return 'assets/weather/clouds/sun_25-50.png';
        case 803:
          return 'assets/weather/clouds/sun_51-84.png';
        case 804:
          return 'assets/weather/clouds/clouds_85-100.png';
        default:
          return 'assets/images/blank.png';
      }
    }
    return 'assets/images/blank.png';
  }

  String _getIconByWeather(weather) {
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
    return 'assets/icons/sun.png';
  }
}
