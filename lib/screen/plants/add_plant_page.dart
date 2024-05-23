import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:garden_control/service/plant_service.dart';
import 'package:garden_control/service/sensor_service.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

import '../../model/plant.dart';
import '../../model/sensor.dart';

class AddPlantPage extends HookWidget {
  AddPlantPage({super.key});
  final TextEditingController controller = TextEditingController(text: '');
  final formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    final plantNameFieldContainer =
        PlantNameFieldContainer(formKey: formKey, nameController: controller);
    final ValueNotifier<Sensor?> selectedSensor = useState(null);

    var image = useState('assets/images/blank.png');
    return Scaffold(
        appBar: AppBar(
          actions: [
            Container(
                margin: const EdgeInsets.only(right: 20, top: 5),
                child: CircleAvatar(
                  radius: 30,
                  backgroundColor: Colors.teal,
                  child: IconButton(
                    icon: const Icon(
                      Icons.add,
                      color: Colors.white,
                    ),
                    onPressed: () async {
                      if (await _addPlantToDatabase(formKey, image.value,
                          controller.value.text, selectedSensor)) {
                        if (context.mounted) {
                          Navigator.of(context).pop();
                        }
                      }
                    },
                  ),
                )),
          ],
          backgroundColor: Colors.white,
          title: const Text(
            "Powrót",
            style: TextStyle(fontSize: 20),
          ),
        ),
        backgroundColor: Colors.white,
        body: ListView(
          physics: const NeverScrollableScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 30),
          children: <Widget>[
            Container(
              alignment: Alignment.center,
              margin: const EdgeInsets.only(top: 30, bottom: 50),
              child: const Text(
                "Dodawanie rośliny",
                style: TextStyle(
                    fontSize: 30,
                    fontWeight: FontWeight.w500,
                    color: Colors.teal),
              ),
            ),
            Container(
              margin: const EdgeInsets.only(bottom: 10),
              child: const Text(
                "Zdjęcie",
                style: TextStyle(fontSize: 20),
              ),
            ),
            Container(
              decoration: BoxDecoration(
                border: Border.all(width: 0.5),
                borderRadius: const BorderRadius.all(Radius.circular(30)),
              ),
              margin: const EdgeInsets.only(bottom: 30),
              child: AspectRatio(
                aspectRatio: 8 / 5,
                child: ClipRRect(
                    borderRadius: BorderRadius.circular(30),
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                          onTap: () async {
                            final pickedFile = await ImagePicker()
                                .pickImage(source: ImageSource.gallery);
                            if (pickedFile != null) {
                              image.value = pickedFile.path;
                            }
                          },
                          child: Ink.image(
                            image: _loadImage(image),
                            fit: BoxFit.cover,
                          )),
                    )),
              ),
            ),
            Container(
              margin: const EdgeInsets.only(bottom: 10),
              child: const Text(
                "Nazwa",
                style: TextStyle(fontSize: 20),
              ),
            ),
            plantNameFieldContainer,
            Container(
              margin: const EdgeInsets.only(bottom: 10, top: 10),
              child: const Text(
                "Sensor",
                style: TextStyle(fontSize: 20),
              ),
            ),
            Container(
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(30),
                  border: Border.all(width: 0.5)),
              padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 5),
              child: StreamProvider<List<Sensor>>(
                create: (context) => SensorService().sensors,
                initialData: const [],
                child: Consumer<List<Sensor>>(
                  builder: (BuildContext context, List<Sensor> sensors,
                      Widget? child) {
                    if (sensors.isEmpty) {
                      return const Center(
                        child: SpinKitWave(
                          color: Colors.teal,
                          size: 50,
                        ),
                      );
                    }
                    return DropdownButton<Sensor>(
                      underline: const SizedBox(),
                      isExpanded: true,
                      borderRadius: BorderRadius.circular(30),
                      hint: const Text(
                        "Wybierz sensor",
                        style: TextStyle(fontSize: 18, color: Colors.grey),
                      ),
                      value: selectedSensor.value,
                      items: sensors
                          .where((element) => element.isOccupied == false)
                          .map<DropdownMenuItem<Sensor>>((Sensor sensor) {
                        return DropdownMenuItem<Sensor>(
                          value: sensor,
                          child: Text(sensor.name),
                        );
                      }).toList(),
                      onChanged: (e) {
                        selectedSensor.value = e!;
                      },
                    );
                  },
                ),
              ),
            )
          ],
        ));
  }

  ImageProvider _loadImage(ValueNotifier<String> image) {
    File file = File(image.value);
    if (file.existsSync()) {
      return FileImage(file);
    } else {
      return AssetImage(image.value);
    }
  }

  Future<bool> _addPlantToDatabase(
      GlobalKey<FormState> formKey,
      String imagePath,
      String name,
      ValueNotifier<Sensor?> selectedSensor) async {
    if (formKey.currentState!.validate() &&
        imagePath != 'assets/images/blank.png' &&
        selectedSensor.value != null) {
      List<String> pathParts = imagePath.split('/');
      String fileName = pathParts.last;
      PlantService plantService = PlantService();
      Plant plant = Plant(
          id: DateTime.now().millisecondsSinceEpoch,
          name: name,
          imageUrl: fileName,
          createdDate: DateTime.now(),
          sensorId: selectedSensor.value!.id);
      plantService.uploadPlant(plant, File(imagePath));
      Sensor oldSensor = selectedSensor.value!;
      Sensor sensor =
          Sensor(id: oldSensor.id, isOccupied: true, name: oldSensor.name);
      SensorService().updateSensor(sensor);
      return true;
    }
    return false;
  }
}

class PlantNameFieldContainer extends StatelessWidget {
  final GlobalKey<FormState> formKey;
  final TextEditingController nameController;
  const PlantNameFieldContainer(
      {super.key, required this.formKey, required this.nameController});

  @override
  Widget build(BuildContext context) {
    return Container(
        // margin: const EdgeInsets.only(bottom: 15),
        decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(30),
            border: Border.all(width: 0.5),
            color: Colors.white),
        padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 5),
        child: Form(
          key: formKey,
          child: TextFormField(
              controller: nameController,
              onChanged: (value) {
                formKey.currentState!.validate();
              },
              validator: (val) => val!.isEmpty ? "Wprowadź nazwę" : null,
              decoration: const InputDecoration(
                  hintStyle: TextStyle(fontSize: 18, color: Colors.grey),
                  hintText: 'Wprowadź nazwę',
                  border: InputBorder.none)),
        ));
  }
}
