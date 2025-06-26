class Comment {
  final String id;
  final String recipeId;
  final String userId;
  final String username;
  final String content;
  final DateTime datePosted;
  final int likes;

  Comment({
    required this.id,
    required this.recipeId,
    required this.userId,
    required this.username,
    required this.content,
    DateTime? datePosted,
    this.likes = 0,
  }) : datePosted = datePosted ?? DateTime.now();

  get text => content;
  get timestamp => datePosted;

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'recipeId': recipeId,
      'userId': userId,
      'username': username,
      'content': content,
      'datePosted': datePosted.millisecondsSinceEpoch,
      'likes': likes,
    };
  }

  factory Comment.fromJson(Map<String, dynamic> json) {
    return Comment(
      id: json['id'] ?? '',
      recipeId: json['recipeId'] ?? '',
      userId: json['userId'] ?? '',
      username: json['username'] ?? '',
      content: json['content'] ?? '',
      datePosted: DateTime.fromMillisecondsSinceEpoch(
          json['datePosted'] ?? DateTime.now().millisecondsSinceEpoch),
      likes: json['likes'] ?? 0,
    );
  }
}
