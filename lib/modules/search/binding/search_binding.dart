import 'package:get/get.dart';
import '../controller/search_controller.dart';
import '../data/repository/search_repository.dart';

class SearchBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => SearchRepository());
    Get.lazyPut<SearchController>(() => SearchController());
  }
}
