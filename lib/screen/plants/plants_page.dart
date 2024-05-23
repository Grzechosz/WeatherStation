import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:garden_control/screen/plants/add_plant_page.dart';
import 'package:garden_control/screen/plants/plant_list_tile.dart';
import 'package:garden_control/service/plant_service.dart';
import 'package:provider/provider.dart';

import '../../model/plant.dart';

class PlantsPage extends HookWidget {
  const PlantsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        floatingActionButton: FloatingActionButton.extended(
          onPressed: () => Navigator.push(context,
              PageRouteBuilder(pageBuilder: (q,w,e) => AddPlantPage(),
                  transitionsBuilder: (context, animation, secondaryAnimation, child) =>
                      SlideTransition(
                        position: Tween(
                          begin: const Offset(0.0, -1.0),
                          end: const Offset(0.0, 0.0),)
                            .animate(animation),
                        child: child,
                      )
              )
          ),
          label: const Text('Add'),
          icon: const Icon(Icons.add, color: Colors.black, size: 25),
        ),
        body: Padding(
            padding: const EdgeInsets.only(top: 40),
            child: Column(
              children: [
                Container(
                  margin: const EdgeInsets.only(left: 30),
                  alignment: Alignment.topLeft,
                  child: const Text("Twoje rośliny",
                    style: TextStyle(
                        fontSize: 35,
                        fontWeight: FontWeight.w600,
                        color: Colors.teal
                    ),),
                ),
                _buildPlants()
              ],
            )
        )
    );
  }

  StreamProvider _buildPlants(){
    return StreamProvider<List<Plant>>.value(
      value: PlantService().plants,
      initialData: const [],
      builder: (context, child) {
        return Expanded(
          child: _buildPlantsList(context),
        );
      },
    );
  }

  Widget _buildPlantsList(BuildContext context){
    final plants = Provider.of<List<Plant>>(context);

    if(PlantService.isLoaded){
      return plants.isNotEmpty ? ListView.builder(
          scrollDirection: Axis.vertical,
          shrinkWrap: true,
          itemCount: plants.length,
          itemBuilder:(context, index) =>
              PlantListTile(plant: plants[index])) :
      const Center(
        child: Text("Brak Roślinek",
          style: TextStyle(letterSpacing: 0.5,
            fontSize: 30,
            color: Colors.black,
            fontWeight: FontWeight.w600,
          ),),
      );

    }else{
      return const Center(
        child: SpinKitWave(
          color: Colors.teal,
          size: 50,
        ),
      );
    }
  }
}