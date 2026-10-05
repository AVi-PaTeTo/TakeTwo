import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/auth_provider.dart';

class ProfileNotifier extends AsyncNotifier<void> {
  @override
  Future<void> build() async {
    // Initial state is data(null)
    return;
  }

  Future<bool> updateProfile({
    required String username,
    required List<int> preferredGenres,
    File? profilePicture,
    File? bannerPicture,
  }) async {
    state = const AsyncValue.loading();

    // Guard automatically catches errors and wraps them in AsyncValue.error
    state = await AsyncValue.guard(() async {
      await ref
          .read(authServiceProvider)
          .updateProfile(
            username: username,
            preferredGenres: preferredGenres,
            profilePicture: profilePicture,
            bannerPicture: bannerPicture,
          );
    });

    // Return true if it succeeded (i.e. no error state)
    return !state.hasError;
  }
}

// Modern Riverpod provider definition
final profileControllerProvider = AsyncNotifierProvider<ProfileNotifier, void>(
  ProfileNotifier.new,
);
