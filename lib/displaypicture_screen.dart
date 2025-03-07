import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';

class DisplayPictureScreen extends StatelessWidget {
  final XFile imageFile;

  const DisplayPictureScreen({Key? key, required this.imageFile}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Display Picture')),
      body: Center(
        child: kIsWeb
            ? FutureBuilder<Uint8List>(
          future: imageFile.readAsBytes(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.done && snapshot.hasData) {
              return Image.memory(snapshot.data!); // ✅ Tampilkan di Web
            } else {
              return const CircularProgressIndicator(); // Loading jika belum siap
            }
          },
        )
            : Image.file(File(imageFile.path)), // ✅ Tampilkan di Android/iOS
      ),
    );
  }
}


//displaypicture_screen.dart