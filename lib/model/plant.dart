import 'package:cloud_firestore/cloud_firestore.dart';

class Plant{
  final int id;
  final String name;
  final String imageUrl;
  final DateTime createdDate;
  final String sensorId;

  Plant({required this.id, required this.name, required this.imageUrl, required this.createdDate, required this.sensorId});

  factory Plant.fromFirebase(Map<String, dynamic> map){
    final int id;
    final String name;
    final String imageUrl;
    final DateTime createdDate;
    final String sensorId;

    id = map['id'] as int;
    name = map['name'];
    imageUrl = map['imageUrl'];
    createdDate = (map['createdDate'] as Timestamp).toDate();
    sensorId = map['sensorId'];

    return Plant(id: id ,name: name, imageUrl: imageUrl, createdDate: createdDate, sensorId: sensorId);
  }

  Future<Map<String, dynamic>> toFirebase() async{
    Map<String, dynamic> map = {
      'id': id,
      'name': name,
      'imageUrl': imageUrl,
      'createdDate': Timestamp.now(),
      'sensorId': sensorId
    };
    return map;
  }
}