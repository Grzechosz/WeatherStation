import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:weather_station/model/reading.dart';
import 'package:weather_station/screen/variables/reading_card.dart';
import 'package:weather_station/service/reading_service.dart';

class MainPage extends HookWidget {
  const MainPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color.fromARGB(255, 170, 220, 240),
      body: Padding(
        padding: const EdgeInsets.only(top: 50, left: 20, right: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              alignment: Alignment.center,
              child: const Text(
                "Twoja pogoda",
                style: TextStyle(
                  fontSize: 50,
                  fontWeight: FontWeight.w800,
                  color: Color.fromARGB(255, 15, 65, 100),
                ),
              ),
            ),
            const SizedBox(height: 10),
            StreamBuilder<List<Reading>>(
              stream: ReadingService().readings,
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const Center(
                    child: SpinKitSquareCircle(color: Color.fromARGB(255, 15, 65, 100), size: 100),
                  );
                }
                final readings = snapshot.data!;
                if (readings.isEmpty) {
                  return Container(
                    alignment: Alignment.center,
                    child: const Text(
                      "Brak danych",
                      style: TextStyle(
                        fontSize: 50,
                        fontWeight: FontWeight.w800,
                        color: Color.fromARGB(255, 15, 65, 100),
                      ),
                    ),
                  ) ;
                }
                final latest = readings.last;
                return Expanded(child: ReadingCard(reading: latest));
              },
            ),
          ],
        ),
      ),
    );
  }
}