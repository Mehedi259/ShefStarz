import 'package:get/get.dart';
import '../controller/upload_controller.dart';
import '../data/repository/upload_repository.dart';

class UploadBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => UploadRepository());
    Get.lazyPut<UploadController>(() => UploadController());
  }
}
