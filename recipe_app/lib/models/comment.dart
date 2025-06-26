class Comment {
  final String username;
  final String text;
  final DateTime timestamp;
  final int likes;

  Comment({
    required this.username,
    required this.text,
    required this.timestamp,
    this.likes = 0,
  });
} 