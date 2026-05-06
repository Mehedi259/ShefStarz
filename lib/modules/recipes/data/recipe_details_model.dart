import 'package:get/get.dart';
import '../../home/data/interaction_action_model.dart';
// Note: InteractionActionModel can be used for comments, likes, saves, pins

class RecipeDetailsModel {
  final int id;
  final String title;
  final String description;
  final String? media;
  final int servings;
  final String preparationTime;
  final String category;
  final String difficulty;
  final List<Ingredient> ingredients;
  final List<Ingredient> frosting;
  final int userId;
  final UserDetails? userDetails;
  final List<StepModel> steps;

  // Interaction counts
  final RxInt totalLikes;
  final RxInt totalComments;
  final RxInt totalShares;
  final RxInt totalPins;
  final RxInt totalSaves;

  // Interaction states
  final RxBool isLiked;
  final RxBool isPinned;
  final RxBool isSaved;

  // Interaction lists
  final RxList<InteractionActionModel> likesList;
  final RxList<InteractionActionModel> commentsList;
  final RxList<InteractionActionModel> sharesList;
  final RxList<InteractionActionModel> pinsList;
  final RxList<InteractionActionModel> savesList;

  final String createdAt;
  final String updatedAt;
  bool get isVideo =>
      media != null &&
      (media!.toLowerCase().endsWith('.mp4') ||
          media!.toLowerCase().endsWith('.mov'));

  RecipeDetailsModel({
    required this.id,
    required this.title,
    required this.description,
    this.media,
    required this.servings,
    required this.preparationTime,
    required this.category,
    required this.difficulty,
    required this.ingredients,
    required this.frosting,
    required this.userId,
    this.userDetails,
    required this.steps,
    required int initialTotalLikes,
    required int initialTotalComments,
    required int initialTotalShares,
    required int initialTotalPins,
    required int initialTotalSaves,
    required List<InteractionActionModel> initialLikesList,
    required List<InteractionActionModel> initialCommentsList,
    required List<InteractionActionModel> initialSharesList,
    required List<InteractionActionModel> initialPinsList,
    required List<InteractionActionModel> initialSavesList,
    required this.createdAt,
    required this.updatedAt,
    bool initialIsLiked = false,
    bool initialIsPinned = false,
    bool initialIsSaved = false,
  }) : totalLikes = initialTotalLikes.obs,
       totalComments = initialTotalComments.obs,
       totalShares = initialTotalShares.obs,
       totalPins = initialTotalPins.obs,
       totalSaves = initialTotalSaves.obs,
       likesList = initialLikesList.obs,
       commentsList = initialCommentsList.obs,
       sharesList = initialSharesList.obs,
       pinsList = initialPinsList.obs,
       savesList = initialSavesList.obs,
       isLiked = initialIsLiked.obs,
       isPinned = initialIsPinned.obs,
       isSaved = initialIsSaved.obs;

  factory RecipeDetailsModel.fromJson(Map<String, dynamic> json) {
    return RecipeDetailsModel(
      id: json['id'] ?? 0,
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      media: json['media'],
      servings: json['servings'] ?? 0,
      preparationTime: json['preparation_time'] ?? '',
      category: json['category'] ?? '',
      difficulty: json['difficulty'] ?? '',
      ingredients:
          (json['ingredients'] as List<dynamic>?)
              ?.map((e) => Ingredient.fromJson(e))
              .toList() ??
          [],
      frosting:
          (json['frosting'] as List<dynamic>?)
              ?.map((e) => Ingredient.fromJson(e))
              .toList() ??
          [],
      userId: json['user'] ?? 0,
      userDetails: json['user_details'] != null
          ? UserDetails.fromJson(json['user_details'])
          : null,
      steps:
          (json['steps'] as List<dynamic>?)
              ?.map((e) => StepModel.fromJson(e))
              .toList() ??
          [],
      initialTotalLikes: json['total_likes'] ?? 0,
      initialTotalComments: json['total_comments'] ?? 0,
      initialTotalShares: json['total_shares'] ?? 0,
      initialTotalPins: json['total_pins'] ?? 0,
      initialTotalSaves: json['total_saves'] ?? 0,
      initialLikesList:
          (json['likes_list'] as List<dynamic>?)
              ?.map((e) => InteractionActionModel.fromJson(e))
              .toList() ??
          [],
      initialCommentsList:
          (json['comments_list'] as List<dynamic>?)
              ?.map((e) => InteractionActionModel.fromJson(e))
              .toList() ??
          [],
      initialSharesList:
          (json['shares_list'] as List<dynamic>?)
              ?.map((e) => InteractionActionModel.fromJson(e))
              .toList() ??
          [],
      initialPinsList:
          (json['pins_list'] as List<dynamic>?)
              ?.map((e) => InteractionActionModel.fromJson(e))
              .toList() ??
          [],
      initialSavesList:
          (json['saves_list'] as List<dynamic>?)
              ?.map((e) => InteractionActionModel.fromJson(e))
              .toList() ??
          [],
      createdAt: json['created_at'] ?? '',
      updatedAt: json['updated_at'] ?? '',
      initialIsLiked: json['is_liked'] ?? false,
      initialIsPinned: json['is_pinned'] ?? false,
      initialIsSaved: json['is_saved'] ?? false,
    );
  }
}

class Ingredient {
  final String name;
  final String amount;

  Ingredient({required this.name, required this.amount});

  factory Ingredient.fromJson(Map<String, dynamic> json) {
    return Ingredient(name: json['name'] ?? '', amount: json['amount'] ?? '');
  }
}

class StepModel {
  final int id;
  final int step;
  final String title;
  final String description;
  final String? image;

  StepModel({
    required this.id,
    required this.step,
    required this.title,
    required this.description,
    this.image,
  });

  factory StepModel.fromJson(Map<String, dynamic> json) {
    return StepModel(
      id: json['id'] ?? 0,
      step: json['step'] ?? 0,
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      image: json['image'],
    );
  }
}

class UserDetails {
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
  final bool isActive;
  final int followerCount;
  final int followingCount;
  final int postsCount;
  final int recipesCount;

  UserDetails({
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
    required this.isActive,
    required this.followerCount,
    required this.followingCount,
    required this.postsCount,
    required this.recipesCount,
  });

  factory UserDetails.fromJson(Map<String, dynamic> json) {
    return UserDetails(
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
      isActive: json['is_active'] ?? false,
      followerCount: json['follower_count'] ?? 0,
      followingCount: json['following_count'] ?? 0,
      postsCount: json['posts_count'] ?? 0,
      recipesCount: json['recipes_count'] ?? 0,
    );
  }
}
