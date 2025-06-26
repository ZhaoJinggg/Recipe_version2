class Post {
  final String id;
  final String userId;
  final String userName;
  final String? userProfileUrl;
  final String content;
  final String? image;
  final DateTime createdAt;
  final List<Comment> comments;
  final int likes;
  final bool hasLiked;

  Post({
    required this.id,
    required this.userId,
    required this.userName,
    this.userProfileUrl,
    required this.content,
    this.image,
    required this.createdAt,
    this.comments = const [],
    this.likes = 0,
    this.hasLiked = false,
  });

  Post copyWith({
    String? id,
    String? userId,
    String? userName,
    String? userProfileUrl,
    String? content,
    String? imageUrl,
    DateTime? createdAt,
    List<Comment>? comments,
    int? likes,
    bool? hasLiked,
  }) {
    return Post(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      userName: userName ?? this.userName,
      userProfileUrl: userProfileUrl ?? this.userProfileUrl,
      content: content ?? this.content,
      image: image ?? this.image,
      createdAt: createdAt ?? this.createdAt,
      comments: comments ?? this.comments,
      likes: likes ?? this.likes,
      hasLiked: hasLiked ?? this.hasLiked,
    );
  }
}

class Comment {
  final String id;
  final String userId;
  final String userName;
  final String? userProfileUrl;
  final String content;
  final DateTime createdAt;

  Comment({
    required this.id,
    required this.userId,
    required this.userName,
    this.userProfileUrl,
    required this.content,
    required this.createdAt,
  });
}
