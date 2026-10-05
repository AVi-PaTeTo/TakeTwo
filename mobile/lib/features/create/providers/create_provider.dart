import 'dart:async';
import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/network/providers.dart';
import '../models/movie.dart';
import '../models/tmdb_search_result.dart';
import '../services/create_service.dart';

final createServiceProvider = Provider<CreateService>((ref) {
  return CreateService(apiClient: ref.read(apiClientProvider));
});

final createProvider = NotifierProvider<CreateNotifier, CreateState>(
  CreateNotifier.new,
);

enum CreateStep { search, writing }

enum MediaType { movie, tv }

class CreateState {
  final CreateStep step;
  final MediaType mediaType;
  final String query;
  final List<TmdbSearchResult> results;
  final Movie? selectedMovie;
  final bool isSearching;
  final bool isLoadingMovie;
  final bool isCreating;
  final String? error;

  const CreateState({
    this.step = CreateStep.search,
    this.mediaType = MediaType.movie,
    this.query = '',
    this.results = const [],
    this.selectedMovie,
    this.isSearching = false,
    this.isLoadingMovie = false,
    this.isCreating = false,
    this.error,
  });

  CreateState copyWith({
    CreateStep? step,
    MediaType? mediaType,
    String? query,
    List<TmdbSearchResult>? results,
    Movie? selectedMovie,
    bool? isSearching,
    bool? isLoadingMovie,
    bool? isCreating,
    String? error,
    bool clearMovie = false,
    bool clearError = false,
  }) {
    return CreateState(
      step: step ?? this.step,
      mediaType: mediaType ?? this.mediaType,
      query: query ?? this.query,
      results: results ?? this.results,
      selectedMovie: clearMovie ? null : selectedMovie ?? this.selectedMovie,
      isSearching: isSearching ?? this.isSearching,
      isLoadingMovie: isLoadingMovie ?? this.isLoadingMovie,
      isCreating: isCreating ?? this.isCreating,
      error: clearError ? null : error ?? this.error,
    );
  }
}

class CreateNotifier extends Notifier<CreateState> {
  Timer? _debounce;

  @override
  CreateState build() {
    ref.onDispose(() {
      _debounce?.cancel();
    });

    return const CreateState();
  }

  void setMediaType(MediaType type) {
    _debounce?.cancel();

    state = state.copyWith(
      mediaType: type,
      results: const [],
      query: '',
      clearError: true,
    );
  }

  void searchChanged(String query) {
    _debounce?.cancel();

    state = state.copyWith(query: query, clearError: true);

    if (query.trim().isEmpty) {
      state = state.copyWith(results: const []);
      return;
    }

    _debounce = Timer(
      const Duration(milliseconds: 400),
      () => search(query.trim()),
    );
  }

  Future<void> search(String query) async {
    if (query.isEmpty) return;

    state = state.copyWith(isSearching: true, clearError: true);

    try {
      final service = ref.read(createServiceProvider);

      final results = await service.searchMedia(
        query: query,
        type: state.mediaType.name,
      );

      state = state.copyWith(results: results, isSearching: false);
    } catch (_) {
      state = state.copyWith(
        isSearching: false,
        error: 'Unable to search right now.',
      );
    }
  }

  Future<void> selectMovie(TmdbSearchResult result) async {
    state = state.copyWith(isLoadingMovie: true, clearError: true);

    try {
      final service = ref.read(createServiceProvider);

      final movie = await service.getOrCreateMovie(
        tmdbId: result.tmdbId,
        type: state.mediaType.name,
      );

      state = state.copyWith(
        step: CreateStep.writing,
        selectedMovie: movie,
        isLoadingMovie: false,
        results: const [],
      );
    } catch (_) {
      state = state.copyWith(
        isLoadingMovie: false,
        error: 'Unable to load this title.',
      );
    }
  }

  Future<dynamic> createPost({
    required String title,
    required String content,
    File? bannerImage,
    File? posterImage,
  }) async {
    final movie = state.selectedMovie;

    if (movie == null) {
      throw Exception('No movie selected');
    }

    state = state.copyWith(isCreating: true, clearError: true);

    try {
      final service = ref.read(createServiceProvider);

      final post = await service.createPost(
        movieId: movie.id,
        title: title.trim(),
        content: content.trim(),
        bannerImage: bannerImage,
        posterImage: posterImage,
      );

      state = state.copyWith(isCreating: false);

      return post;
    } catch (_) {
      state = state.copyWith(
        isCreating: false,
        error: 'Unable to create your post.',
      );

      rethrow;
    }
  }

  void reset() {
    _debounce?.cancel();

    state = const CreateState();
  }
}
