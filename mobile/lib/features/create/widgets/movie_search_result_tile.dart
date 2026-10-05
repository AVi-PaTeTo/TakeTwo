import 'package:flutter/material.dart';

import '../../../core/config/tmdb_image.dart';
import '../models/tmdb_search_result.dart';
import '../providers/create_provider.dart';

class MovieSearchResultTile extends StatelessWidget {
  final TmdbSearchResult result;
  final MediaType mediaType;
  final VoidCallback onTap;

  const MovieSearchResultTile({
    super.key,
    required this.result,
    required this.mediaType,
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
    final theme = Theme.of(context);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Ink(
          decoration: BoxDecoration(
            color: const Color(0xFF212530),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: Colors.white.withValues(alpha: 0.06),
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(8),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(9),
                  child: SizedBox(
                    width: 78,
                    height: 108,
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

                const SizedBox(width: 13),

                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      vertical: 5,
                      horizontal: 2,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          result.title,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w700,
                            height: 1.2,
                          ),
                        ),

                        if (_year.isNotEmpty) ...[
                          const SizedBox(height: 7),
                          Text(
                            _year,
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: Colors.white54,
                            ),
                          ),
                        ],

                        const SizedBox(height: 12),

                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFFD32F2F)
                                .withValues(alpha: 0.14),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            mediaType == MediaType.tv
                                ? 'TV SHOW'
                                : 'MOVIE',
                            style: theme.textTheme.labelSmall?.copyWith(
                              color: const Color(0xFFFF6B6B),
                              fontWeight: FontWeight.w700,
                              letterSpacing: 0.4,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                const Padding(
                  padding: EdgeInsets.only(
                    top: 5,
                    right: 2,
                  ),
                  child: Icon(
                    Icons.chevron_right,
                    color: Colors.white30,
                    size: 22,
                  ),
                ),
              ],
            ),
          ),
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
      color: const Color(0xFF30343D),
      child: Icon(
        Icons.movie_outlined,
        color: Colors.white38,
        size: 28,
      ),
    );
  }
}