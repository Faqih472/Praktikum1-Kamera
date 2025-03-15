import 'dart:io';
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';

class TakePictureScreen extends StatefulWidget {
  final CameraDescription camera;

  const TakePictureScreen({super.key, required this.camera});

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

  void _initializeCamera(CameraDescription camera) {
    _controller = CameraController(
      camera,
      ResolutionPreset.medium,
      enableAudio: false,
    );
    _initializeControllerFuture = _controller.initialize();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _toggleCamera(List<CameraDescription> cameras) {
    setState(() {
      _currentCamera = _currentCamera.lensDirection == CameraLensDirection.front
          ? cameras.firstWhere((camera) => camera.lensDirection == CameraLensDirection.back)
          : cameras.firstWhere((camera) => camera.lensDirection == CameraLensDirection.front);
      _initializeCamera(_currentCamera);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Take a Picture')),
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
      floatingActionButton: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
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
          FloatingActionButton(
            onPressed: () async {
              try {
                await _initializeControllerFuture;
                final image = await _controller.takePicture();
                File imageFile = File(image.path);

                await Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => DisplayPictureScreen(
                      imageFile: imageFile,
                      isFrontCamera: _currentCamera.lensDirection == CameraLensDirection.front,
                    ),
                  ),
                );
              } catch (e) {
                print('Error capturing image: $e');
              }
            },
            child: const Icon(Icons.camera_alt),
          ),
        ],
      ),
    );
  }
}

class DisplayPictureScreen extends StatelessWidget {
  final File imageFile;
  final bool isFrontCamera;

  const DisplayPictureScreen({super.key, required this.imageFile, required this.isFrontCamera});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Captured Image')),
      body: Center(
        child: Transform(
          alignment: Alignment.center,
          transform: isFrontCamera
              ? (Matrix4.identity()..scale(-1.0, 1.0, 1.0)) // Flip horizontal jika kamera depan
              : Matrix4.identity(), // Tidak ada perubahan untuk kamera belakang
          child: Image.file(imageFile),
        ),
      ),
    );
  }
}
