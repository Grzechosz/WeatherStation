import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:provider/provider.dart';

import '../../model/reading.dart';
import '../../service/reading_service.dart';

class ForecastPage extends HookWidget {
  final String dataType;
  final String title;

  const ForecastPage({
    super.key,
    required this.dataType,
    required this.title,
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
                AspectRatio(
                  aspectRatio: MediaQuery.of(context).orientation
                      == Orientation.portrait
                      ? 1.2
                      : MediaQuery.of(context).devicePixelRatio,
                  child: _buildChart(context),
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
        'pressure' => e.pressure,
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
              reservedSize: 45,
              minIncluded: false,
              maxIncluded: false,
              getTitlesWidget: (value, meta) {
                double temp = value.toDouble();
                return SideTitleWidget(
                  space: 5,
                  meta: meta,
                  child: Text("${temp}°C",
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
}
