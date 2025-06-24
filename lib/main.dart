import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:weather_station/screen/main_page.dart';
import 'firebase_options.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color.fromARGB(255, 170, 220, 240)),
        useMaterial3: true,
        fontFamily: 'ComicSans'
      ),
      home: const MainPage(),
    );
  }
}