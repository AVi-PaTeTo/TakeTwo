import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/network/providers.dart';
import '../models/user_detail.dart';

final userDetailProvider =
    AsyncNotifierProvider.family<UserDetailNotifier, UserDetail, int>(
      UserDetailNotifier.new,
    );

class UserDetailNotifier extends AsyncNotifier<UserDetail> {
  UserDetailNotifier(this.userId);
  late int userId;

  @override
  Future<UserDetail> build() async {
    final api = ref.read(apiClientProvider);

    final response = await api.dio.get('/auth/users/$userId/');

    return UserDetail.fromJson(response.data);
  }

  Future<void> toggleFollow() async {
    final current = state.value;

    if (current == null) return;

    final api = ref.read(apiClientProvider);

    final wasFollowing = current.isFollowing;

    // Optimistic UI update
    state = AsyncData(
      current.copyWith(
        isFollowing: !wasFollowing,
        followerCount: wasFollowing
            ? current.followerCount - 1
            : current.followerCount + 1,
      ),
    );

    try {
      if (wasFollowing) {
        await api.dio.delete('/users/$userId/follow/');
      } else {
        await api.dio.post('/users/$userId/follow/');
      }
    } catch (e, stack) {
      // Roll back if the request failed.
      state = AsyncData(current);
    }
  }
}
