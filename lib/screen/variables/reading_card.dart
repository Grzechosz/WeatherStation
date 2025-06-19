import 'package:flutter/material.dart';
import 'package:weather_station/screen/variables/readings_page.dart';

import '../../model/reading.dart';

class ReadingCard extends StatelessWidget {
  final Reading reading;

  const ReadingCard({super.key, required this.reading});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        children: [
          _buildMainTile(
            Icons.wb_sunny,
            'Temperatura na zewnątrz',
            '${reading.temperatureOutside.toStringAsFixed(0)}°C',
              () => _navigateToSensor(
              context, 'temperatureOutside', 'Temperatura na zewnątrz'),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: _buildTile(
                    Icons.home,
                    '${reading.temperatureInside.toStringAsFixed(0)}°C',
                    const Color.fromARGB(255, 255, 240, 225),
                    () => _navigateToSensor(
                        context, 'temperatureInside', 'Temperatura w środku')),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _buildTile(
                    Icons.speed,
                    '${(reading.pressure / 100).toStringAsFixed(0)}hPa',
                    const Color.fromARGB(255, 215, 240, 240),
                    () => _navigateToSensor(context, 'pressure', 'Ciśnienie atmosferyczne')),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: _buildTile(
                    Icons.water_drop,
                    '${reading.humidity.toStringAsFixed(0)}%',
                    const Color.fromARGB(255, 210, 245, 215),
                    () => _navigateToSensor(context, 'humidity', 'Wilgotność powietrza')),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _buildTile(
                    Icons.lightbulb,
                    '${reading.light.toStringAsFixed(0)}%',
                    const Color.fromARGB(255, 255, 240, 190),
                    () => _navigateToSensor(context, 'light', 'Natężenie światła')),
              ),
            ],
          ),
          const SizedBox(height: 10),
          _buildTile(
              Icons.cloud,
              '${reading.co.toStringAsFixed(0)}ppm',
              const Color.fromARGB(255, 250, 245, 230),
              () => _navigateToSensor(context, 'co', 'Stężenie tlenku węgla')),
          const SizedBox(height: 10),
          _buildTile(
              Icons.adb_outlined,
              'Dowiedz się czegoś ciekawego!',
              const Color.fromARGB(255, 250, 245, 230),
              () => _navigateToSensor(context, 'co', 'co')),
        ],
      ),
    );
  }

  Widget _buildTile(
      IconData icon, String value, Color backgroundColor, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 5),
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(25),
          border: Border.all(color: Colors.teal.shade100),
        ),
        child: Row(
          children: [
            Icon(icon, color: Colors.teal, size: 80),
            const SizedBox(width: 5),
            Expanded(
              child: Text(
                value,
                style: const TextStyle(
                    fontSize: 25,
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
      IconData icon, String title, String value, VoidCallback onTap) {
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
                  Icon(icon, color: Colors.deepOrange, size: 150),
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
              ))
            ],
          ),
        ));
  }

  void _navigateToSensor(BuildContext context, String datatype, String title) {
    Navigator.push(
        context,
        PageRouteBuilder(
            pageBuilder: (q, w, e) => ReadingChartPage(
                  dataType: datatype,
                  title: title,
                ),
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
}
