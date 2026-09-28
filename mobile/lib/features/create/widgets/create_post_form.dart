import 'package:flutter/material.dart';

class CreatePostForm extends StatelessWidget {
  final TextEditingController titleController;
  final TextEditingController contentController;

  const CreatePostForm({
    super.key,
    required this.titleController,
    required this.contentController,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextField(
          controller: titleController,
          textInputAction: TextInputAction.next,
          maxLength: 120,
          decoration: const InputDecoration(
            labelText: 'Title',
            hintText: 'Give your post a title',
          ),
        ),

        const SizedBox(height: 16),

        TextField(
          controller: contentController,
          minLines: 8,
          maxLines: 16,
          maxLength: 5000,
          textInputAction: TextInputAction.newline,
          decoration: const InputDecoration(
            labelText: 'Review',
            hintText: 'What did you think?',
            alignLabelWithHint: true,
          ),
        ),
      ],
    );
  }
}
