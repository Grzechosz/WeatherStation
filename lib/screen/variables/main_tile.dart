import 'package:cached_network_image/cached_network_image.dart';
import 'package:firebase_cached_image/firebase_cached_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

class MainTile extends HookWidget {
  MainTile({super.key});

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    ImageProvider provider =
        const AssetImage('assets/images/cactus.jpg');
    final ValueNotifier<ImageProvider> providerNotifier =
      useState(const AssetImage('assets/images/cactus.jpg'));
    //
    // useMemoized(() => storageService.addListener(() async {
    //       if (context.mounted) {
    //         provider = await _getImageUrl(storageService);
    //         providerNotifier.value = provider;
    //       }
    //     }));

    return InkWell(
      borderRadius: const BorderRadius.all(Radius.circular(40)),
      highlightColor: Colors.teal.shade100,
      splashColor: Colors.grey.shade200,
      // onTap: () => _navigateToSensor(context, provider),
      onLongPress: () => _deleteOrEdit(context),
      child: Container(
        margin: const EdgeInsets.only(bottom: 15, top: 15),
        child: Container(),
      ),
    );
  }

  // void _navigateToSensor(BuildContext context, ImageProvider image) {
  //   Navigator.push(
  //       context,
  //       PageRouteBuilder(
  //           pageBuilder: (q, w, e) => ReadingPage(),
  //           transitionsBuilder:
  //               (context, animation, secondaryAnimation, child) =>
  //                   SlideTransition(
  //                     position: Tween(
  //                       begin: const Offset(1.0, 0.0),
  //                       end: const Offset(0.0, 0.0),
  //                     ).animate(animation),
  //                     child: child,
  //                   )));
  // }

  void _deleteOrEdit(BuildContext context) {
    showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: const Text(
              "Co zamierzasz?",
              style: TextStyle(fontSize: 20),
            ),
            actions: [
              TextButton(
                child: const Text(
                  "Anuluj",
                  style: TextStyle(color: Colors.black, fontSize: 16),
                ),
                onPressed: () {
                  Navigator.pop(context);
                },
              )
            ],
          );
        });
  }
}
