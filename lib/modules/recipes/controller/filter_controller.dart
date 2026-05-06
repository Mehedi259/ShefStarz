import 'package:get/get.dart';

class FilterController extends GetxController {
  final selectedCategory = "Breakfast".obs;
  final selectedMediaType = "Recipes Only".obs;
  final selectedTime = "Under 10 Minutes".obs;
  final selectedDifficulty = "Easy".obs;
  final selectedLocation = "Global".obs;
  final isVerifiedOnly = false.obs;

  void setCategory(String value) => selectedCategory.value = value;
  void setMediaType(String value) => selectedMediaType.value = value;
  void setTime(String value) => selectedTime.value = value;
  void setDifficulty(String value) => selectedDifficulty.value = value;
  void setLocation(String? value) {
    if (value != null) selectedLocation.value = value;
  }

  void toggleVerified(bool? value) => isVerifiedOnly.value = value ?? false;

  void reset() {
    selectedCategory.value = "Breakfast";
    selectedMediaType.value = "Recipes Only";
    selectedTime.value = "Under 10 Minutes";
    selectedDifficulty.value = "Easy";
    selectedLocation.value = "Global";
    isVerifiedOnly.value = false;
  }
}
