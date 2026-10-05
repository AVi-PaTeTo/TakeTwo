import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import './in_app_crop_screen.dart';

class AppImagePicker extends StatefulWidget {
  final ValueChanged<File?> onImageSelected;
  final double aspectRatio;
  final String label;
  final bool isCircular; // Perfect for profile pictures
  final String? initialImageUrl; // Added for initial URL preview

  const AppImagePicker({
    super.key,
    required this.onImageSelected,
    this.aspectRatio = 16 / 9,
    this.label = 'Add Image',
    this.isCircular = false,
    this.initialImageUrl,
  });

  @override
  State<AppImagePicker> createState() => _AppImagePickerState();
}

class _AppImagePickerState extends State<AppImagePicker> {
  File? _selectedImage;

  Future<void> _pickAndCropImage(ImageSource source) async {
    try {
      final ImagePicker picker = ImagePicker();
      final XFile? image = await picker.pickImage(source: source);
      if (image == null) return;

      final File? croppedFile = await Navigator.push<File>(
        context,
        MaterialPageRoute(
          builder: (context) => InAppCropScreen(
            imageFile: File(image.path),
            aspectRatio: widget.aspectRatio,
          ),
        ),
      );

      if (croppedFile != null) {
        setState(() {
          _selectedImage = croppedFile;
        });
        widget.onImageSelected(croppedFile);
      }
    } catch (e) {
      debugPrint("Error picking image: $e");
    }
  }

  void _showSourceSelector() {
    showModalBottomSheet(
      context: context,
      builder: (context) => SafeArea(
        child: Wrap(
          children: [
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: const Text('Gallery'),
              onTap: () {
                Navigator.of(context).pop();
                _pickAndCropImage(ImageSource.gallery);
              },
            ),
            ListTile(
              leading: const Icon(Icons.camera_alt),
              title: const Text('Camera'),
              onTap: () {
                Navigator.of(context).pop();
                _pickAndCropImage(ImageSource.camera);
              },
            ),
          ],
        ),
      ),
    );
  }

  void _removeImage() {
    setState(() {
      _selectedImage = null;
    });
    // Passing null lets your parent form know the image was removed/cleared
    widget.onImageSelected(null);
  }

  @override
  Widget build(BuildContext context) {
    // Determines whether to show local file, network preview, or empty state
    final bool hasLocalImage = _selectedImage != null;
    final bool hasNetworkImage =
        widget.initialImageUrl != null && widget.initialImageUrl!.isNotEmpty;

    // 1. Circular Layout (Profile Pictures)
    if (widget.isCircular) {
      ImageProvider? bgProvider;
      if (hasLocalImage) {
        bgProvider = FileImage(_selectedImage!);
      } else if (hasNetworkImage && !hasLocalImage) {
        bgProvider = NetworkImage(widget.initialImageUrl!);
      }

      return Center(
        child: GestureDetector(
          onTap: _showSourceSelector,
          child: Stack(
            children: [
              CircleAvatar(
                radius: 50,
                backgroundColor: Colors.grey[200],
                backgroundImage: bgProvider,
                child: (bgProvider == null)
                    ? const Icon(Icons.camera_alt, size: 30, color: Colors.grey)
                    : null,
              ),
              // Show close/remove button if either local file or network image exists
              if (hasLocalImage || hasNetworkImage)
                Positioned(
                  bottom: 0,
                  right: 0,
                  child: InkWell(
                    onTap: _removeImage,
                    child: const CircleAvatar(
                      radius: 14,
                      backgroundColor: Colors.red,
                      child: Icon(Icons.close, size: 16, color: Colors.white),
                    ),
                  ),
                ),
            ],
          ),
        ),
      );
    }

    // 2. Rectangular Layout (Banners & Posters)
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        GestureDetector(
          onTap: _showSourceSelector,
          child: AspectRatio(
            aspectRatio: widget.aspectRatio,
            child: Container(
              decoration: BoxDecoration(
                color: Colors.grey[200],
                borderRadius: BorderRadius.circular(12),
                // border: Border.all(color: Colors.grey[400]!),
              ),
              child: hasLocalImage || hasNetworkImage
                  ? ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Stack(
                        fit: StackFit.expand,
                        children: [
                          hasLocalImage
                              ? Image.file(_selectedImage!, fit: BoxFit.cover)
                              : Image.network(
                                  widget.initialImageUrl!,
                                  fit: BoxFit.cover,
                                ),
                          Positioned(
                            top: 8,
                            right: 8,
                            child: CircleAvatar(
                              backgroundColor: Colors.black54,
                              child: IconButton(
                                icon: const Icon(
                                  Icons.close,
                                  color: Colors.white,
                                  size: 20,
                                ),
                                onPressed: _removeImage,
                              ),
                            ),
                          ),
                        ],
                      ),
                    )
                  : Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.add_photo_alternate,
                          size: 40,
                          color: Colors.grey,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          widget.label,
                          style: const TextStyle(color: Colors.grey),
                        ),
                      ],
                    ),
            ),
          ),
        ),
      ],
    );
  }
}
