class User {
  final String id;
  final String name;
  final String email;
  final String? profileImageUrl;
  final String? bio;
  final String? phone;
  final String? dateOfBirth;
  final String? gender;
  final List<String> favoriteRecipes;
  final List<String> postedRecipes;

  User({
    required this.id,
    required this.name,
    required this.email,
    this.profileImageUrl,
    this.bio,
    this.phone,
    this.dateOfBirth,
    this.gender,
    this.favoriteRecipes = const [],
    this.postedRecipes = const [],
  });

  get profileImage => null;

  User copyWith({
    String? id,
    String? name,
    String? email,
    String? profileImageUrl,
    String? bio,
    String? phone,
    String? dateOfBirth,
    String? gender,
    List<String>? favoriteRecipes,
    List<String>? postedRecipes,
  }) {
    return User(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      profileImageUrl: profileImageUrl ?? this.profileImageUrl,
      bio: bio ?? this.bio,
      phone: phone ?? this.phone,
      dateOfBirth: dateOfBirth ?? this.dateOfBirth,
      gender: gender ?? this.gender,
      favoriteRecipes: favoriteRecipes ?? this.favoriteRecipes,
      postedRecipes: postedRecipes ?? this.postedRecipes,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'profileImageUrl': profileImageUrl,
      'bio': bio,
      'phone': phone,
      'dateOfBirth': dateOfBirth,
      'gender': gender,
      'favoriteRecipes': favoriteRecipes,
      'postedRecipes': postedRecipes,
    };
  }

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'],
      name: json['name'],
      email: json['email'],
      profileImageUrl: json['profileImageUrl'],
      bio: json['bio'],
      phone: json['phone'],
      dateOfBirth: json['dateOfBirth'],
      gender: json['gender'],
      favoriteRecipes: List<String>.from(json['favoriteRecipes'] ?? []),
      postedRecipes: List<String>.from(json['postedRecipes'] ?? []),
    );
  }
}
