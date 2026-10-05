import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile/features/auth/controllers/profile_controller.dart';

import '../../../shared/widgets/image_uploader.dart';

class EditProfileScreen extends ConsumerStatefulWidget {
  final String initialUsername;
  final List<int> initialGenres;
  final String? initialAvatarUrl;
  final String? initialBannerUrl;
  final VoidCallback? onProfileUpdated;

  const EditProfileScreen({
    super.key,
    required this.initialUsername,
    required this.initialGenres,
    this.initialAvatarUrl,
    this.initialBannerUrl,
    this.onProfileUpdated,
  });

  @override
  ConsumerState<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends ConsumerState<EditProfileScreen> {
  // Static TMDB genre map
  static const Map<int, String> genreNames = {
    28: 'Action',
    12: 'Adventure',
    16: 'Animation',
    35: 'Comedy',
    80: 'Crime',
    99: 'Documentary',
    18: 'Drama',
    10751: 'Family',
    14: 'Fantasy',
    36: 'History',
    27: 'Horror',
    10402: 'Music',
    9648: 'Mystery',
    10749: 'Romance',
    878: 'Science Fiction',
    10770: 'TV Movie',
    53: 'Thriller',
    10752: 'War',
    37: 'Western',
  };

  late final TextEditingController _usernameController;
  late List<int> _selectedGenres;

  File? _profileImageFile;
  File? _bannerImageFile;

  bool _isSaving = false;

  @override
  void initState() {
    super.initState();

    _usernameController = TextEditingController(text: widget.initialUsername);

    _selectedGenres = List.from(widget.initialGenres);
  }

  @override
  void dispose() {
    _usernameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Profile'),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: _isSaving ? null : () => Navigator.of(context).pop(),
        ),
        actions: [
          TextButton(
            onPressed: _isSaving
                ? null
                : () async {
                    setState(() {
                      _isSaving = true;
                    });

                    try {
                      final success = await ref
                          .read(profileControllerProvider.notifier)
                          .updateProfile(
                            username: _usernameController.text.trim(),
                            preferredGenres: _selectedGenres,
                            profilePicture: _profileImageFile,
                            bannerPicture: _bannerImageFile,
                          );

                      if (!mounted) return;

                      if (success) {
                        widget.onProfileUpdated?.call();

                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Profile updated successfully!'),
                          ),
                        );

                        Navigator.of(context).pop();
                      } else {
                        setState(() {
                          _isSaving = false;
                        });

                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Unable to update profile.'),
                          ),
                        );
                      }
                    } catch (e) {
                      if (!mounted) return;

                      setState(() {
                        _isSaving = false;
                      });

                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Unable to update profile.'),
                        ),
                      );
                    }
                  },
            child: _isSaving
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Text(
                    'Save',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
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
                      initialImageUrl: widget.initialBannerUrl,
                      onImageSelected: (file) {
                        setState(() {
                          _bannerImageFile = file;
                        });
                      },
                    ),
                    Positioned(
                      left: 0,
                      bottom: 0,
                      child: Container(
                        width: 100,
                        height: 100,
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
                            initialImageUrl: widget.initialAvatarUrl,
                            onImageSelected: (file) {
                              setState(() {
                                _profileImageFile = file;
                              });
                            },
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
                controller: _usernameController,
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
                  return _buildGenreChip(id: entry.key, label: entry.value);
                }).toList(),
              ),

              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildGenreChip({required int id, required String label}) {
    final isSelected = _selectedGenres.contains(id);

    return FilterChip(
      label: Text(label),
      selected: isSelected,
      onSelected: _isSaving
          ? null
          : (selected) {
              setState(() {
                if (selected) {
                  _selectedGenres.add(id);
                } else {
                  _selectedGenres.remove(id);
                }
              });
            },
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
    );
  }
}
