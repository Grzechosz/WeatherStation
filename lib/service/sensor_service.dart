import 'package:cloud_firestore/cloud_firestore.dart';

import '../model/sensor.dart';

class SensorService {
  CollectionReference? sensorCollection =
      FirebaseFirestore.instance.collection('sensors');

  Stream<List<Sensor>> get sensors {
    return sensorCollection!.snapshots().map(_sensorsFromSnapshot);
  }

  List<Sensor> _sensorsFromSnapshot(QuerySnapshot snapshot) {
    List<Sensor> items = snapshot.docs
        .map((e) => Sensor.fromFirebase(e.data() as Map<String, dynamic>))
        .toList();
    return items;
  }

  Future<Sensor?> getSensorById(String id) async{
    DocumentSnapshot doc = await sensorCollection!
        .doc(id).get();
    if(doc.exists){
      return Sensor.fromFirebase(doc.data() as Map<String, dynamic>);
    }
    return null;
  }

  Future updateSensor(Sensor sensor) async {
    sensorCollection!
        .doc(sensor.id)
        .update(
            sensor.toMap());
  }
}
