class UserModel {
  final String id;
  final String email;
  final String username;
  final String? ageGroup;
  final String? profilePicture;
  final String? bio;
  final String? location;
  final String? parentEmail;
  final bool isEmailVerified;
  final bool isParentApproved;
  final bool isActive;
  final int followerCount;
  final int followingCount;
  final int postsCount;
  final int recipesCount;

  // Added name getter to map to username for compatibility
  String get name => username;

  UserModel({
    required this.id,
    required this.email,
    required this.username,
    this.ageGroup,
    this.profilePicture,
    this.bio,
    this.location,
    this.parentEmail,
    this.isEmailVerified = false,
    this.isParentApproved = false,
    this.isActive = true,
    this.followerCount = 0,
    this.followingCount = 0,
    this.postsCount = 0,
    this.recipesCount = 0,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id']?.toString() ?? '',
      email: json['email'] ?? '',
      username: json['username'] ?? json['name'] ?? '',
      ageGroup: json['age_group'],
      profilePicture:
          json['profile_picture'] ?? json['avatar'] ?? json['image'],
      bio: json['bio'],
      location: json['location'],
      parentEmail: json['parent_email'] ?? json['parentEmail'],
      isEmailVerified: json['is_email_verified'] ?? json['isVerified'] ?? false,
      isParentApproved: json['is_parent_approved'] ?? false,
      isActive: json['is_active'] ?? true,
      followerCount:
          int.tryParse(json['follower_count']?.toString() ?? '0') ?? 0,
      followingCount:
          int.tryParse(json['following_count']?.toString() ?? '0') ?? 0,
      postsCount: int.tryParse(json['posts_count']?.toString() ?? '0') ?? 0,
      recipesCount: int.tryParse(json['recipes_count']?.toString() ?? '0') ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'username': username,
      'age_group': ageGroup,
      'profile_picture': profilePicture,
      'bio': bio,
      'location': location,
      'parent_email': parentEmail,
      'is_email_verified': isEmailVerified,
      'is_parent_approved': isParentApproved,
      'is_active': isActive,
      'follower_count': followerCount,
      'following_count': followingCount,
      'posts_count': postsCount,
      'recipes_count': recipesCount,
    };
  }

  UserModel copyWith({
    String? email,
    String? username,
    String? ageGroup,
    String? profilePicture,
    String? bio,
    String? location,
    String? parentEmail,
    bool? isEmailVerified,
    bool? isParentApproved,
    bool? isActive,
    int? followerCount,
    int? followingCount,
    int? postsCount,
    int? recipesCount,
    String? name, // for backwards compat
  }) {
    return UserModel(
      id: id,
      email: email ?? this.email,
      username: username ?? name ?? this.username,
      ageGroup: ageGroup ?? this.ageGroup,
      profilePicture: profilePicture ?? this.profilePicture,
      bio: bio ?? this.bio,
      location: location ?? this.location,
      parentEmail: parentEmail ?? this.parentEmail,
      isEmailVerified: isEmailVerified ?? this.isEmailVerified,
      isParentApproved: isParentApproved ?? this.isParentApproved,
      isActive: isActive ?? this.isActive,
      followerCount: followerCount ?? this.followerCount,
      followingCount: followingCount ?? this.followingCount,
      postsCount: postsCount ?? this.postsCount,
      recipesCount: recipesCount ?? this.recipesCount,
    );
  }
}
