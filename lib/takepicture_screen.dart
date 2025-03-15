import 'dart:io';
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'displaypicture_screen.dart';
import 'widgets/photo_filter_carousel.dart'; // Import layar filter foto
import 'package:image/image.dart' as img;

class TakePictureScreen extends StatefulWidget {
  const TakePictureScreen({super.key, required this.camera});

  final CameraDescription camera;

  @override
  TakePictureScreenState createState() => TakePictureScreenState();
}

class TakePictureScreenState extends State<TakePictureScreen> {
  late CameraController _controller;
  late Future<void> _initializeControllerFuture;
  late CameraDescription _currentCamera;

  @override
  void initState() {
    super.initState();
    _currentCamera = widget.camera;
    _initializeCamera(_currentCamera);
  }

  // Fungsi untuk menginisialisasi ulang kamera
  void _initializeCamera(CameraDescription camera) {
    _controller = CameraController(
      camera,
      ResolutionPreset.medium,
    );
    _initializeControllerFuture = _controller.initialize();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  // Fungsi untuk beralih kamera
  void _toggleCamera(List<CameraDescription> cameras) {
    setState(() {
      _currentCamera = _currentCamera.lensDirection == CameraLensDirection.front
          ? cameras.firstWhere((camera) => camera.lensDirection == CameraLensDirection.back)
          : cameras.firstWhere((camera) => camera.lensDirection == CameraLensDirection.front);

      // Menginisialisasi ulang controller kamera
      _initializeCamera(_currentCamera);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Take a Picture'),
      ),
      body: FutureBuilder<void>(
        future: _initializeControllerFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            return CameraPreview(_controller);
          } else {
            return const Center(child: CircularProgressIndicator());
          }
        },
      ),
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(bottom: 20.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Tombol untuk beralih kamera
            FloatingActionButton(
              onPressed: () async {
                try {
                  final cameras = await availableCameras();
                  _toggleCamera(cameras);
                } catch (e) {
                  print('Error getting cameras: $e');
                }
              },
              child: const Icon(Icons.switch_camera),
            ),
            const SizedBox(width: 20), // Jarak antar tombol
            // Tombol untuk mengambil gambar
            // Tombol untuk mengambil gambar
            FloatingActionButton(
              onPressed: () async {
                try {
                  await _initializeControllerFuture;
                  final image = await _controller.takePicture();
                  File imageFile = File(image.path);

                  // Jika kamera depan, balik gambar horizontal
                  if (_currentCamera.lensDirection == CameraLensDirection.front) {
                    img.Image originalImage = img.decodeImage(await imageFile.readAsBytes())!;
                    img.Image flippedImage = img.flipHorizontal(originalImage);
                    await imageFile.writeAsBytes(img.encodeJpg(flippedImage));
                  }

                  // Pindah ke layar filter
                  await Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => PhotoFilterCarousel(imageFile: imageFile),
                    ),
                  );
                } catch (e) {
                  print(e);
                }
              },
              child: const Icon(Icons.camera_alt),
            ),
          ],
        ),
      ),
    );
  }
}
