import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../routes/app_pages.dart';
import '../data/auth_service.dart';

class AuthController extends GetxController {
  final nameController = TextEditingController();
  final emailController = TextEditingController(); // Kid's Signup Email

  final userEmail = ''.obs;

  final forgotPasswordEmailController = TextEditingController();
  final forgotPasswordEmailError = RxnString();
  final forgotPasswordEmailValid = false.obs;

  @override
  void onInit() {
    super.onInit();
    startResendTimer();
  }

  final parentEmailController = TextEditingController();

  // --- Password Management States ---
  final changePassword1Controller = TextEditingController();
  final changePassword2Controller = TextEditingController();
  final changePassword1Error = RxnString();
  final changePassword2Error = RxnString();
  final changePassword1Valid = false.obs;
  final changePassword2Valid = false.obs;

  final resetPasswordUid = ''.obs;
  final resetPasswordToken = ''.obs;
  final resetPassword1Controller = TextEditingController();
  final resetPassword2Controller = TextEditingController();
  final resetPassword1Error = RxnString();
  final resetPassword2Error = RxnString();
  final resetPassword1Valid = false.obs;
  final resetPassword2Valid = false.obs;

  // Form Keys for Password
  final changePasswordFormKey = GlobalKey<FormState>();
  final resetPasswordFormKey = GlobalKey<FormState>();

  // --- Dedicated Verification States ---
  final signupOtpController = TextEditingController();
  final signupOtpError = RxnString();
  final signupOtpValid = false.obs;

  final parentOtpController = TextEditingController();
  final parentOtpError = RxnString();
  final parentOtpValid = false.obs;

  final forgotPasswordOtpController = TextEditingController();
  final forgotPasswordOtpError = RxnString();
  final forgotPasswordOtpValid = false.obs;

  Rx<TextEditingController> passController = TextEditingController().obs;
  RxString passValue = ''.obs;
  var isObscure = true.obs;
  void togglePassword() => isObscure.value = !isObscure.value;

  // --- Dedicated Sign In State ---
  final loginEmailController = TextEditingController();
  final loginPassController = TextEditingController();
  var isLoginObscure = true.obs;
  void toggleLoginPassword() => isLoginObscure.value = !isLoginObscure.value;

  final isLoading = false.obs;

  // Form Keys
  final loginFormKey = GlobalKey<FormState>();
  final signupFormKey = GlobalKey<FormState>();
  final forgotPasswordFormKey = GlobalKey<FormState>();
  final parentFormKey = GlobalKey<FormState>();
  final verificationFormKey = GlobalKey<FormState>();
  final parentVerificationFormKey = GlobalKey<FormState>();
  final signupVerificationFormKey = GlobalKey<FormState>();

  // Validation observables
  final emailError = RxnString();
  final emailValid = false.obs;
  final passError = RxnString();
  final passValid = false.obs;
  final passStrength = ''.obs;
  final loginEmailError = RxnString();
  final loginEmailValid = false.obs;
  final loginPassError = RxnString();
  final loginPassValid = false.obs;
  final nameError = RxnString();
  final nameValid = false.obs;
  final parentEmailError = RxnString();
  final parentEmailValid = false.obs;

  // Server error tracking
  String? serverEmailError;
  String? lastCheckedEmail;
  String? serverPassError;
  String? lastCheckedPass;
  String? serverNameError;
  String? lastCheckedName;
  String? serverParentEmailError;
  String? lastCheckedParentEmail;
  String? serverSignupOtpError;
  String? lastCheckedSignupOtp;

  // Age Group selection
  final selectedAgeGroup = "1".obs;
  final List<dynamic> ageList = ['05-10 yrs', '11-15 yrs', '16-20 yrs'];

  void setAgeGroup(String ageGroup) {
    selectedAgeGroup.value = ageGroup;
  }

  // Resend Timer logic
  final resendTimerSeconds = 60.obs;
  Timer? _timer;
  final canResend = false.obs;

