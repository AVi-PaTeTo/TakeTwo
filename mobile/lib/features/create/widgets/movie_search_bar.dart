import 'package:flutter/material.dart';

class MovieSearchBar extends StatefulWidget {
  final String initialValue;
  final ValueChanged<String> onChanged;

  const MovieSearchBar({
    super.key,
    required this.initialValue,
    required this.onChanged,
  });

  @override
  State<MovieSearchBar> createState() => _MovieSearchBarState();
}

class _MovieSearchBarState extends State<MovieSearchBar> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();

    _controller = TextEditingController(text: widget.initialValue);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: _controller,
      onSubmitted: widget.onChanged,
      onChanged: (value) {
        widget.onChanged(value);
        setState(() {});
      },
      textInputAction: TextInputAction.search,
      style: const TextStyle(color: Colors.white, fontSize: 15),
      cursorColor: const Color(0xFFFF5252),
      decoration: InputDecoration(
        hintText: 'Search movies and TV shows',
        hintStyle: const TextStyle(color: Colors.white38, fontSize: 15),

        prefixIcon: const Icon(Icons.search, color: Colors.white54),

        suffixIcon: _controller.text.isEmpty
            ? null
            : IconButton(
                icon: const Icon(Icons.close, color: Colors.white54),
                onPressed: () {
                  _controller.clear();
                  widget.onChanged('');
                  setState(() {});
                },
              ),

        filled: true,
        fillColor: const Color(0xFF212530),

        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 15,
        ),

        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.06)),
        ),

        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.06)),
        ),

        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: Color(0xFFD32F2F), width: 1.2),
        ),
      ),
    );
  }
}
