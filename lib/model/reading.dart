import 'package:cloud_firestore/cloud_firestore.dart';

class Reading{
  final double pressure;
  final double temperatureOutside;
  final double temperatureInside;
  final double humidity;
  final double light;
  final double co;
  final DateTime time;

  Reading({required this.pressure, required this.temperatureOutside,
    required this.temperatureInside, required this.humidity,
    required this.light, required this.co, required this.time});

  factory Reading.fromFirebase(Map<String, dynamic> map){
    final double pressure;
    final double temperatureOutside;
    final double temperatureInside;
    final double humidity;
    final double light;
    final double co;
    final DateTime time;

    temperatureOutside = map['bmp_temperature'] as double;
    temperatureInside = map['dht_temperature'] as double;
    pressure = map['bmp_pressure'] as double;
    light = map['lightValue'] as double;
    co = map['mqValue'] as double;
    humidity = map['dht_humidity'] as double;
    time = (map['tsms'] as Timestamp).toDate();

    return Reading(
      pressure: pressure,
        temperatureInside: temperatureInside,
        temperatureOutside: temperatureOutside,
        co: co,
        light: light,
        time: time,
        humidity:humidity
    );
  }
}