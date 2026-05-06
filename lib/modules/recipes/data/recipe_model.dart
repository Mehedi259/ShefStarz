import 'package:get/get.dart';
import '../../home/data/interaction_action_model.dart';

class Recipe {
  final String id;
  final String title;
  final String chefName;
  final String time;
  final String servings;
  final String description;
  final String image;
  final String rating; // Added rating
  final List<String> ingredients;
  final List<String> frostingIngredients;
  final List<RecipeStep> steps;

  // Interaction states
  final RxBool isLiked;
  final RxBool isPinned;
  final RxBool isSaved;
  final RxInt likesCount;
  final RxInt commentsCount; // Added for comments
  final RxList<InteractionActionModel> commentsList; // Added for comments list
  bool get isVideo =>
      image.toLowerCase().endsWith('.mp4') ||
      image.toLowerCase().endsWith('.mov');

  Recipe({
    required this.id,
    required this.title,
    required this.chefName,
    required this.time,
    required this.servings,
    required this.description,
    required this.image,
    this.rating = '4.5', // Default value
    required this.ingredients,
    this.frostingIngredients = const [],
    required this.steps,
    bool isLiked = false,
    bool isPinned = false,
    bool isSaved = false,
    int likesCount = 0,
    int commentsCount = 0,
    List<InteractionActionModel>? commentsList,
  }) : isLiked = isLiked.obs,
       isPinned = isPinned.obs,
       isSaved = isSaved.obs,
       likesCount = likesCount.obs,
       commentsCount = commentsCount.obs,
       commentsList = (commentsList ?? []).obs;

  factory Recipe.fromJson(Map<String, dynamic> json) {
    return Recipe(
      id: json['id']?.toString() ?? '',
      title: json['title']?.toString() ?? '',
      chefName: json['chefName']?.toString() ?? '',
      time: json['time']?.toString() ?? '',
      servings: json['servings']?.toString() ?? '',
      description: json['description']?.toString() ?? '',
      image: json['media']?.toString() ?? json['image']?.toString() ?? '',
      rating: json['rating']?.toString() ?? '4.5',
      ingredients: (json['ingredients'] as List? ?? []).map((e) {
        if (e is String) return e;
        if (e is Map) return "${e['amount'] ?? ''} ${e['name'] ?? ''}".trim();
        return e.toString();
      }).toList(),
      frostingIngredients: List<String>.from(json['frostingIngredients'] ?? []),
      steps: (json['steps'] as List? ?? [])
          .map((s) => RecipeStep.fromJson(s))
          .toList(),
      isLiked: json['is_liked'] ?? false,
      isPinned: json['is_pinned'] ?? false,
      isSaved: json['is_saved'] ?? false,
      likesCount: json['likes_count'] ?? 0,
      commentsCount: json['comments_count'] ?? 0,
      commentsList:
          (json['comments'] as List<dynamic>?)
              ?.map((c) => InteractionActionModel.fromJson(c))
              .toList() ??
          (json['comments_list'] as List<dynamic>?)
              ?.map((c) => InteractionActionModel.fromJson(c))
              .toList() ??
          [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'chefName': chefName,
      'time': time,
      'servings': servings,
      'description': description,
      'image': image,
      'ingredients': ingredients,
      'frostingIngredients': frostingIngredients,
      'steps': steps.map((s) => s.toJson()).toList(),
      'is_liked': isLiked.value,
      'is_pinned': isPinned.value,
      'is_saved': isSaved.value,
      'likes_count': likesCount.value,
      'comments_count': commentsCount.value,
      'comments': commentsList.map((c) => c.toJson()).toList(),
    };
  }
}

class RecipeStep {
  final String title;
  final String description;
  final String image;

  RecipeStep({
    required this.title,
    required this.description,
    required this.image,
  });

  factory RecipeStep.fromJson(Map<String, dynamic> json) {
    return RecipeStep(
      title: json['title']?.toString() ?? '',
      description: json['description']?.toString() ?? '',
      image: json['image']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {'title': title, 'description': description, 'image': image};
  }
}
