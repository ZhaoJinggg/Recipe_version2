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
  final int failedLoginAttempts;
  final bool isAccountLocked;
  final DateTime? lastFailedAttempt;
  final DateTime? accountLockedUntil;

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
    this.failedLoginAttempts = 0,
    this.isAccountLocked = false,
    this.lastFailedAttempt,
    this.accountLockedUntil,
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
    int? failedLoginAttempts,
    bool? isAccountLocked,
    DateTime? lastFailedAttempt,
    DateTime? accountLockedUntil,
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
      failedLoginAttempts: failedLoginAttempts ?? this.failedLoginAttempts,
      isAccountLocked: isAccountLocked ?? this.isAccountLocked,
      lastFailedAttempt: lastFailedAttempt ?? this.lastFailedAttempt,
      accountLockedUntil: accountLockedUntil ?? this.accountLockedUntil,
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
      'failedLoginAttempts': failedLoginAttempts,
      'isAccountLocked': isAccountLocked,
      'lastFailedAttempt': lastFailedAttempt?.toIso8601String(),
      'accountLockedUntil': accountLockedUntil?.toIso8601String(),
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
      failedLoginAttempts: json['failedLoginAttempts'] ?? 0,
      isAccountLocked: json['isAccountLocked'] ?? false,
      lastFailedAttempt: json['lastFailedAttempt'] != null
          ? DateTime.parse(json['lastFailedAttempt'])
          : null,
      accountLockedUntil: json['accountLockedUntil'] != null
          ? DateTime.parse(json['accountLockedUntil'])
          : null,
    );
  }
}
