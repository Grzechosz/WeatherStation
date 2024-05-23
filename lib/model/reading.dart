import 'package:cloud_firestore/cloud_firestore.dart';

class Reading{
  final double temperature;
  final int light;
  final double humidity;
  final int soilMoisture;
  final DateTime time;

  Reading({required this.temperature, required this.light, required this.humidity, required this.soilMoisture, required this.time});

  factory Reading.fromFirebase(Map<String, dynamic> map){
    final double temperature;
    final int light;
    final double humidity;
    final int soilMoisture;
    final DateTime time;

    temperature = map['temperature'] as double;
    light = map['light'] as int;
    soilMoisture = map['soil_moisture'] as int;
    humidity = map['humidity'] as double;
    time = (map['time'] as Timestamp).toDate();

    return Reading(temperature: temperature, light: light, humidity: humidity, soilMoisture: soilMoisture, time: time);
  }
}