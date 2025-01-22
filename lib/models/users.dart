class UserModel {
  String id; // ID người dùng (UID từ Firebase Authentication)
  String username; // Tên người dùng
  List<String> interests; // Danh sách sở thích

  UserModel({
    required this.id,
    required this.username,
    required this.interests,
  // required this.subscribed,
  });

  // Chuyển từ Map (Firestore) sang UserModel object
  factory UserModel.fromMap(String id, Map<String, dynamic> data) {
    return UserModel(
      id: id,
      username: data['username'] ?? 'Người dùng',
      interests: List<String>.from(data['interests'] ?? []),
    );
  }

  // Chuyển từ UserModel object sang Map (Firestore)
  Map<String, dynamic> toMap() {
    return {
      'username': username,
      'interests': interests,
    };
  }

  // Chuyển từ UserModel object sang JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'username': username,
      'interests': interests,
    };
  }
}
