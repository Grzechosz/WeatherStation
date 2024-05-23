import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:garden_control/model/plant.dart';
import 'package:garden_control/service/storage_service.dart';

class PlantService{
  static final StorageService storageService = StorageService();

  CollectionReference? plantCollection = FirebaseFirestore
      .instance.collection('plants');
  static bool isLoaded = false;

    Stream<List<Plant>> get plants{
    isLoaded = false;
    return plantCollection!
        .snapshots()
        .map(_plantsFromSnapshot);
  }

  List<Plant> _plantsFromSnapshot(QuerySnapshot snapshot){
    List<Plant> items = snapshot.docs.map(
            (e) => Plant.fromFirebase(
            e.data() as Map<String, dynamic>)
    ).toList();
    isLoaded = true;
    return items;
  }

  // upload product to firebase
  Future uploadPlant(Plant plant, File image) async {
    storageService.uploadPlantImage(image);
    plantCollection!
        .doc(plant.id.toString())
        .set(await plant.toFirebase());
  }

  // delete product from firebase
  Future deletePlant(Plant plant) async {
    storageService.deletePlantImage(plant);
    await plantCollection!.doc(plant.id.toString())
        .delete();
  }
}