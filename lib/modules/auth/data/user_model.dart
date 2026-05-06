class User {
  final String id;
  final String name;
  final String email;
  final String parentEmail;
  final bool isVerified;

  User({
    required this.id,
    required this.name,
    required this.email,
    required this.parentEmail,
    this.isVerified = false,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id']?.toString() ?? '',
      name: json['name'] ?? '',
      email: json['email'] ?? '',
      parentEmail: json['parentEmail'] ?? '',
      isVerified: json['isVerified'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'parentEmail': parentEmail,
      'isVerified': isVerified,
    };
  }
}
