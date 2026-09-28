import 'package:flutter/material.dart';

import '../../../core/config/tmdb_image.dart';
import '../models/tmdb_search_result.dart';

class MovieSearchResultTile extends StatelessWidget {
  final TmdbSearchResult result;
  final VoidCallback onTap;

  const MovieSearchResultTile({
    super.key,
    required this.result,
    required this.onTap,
  });

  String? get _posterUrl {
    if (result.posterPath == null || result.posterPath!.isEmpty) {
      return null;
    }

    return TmdbImage.poster(result.posterPath!);
  }

  String get _year {
    final date = result.releaseDate;

    if (date == null || date.length < 4) {
      return '';
    }

    return date.substring(0, 4);
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: SizedBox(
                width: 64,
                height: 96,
                child: _posterUrl != null
                    ? Image.network(
                        _posterUrl!,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) {
                          return const _PosterPlaceholder();
                        },
                      )
                    : const _PosterPlaceholder(),
              ),
            ),

            const SizedBox(width: 12),

            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      result.title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    if (_year.isNotEmpty) ...[
                      const SizedBox(height: 6),
                      Text(
                        _year,
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    ],
                  ],
                ),
              ),
            ),

            const Icon(Icons.chevron_right),
          ],
        ),
      ),
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
