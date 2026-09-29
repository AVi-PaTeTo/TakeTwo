import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';

class CachedPosterImage extends StatelessWidget {
  final String? posterPath;
  final double? width;
  final double? height;
  final BoxFit fit;

  const CachedPosterImage({
    super.key,
    required this.posterPath,
    this.width,
    this.height,
    this.fit = BoxFit.cover,
  });

  @override
  Widget build(BuildContext context) {
    if (posterPath == null || posterPath!.isEmpty) {
      return _placeholder();
    }

    // Format full TMDB path if it's a relative path, or use full URL if it's custom
    final imageUrl = posterPath!.startsWith('http')
        ? posterPath!
        : 'https://image.tmdb.org/t/p/w500$posterPath';

    return CachedNetworkImage(
      imageUrl: imageUrl,
      width: width,
      height: height,
      fit: fit,
      // Shows a smooth placeholder while downloading the image for the first time
      placeholder: (context, url) => Container(
        width: width,
        height: height,
        color: Colors.grey.shade300,
        child: const Center(
          child: SizedBox(
            width: 24,
            height: 24,
            child: CircularProgressIndicator(strokeWidth: 2),
          ),
        ),
      ),
      // Falls back to placeholder if the network fails
      errorWidget: (context, url, error) => _placeholder(),
    );
  }

  Widget _placeholder() {
    return Container(
      width: width,
      height: height,
      color: Colors.grey.shade300,
      child: const Center(
        child: Icon(Icons.movie_outlined, size: 40, color: Colors.grey),
      ),
    );
  }
}
