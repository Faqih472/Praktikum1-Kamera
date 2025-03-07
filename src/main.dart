import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'takepicture_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized(); // Pastikan binding Flutter sudah siap

  // Dapatkan daftar kamera yang tersedia
  final cameras = await availableCameras();

  // Pilih kamera pertama (biasanya kamera belakang)
  final firstCamera = cameras.first;

  runApp(
    MaterialApp(
      theme: ThemeData.dark(),
      home: TakePictureScreen(
        camera: firstCamera,
      ),
      debugShowCheckedModeBanner: false,
    ),
  );
}
