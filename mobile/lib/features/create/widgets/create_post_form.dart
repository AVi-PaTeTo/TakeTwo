import 'dart:io';

import 'package:flutter/material.dart';
import 'package:mobile/core/config/tmdb_image.dart';
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

  InputDecoration _inputDecoration({
    required String label,
    required String hint,
    required IconData icon,
    bool alignLabelWithHint = false,
  }) {
    return InputDecoration(
      labelText: label,
      hintText: hint,
      prefixIcon: Icon(icon),
      alignLabelWithHint: alignLabelWithHint,

      filled: true,
      fillColor: const Color(0xFF212530),

      labelStyle: const TextStyle(color: Colors.white60),

      hintStyle: const TextStyle(color: Colors.white30),

      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 15),

      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.06)),
      ),

      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.06)),
      ),

      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: Color(0xFFD32F2F), width: 1.2),
      ),

      counterStyle: const TextStyle(color: Colors.white30),
    );
  }

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
          initialImageUrl: posterUrl,
          onImageSelected: onPosterImageSelected,
        ),

        const SizedBox(height: 22),

        TextField(
          controller: titleController,
          textInputAction: TextInputAction.next,
          maxLength: 120,
          style: const TextStyle(color: Colors.white, fontSize: 16),
          decoration: _inputDecoration(
            label: 'Post title',
            hint: 'Give your post a title',
            icon: Icons.title_outlined,
          ),
        ),

        const SizedBox(height: 12),

        TextField(
          controller: contentController,
          minLines: 8,
          maxLines: 16,
          maxLength: 5000,
          textInputAction: TextInputAction.newline,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 15,
            height: 1.45,
          ),
          decoration: _inputDecoration(
            label: 'Your review',
            hint: 'What did you think?',
            icon: Icons.rate_review_outlined,
            alignLabelWithHint: true,
          ),
        ),
      ],
    );
  }
}
