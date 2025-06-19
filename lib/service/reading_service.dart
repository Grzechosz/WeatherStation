import 'package:cloud_firestore/cloud_firestore.dart';

import '../model/reading.dart';


class ReadingService {
  CollectionReference? sensorCollection =
  FirebaseFirestore.instance.collection('weather-data');
  static bool isLoaded = false;
  ReadingService();

  get readings {
    isLoaded = false;
    return sensorCollection!.snapshots().map((snapshot) => _readingsFromSnapshot(snapshot));
  }

  List<Reading> _readingsFromSnapshot(QuerySnapshot snapshot) {
    List<Reading> items = snapshot.docs
        .map((e) => Reading.fromFirebase(e.data() as Map<String, dynamic>))
        .toList();
    isLoaded = true;
    return items;
  }
}
