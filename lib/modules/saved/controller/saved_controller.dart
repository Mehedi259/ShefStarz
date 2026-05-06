import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../home/data/post_model.dart';
import '../../home/data/home_service.dart';
import '../../recipes/data/recipe_service.dart';
import '../../../core/api/api_client.dart';

class SavedCollection {
  final String id;
  final String name;
  final String? coverImage;
  final List<String> itemIds;

  SavedCollection({
    required this.id,
    required this.name,
    this.coverImage,
    required this.itemIds,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'coverImage': coverImage,
    'itemIds': itemIds,
  };

  factory SavedCollection.fromJson(Map<String, dynamic> json) =>
      SavedCollection(
        id: json['id'],
        name: json['name'],
        coverImage: json['coverImage'],
        itemIds: List<String>.from(json['itemIds'] ?? []),
      );
}

class SavedController extends GetxController {
  static SavedController get to => Get.find();

  final customCollections = <SavedCollection>[].obs;
  final savedItems = <Post>[].obs;
  final isLoading = false.obs;
  final ImagePicker _picker = ImagePicker();

  final selectedCollections = <String>{}.obs;

  @override
  void onInit() {
    super.onInit();
    _loadCollections();
  }

  Future<void> _loadCollections() async {
    final prefs = await SharedPreferences.getInstance();
    final String? collectionsJson = prefs.getString('saved_collections');

    if (collectionsJson != null && collectionsJson.isNotEmpty) {
      try {
        final List<dynamic> decoded = jsonDecode(collectionsJson);
        customCollections.value = decoded
            .map((e) => SavedCollection.fromJson(e))
            .toList();
      } catch (e) {
        Get.log("Error decoding collections: $e");
        customCollections.clear();
      }
    } else {
      customCollections.clear();
    }

    // Fetch the real saved items from the backend
    fetchSavedItems();
  }

  Future<void> _saveCollections() async {
    final prefs = await SharedPreferences.getInstance();
    final String encoded = jsonEncode(
      customCollections.map((c) => c.toJson()).toList(),
    );
    await prefs.setString('saved_collections', encoded);
  }

  Future<void> fetchSavedItems() async {
    isLoading.value = true;
    try {
      List<Post> items = [];

      // Fetch saved posts
      final postRes = await ApiClient.to.getRequest('posts/posts/?saved=true');
      if (postRes.statusCode == 200 && postRes.body is List) {
        items.addAll(
          (postRes.body as List).map((j) => Post.fromJson(j)).toList(),
        );
      }

      // Fetch saved recipes
      final recipeRes = await ApiClient.to.getRequest(
        'recipes/recipes/?saved=true',
      );
      if (recipeRes.statusCode == 200 && recipeRes.body is List) {
        items.addAll(
          (recipeRes.body as List).map((j) {
            final r = j as Map<String, dynamic>;
            final user = r['user_details'] ?? {};
            return Post(
              id: r['id'].toString(),
              title: r['title'] ?? '',
              description: r['description'] ?? '',
              image: r['media'] ?? '',
              chefName: user['username'] ?? 'Unknown',
              timeAgo: r['created_at'] ?? '',
              likes: (r['total_likes'] ?? 0).toString(),
              commentsCount: (r['total_comments'] ?? 0).toString(),
              isSaved: true,
              postType: 'recipe',
            );
          }).toList(),
        );
      }
      savedItems.value = items;
    } catch (e) {
      Get.log("Error: $e");
    } finally {
      isLoading.value = false;
    }
  }

  Future<String?> pickImage() async {
    try {
      final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
      return image?.path;
    } catch (e) {
      Get.snackbar('Error', 'Failed to pick image');
      return null;
    }
  }

  void createCollection(String name, String? imagePath) {
    if (name.trim().isEmpty) return;
    customCollections.add(
      SavedCollection(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        name: name.trim(),
        coverImage: imagePath,
        itemIds: [],
      ),
    );
    _saveCollections(); // Persist to local storage
    Get.back();
    Get.snackbar('Success', 'Collection created successfully');
  }

  void saveItemToCollection(String collectionId, String itemId) {
    final index = customCollections.indexWhere((c) => c.id == collectionId);
    if (index != -1 &&
        !customCollections[index].itemIds.contains(itemId.toString())) {
      customCollections[index].itemIds.add(itemId.toString());
      customCollections.refresh();
      _saveCollections(); // Persist to local storage
    }
  }

  // Selection & Deletion Logic
  void toggleSelection(String id) {
    if (selectedCollections.contains(id)) {
      selectedCollections.remove(id);
    } else {
      selectedCollections.add(id);
    }
  }

  void clearSelection() => selectedCollections.clear();

  void deleteSelectedCollections() {
    if (selectedCollections.isEmpty) return;
    Get.defaultDialog(
      title: "Delete Collections",
      middleText: "Are you sure you want to delete the selected collections?",
      textConfirm: "Delete",
      textCancel: "Cancel",
      confirmTextColor: Colors.white,
      buttonColor: Colors.red,
      onConfirm: () {
        customCollections.removeWhere(
          (c) => selectedCollections.contains(c.id),
        );
        selectedCollections.clear();
        _saveCollections(); // Persist deletion to local storage
        Get.back();
        Get.snackbar('Success', 'Collections deleted successfully.');
      },
    );
  }

  void confirmAndUnsave(Post post) {
    Get.defaultDialog(
      title: "Unsave Item",
      middleText: "Are you sure you want to unsave this item?",
      textConfirm: "Yes, Unsave",
      textCancel: "Cancel",
      confirmTextColor: Colors.white,
      buttonColor: const Color(0xFFFF8A1F),
      onConfirm: () async {
        Get.back();
        isLoading.value = true;
        if (post.postType == 'recipe') {
          await ApiClient.to.postRequest(
            'recipes/recipes/${post.id}/save_recipe/',
            {},
          );
        } else {
          await HomeService.to.saveFeedPost(post.id);
        }
        // Remove locally from collections
        for (var collection in customCollections) {
          collection.itemIds.remove(post.id.toString());
        }
        _saveCollections();
        await fetchSavedItems(); // Fetch latest from backend
      },
    );
  }

  Future<void> clearAllSaves() async {
    isLoading.value = true;
    try {
      // Unsave from backend
      for (var item in savedItems) {
        if (item.postType == 'recipe') {
          await ApiClient.to.postRequest(
            'recipes/recipes/${item.id}/save_recipe/',
            {},
          );
        } else {
          await ApiClient.to.postRequest(
            'posts/posts/${item.id}/save_post/',
            {},
          );
        }
      }

      // Reset Local State
      savedItems.clear();
      customCollections.clear(); // Make it completely empty
      await _saveCollections();

      if (Get.isRegistered<HomeService>()) HomeService.to.fetchFeed();
      if (Get.isRegistered<RecipeService>()) RecipeService.to.fetchRecipes();

      Get.snackbar(
        'Success',
        'All saved items and collections have been wiped clean.',
      );
    } catch (e) {
      Get.snackbar('Error', 'Failed to clear items.');
    } finally {
      isLoading.value = false;
    }
  }
}
