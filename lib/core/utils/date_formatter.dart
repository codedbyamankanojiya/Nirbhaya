import 'package:intl/intl.dart';

String formatDate(DateTime date) {
  return DateFormat('MMM d, yyyy').format(date);
}

String formatTime(DateTime date) {
  return DateFormat('h:mm a').format(date);
}

String formatDateTime(DateTime date) {
  return '${formatDate(date)} at ${formatTime(date)}';
}

String formatRelative(DateTime date) {
  final now = DateTime.now();
  final difference = now.difference(date);

  if (difference.inDays > 7) {
    return formatDate(date);
  } else if (difference.inDays >= 2) {
    return '${difference.inDays} days ago';
  } else if (difference.inDays >= 1) {
    return 'Yesterday';
  } else if (difference.inHours >= 2) {
    return '${difference.inHours} hours ago';
  } else if (difference.inHours >= 1) {
    return 'An hour ago';
  } else if (difference.inMinutes >= 2) {
    return '${difference.inMinutes} minutes ago';
  } else if (difference.inMinutes >= 1) {
    return 'A minute ago';
  } else {
    return 'Just now';
  }
}
