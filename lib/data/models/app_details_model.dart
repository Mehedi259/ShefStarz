class AppDetailsModel {
  final int id;
  final String termsAndConditions;
  final String privacyPolicy;
  final String aboutUs;
  final String contactUs;

  AppDetailsModel({
    required this.id,
    required this.termsAndConditions,
    required this.privacyPolicy,
    required this.aboutUs,
    required this.contactUs,
  });

  factory AppDetailsModel.fromJson(Map<String, dynamic> json) {
    return AppDetailsModel(
      id: json['id'] ?? 0,
      termsAndConditions: json['terms_and_conditions'] ?? '',
      privacyPolicy: json['privacy_policy'] ?? '',
      aboutUs: json['about_us'] ?? '',
      contactUs: json['contact_us'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'terms_and_conditions': termsAndConditions,
      'privacy_policy': privacyPolicy,
      'about_us': aboutUs,
      'contact_us': contactUs,
    };
  }
}
