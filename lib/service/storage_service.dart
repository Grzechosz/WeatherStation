import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';

import '../model/plant.dart';

class StorageService extends ChangeNotifier{

  Reference get firebaseStorage => FirebaseStorage.instance.ref();

  // download product image from firebase storage
  Future<String> getPlantImage(Plant plant) {
    return firebaseStorage
        .child("plants/")
        .child(plant.imageUrl)
        .getDownloadURL();
  }

  // upload product image to firebase storage
  Future uploadPlantImage(File image) async {
    final metadata = SettableMetadata(contentType: "image/jpeg");
    final uploadFile = image;
    List<String> pathParts = image.path.split('/');
    String fileName = pathParts.last;
    final uploadTask = firebaseStorage
        .child("plants/")
        .child(fileName)
        .putFile(uploadFile, metadata);
    uploadTask.snapshotEvents.listen((TaskSnapshot taskSnapshot) {
      switch (taskSnapshot.state) {
        case TaskState.running:
          break;
        case TaskState.paused:
          break;
        case TaskState.canceled:
          break;
        case TaskState.error:
          break;
        case TaskState.success:
          notifyListeners();
          break;
      }
    });
  }

  // delete product image from firebase storage
  void deletePlantImage(Plant product){
    firebaseStorage
        .child("plants/")
        .child(product.imageUrl)
        .delete();
  }
}