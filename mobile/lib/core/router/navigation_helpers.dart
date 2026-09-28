import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../features/auth/providers/auth_provider.dart';

void openUserProfile(BuildContext context, WidgetRef ref, int userId) {
  final currentUserId = ref.read(authProvider).value?.id;

  if (userId == currentUserId) {
    context.go('/profile');
  } else {
    context.push('/users/$userId');
  }
}
