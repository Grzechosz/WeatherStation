import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:provider/provider.dart';

import '../../model/reading.dart';
import '../../service/reading_service.dart';

class ReadingChartPage extends HookWidget {
  final String dataType;
  final String title;

  const ReadingChartPage({
    super.key,
    required this.dataType,
    required this.title,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(title),
        backgroundColor: Colors.teal,
      ),
      body: StreamProvider<List<Reading>>.value(
        value: ReadingService().readings,
        initialData: const [],
        builder: (context, child) {
          return _buildChart(context);
        },
      ),
    );
  }

  Widget _buildChart(BuildContext context) {
    final readings = Provider.of<List<Reading>>(context);

    if (!ReadingService.isLoaded) {
      return const Center(
        child: SpinKitWave(color: Colors.teal, size: 50),
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

    final List<FlSpot> data = readings.map((e) {
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

    return Padding(
      padding: const EdgeInsets.all(16),
      child: LineChart(LineChartData(
        lineBarsData: [
          LineChartBarData(
            spots: data,
            isCurved: true,
            color: Colors.teal,
            barWidth: 2,
            belowBarData: BarAreaData(show: true, color: Colors.teal.withOpacity(0.2)),
            dotData: FlDotData(show: false),
          )
        ],
        titlesData: FlTitlesData(
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              interval: _calculateTimeInterval(data),
              getTitlesWidget: (value, meta) {
                DateTime date = DateTime.fromMillisecondsSinceEpoch(value.toInt());
                return SideTitleWidget(
                  axisSide: meta.axisSide,
                  child: Text("${date.day}.${date.month}"),
                );
              },
            ),
          ),
          leftTitles: AxisTitles(
            sideTitles: SideTitles(showTitles: true, reservedSize: 40),
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

  double _calculateTimeInterval(List<FlSpot> data) {
    if (data.length < 2) return 100000000;
    final min = data.first.x;
    final max = data.last.x;
    return ((max - min) / 5).clamp(60000 * 60, 100000000);
  }
}
