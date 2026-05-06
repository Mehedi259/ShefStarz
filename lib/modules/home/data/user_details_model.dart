class UserDetailsModel {
  final int id;
  final String email;
  final String username;
  final String? ageGroup;
  final String? profilePicture;
  final String? bio;
  final String? location;
  final String? parentEmail;
  final bool isEmailVerified;
  final bool isParentApproved;
  final int followerCount;
  final int followingCount;
  final int postsCount;
  final int recipesCount;

  UserDetailsModel({
    required this.id,
    required this.email,
    required this.username,
    this.ageGroup,
    this.profilePicture,
    this.bio,
    this.location,
    this.parentEmail,
    required this.isEmailVerified,
    required this.isParentApproved,
    required this.followerCount,
    required this.followingCount,
    required this.postsCount,
    required this.recipesCount,
  });

  factory UserDetailsModel.fromJson(Map<String, dynamic> json) {
    return UserDetailsModel(
      id: json['id'] ?? 0,
      email: json['email'] ?? '',
      username: json['username'] ?? '',
      ageGroup: json['age_group'],
      profilePicture: json['profile_picture'],
      bio: json['bio'],
      location: json['location'],
      parentEmail: json['parent_email'],
      isEmailVerified: json['is_email_verified'] ?? false,
      isParentApproved: json['is_parent_approved'] ?? false,
      followerCount: json['follower_count'] ?? 0,
      followingCount: json['following_count'] ?? 0,
      postsCount: json['posts_count'] ?? 0,
      recipesCount: json['recipes_count'] ?? 0,
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
      'follower_count': followerCount,
      'following_count': followingCount,
      'posts_count': postsCount,
      'recipes_count': recipesCount,
    };
  }
}
