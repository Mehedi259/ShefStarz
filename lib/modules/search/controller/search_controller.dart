import 'package:get/get.dart';
import '../data/repository/search_repository.dart';
import '../../recipes/data/recipe_model.dart';

class SearchController extends GetxController {
  final SearchRepository _repository = Get.find<SearchRepository>();

  final searchText = ''.obs;

  final recentSearches = <String>[
    "Rainbow Cake",
    "Chicken Tikka",
    "Breakfast",
    "Lunch",
  ].obs;

  final searchResults = <Recipe>[].obs;
  final isLoading = false.obs;
  final status = RxStatus.empty().obs;

  void onSearchChanged(String query) {
    searchText.value = query;
    if (query.isEmpty) {
      status.value = RxStatus.empty();
      searchResults.clear();
      return;
    }

    // Use GetX debounce on searchText
    debounce(
      searchText,
      (_) => _performSearch(searchText.value),
      time: const Duration(milliseconds: 500),
    );
  }

  Future<void> _performSearch(String query) async {
    if (query.isEmpty) return;

    try {
      isLoading.value = true;
      status.value = RxStatus.loading();

      final results = await _repository.search(query);
      searchResults.assignAll(results);

      if (results.isEmpty) {
        status.value = RxStatus.empty();
      } else {
        status.value = RxStatus.success();
      }

      // Add to recent searches if not present
      if (!recentSearches.contains(query)) {
        recentSearches.insert(0, query);
      }
    } catch (e) {
      status.value = RxStatus.error(e.toString());
    } finally {
      isLoading.value = false;
    }
  }

  void removeSearchItem(int index) {
    recentSearches.removeAt(index);
  }

  void clearRecentSearches() {
    recentSearches.clear();
  }
}
