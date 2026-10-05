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
        showSelectedIcon: false,
        style: ButtonStyle(
          padding: const WidgetStatePropertyAll(
            EdgeInsets.symmetric(horizontal: 18, vertical: 12),
          ),
          textStyle: const WidgetStatePropertyAll(
            TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
          ),
          shape: WidgetStatePropertyAll(
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
          side: WidgetStatePropertyAll(
            BorderSide(color: Colors.white.withValues(alpha: 0.07)),
          ),
          backgroundColor: WidgetStateProperty.resolveWith((states) {
            if (states.contains(WidgetState.selected)) {
              return const Color(0xFFD32F2F);
            }

            return const Color(0xFF212530);
          }),
          foregroundColor: WidgetStateProperty.resolveWith((states) {
            if (states.contains(WidgetState.selected)) {
              return Colors.white;
            }

            return Colors.white60;
          }),
          overlayColor: const WidgetStatePropertyAll(Color(0x22FFFFFF)),
        ),
      ),
    );
  }
}
