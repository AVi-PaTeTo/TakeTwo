import 'dart:io';

import 'package:mobile/core/config/tmdb_image.dart';
import 'package:flutter/material.dart';
import 'package:mobile/features/create/models/movie.dart';
import 'package:mobile/shared/widgets/image_uploader.dart';

class CreatePostForm extends StatelessWidget {
  final Movie movie;
  final TextEditingController titleController;
  final TextEditingController contentController;
  final ValueChanged<File?> onBannerImageSelected;
  final ValueChanged<File?> onPosterImageSelected;

  const CreatePostForm({
    super.key,
    required this.movie,
    required this.titleController,
    required this.contentController,
    required this.onBannerImageSelected,
    required this.onPosterImageSelected,
  });

  @override
  Widget build(BuildContext context) {
    final posterUrl = movie.posterPath.isEmpty
        ? null
        : TmdbImage.poster(movie.posterPath);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AppImagePicker(
          label: 'Add Movie Banner',
          aspectRatio: 16 / 8,
          onImageSelected: onBannerImageSelected,
        ),
        const SizedBox(height: 16),

        AppImagePicker(
          label: 'Add Movie Poster',
          aspectRatio: 2 / 3,
          initialImageUrl: posterUrl, // <-- Loads the URL preview seamlessly!
          onImageSelected: (File? croppedFile) {
            // croppedFile will be null if they didn't touch it or if they clicked 'X' to clear.
            // If they picked a new file, it passes the File object for your API upload.
            onPosterImageSelected(croppedFile);
          },
        ),
        const SizedBox(height: 16),

        TextField(
          controller: titleController,
          textInputAction: TextInputAction.next,
          maxLength: 120,
          decoration: const InputDecoration(
            labelText: 'Title',
            hintText: 'Give your post a title',
          ),
        ),

        const SizedBox(height: 16),

        TextField(
          controller: contentController,
          minLines: 8,
          maxLines: 16,
          maxLength: 5000,
          textInputAction: TextInputAction.newline,
          decoration: const InputDecoration(
            labelText: 'Review',
            hintText: 'What did you think?',
            alignLabelWithHint: true,
          ),
        ),
      ],
    );
  }
}
