import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:garden_control/model/reading.dart';


class ReadingService {
  final String sensorId;
  CollectionReference? sensorCollection =
  FirebaseFirestore.instance.collection('sensors');
  static bool isLoaded = false;
  ReadingService({required this.sensorId});

  get readings {
    isLoaded = false;
    return sensorCollection!.doc(sensorId).collection('readings').snapshots().map((snapshot) => _readingsFromSnapshot(snapshot));
  }

  List<Reading> _readingsFromSnapshot(QuerySnapshot snapshot) {
    List<Reading> items = snapshot.docs
        .map((e) => Reading.fromFirebase(e.data() as Map<String, dynamic>))
        .toList();
    isLoaded = true;
    return items;
  }
}
