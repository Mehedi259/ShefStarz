import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_sign_in/google_sign_in.dart' as g_auth;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../../../core/api/api_client.dart';
import '../../../core/api/api_config.dart';
import '../../../routes/app_pages.dart';
import '../data/auth_service.dart';
import '../../../data/models/user_model.dart';

class SocialAuthController extends GetxController {
  final ApiClient _apiClient = ApiClient.to;
  final _storage = const FlutterSecureStorage();

  final g_auth.GoogleSignIn _googleSignIn = g_auth.GoogleSignIn(
    scopes: ['email', 'profile'],
  );

  final isLoading = false.obs;

  /// Google Login logic
  Future<void> loginWithGoogle() async {
    try {
      isLoading.value = true;

      // 1. Native Google Sign-In
      final g_auth.GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) {
        isLoading.value = false;
        return; // User cancelled
      }

      final g_auth.GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;

      // 2. Send tokens to backend
      final response = await _apiClient.postRequest(
        ApiConfig.googleLogin,
        {
          "access_token": googleAuth.accessToken,
          "id_token": googleAuth.idToken,
        },
        requiresAuth: false,
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        await _handleAuthSuccess(response.body);
      } else {
        _handleAuthError(response);
      }
    } catch (e) {
      Get.snackbar("Google Login Error", e.toString(),
          backgroundColor: Colors.redAccent, colorText: Colors.white);
    } finally {
      isLoading.value = false;
    }
  }

  /// Apple Login logic
  Future<void> loginWithApple() async {
    try {
      isLoading.value = true;

      // 1. Native Apple Sign-In
      final AuthorizationCredentialAppleID credential =
          await SignInWithApple.getAppleIDCredential(
        scopes: [
          AppleIDAuthorizationScopes.email,
          AppleIDAuthorizationScopes.fullName,
        ],
      );

      // 2. Send identity token to backend
      final response = await _apiClient.postRequest(
        ApiConfig.appleLogin,
        {
          "access_token": credential.identityToken,
        },
        requiresAuth: false,
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        await _handleAuthSuccess(response.body);
      } else {
        _handleAuthError(response);
      }
    } catch (e) {
      Get.snackbar("Apple Login Error", e.toString(),
          backgroundColor: Colors.redAccent, colorText: Colors.white);
    } finally {
      isLoading.value = false;
    }
  }

  /// Handle successful authentication
  Future<void> _handleAuthSuccess(Map<String, dynamic> data) async {
    final String? accessToken = data['access'];
    final String? refreshToken = data['refresh'];
    final Map<String, dynamic>? user = data['user'];

    if (accessToken != null && refreshToken != null) {
      // 3. Securely save tokens in FlutterSecureStorage (Unified with ApiClient)
      await _storage.write(key: 'access_token', value: accessToken);
      await _storage.write(key: 'refresh_token', value: refreshToken);

      // 4. Parse user and sync with AuthService
      if (user != null) {
        final String? username = user['username'];
        final String? ageGroup = user['age_group'];

        final userModel = UserModel(
          id: user['id']?.toString() ?? '',
          username: (username == null || username.isEmpty) ? 'Chef Star' : username,
          email: user['email'] ?? '',
          parentEmail: user['parent_email'] ?? '',
          isEmailVerified: user['is_verified'] ?? true,
        );

        // Save to SharedPreferences for app restart persistence (matches AuthService logic)
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('user_data', jsonEncode(userModel.toJson()));

        // Update global AuthService state if available
        try {
          AuthService.to.currentUser.value = userModel;
        } catch (_) {
          // AuthService not initialized yet, will be handled on next restart
        }

        // Redirection based on profile completion
        if (username == null ||
            username.isEmpty ||
            ageGroup == null ||
            ageGroup.isEmpty) {
          Get.toNamed(Routes.SIGNUP_DETAILS);
        } else {
          Get.offAllNamed(Routes.DASHBOARD);
        }
      } else {
        Get.offAllNamed(Routes.DASHBOARD);
      }
    }
  }

  void _handleAuthError(Response response) {
    String errorMsg = "Authentication failed";
    if (response.body != null && response.body is Map) {
      errorMsg =
          response.body['detail'] ?? response.body['message'] ?? errorMsg;
    }
    Get.snackbar("Login Failed", errorMsg,
        backgroundColor: Colors.redAccent, colorText: Colors.white);
  }
}
