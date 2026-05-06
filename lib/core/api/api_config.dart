class ApiConfig {
  static const String baseUrl =
      "https://api.chefstarz.com/v1/"; // Updated based on Postman

  // Endpoints
  static const String recipes =
      "88995874-cb2d-4954-a690-3b092f232491"; // Dummy list
  static String get getRecipesList => "recipes/recipes/";
  static const String signUp =
      "signup"; // Kept for backwards compatibility if needed
  static const String signUpKid = "users/signup/kid/";
  static const String verifyKid = "users/signup/verify-kid/";
  static const String completeProfile = "users/signup/complete-profile/";
  static const String verifyParent = "users/signup/verify-parent/";
  static const String checkEmail = "users/signup/check-email";
  static const String login = "users/auth/login/";
  static const String logout = "users/auth/logout/";
  static const String googleLogin = "users/auth/google/";
  static const String appleLogin = "users/auth/apple/";
  static const String feed = "feed";
  static const String stories = "stories";
  static const String explore = "explore";
  static const String search = "search";
  static const String notifications = "notifications/";
  static String get markAllRead => "notifications/mark-all-read/";
  static String markRead(String id) => "notifications/$id/mark-read/";
  static String deleteNotification(String id) => "notifications/$id/";
  static String getNotificationDetails(String id) => "notifications/$id/";

  static const String profileMe = "users/profiles/me/";
  static const String appSettings = "app_settings/app-settings";
  static const String changePassword = "users/auth/password/change/";
  static const String requestPasswordReset = "users/auth/password/reset/";
  static const String resetPasswordConfirm =
      "users/auth/password/reset/confirm/";
  static const String adminAppDetails = "admins/app-details/";

  // Trust and Safety
  static const String blockUser = "users/block/";
  static const String unblockUser = "users/unblock/";
  static const String report = "reports/";
  static const String blockedList = "users/blocked-list/";

  // Post Interactions
  static String likePost(String id) => "posts/posts/$id/like/";
  static String pinPost(String id) => "posts/posts/$id/pin/";
  static String savePost(String id) => "posts/posts/$id/save_post/";
  static String getPostDetails(String id) => "posts/posts/$id/";
  static String updatePost(String id) => "posts/posts/$id/";
  static String deletePost(String id) => "posts/posts/$id/";
  static String get getPostsList => "posts/posts/";
  static String get createPost => "posts/posts/";
  static String addComment(String id) => "posts/posts/$id/add_comment/";

  // Timeout
  static const Duration timeout = Duration(seconds: 60);
}
