import 'package:flutter/material.dart';

import '../providers/create_provider.dart';

class MediaTypeToggle extends StatelessWidget {
  final MediaType selectedType;
  final ValueChanged<MediaType> onChanged;

  const MediaTypeToggle({
    super.key,
    required this.selectedType,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: SegmentedButton<MediaType>(
        segments: const [
          ButtonSegment(
            value: MediaType.movie,
            icon: Icon(Icons.movie_outlined),
            label: Text('Movies'),
          ),
          ButtonSegment(
            value: MediaType.tv,
            icon: Icon(Icons.tv_outlined),
            label: Text('TV Shows'),
          ),
        ],
        selected: {selectedType},
        onSelectionChanged: (selection) {
          onChanged(selection.first);
        },
      ),
    );
  }
}
