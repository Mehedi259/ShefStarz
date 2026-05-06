class ActivityModel {
  final String id;
  final String title;
  final String type; // 'like', 'post', 'comment', 'upload'
  final DateTime timestamp;
  final String? imageUrl;

  ActivityModel({
    required this.id,
    required this.title,
    required this.type,
    required this.timestamp,
    this.imageUrl,
  });

  factory ActivityModel.fromJson(Map<String, dynamic> json) {
    return ActivityModel(
      id: json['id'] ?? '',
      title: json['title'] ?? '',
      type: json['type'] ?? '',
      timestamp: DateTime.parse(
        json['timestamp'] ?? DateTime.now().toIso8601String(),
      ),
      imageUrl: json['image_url'],
    );
  }
}
