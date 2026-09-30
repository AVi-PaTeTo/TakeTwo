import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile/shared/providers/post_cache_provider.dart';
import 'package:mobile/features/explore/providers/explore_provider.dart';
import 'package:mobile/shared/providers/feed_providers.dart';

import '../../../core/network/providers.dart';
import '../../../core/storage/providers.dart';
import '../models/user.dart';
import '../services/auth_service.dart';

final authServiceProvider = Provider<AuthService>((ref) {
  return AuthService(
    apiClient: ref.read(apiClientProvider),
    storage: ref.read(secureStorageProvider),
  );
});

final authProvider = AsyncNotifierProvider<AuthNotifier, User?>(
  AuthNotifier.new,
);

class AuthNotifier extends AsyncNotifier<User?> {
  @override
  Future<User?> build() async {
    final storage = ref.read(secureStorageProvider);

    final token = await storage.getAccessToken();

    if (token == null) {
      return null;
    }

    try {
      return await ref.read(authServiceProvider).getMe();
    } catch (_) {
      await storage.deleteAccessToken();
      return null;
    }
  }

  Future<void> login({
    required String username,
    required String password,
  }) async {
    state = const AsyncLoading();

    state = await AsyncValue.guard(
      () => ref
          .read(authServiceProvider)
          .login(username: username, password: password),
    );

    await ref.read(homeFeedIdsProvider.notifier).refresh();
    await ref.read(explorePostsProvider.notifier).refresh();
  }

  Future<void> logout() async {
    await ref.read(authServiceProvider).logout();

    ref.read(postCacheProvider.notifier).clear();
    state = const AsyncData(null);
  }

  bool isCurrentUser(int userId) {
    return state.value?.id == userId;
  }
}
