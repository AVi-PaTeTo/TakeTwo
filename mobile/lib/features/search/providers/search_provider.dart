import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/network/providers.dart';
import '../models/search_response.dart';
import '../services/search_service.dart';

final searchServiceProvider = Provider<SearchService>((ref) {
  return SearchService(ref.read(apiClientProvider));
});

final searchProvider = NotifierProvider<SearchNotifier, SearchState>(
  SearchNotifier.new,
);

class SearchState {
  final SearchResponse results;
  final bool isLoading;
  final String? error;
  final String query;

  const SearchState({
    this.results = const SearchResponse(),
    this.isLoading = false,
    this.error,
    this.query = '',
  });

  SearchState copyWith({
    SearchResponse? results,
    bool? isLoading,
    String? error,
    String? query,
  }) {
    return SearchState(
      results: results ?? this.results,
      isLoading: isLoading ?? this.isLoading,
      error: error,
      query: query ?? this.query,
    );
  }
}

class SearchNotifier extends Notifier<SearchState> {
  Timer? _debounce;

  SearchService get _service => ref.read(searchServiceProvider);

  @override
  SearchState build() {
    ref.onDispose(() {
      _debounce?.cancel();
    });

    return const SearchState();
  }

  void search(String query) {
    _debounce?.cancel();

    final trimmedQuery = query.trim();

    if (trimmedQuery.isEmpty) {
      state = const SearchState();
      return;
    }

    state = state.copyWith(query: trimmedQuery, isLoading: true, error: null);

    _debounce = Timer(
      const Duration(milliseconds: 400),
      () => _performSearch(trimmedQuery),
    );
  }

  Future<void> _performSearch(String query) async {
    try {
      final results = await _service.search(query);

      state = state.copyWith(results: results, isLoading: false, error: null);
    } catch (e) {
      state = state.copyWith(
        results: const SearchResponse(),
        isLoading: false,
        error: 'Something went wrong. Please try again.',
      );
    }
  }

  void clear() {
    _debounce?.cancel();
    state = const SearchState();
  }
}
