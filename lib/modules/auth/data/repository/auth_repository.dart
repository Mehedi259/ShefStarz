import '../../../../core/api/api_client.dart';
import '../../../../core/api/api_config.dart';
import '../user_model.dart';
import 'package:get/get.dart';

class AuthRepository {
  final ApiClient _apiClient = ApiClient.to;

  Future<Response> signupKid(String email, String password) async {
    return await _apiClient.postRequest(ApiConfig.signUpKid, {
      "email": email,
      "password": password,
    }, requiresAuth: false);
  }

  Future<Map<String, dynamic>> verifyKid(String email, String code) async {
    final response = await _apiClient.postRequest(ApiConfig.verifyKid, {
      "email": email,
      "code": code,
    }, requiresAuth: false);

    bool isSuccess = response.statusCode == 200 || response.statusCode == 201;

    if (!isSuccess) {
      if (response.body != null && response.body is Map) {
        if (response.body['error'] != null) {
          return Future.error(response.body['error']);
        }
        if (response.body['message'] != null) {
          return Future.error(response.body['message']);
        }
        if (response.body['detail'] != null) {
          return Future.error(response.body['detail']);
        }
        return Future.error(response.body.toString());
      }
      return Future.error("Verification failed");
    }
    return response.body ?? {};
  }

  Future<Map<String, dynamic>> completeProfile(
    String email,
    String username,
    String ageGroup,
    String parentEmail,
  ) async {
    final response = await _apiClient.postRequest(ApiConfig.completeProfile, {
      "email": email,
      "username": username,
      "age_group": ageGroup,
      "parent_email": parentEmail,
    }, requiresAuth: false);

    bool isSuccess = response.statusCode == 200 || response.statusCode == 201;

    if (!isSuccess) {
      if (response.body != null && response.body is Map) {
        return Future.error(response.body);
      }
      return Future.error("Profile completion failed");
    } else {
      return response.body ?? {};
    }
  }

  Future<User> checkApprovalStatus(String userId) async {
    final response = await _apiClient.getRequest(
      "${ApiConfig.verifyParent}/$userId",
    );
    if (response.statusCode != 200 && response.statusCode != 201) {
      return Future.error("Verification check failed");
    } else {
      return User.fromJson(response.body ?? {});
    }
  }

  Future<bool> checkEmail(String email) async {
    final response = await _apiClient.postRequest(ApiConfig.checkEmail, {
      "email": email,
    }, requiresAuth: false);

    if (response.statusCode != 200) {
      if (response.body != null && response.body is Map) {
        if (response.body['email'] != null) {
          return Future.error(
            (response.body['email'] is List)
                ? response.body['email'][0]
                : response.body['email'],
          );
        }
        if (response.body['error'] != null) {
          return Future.error(response.body['error']);
        }
      }
      return true;
    }
    return true;
  }

  Future<bool> verifyParent(String email, String code) async {
    final response = await _apiClient.postRequest(ApiConfig.verifyParent, {
      "email": email,
      "code": code,
    }, requiresAuth: false);

    bool isSuccess = response.statusCode == 200 || response.statusCode == 201;

    if (!isSuccess ||
        (response.body is Map && response.body['error'] != null)) {
      if (response.body != null &&
          response.body is Map &&
          response.body['error'] != null) {
        return Future.error(response.body['error']);
      }
      return Future.error("Verification failed");
    }
    return true;
  }

  Future<Map<String, dynamic>> login(String email, String password) async {
    final response = await _apiClient.postRequest(ApiConfig.login, {
      "email": email,
      "password": password,
    }, requiresAuth: false);

    if (response.statusCode != 200) {
      if (response.body != null && response.body is Map) {
        return Future.error(response.body);
      }
      return Future.error("Login failed");
    } else {
      return response.body ?? {};
    }
  }

  Future<bool> logout(String refreshToken) async {
    final response = await _apiClient.postRequest(ApiConfig.logout, {
      "refresh": refreshToken,
    });

    if (response.statusCode != 200 && response.statusCode != 201) {
      return Future.error("Logout failed on server");
    }
    return true;
  }

  Future<User> signInWithGoogle() async {
    final response = await _apiClient.postRequest("auth/google", {});
    if (response.statusCode != 200 && response.statusCode != 201) {
      throw "Google Sign-In failed";
    }
    return User.fromJson(response.body);
  }

  Future<User> signInWithApple() async {
    final response = await _apiClient.postRequest("auth/apple", {});
    if (response.statusCode != 200 && response.statusCode != 201) {
      throw "Apple Sign-In failed";
    }
    return User.fromJson(response.body);
  }

  Future<bool> resendOTP(String email) async {
    final response = await _apiClient.postRequest("users/signup/resend-otp/", {
      "email": email,
    }, requiresAuth: false);

    bool isSuccess = response.statusCode == 200 || response.statusCode == 201;

    if (!isSuccess) {
      if (response.body != null && response.body is Map) {
        if (response.body['error'] != null) {
          return Future.error(response.body['error']);
        }
        if (response.body['message'] != null) {
          return Future.error(response.body['message']);
        }
        if (response.body['detail'] != null) {
          return Future.error(response.body['detail']);
        }
        return Future.error(response.body.toString());
      }
      return Future.error("Failed to resend Verification Code");
    }
    return true;
  }

  Future<bool> verifyOTP(String email, String code) async {
    final response = await _apiClient.postRequest("auth/verify-otp", {
      "email": email,
      "code": code,
    }, requiresAuth: false);
    return response.statusCode == 200 || response.statusCode == 201;
  }

  Future<Map<String, dynamic>> requestPasswordReset(String email) async {
    final response = await _apiClient.postRequest(
      ApiConfig.requestPasswordReset,
      {"email": email},
      requiresAuth: false,
    );

    if (response.statusCode != 200 && response.statusCode != 201) {
      if (response.body != null && response.body is Map) {
        return Future.error(response.body);
      }
      return Future.error("Password reset request failed");
    }
    return response.body ?? {};
  }

  Future<Map<String, dynamic>> changePassword(
    String newPassword1,
    String newPassword2,
  ) async {
    final response = await _apiClient.postRequest(ApiConfig.changePassword, {
      "new_password1": newPassword1,
      "new_password2": newPassword2,
    });

    if (response.statusCode != 200 && response.statusCode != 201) {
      if (response.body != null && response.body is Map) {
        return Future.error(response.body);
      }
      return Future.error("Password change failed");
    }
    return response.body ?? {};
  }

  Future<Map<String, dynamic>> confirmPasswordReset(
    String uid,
    String token,
    String newPassword1,
    String newPassword2,
  ) async {
    final response = await _apiClient
        .postRequest(ApiConfig.resetPasswordConfirm, {
          "uid": uid,
          "token": token,
          "new_password1": newPassword1,
          "new_password2": newPassword2,
        }, requiresAuth: false);

    if (response.statusCode != 200 && response.statusCode != 201) {
      if (response.body != null && response.body is Map) {
        return Future.error(response.body);
      }
      return Future.error("Password reset confirmation failed");
    }
    return response.body ?? {};
  }

  Future<Response> deleteAccount() async {
    return await _apiClient.deleteRequest("users/auth/delete-account/");
  }
}
