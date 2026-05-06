import 'dart:convert';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../../../data/models/user_model.dart';
import '../../../routes/app_pages.dart';
import 'repository/auth_repository.dart';
import 'user_model.dart';

class AuthService extends GetxService {
  static AuthService get to => Get.find();

  final AuthRepository _repository = AuthRepository();
  final currentUser = Rxn<UserModel>();
  final isApprovalPending = false.obs;
  final _storage = const FlutterSecureStorage();

  // Token storage
  String? refreshToken;

  @override
  void onInit() {
    super.onInit();
  }

  /// Check if user has a valid access token
  Future<bool> hasValidToken() async {
    final token = await _storage.read(key: 'access_token');
    return token != null && token.isNotEmpty;
  }

  Future<void> checkLoginStatus() async {
    final prefs = await SharedPreferences.getInstance();
    final token = await _storage.read(key: 'access_token');
    final userData = prefs.getString('user_data');

    if (token != null && token.isNotEmpty) {
      if (userData != null) {
        try {
          currentUser.value = UserModel.fromJson(jsonDecode(userData));
        } catch (e) {
          Get.log("Failed to parse user data: $e");
        }
      }
      Get.offAllNamed(Routes.DASHBOARD);
    } else {
      // Changed from ONBOARDING to LOGIN - directly go to sign-in screen
      Get.offAllNamed(Routes.LOGIN);
    }
  }

  Future<Response> signupKid(String email, String password) async {
    try {
      final response = await _repository.signupKid(email, password);

      if (response.statusCode == 200 || response.statusCode == 201) {
        // Backend does not return user details here yet; setup locally temporarily
        final userModel = UserModel(
          id: '',
          username: '',
          email: email,
          parentEmail: '',
          isEmailVerified: false,
        );
        currentUser.value = userModel;
        isApprovalPending.value = true;
      }
      return response;
    } catch (e) {
      rethrow;
    }
  }

  Future<bool> checkEmail(String email) async {
    try {
      return await _repository.checkEmail(email);
    } catch (e) {
      rethrow;
    }
  }

  Future<void> checkStatus() async {
    if (currentUser.value != null && isApprovalPending.value) {
      try {
        final user = await _repository.checkApprovalStatus(
          currentUser.value!.id,
        );
        if (user.isVerified) {
          currentUser.value = currentUser.value?.copyWith(
            isEmailVerified: true,
          );
          isApprovalPending.value = false;
        }
      } catch (e) {
        // Handle error if needed
      }
    }
  }

  Future<void> verifyKid(String email, String code) async {
    try {
      final responseMap = await _repository.verifyKid(email, code);

      if (responseMap['access'] != null) {
        await _storage.write(key: 'access_token', value: responseMap['access']);
      }

      if (responseMap['refresh'] != null) {
        refreshToken = responseMap['refresh'];
        await _storage.write(key: 'refresh_token', value: responseMap['refresh']);
      }

      // Optional: update local verification state
      if (currentUser.value != null && currentUser.value!.email == email) {
        currentUser.value = currentUser.value!.copyWith(isEmailVerified: true);
        isApprovalPending.value = false;
      }
    } catch (e) {
      rethrow;
    }
  }

  Future<void> completeProfile(
      String email,
      String username,
      String ageGroup,
      String parentEmail,
      ) async {
    try {
      await _repository.completeProfile(email, username, ageGroup, parentEmail);
      // Update local global user state if necessary
      if (currentUser.value != null && currentUser.value!.email == email) {
        currentUser.value = currentUser.value!.copyWith(
          name: username,
          parentEmail: parentEmail,
        );
      }
    } catch (e) {
      rethrow;
    }
  }

  Future<void> verifyParent(String email, String code) async {
    try {
      await _repository.verifyParent(email, code);
      // Update local state indicating parent approval
      if (currentUser.value != null && currentUser.value!.email == email) {
        // Assuming parent verification marks the account fully active
        isApprovalPending.value = false;
      }
    } catch (e) {
      rethrow;
    }
  }

  Future<void> login(String email, String password) async {
    try {
      final responseMap = await _repository.login(email, password);

      if (responseMap['access'] != null) {
        await _storage.write(key: 'access_token', value: responseMap['access']);
      }

      // Store the refresh token securely
      if (responseMap['refresh'] != null) {
        refreshToken = responseMap['refresh'];
        await _storage.write(key: 'refresh_token', value: responseMap['refresh']);
      }

      // Parse user
      if (responseMap['user'] != null) {
        final prefs = await SharedPreferences.getInstance();
        final user = User.fromJson(responseMap['user']);
        final userModel = UserModel(
          id: user.id,
          username: user.name.isEmpty ? 'Chef Star' : user.name,
          email: user.email,
          parentEmail: user.parentEmail,
          isEmailVerified: user.isVerified,
        );
        await prefs.setString('user_data', jsonEncode(userModel.toJson()));
        currentUser.value = userModel;
      }
    } catch (e) {
      rethrow;
    }
  }

  Future<void> logout() async {
    try {
      final refresh = await _storage.read(key: 'refresh_token') ?? refreshToken;

      if (refresh != null) {
        await _repository.logout(refresh);
      }
    } catch (e) {
      Get.log("Logout API failed: $e");
    } finally {
      final prefs = await SharedPreferences.getInstance();
      await _storage.deleteAll();
      await prefs.remove('user_data');
      refreshToken = null;
      currentUser.value = null;
      isApprovalPending.value = false;

      Get.offAllNamed(Routes.LOGIN);
    }
  }

  Future<void> resendOTP(String email) async {
    try {
      final success = await _repository.resendOTP(email);
      if (!success) throw "Failed to resend Verification Code";
    } catch (e) {
      rethrow;
    }
  }

  Future<bool> verifyOTP(String email, String code) async {
    try {
      return await _repository.verifyOTP(email, code);
    } catch (e) {
      rethrow;
    }
  }

  Future<void> requestPasswordReset(String email) async {
    try {
      await _repository.requestPasswordReset(email);
    } catch (e) {
      rethrow;
    }
  }

  Future<Map<String, dynamic>> changePassword(
      String newPassword1,
      String newPassword2,
      ) async {
    try {
      return await _repository.changePassword(newPassword1, newPassword2);
    } catch (e) {
      rethrow;
    }
  }

  Future<Map<String, dynamic>> confirmPasswordReset(
      String uid,
      String token,
      String newPassword1,
      String newPassword2,
      ) async {
    try {
      return await _repository.confirmPasswordReset(
        uid,
        token,
        newPassword1,
        newPassword2,
      );
    } catch (e) {
      rethrow;
    }
  }

  Future<void> deleteAccount() async {
    try {
      await _repository.deleteAccount();
    } catch (e) {
      Get.log("Delete Account API failed: $e");
      rethrow;
    } finally {
      final prefs = await SharedPreferences.getInstance();
      await _storage.deleteAll();
      await prefs.remove('user_data');
      refreshToken = null;
      currentUser.value = null;
      isApprovalPending.value = false;

      Get.offAllNamed(Routes.LOGIN);
    }
  }
}
