import 'interaction_action_model.dart';
import 'user_details_model.dart';

class Post {
  final String id;
  final String chefName;
  final String timeAgo;
  final String title;
  final String description;
  final String likes;
  final String commentsCount;
  final String image;
  final bool isLiked;
  final bool isPinned;
  final bool isSaved;

  // New detailed properties
  final String? postType;
  final UserDetailsModel? userDetails;
  final int? totalLikes;
  final int? totalComments;
  final int? totalShares;
  final int? totalPins;
  final int? totalSaves;
  final List<InteractionActionModel>? likesList;
  final List<InteractionActionModel>? commentsList;
  final List<InteractionActionModel>? sharesList;
  final List<InteractionActionModel>? pinsList;
  final List<InteractionActionModel>? savesList;
  final String? createdAt;
  final String? updatedAt;

  Post({
    required this.id,
    required this.chefName,
    required this.timeAgo,
    required this.title,
    required this.description,
    required this.likes,
    required this.commentsCount,
    required this.image,
    this.isLiked = false,
    this.isPinned = false,
    this.isSaved = false,
    this.postType,
    this.userDetails,
    this.totalLikes,
    this.totalComments,
    this.totalShares,
    this.totalPins,
    this.totalSaves,
    this.likesList,
    this.commentsList,
    this.sharesList,
    this.pinsList,
    this.savesList,
    this.createdAt,
    this.updatedAt,
  });

  factory Post.fromJson(Map<String, dynamic> json) {
    return Post(
      id: json['id']?.toString() ?? '',
      chefName: json['user_details']?['username'] ?? json['chefName'] ?? '',
      timeAgo: json['created_at'] ?? json['timeAgo'] ?? '',
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      likes:
          json['total_likes']?.toString() ?? json['likes']?.toString() ?? '0',
      commentsCount:
          json['total_comments']?.toString() ??
          json['commentsCount']?.toString() ??
          '0',
      image: json['media'] ?? json['image'] ?? '',
      isLiked: json['is_liked'] ?? false,
      isPinned: json['is_pinned'] ?? false,
      isSaved: json['is_saved'] ?? false,
      postType: json['post_type'],
      userDetails: json['user_details'] != null
          ? UserDetailsModel.fromJson(json['user_details'])
          : null,
      totalLikes: json['total_likes'],
      totalComments: json['total_comments'],
      totalShares: json['total_shares'],
      totalPins: json['total_pins'],
      totalSaves: json['total_saves'],
      likesList: (json['likes_list'] as List<dynamic>?)
          ?.map((e) => InteractionActionModel.fromJson(e))
          .toList(),
      commentsList: (json['comments_list'] as List<dynamic>?)
          ?.map((e) => InteractionActionModel.fromJson(e))
          .toList(),
      sharesList: (json['shares_list'] as List<dynamic>?)
          ?.map((e) => InteractionActionModel.fromJson(e))
          .toList(),
      pinsList: (json['pins_list'] as List<dynamic>?)
          ?.map((e) => InteractionActionModel.fromJson(e))
          .toList(),
      savesList: (json['saves_list'] as List<dynamic>?)
          ?.map((e) => InteractionActionModel.fromJson(e))
          .toList(),
      createdAt: json['created_at'],
      updatedAt: json['updated_at'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'chefName': chefName,
      'timeAgo': timeAgo,
      'title': title,
      'description': description,
      'likes': likes,
      'commentsCount': commentsCount,
      'image': image,
      'is_liked': isLiked,
      'is_pinned': isPinned,
      'is_saved': isSaved,
      'post_type': postType,
      'user_details': userDetails?.toJson(),
      'total_likes': totalLikes,
      'total_comments': totalComments,
      'total_shares': totalShares,
      'total_pins': totalPins,
      'total_saves': totalSaves,
      'likes_list': likesList?.map((e) => e.toJson()).toList(),
      'comments_list': commentsList?.map((e) => e.toJson()).toList(),
      'shares_list': sharesList?.map((e) => e.toJson()).toList(),
      'pins_list': pinsList?.map((e) => e.toJson()).toList(),
      'saves_list': savesList?.map((e) => e.toJson()).toList(),
      'created_at': createdAt,
      'updated_at': updatedAt,
    };
  }

  Post copyWith({
    String? id,
    String? chefName,
    String? timeAgo,
    String? title,
    String? description,
    String? likes,
    String? commentsCount,
    String? image,
    bool? isLiked,
    bool? isPinned,
    bool? isSaved,
    String? postType,
    UserDetailsModel? userDetails,
    int? totalLikes,
    int? totalComments,
    int? totalShares,
    int? totalPins,
    int? totalSaves,
    List<InteractionActionModel>? likesList,
    List<InteractionActionModel>? commentsList,
    List<InteractionActionModel>? sharesList,
    List<InteractionActionModel>? pinsList,
    List<InteractionActionModel>? savesList,
    String? createdAt,
    String? updatedAt,
  }) {
    return Post(
      id: id ?? this.id,
      chefName: chefName ?? this.chefName,
      timeAgo: timeAgo ?? this.timeAgo,
      title: title ?? this.title,
      description: description ?? this.description,
      likes: likes ?? this.likes,
      commentsCount: commentsCount ?? this.commentsCount,
      image: image ?? this.image,
      isLiked: isLiked ?? this.isLiked,
      isPinned: isPinned ?? this.isPinned,
      isSaved: isSaved ?? this.isSaved,
      postType: postType ?? this.postType,
      userDetails: userDetails ?? this.userDetails,
      totalLikes: totalLikes ?? this.totalLikes,
      totalComments: totalComments ?? this.totalComments,
      totalShares: totalShares ?? this.totalShares,
      totalPins: totalPins ?? this.totalPins,
      totalSaves: totalSaves ?? this.totalSaves,
      likesList: likesList ?? this.likesList,
      commentsList: commentsList ?? this.commentsList,
      sharesList: sharesList ?? this.sharesList,
      pinsList: pinsList ?? this.pinsList,
      savesList: savesList ?? this.savesList,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}

class Chef {
  final String id;
  final String name;
  final String image;

  Chef({required this.id, required this.name, required this.image});

  factory Chef.fromJson(Map<String, dynamic> json) {
    return Chef(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      image: json['image'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {'id': id, 'name': name, 'image': image};
  }
}
