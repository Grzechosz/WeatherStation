// import 'package:cached_network_image/cached_network_image.dart';
// import 'package:firebase_cached_image/firebase_cached_image.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_hooks/flutter_hooks.dart';
// import 'package:flutter_spinkit/flutter_spinkit.dart';
// import 'package:weather_station/screen/plants/readings_page.dart';
// /*/
// import '../../service/sensor_service.dart';
// import '../../service/storage_service.dart';
//
// class PlantListTile extends HookWidget {
//   PlantListTile({super.key});
//
//   @override
//   Widget build(BuildContext context) {
//     double width = MediaQuery.of(context).size.width;
//     ImageProvider provider =
//         const AssetImage('assets/images/cactus.jpg');
//     final ValueNotifier<ImageProvider> providerNotifier =
//       useState(const AssetImage('assets/images/cactus.jpg'));
//
//     useMemoized(() => storageService.addListener(() async {
//           if (context.mounted) {
//             provider = await _getImageUrl(storageService);
//             providerNotifier.value = provider;
//           }
//         }));
//
//     return InkWell(
//       borderRadius: const BorderRadius.all(Radius.circular(40)),
//       highlightColor: Colors.teal.shade100,
//       splashColor: Colors.grey.shade200,
//       onTap: () => _navigateToSensor(context, provider),
//       onLongPress: () => _deleteOrEdit(context),
//       child: Container(
//         margin: const EdgeInsets.only(bottom: 15, top: 15),
//         child: AspectRatio(
//           aspectRatio: 8 / 5,
//           child: FutureBuilder<String>(
//             future: _loadImage(storageService),
//             builder: (context, snapshot) {
//               if (snapshot.connectionState == ConnectionState.waiting) {
//                 return const Center(
//                   child: SpinKitWave(
//                     color: Colors.teal,
//                     size: 50,
//                   ),
//                 );
//               } else if (snapshot.hasError) {
//                 return const Center(
//                   child: SpinKitWave(
//                     color: Colors.teal,
//                     size: 50,
//                   ),
//                 );
//               } else {
//                 return CachedNetworkImage(
//                     imageUrl: snapshot.data!,
//                     progressIndicatorBuilder:
//                         (context, url, downloadProgress) => const Center(
//                               child: SpinKitWave(
//                                 color: Colors.teal,
//                                 size: 50,
//                               ),
//                             ),
//                     imageBuilder: (context, imageProvider) {
//                       provider = imageProvider;
//                       return Container(
//                         margin: const EdgeInsets.symmetric(horizontal: 20),
//                         decoration: BoxDecoration(
//                           borderRadius:
//                               const BorderRadius.all(Radius.circular(30)),
//                           image: DecorationImage(
//                             fit: BoxFit.fitWidth,
//                             image: imageProvider,
//                           ),
//                         ),
//                         child: Container(
//                           padding: const EdgeInsets.symmetric(horizontal: 5),
//                           decoration: BoxDecoration(
//                             color: const Color(0xCCFFFFFF),
//                             borderRadius:
//                                 const BorderRadius.all(Radius.circular(30)),
//                             boxShadow: [
//                               BoxShadow(
//                                 color: Colors.grey.withOpacity(0.5),
//                                 spreadRadius: 5,
//                                 blurRadius: 7,
//                                 offset: const Offset(
//                                     0, 3), // changes position of shadow
//                               ),
//                             ],
//                           ),
//                           margin: EdgeInsets.only(top: 8 * width / 17),
//                           child: ListTile(
//                             title: Text(
//                               plant.name,
//                               style: const TextStyle(
//                                   fontSize: 22, fontWeight: FontWeight.w600),
//                             ),
//                             trailing: const Icon(
//                               Icons.arrow_right_alt,
//                               size: 35,
//                               color: Colors.black,
//                             ),
//                           ),
//                         ),
//                       );
//                     });
//               }
//             },
//           ),
//         ),
//       ),
//     );
//   }
//
//   Future<String> _loadImageProviderFuture(StorageService storageService) async {
//     return await storageService.getPlantImage(plant);
//   }
//
//   Future<ImageProvider> _getImageUrl(StorageService storageService) async {
//     return FirebaseImageProvider(
//         FirebaseUrl(await _loadImageProviderFuture(storageService)));
//   }
//
//   Future<String> _loadImage(StorageService storageService) async {
//     return await storageService.getPlantImage(plant);
//   }
//
//   void _navigateToSensor(BuildContext context, ImageProvider image) {
//     Navigator.push(
//         context,
//         PageRouteBuilder(
//             pageBuilder: (q, w, e) => ReadingPage(),
//             transitionsBuilder:
//                 (context, animation, secondaryAnimation, child) =>
//                     SlideTransition(
//                       position: Tween(
//                         begin: const Offset(1.0, 0.0),
//                         end: const Offset(0.0, 0.0),
//                       ).animate(animation),
//                       child: child,
//                     )));
//   }
//
//   void _deleteOrEdit(BuildContext context) {
//     showDialog(
//         context: context,
//         builder: (context) {
//           return AlertDialog(
//             title: const Text(
//               "Co zamierzasz?",
//               style: TextStyle(fontSize: 20),
//             ),
//             actions: [
//               TextButton(
//                 child: const Text(
//                   "Anuluj",
//                   style: TextStyle(color: Colors.black, fontSize: 16),
//                 ),
//                 onPressed: () {
//                   Navigator.pop(context);
//                 },
//               ),
//               TextButton(
//                 onPressed: () => _deletePlant(context),
//                 child: const Text(
//                   "Usuń",
//                   style: TextStyle(color: Colors.red, fontSize: 16),
//                 ),
//               ),
//             ],
//           );
//         });
//   }
//
//   Future<void> _deletePlant(BuildContext context) async {
//     PlantService().deletePlant(plant);
//     SensorService service = SensorService();
//     Sensor? sensor = await service.getSensorById(plant.sensorId);
//     if (sensor != null) {
//       service.updateSensor(
//           Sensor(id: sensor.id, isOccupied: false, name: sensor.name));
//     }
//     if (context.mounted) {
//       Navigator.pop(context);
//     }
//   }
// }
