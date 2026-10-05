class TimeAgo {
  static String format(String timestamp) {
    try {
      final postedAt = DateTime.parse(timestamp).toLocal();
      final now = DateTime.now();

      final difference = now.difference(postedAt);

      // Future timestamps
      if (difference.isNegative) {
        return 'just now';
      }

      // Less than a minute
      if (difference.inSeconds < 60) {
        return 'just now';
      }

      // Less than an hour
      if (difference.inMinutes < 60) {
        final minutes = difference.inMinutes;
        return '$minutes ${minutes == 1 ? 'minute' : 'minutes'} ago';
      }

      // Less than a day
      if (difference.inHours < 24) {
        final hours = difference.inHours;
        return '$hours ${hours == 1 ? 'hour' : 'hours'} ago';
      }

      // Yesterday / days ago
      if (difference.inDays == 1) {
        return 'yesterday';
      }

      if (difference.inDays < 7) {
        return '${difference.inDays} days ago';
      }

      // Older posts
      const months = [
        'Jan',
        'Feb',
        'Mar',
        'Apr',
        'May',
        'Jun',
        'Jul',
        'Aug',
        'Sep',
        'Oct',
        'Nov',
        'Dec',
      ];

      return '${months[postedAt.month - 1]} ${postedAt.day}';
    } catch (_) {
      return '';
    }
  }
}
