import 'package:get/get.dart';
import '../api/api_client.dart';
import '../../modules/auth/data/auth_service.dart';

class InitialBinding extends Bindings {
  @override
  void dependencies() {
    Get.put(ApiClient(), permanent: true);
    Get.put(AuthService(), permanent: true);
  }
}