  String get formattedTime {
    int minutes = resendTimerSeconds.value ~/ 60;
    int seconds = resendTimerSeconds.value % 60;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  void startResendTimer() {
    canResend.value = false;
    resendTimerSeconds.value = 60;
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (resendTimerSeconds.value > 0) {
        resendTimerSeconds.value--;
      } else {
        canResend.value = true;
        _timer?.cancel();
      }
    });
  }

  // --- Validation Methods ---
  String? validateEmail(String? value) {
    final text = value?.trim() ?? '';
    String? errorResult;
    bool validResult = false;
    if (serverEmailError != null && text == lastCheckedEmail) {
      errorResult = serverEmailError;
    } else {
      serverEmailError = null;
      if (text.isEmpty) {
        errorResult = "Email is required";
      } else {
        final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
        if (!emailRegex.hasMatch(text)) {
          errorResult = "Enter a valid email address";
        } else {
          validResult = true;
        }
      }
    }
    Future.microtask(() {
      emailError.value = errorResult;
      emailValid.value = validResult;
    });
    return errorResult;
  }

  String? validateLoginEmail(String? value) {
    final text = value ?? '';
    String? errorResult;
    bool validResult = false;
    if (serverEmailError != null && text == lastCheckedEmail) {
      errorResult = serverEmailError;
    } else {
      serverEmailError = null;
      if (text.isEmpty) {
        errorResult = "Email is required";
      } else {
        final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
        if (!emailRegex.hasMatch(text)) {
          errorResult = "Enter a valid email address";
        } else {
          validResult = true;
        }
      }
    }
    Future.microtask(() {
      loginEmailError.value = errorResult;
      loginEmailValid.value = validResult;
    });
    return errorResult;
  }

  String? validateLoginPassword(String? value) {
    final text = value ?? '';
    String? errorResult;
    bool validResult = false;
    if (serverPassError != null && text == lastCheckedPass) {
      errorResult = serverPassError;
    } else {
      serverPassError = null;
      if (text.isEmpty) {
        errorResult = "Password is required";
      } else if (text.length < 6) {
        errorResult = "Password must be at least 6 characters";
      } else {
        validResult = true;
      }
    }
    Future.microtask(() {
      loginPassError.value = errorResult;
      loginPassValid.value = validResult;
    });
    return errorResult;
  }

  String? validatePassword(String? value) {
    final text = value ?? '';
    Future.microtask(() => passValue.value = text);
    String? errorResult;
    bool validResult = false;
    String strengthResult = "";
    if (serverPassError != null && text == lastCheckedPass) {
      errorResult = serverPassError;
    } else {
      serverPassError = null;
      if (text.isEmpty) {
        errorResult = "Password is required";
      } else if (text.length < 6) {
        errorResult = "Password must be at least 6 characters";
        strengthResult = "Weak";
      } else {
        validResult = true;
        bool hasUppercase = text.contains(RegExp(r'[A-Z]'));
        bool hasDigits = text.contains(RegExp(r'[0-9]'));
        bool hasSpecialCharacters = text.contains(
          RegExp(r'[!@#$%^&*(),.?":{}|<>]'),
        );
        int strengthScore = 0;
        if (text.length >= 8) strengthScore++;
        if (hasUppercase) strengthScore++;
        if (hasDigits) strengthScore++;
        if (hasSpecialCharacters) strengthScore++;
        if (strengthScore <= 1) {
          strengthResult = "Weak";
        } else if (strengthScore <= 3) {
          strengthResult = "Medium";
        } else {
          strengthResult = "Strong";
        }
      }
    }
    Future.microtask(() {
      passError.value = errorResult;
      passValid.value = validResult;
      passStrength.value = strengthResult;
    });
    return errorResult;
  }

  String? validateName(String? value) {
    final text = value ?? '';
    String? errorResult;
    bool validResult = false;
    if (serverNameError != null && text == lastCheckedName) {
      errorResult = serverNameError;
    } else {
      serverNameError = null;
      if (text.isEmpty) {
        errorResult = "Name is required";
      } else {
        validResult = true;
      }
    }
    Future.microtask(() {
      nameError.value = errorResult;
      nameValid.value = validResult;
    });
    return errorResult;
  }

  String? validateParentEmail(String? value) {
    final text = value ?? '';
    String? errorResult;
    bool validResult = false;
    if (serverParentEmailError != null && text == lastCheckedParentEmail) {
      errorResult = serverParentEmailError;
    } else {
      serverParentEmailError = null;
      if (text.isEmpty) {
        errorResult = "Parent email is required";
      } else {
        final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
        if (!emailRegex.hasMatch(text)) {
          errorResult = "Enter a valid email address";
        } else {
          validResult = true;
        }
      }
    }
    Future.microtask(() {
      parentEmailError.value = errorResult;
      parentEmailValid.value = validResult;
    });
    return errorResult;
  }

  String? validateForgotPasswordEmail(String? value) {
    final text = value ?? '';
    String? errorResult;
    bool validResult = false;
    if (text.isEmpty) {
      errorResult = "Email is required";
    } else {
      final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
      if (!emailRegex.hasMatch(text)) {
        errorResult = "Enter a valid email address";
      } else {
        validResult = true;
      }
    }
    Future.microtask(() {
      forgotPasswordEmailError.value = errorResult;
      forgotPasswordEmailValid.value = validResult;
    });
    return errorResult;
  }

  String? validateSignupOtp(String? value) {
    final text = value ?? '';
    String? errorResult;
    bool validResult = false;
    if (serverSignupOtpError != null && text == lastCheckedSignupOtp) {
      errorResult = serverSignupOtpError;
    } else {
      serverSignupOtpError = null;
      if (text.isEmpty) {
        errorResult = "Verification code is required";
      } else if (text.length < 6) {
        errorResult = "Must be 6 digits";
      } else {
        validResult = true;
      }
    }
    Future.microtask(() {
      signupOtpError.value = errorResult;
      signupOtpValid.value = validResult;
    });
    return errorResult;
  }

  String? validateParentOtp(String? value) {
    final text = value ?? '';
    String? errorResult;
    bool validResult = false;
    if (text.isEmpty) {
      errorResult = "Verification code is required";
    } else if (text.length < 6) {
      errorResult = "Must be 6 digits";
    } else {
      validResult = true;
    }
    Future.microtask(() {
      parentOtpError.value = errorResult;
      parentOtpValid.value = validResult;
    });
    return errorResult;
  }

  String? validateForgotPasswordOtp(String? value) {
    final text = value ?? '';
    String? errorResult;
    bool validResult = false;
    if (text.isEmpty) {
      errorResult = "Verification code is required";
    } else if (text.length < 6) {
      errorResult = "Must be 6 digits";
    } else {
      validResult = true;
    }
    Future.microtask(() {
      forgotPasswordOtpError.value = errorResult;
      forgotPasswordOtpValid.value = validResult;
    });
    return errorResult;
  }

  // Navigation Methods
  void navigateToLogin() {
    FocusManager.instance.primaryFocus?.unfocus();
    Get.offAllNamed(Routes.LOGIN);
  }

  void navigateToHome() {
    FocusManager.instance.primaryFocus?.unfocus();
    Get.offAllNamed(Routes.DASHBOARD);
  }

  void navigateToSignupDetails() {
    FocusManager.instance.primaryFocus?.unfocus();
    Get.offAllNamed(Routes.SIGNUP_DETAILS);
  }

  void navigateToForgotPassword() {
    FocusManager.instance.primaryFocus?.unfocus();
    Get.toNamed(Routes.FORGOT_PASSWORD);
  }

  void verifyAndGoHome() {
    FocusManager.instance.primaryFocus?.unfocus();
    Future.delayed(const Duration(milliseconds: 100), () {
      Get.offAllNamed(Routes.DASHBOARD);
    });
  }

  // --- Registration Flow Methods ---
  Future<void> submitSignup() async {
    FocusManager.instance.primaryFocus?.unfocus();
    if (!signupFormKey.currentState!.validate()) return;

    isLoading.value = true;
    try {
      userEmail.value = emailController.text;

      final response = await AuthService.to.signupKid(
        emailController.text,
        passController.value.text,
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('signup_email', emailController.text);

        startResendTimer();
        Get.toNamed(Routes.singupVerification);
      } else {
        String errorMsg = "Sign up failed. Please try again.";
        if (response.body != null && response.body is Map) {
          errorMsg =
              response.body['detail'] ??
              response.body['message'] ??
              response.body['error'] ??
              errorMsg;
        } else if (response.statusText != null) {
          errorMsg = response.statusText!;
        }
        Get.snackbar(
          "Error",
          errorMsg,
          backgroundColor: Colors.redAccent,
          colorText: Colors.white,
        );
      }
    } catch (e) {
      Get.snackbar(
        "Error",
        e.toString(),
        backgroundColor: Colors.redAccent,
        colorText: Colors.white,
      );
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> verifySignupCode() async {
    FocusManager.instance.primaryFocus?.unfocus();
    if (!signupVerificationFormKey.currentState!.validate()) return;

    isLoading.value = true;
    try {
      final prefs = await SharedPreferences.getInstance();
      final storedEmail = prefs.getString('signup_email') ?? userEmail.value;

      await AuthService.to.verifyKid(storedEmail, signupOtpController.text);
      Get.offNamed(Routes.Parent_View);
    } catch (e) {
      Get.snackbar(
        "Verification Failed",
        e.toString(),
        backgroundColor: Colors.redAccent,
        colorText: Colors.white,
      );
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> submitParentInfo() async {
    FocusManager.instance.primaryFocus?.unfocus();
    if (!parentFormKey.currentState!.validate()) return;

    isLoading.value = true;
    try {
      String ageGroupValue = selectedAgeGroup.value;
      if (int.tryParse(selectedAgeGroup.value) != null) {
        int index = int.parse(selectedAgeGroup.value);
        if (index >= 0 && index < ageList.length) {
          ageGroupValue = ageList[index].toString();
        }
      }

      // Map UI age group strings to exact backend model choices.
      // Adjust the backend string values here if the API still rejects them.
      final Map<String, String> ageGroupMap = {
        '05-10 yrs': '05-10 yrs',
        '11-15 yrs': '11-15 yrs',
        '16-20 yrs': '16-20 yrs',
      };

      final apiAgeGroupValue = ageGroupMap[ageGroupValue] ?? ageGroupValue;

      final prefs = await SharedPreferences.getInstance();
      final storedEmail = prefs.getString('signup_email') ?? userEmail.value;

      await AuthService.to.completeProfile(
        storedEmail,
        nameController.text,
        apiAgeGroupValue,
        parentEmailController.text,
      );

      await prefs.setString('parent_email', parentEmailController.text);
      Get.toNamed(Routes.parentVerification);
    } catch (e) {
      Get.snackbar("Error", e.toString());
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> verifyParentCode() async {
    FocusManager.instance.primaryFocus?.unfocus();
    if (!parentVerificationFormKey.currentState!.validate()) return;

    isLoading.value = true;
    try {
      final prefs = await SharedPreferences.getInstance();
      final kidEmail = prefs.getString('signup_email') ?? userEmail.value;

      await AuthService.to.verifyParent(kidEmail, parentOtpController.text);

      await prefs.remove('signup_email');
      await prefs.remove('parent_email');

      Get.snackbar(
        "Success",
        "Registration Successful",
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );
      Get.offAllNamed(Routes.DASHBOARD);
    } catch (e) {
      parentOtpError.value = e.toString();
      parentOtpValid.value = false;
      parentVerificationFormKey.currentState!.validate();
      Get.snackbar(
        "Error",
        e.toString(),
        backgroundColor: Colors.redAccent,
        colorText: Colors.white,
      );
    } finally {
      isLoading.value = false;
    }
  }

  // --- Auth & Login Flow ---
  Future<void> submitLogin() async {
    FocusManager.instance.primaryFocus?.unfocus();
    if (!loginFormKey.currentState!.validate()) return;

    isLoading.value = true;
    try {
      await AuthService.to.login(
        loginEmailController.text,
        loginPassController.text,
      );
      navigateToHome();
    } catch (e) {
      Get.snackbar("Error", e.toString());
    } finally {
      isLoading.value = false;
    }
  }


  // --- Password Reset Flow ---
  Future<void> submitForgotPassword() async {
    FocusManager.instance.primaryFocus?.unfocus();
    if (!forgotPasswordFormKey.currentState!.validate()) return;

    isLoading.value = true;
    try {
      await AuthService.to.requestPasswordReset(
        forgotPasswordEmailController.text,
      );
      Get.snackbar("Success", "Password reset e-mail has been sent.");
      // If your API sends OTP to email, navigate to verification:
      // Get.toNamed(Routes.VERIFICATION);
      Get.toNamed(Routes.LOGIN); // Based on your current code logic
    } catch (e) {
      Get.snackbar("Error", e.toString());
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> verifyCode() async {
    FocusManager.instance.primaryFocus?.unfocus();
    if (!verificationFormKey.currentState!.validate()) return;

    isLoading.value = true;
    try {
      final success = await AuthService.to.verifyOTP(
        forgotPasswordEmailController.text,
        forgotPasswordOtpController.text,
      );
      if (success) {
        verifyAndGoHome();
      } else {
        forgotPasswordOtpValid.value = false;
      }
    } catch (e) {
      forgotPasswordOtpError.value = e.toString();
      forgotPasswordOtpValid.value = false;
    } finally {
      isLoading.value = false;
    }
  }

  // --- Resend OTP Methods ---
  Future<void> resendSignupCode() async {
    if (!canResend.value) return;
    isLoading.value = true;
    try {
      final prefs = await SharedPreferences.getInstance();
      final storedEmail = prefs.getString('signup_email') ?? userEmail.value;

      if (storedEmail.isEmpty) {
        throw "Email not found. Please try signing up again.";
      }

      await AuthService.to.resendOTP(storedEmail);
      Get.snackbar("Success", "Verification code resent!");
      startResendTimer();
    } catch (e) {
      Get.snackbar("Error", e.toString());
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> resendParentCode() async {
    if (!canResend.value) return;
    isLoading.value = true;
    try {
      final prefs = await SharedPreferences.getInstance();
      final storedEmail = prefs.getString('signup_email') ?? userEmail.value;

      if (storedEmail.isEmpty) {
        throw "Email not found. Please try signing up again.";
      }

      await AuthService.to.resendOTP(storedEmail);
      Get.snackbar("Success", "Verification code resent to Parent!");
      startResendTimer();
    } catch (e) {
      Get.snackbar("Error", e.toString());
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> resendForgotPasswordCode() async {
    if (!canResend.value) return;
    isLoading.value = true;
    try {
      await AuthService.to.resendOTP(forgotPasswordEmailController.text);
      Get.snackbar("Success", "Verification code resent!");
      startResendTimer();
    } catch (e) {
      Get.snackbar("Error", e.toString());
    } finally {
      isLoading.value = false;
    }
  }

  @override
  void onClose() {
    _timer?.cancel();
    super.onClose();
  }
}
