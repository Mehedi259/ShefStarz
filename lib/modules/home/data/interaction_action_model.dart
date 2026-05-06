class InteractionActionModel {
  final int id;
  final String user;
  final String createdAt;
  final String? text;
  final String? comment;
  final String? profilePicture;

  InteractionActionModel({
    required this.id,
    required this.user,
    required this.createdAt,
    this.text,
    this.comment,
    this.profilePicture,
  });

  String get formattedUser {
    if (user.contains('@')) {
      return user.split('@').first;
    }
    return user;
  }

  factory InteractionActionModel.fromJson(Map<String, dynamic> json) {
    return InteractionActionModel(
      id: json['id'] is int
          ? json['id']
          : int.tryParse(json['id']?.toString() ?? '') ?? 0,
      user: json['user']?.toString() ?? json['username']?.toString() ?? '',
      createdAt: json['created_at']?.toString() ?? '',
      text: json['text']?.toString(),
      comment: json['comment']?.toString(),
      profilePicture:
          json['profile_picture']?.toString() ?? json['avatar']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user': user,
      'created_at': createdAt,
      'text': text,
      'comment': comment,
      'profile_picture': profilePicture,
    };
  }
}
