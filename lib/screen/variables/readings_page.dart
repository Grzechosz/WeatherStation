import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:provider/provider.dart';

import '../../model/reading.dart';
import '../../service/reading_service.dart';

class ReadingChartPage extends HookWidget {
  final String dataType;
  final String title;
  final Color styleColor;
  final String unit;

  const ReadingChartPage({
    super.key,
    required this.dataType,
    required this.title,
    required this.styleColor,
    required this.unit
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(title, style: const TextStyle(
          fontWeight: FontWeight.w800,
          color: Color.fromARGB(255, 15, 65, 100),
        ),
        ),
          backgroundColor: const Color.fromARGB(255, 170, 220, 240)
      ),
      body: StreamProvider<List<Reading>>.value(
        value: ReadingService().readings,
        initialData: const [],
        builder: (context, child) {
          return SingleChildScrollView(
            child: Column(
              children: [
                Container(
                  margin: MediaQuery.of(context).orientation
                      == Orientation.portrait
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
                      aspectRatio: MediaQuery.of(context).orientation
                          == Orientation.portrait
                          ? 1.2
                          : MediaQuery.of(context).devicePixelRatio,
                      child: _buildChart(context),
                    ),
                  ),
                ),
                SizedBox(
                  height: 10,
                ),
                Container(
                  margin: MediaQuery.of(context).orientation
                      == Orientation.portrait
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
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Container(
                                  decoration: BoxDecoration(
                                    color: styleColor,
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  padding: EdgeInsetsGeometry.all(12),
                                  child: Image.asset(_getImageAsset(), scale: 7)
                              ),
                              SizedBox(
                                width: 20,
                              ),
                              Text(
                                "${_formatWithSuffix(_getLastValue(context))}${unit.length>2 ? "\n" : ""}${unit}",
                                style: TextStyle(
                                    fontWeight: FontWeight.w800,
                                    fontSize: 70,
                                    color: Color.fromARGB(255, 15, 65, 100),
                                  height: 0.8
                                ),
                              )
                            ],
                          ),
                        SizedBox(
                          height: 20,
                        ),
                        Text(
                          'W tej chwili',
                          style:
                          TextStyle(
                            fontSize: 40,
                            fontWeight: FontWeight.w600,
                            color: Color.fromARGB(255, 15, 65, 100)
                          ),
                        )
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ) ;
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

    final recentReadings = readings.where((e) => e.time.isAfter(fiveDaysAgo)).toList();

    final List<FlSpot> data = recentReadings.map((e) {
      final x = e.time.millisecondsSinceEpoch.toDouble();
      final y = switch (dataType) {
        'temperatureInside' => e.temperatureInside,
        'temperatureOutside' => e.temperatureOutside,
        'humidity' => e.humidity,
        'light' => e.light,
        'pressure' => e.pressure/100.toInt(),
        'co' => e.co,
        _ => 0.0,
      };
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
            belowBarData: BarAreaData(show: true, color: const Color.fromARGB(150, 170, 220, 240)),
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
                DateTime date = DateTime.fromMillisecondsSinceEpoch(value.toInt());
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
                  child: Text("${_formatWithSuffix(xValue)}${unit.length>2 ? "\n" : ""}${unit}",
                      style: const TextStyle(fontSize: 14)
                  ),
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

  int _getLastValue(BuildContext context){
    final readings = Provider.of<List<Reading>>(context);

    switch (dataType) {
      case 'temperatureInside': 
        return readings.isNotEmpty ? readings.last.temperatureInside.toInt() : 0;
      case 'temperatureOutside':
        return readings.isNotEmpty ? readings.last.temperatureOutside.toInt() : 0;
      case 'humidity':        
        return readings.isNotEmpty ? readings.last.humidity.toInt() : 0;
      case 'light':        
        return readings.isNotEmpty ? readings.last.light.toInt() : 0;
      case 'pressure':        
        return readings.isNotEmpty ? (readings.last.pressure/100).toInt() : 0;
      case 'co':        
        return readings.isNotEmpty ? readings.last.co.toInt() : 0;
    }
    return 0;
  }

  String _formatWithSuffix(int value) {
    if (value >= 1000000) {
      return "${(value / 1000000).toStringAsFixed(1)}M";
    } else if (value >= 1000) {
      return "${(value / 1000).toStringAsFixed(1)}K";
    } else {
      return value.toString();
    }
  }

  String _getImageAsset() {
    switch (dataType) {
      case 'temperatureOutside':
        return 'assets/icons/sun.png';
      case 'humidity':
        return 'assets/icons/glass-of-water.png';
      case 'light':
        return 'assets/icons/light-bulb.png';
      case 'pressure':
        return 'assets/icons/balloon.png';
      case 'co':
        return 'assets/icons/carbon-monoxide.png';
    }
    return 'assets/icons/house.png';
  }
}
