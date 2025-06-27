// Import removed - PostComment is defined in this file

class Post {
  final String id;
  final String userId;
  final String userName;
  final String? userProfileUrl;
  final String content;
  final String? image;
  final DateTime createdAt;
  final List<PostComment> comments;
  final int likes;
  final bool hasLiked;
  final List<String> likedBy;

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
    this.likedBy = const [],
  });

  // Helper method to check if a specific user has liked the post
  bool isLikedByUser(String userId) {
    return likedBy.contains(userId);
  }

  Post copyWith({
    String? id,
    String? userId,
    String? userName,
    String? userProfileUrl,
    String? content,
    String? imageUrl,
    DateTime? createdAt,
    List<PostComment>? comments,
    int? likes,
    bool? hasLiked,
    List<String>? likedBy,
  }) {
    return Post(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      userName: userName ?? this.userName,
      userProfileUrl: userProfileUrl ?? this.userProfileUrl,
      content: content ?? this.content,
      image: imageUrl ?? image,
      createdAt: createdAt ?? this.createdAt,
      comments: comments ?? this.comments,
      likes: likes ?? this.likes,
      hasLiked: hasLiked ?? this.hasLiked,
      likedBy: likedBy ?? this.likedBy,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'userName': userName,
      'userProfileUrl': userProfileUrl,
      'content': content,
      'image': image,
      'createdAt': createdAt.millisecondsSinceEpoch,
      'comments': comments.map((comment) => comment.toJson()).toList(),
      'likes': likes,
      'hasLiked': hasLiked,
      'likedBy': likedBy,
    };
  }

  factory Post.fromJson(Map<String, dynamic> json) {
    final likedBy = List<String>.from(json['likedBy'] ?? []);
    final likes = json['likes'] ?? 0;

    // Ensure likes count matches likedBy array length if likedBy exists
    final actualLikes = likedBy.isNotEmpty ? likedBy.length : likes;

    return Post(
      id: json['id'] ?? '',
      userId: json['userId'] ?? '',
      userName: json['userName'] ?? '',
      userProfileUrl: json['userProfileUrl'],
      content: json['content'] ?? '',
      image: json['image'],
      createdAt: DateTime.fromMillisecondsSinceEpoch(
          json['createdAt'] ?? DateTime.now().millisecondsSinceEpoch),
      comments: (json['comments'] as List<dynamic>? ?? [])
          .map((commentJson) => PostComment.fromJson(commentJson))
          .toList(),
      likes: actualLikes,
      hasLiked: json['hasLiked'] ?? false,
      likedBy: likedBy,
    );
  }
}

class PostComment {
  final String id;
  final String userId;
  final String userName;
  final String? userProfileUrl;
  final String content;
  final DateTime createdAt;

  PostComment({
    required this.id,
    required this.userId,
    required this.userName,
    this.userProfileUrl,
    required this.content,
    required this.createdAt,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'userName': userName,
      'userProfileUrl': userProfileUrl,
      'content': content,
      'createdAt': createdAt.millisecondsSinceEpoch,
    };
  }

  factory PostComment.fromJson(Map<String, dynamic> json) {
    return PostComment(
      id: json['id'] ?? '',
      userId: json['userId'] ?? '',
      userName: json['userName'] ?? '',
      userProfileUrl: json['userProfileUrl'],
      content: json['content'] ?? '',
      createdAt: DateTime.fromMillisecondsSinceEpoch(
          json['createdAt'] ?? DateTime.now().millisecondsSinceEpoch),
    );
  }
}
