import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/network/providers.dart';
import '../models/follow_suggestion.dart';

final userSuggestionsProvider = FutureProvider<List<UserSuggestion>>((
  ref,
) async {
  final apiClient = ref.read(apiClientProvider);

  final response = await apiClient.dio.get('/users/suggestions/');

  final data = response.data as List<dynamic>;

  return data
      .map((item) => UserSuggestion.fromJson(item as Map<String, dynamic>))
      .toList();
});
