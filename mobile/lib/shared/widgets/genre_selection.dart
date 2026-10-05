import 'package:flutter/material.dart';

class GenreSelectorWidget extends StatelessWidget {
  static const Map<int, String> genreNames = {
    28: 'Action',
    12: 'Adventure',
    16: 'Animation',
    35: 'Comedy',
    80: 'Crime',
    99: 'Documentary',
    18: 'Drama',
    10751: 'Family',
    14: 'Fantasy',
    36: 'History',
    27: 'Horror',
    10402: 'Music',
    9648: 'Mystery',
    10749: 'Romance',
    878: 'Science Fiction',
    10770: 'TV Movie',
    53: 'Thriller',
    10752: 'War',
    37: 'Western',
  };

  final Set<int> selectedGenres;
  final ValueChanged<int> onGenreToggled;

  const GenreSelectorWidget({
    super.key,
    required this.selectedGenres,
    required this.onGenreToggled,
  });

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      runSpacing: 4,
      children: genreNames.entries.map((entry) {
        final genreId = entry.key;
        final genreName = entry.value;
        final selected = selectedGenres.contains(genreId);

        return FilterChip(
          label: Text(genreName),
          selected: selected,
          onSelected: (_) => onGenreToggled(genreId),
        );
      }).toList(),
    );
  }
}
