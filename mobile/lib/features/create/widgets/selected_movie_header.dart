import 'package:flutter/material.dart';

import '../../../core/config/tmdb_image.dart';
import '../models/movie.dart';

class SelectedMovieHeader extends StatelessWidget {
  final Movie movie;

  const SelectedMovieHeader({super.key, required this.movie});

  @override
  Widget build(BuildContext context) {
    final posterUrl = movie.posterPath.isEmpty
        ? null
        : TmdbImage.poster(movie.posterPath);

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(10),
          child: SizedBox(
            width: 90,
            height: 135,
            child: posterUrl != null
                ? Image.network(
                    posterUrl,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) {
                      return const _PosterPlaceholder();
                    },
                  )
                : const _PosterPlaceholder(),
          ),
        ),

        const SizedBox(width: 16),

        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(movie.title, style: Theme.of(context).textTheme.titleLarge),

              if (movie.releaseDate.isNotEmpty) ...[
                const SizedBox(height: 6),
                Text(
                  movie.releaseDate.length >= 4
                      ? movie.releaseDate.substring(0, 4)
                      : movie.releaseDate,
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ],

              const SizedBox(height: 8),

              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(6),
                  color: Theme.of(context).colorScheme.surfaceContainerHighest,
                ),
                child: Text(
                  movie.mediaType == 'tv' ? 'TV Show' : 'Movie',
                  style: Theme.of(context).textTheme.labelMedium,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _PosterPlaceholder extends StatelessWidget {
  const _PosterPlaceholder();

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: Theme.of(context).colorScheme.surfaceContainerHighest,
      child: const Icon(Icons.movie_outlined),
    );
  }
}
