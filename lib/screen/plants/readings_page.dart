import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:garden_control/service/reading_service.dart';
import 'package:provider/provider.dart';

import '../../model/plant.dart';
import '../../model/reading.dart';

class ReadingPage extends HookWidget {
  final Plant plant;
  final ImageProvider image;
  const ReadingPage({super.key, required this.plant, required this.image});

  @override
  Widget build(BuildContext context) {
    final choseButton = useState(0);
    return Scaffold(
      body: StreamProvider<List<Reading>>.value(
        value: ReadingService(sensorId: plant.sensorId).readings,
        initialData: const [],
        builder: (context, child) {
          return _buildBody(choseButton, context);
        },
      ),
      appBar: AppBar(
        toolbarHeight: 75,
        backgroundColor: Colors.transparent,
        title: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                image: DecorationImage(fit: BoxFit.cover, image: image),
                borderRadius: const BorderRadius.all(Radius.circular(90)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.3),
                    spreadRadius: 2,
                    blurRadius: 4,
                    offset: const Offset(0, 3), // changes position of shadow
                  ),
                ],
              ),
            ),
            const SizedBox(
              width: 20,
            ),
            Text(
              plant.name,
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBody(ValueNotifier<int> choseButton, BuildContext context) {
    final readings = Provider.of<List<Reading>>(context);

    if (ReadingService.isLoaded && readings.isNotEmpty) {
      final temperatures = readings
          .map((e) =>
              FlSpot(e.time.millisecondsSinceEpoch.toDouble(), e.temperature))
          .toList();
      final soilMoistures = readings
          .map((e) => FlSpot(e.time.millisecondsSinceEpoch.toDouble(),
              e.soilMoisture.toDouble()))
          .toList();
      final humidities = readings
          .map((e) => FlSpot(
              e.time.millisecondsSinceEpoch.toDouble(), e.humidity.toDouble()))
          .toList();
      final lights = readings
          .map((e) => FlSpot(
              e.time.millisecondsSinceEpoch.toDouble(), e.light.toDouble()))
          .toList();

      return ListView(
        children: [
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 25, vertical: 12),
            padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: const BorderRadius.all(Radius.circular(30)),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.3),
                  spreadRadius: 2,
                  blurRadius: 4,
                  offset: const Offset(0, 3), // changes position of shadow
                ),
              ],
            ),
            height: 300,
            child: LineChart(LineChartData(
              lineBarsData: [
                LineChartBarData(
                  spots: _getGraphValues(choseButton, temperatures,
                      soilMoistures, humidities, lights),
                  isCurved: false,
                  color: Colors.teal,
                  barWidth: 2,
                  belowBarData: BarAreaData(show: true, color: Colors.black26),
                ),
              ],
              titlesData: FlTitlesData(
                bottomTitles: AxisTitles(
                  sideTitles: SideTitles(
                      showTitles: true,
                      interval: 100000000,
                      getTitlesWidget: (value, meta) {
                        DateTime date =
                            DateTime.fromMillisecondsSinceEpoch(value.toInt());
                        return SideTitleWidget(
                          space: 1,
                          axisSide: meta.axisSide,
                          child: Text('${date.day}.${date.month}'),
                        );
                      }),
                ),
                topTitles:
                    const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                rightTitles: const AxisTitles(
                  sideTitles: SideTitles(showTitles: false),
                ),
                leftTitles: AxisTitles(
                  sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 40,
                      interval: _getInterval(choseButton).toDouble()),
                ),
              ),
              borderData: FlBorderData(show: true),
              gridData: const FlGridData(show: true),
            )),
          ),
          standardButton("Nasłonecznienie", "${lights.last.y.toString()}%",
              choseButton, 0),
          standardButton("Wilgotność", "${humidities.last.y}%", choseButton, 1),
          standardButton(
              "Temperatura", "${temperatures.last.y}°C", choseButton, 2),
          standardButton(
              "Wilgotność gleby", "${soilMoistures.last.y}%", choseButton, 3)
        ],
      );
    } else if (readings.isEmpty) {
      return const Center(
        child: Text(
          "Brak Danych",
          style: TextStyle(
            letterSpacing: 0.5,
            fontSize: 30,
            color: Colors.black,
            fontWeight: FontWeight.w600,
          ),
        ),
      );
    } else {
      return const Center(
        child: SpinKitWave(
          color: Colors.teal,
          size: 50,
        ),
      );
    }
  }

  Widget standardButton(String title, String data,
      ValueNotifier<int> choseButton, int buttonNumber) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 25, vertical: 12),
      child: ElevatedButton(
        onPressed: () {
          choseButton.value = buttonNumber;
        },
        style: ButtonStyle(
          backgroundColor: MaterialStateProperty.resolveWith<Color>(
            (Set<MaterialState> states) {
              if (states.contains(MaterialState.pressed) ||
                  choseButton.value == buttonNumber) {
                return Colors.teal.shade100;
              }
              return Colors.white; // Default color
            },
          ),
          shape: MaterialStateProperty.all<RoundedRectangleBorder>(
            RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20.0),
            ),
          ),
          shadowColor: MaterialStateProperty.all<Color>(Colors.grey),
          elevation: MaterialStateProperty.all<double>(5.0),
        ),
        child: Padding(
            padding:
                const EdgeInsets.symmetric(vertical: 10.0, horizontal: 20.0),
            child: Row(
              children: [
                Text(
                  data,
                  style: const TextStyle(
                    fontSize: 20,
                    color: Colors.black,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(
                  width: 10,
                ),
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 20,
                    color: Colors.black,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            )),
      ),
    );
  }

  List<FlSpot> _getGraphValues(
      ValueNotifier<int> choseButton,
      List<FlSpot> temperatures,
      List<FlSpot> soilMoistures,
      List<FlSpot> humidities,
      List<FlSpot> lights) {
    int valueButton = choseButton.value;
    if (valueButton == 0) {
      return lights;
    } else if (valueButton == 1) {
      return humidities;
    } else if (valueButton == 2) {
      return temperatures;
    } else {
      return soilMoistures;
    }
  }

  int _getInterval(ValueNotifier<int> choseButton) {
    int valueButton = choseButton.value;
    if (valueButton == 0) {
      return 10;
    } else if (valueButton == 1) {
      return 10;
    } else if (valueButton == 2) {
      return 2;
    } else {
      return 5;
    }
  }
}