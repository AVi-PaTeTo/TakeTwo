import 'dart:io';

import 'package:flutter/material.dart';

import '../../../shared/widgets/image_uploader.dart';

class EditProfileForm extends StatelessWidget {
  final String? initialAvatarUrl;
  final String? initialBannerUrl;
  final TextEditingController usernameController;
  final List<int> selectedGenres;
  final Map<int, String> genreNames;
  final ValueChanged<File?> onBannerImageSelected;
  final ValueChanged<File?> onProfileImageSelected;
  final ValueChanged<int> onGenreToggled;

  const EditProfileForm({
    super.key,
    required this.initialAvatarUrl,
    required this.initialBannerUrl,
    required this.usernameController,
    required this.selectedGenres,
    required this.genreNames,
    required this.onBannerImageSelected,
    required this.onProfileImageSelected,
    required this.onGenreToggled,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // --- BANNER & AVATAR STACK ---
          SizedBox(
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                AppImagePicker(
                  label: 'Add Profile Banner',
                  aspectRatio: 16 / 8,
                  initialImageUrl:
                      initialBannerUrl, // Shows existing URL seamlessly
                  onImageSelected: onBannerImageSelected,
                ),
                Positioned(
                  left: 0,
                  bottom: 0,
                  child: Container(
                    width: 90,
                    height: 90,
                    padding: const EdgeInsets.all(5),
                    decoration: BoxDecoration(
                      color: Theme.of(context).scaffoldBackgroundColor,
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(100),
                        topRight: Radius.circular(100),
                        bottomRight: Radius.circular(100),
                        bottomLeft: Radius.circular(20),
                      ),
                    ),
                    child: Container(
                      clipBehavior: Clip.antiAlias,
                      decoration: const BoxDecoration(
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(100),
                          topRight: Radius.circular(100),
                          bottomRight: Radius.circular(100),
                          bottomLeft: Radius.circular(20),
                        ),
                      ),
                      child: AppImagePicker(
                        label: 'Profile',
                        aspectRatio: 1 / 1,
                        initialImageUrl:
                            initialAvatarUrl, // Shows existing URL seamlessly
                        onImageSelected: onProfileImageSelected,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // --- USERNAME FIELD ---
          const Text(
            'Username',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Colors.white70,
            ),
          ),
          const SizedBox(height: 8),
          TextField(
            controller: usernameController,
            maxLength: 25,
            style: const TextStyle(fontSize: 16),
            decoration: InputDecoration(
              hintText: 'Enter username...',
              filled: true,
              fillColor: Colors.white.withOpacity(0.05),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 14,
              ),
              counterText: '',
            ),
          ),
          const SizedBox(height: 24),

          // --- GENRE PILLS SECTION ---
          const Text(
            'Preferred Genres',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Colors.white70,
            ),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: genreNames.entries.map((entry) {
              final isSelected = selectedGenres.contains(entry.key);
              return FilterChip(
                label: Text(entry.value),
                selected: isSelected,
                onSelected: (_) => onGenreToggled(entry.key),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 32),
        ],
      ),
    );
  }
}
