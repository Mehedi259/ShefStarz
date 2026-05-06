import 'package:get/get.dart';
import '../controller/saved_controller.dart';

class SavedBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<SavedController>(() => SavedController());
  }
}
