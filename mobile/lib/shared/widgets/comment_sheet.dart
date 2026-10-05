import 'package:flutter/material.dart';

class CommentsSheet extends StatefulWidget {
  final int postId;

  const CommentsSheet({super.key, required this.postId});

  @override
  State<CommentsSheet> createState() => _CommentsSheetState();
}

class _CommentsSheetState extends State<CommentsSheet> {
  final TextEditingController _commentController = TextEditingController();

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // This padding ensures the sheet and input box rise smoothly when the keyboard opens
    final keyboardHeight = MediaQuery.of(context).viewInsets.bottom;

    return Container(
      height:
          MediaQuery.of(context).size.height *
          0.65, // Takes up ~65% of screen height
      decoration: const BoxDecoration(
        color: Color(0xFF1E1E1E), // Dark modern sheet background
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: EdgeInsets.only(
        left: 16,
        right: 16,
        top: 12,
        bottom: keyboardHeight + 16,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Drag handle indicator
          Center(
            child: Container(
              width: 36,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.white24,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Title
          const Text(
            'Comments',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 12),

          // Comment list area (Placeholder for your comment stream)
          Expanded(
            child: ListView(
              children: const [
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: CircleAvatar(child: Text('A')),
                  title: Text(
                    '@alice',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  subtitle: Text(
                    'This is such an amazing take on the movie!',
                    style: TextStyle(color: Colors.white70, fontSize: 14),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 8),

          // Input field inside the tray
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _commentController,
                  autofocus: true,
                  style: const TextStyle(color: Colors.white, fontSize: 14),
                  decoration: InputDecoration(
                    hintText: 'Write a comment...',
                    hintStyle: const TextStyle(color: Colors.white54),
                    filled: true,
                    fillColor: Colors.white.withOpacity(0.08),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 10,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(30),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              IconButton(
                icon: const Icon(Icons.send_rounded),
                color: Theme.of(context).colorScheme.primary,
                onPressed: () {
                  final text = _commentController.text.trim();
                  if (text.isNotEmpty) {
                    // TODO: Handle sending comment via API
                    _commentController.clear();
                  }
                },
              ),
            ],
          ),
        ],
      ),
    );
  }
}
