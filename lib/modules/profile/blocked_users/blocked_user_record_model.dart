import '../../../data/models/user_model.dart';

class BlockedUserRecord {
  final int id;
  final UserModel blockedUser;

  BlockedUserRecord({
    required this.id,
    required this.blockedUser,
  });

  factory BlockedUserRecord.fromJson(Map<String, dynamic> json) {
    return BlockedUserRecord(
      id: json['id'] ?? 0,
      blockedUser: UserModel.fromJson(json['blocked_user'] ?? {}),
    );
  }
}
