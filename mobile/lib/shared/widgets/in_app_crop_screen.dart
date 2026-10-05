import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:crop_your_image/crop_your_image.dart';

// import 'path_provider'; // optional if saving temporarily, or just return Uint8List

class InAppCropScreen extends StatefulWidget {
  final File imageFile;
  final double aspectRatio;

  const InAppCropScreen({
    super.key,
    required this.imageFile,
    required this.aspectRatio,
  });

  @override
  State<InAppCropScreen> createState() => _InAppCropScreenState();
}

class _InAppCropScreenState extends State<InAppCropScreen> {
  final _cropController = CropController();
  late Uint8List _imageBytes;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadImageBytes();
  }

  Future<void> _loadImageBytes() async {
    final bytes = await widget.imageFile.readAsBytes();
    setState(() {
      _imageBytes = bytes;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Crop Image'),
        actions: [
          IconButton(
            icon: const Icon(Icons.check),
            onPressed: () {
              // Trigger the crop action
              _cropController.crop();
            },
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Crop(
              image: _imageBytes,
              controller: _cropController,
              aspectRatio: widget.aspectRatio,
              onCropped: (result) async {
                // Handle the CropResult using pattern matching
                switch (result) {
                  case CropSuccess(:final croppedImage):
                    final tempDir = Directory.systemTemp;
                    final tempFile = File(
                      '${tempDir.path}/${DateTime.now().millisecondsSinceEpoch}.jpg',
                    );
                    await tempFile.writeAsBytes(croppedImage);

                    if (mounted) {
                      Navigator.of(context)
                          .pop(tempFile); // Return the saved File
                    }
                    break;
                  case CropFailure(:final cause):
                    // Handle crop failure if necessary
                    break;
                }
              },
            ),
    );
  }
}
