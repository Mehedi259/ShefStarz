class AppSettingsModel {
  final int id;
  final int user;
  final bool darkMode;
  final bool parentalControl;
  final bool comments;
  final bool notifications;

  AppSettingsModel({
    required this.id,
    required this.user,
    required this.darkMode,
    required this.parentalControl,
    required this.comments,
    required this.notifications,
  });

  factory AppSettingsModel.fromJson(Map<String, dynamic> json) {
    return AppSettingsModel(
      id: json['id'] ?? 0,
      user: json['user'] ?? 0,
      darkMode: json['dark_mode'] ?? false,
      parentalControl: json['parental_control'] ?? false,
      comments: json['comments'] ?? true,
      notifications: json['notifications'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user': user,
      'dark_mode': darkMode,
      'parental_control': parentalControl,
      'comments': comments,
      'notifications': notifications,
    };
  }

  AppSettingsModel copyWith({
    int? id,
    int? user,
    bool? darkMode,
    bool? parentalControl,
    bool? comments,
    bool? notifications,
  }) {
    return AppSettingsModel(
      id: id ?? this.id,
      user: user ?? this.user,
      darkMode: darkMode ?? this.darkMode,
      parentalControl: parentalControl ?? this.parentalControl,
      comments: comments ?? this.comments,
      notifications: notifications ?? this.notifications,
    );
  }
}
