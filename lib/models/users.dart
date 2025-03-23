class UserModel {
  String id; // ID người dùng (UID từ Firebase Authentication)
  String username; // Tên người dùng
  String email; // Email người dùng
  String phone; // Số điện thoại
  String location; // Vị trí
  double height; // Chiều cao
  double weight; // Cân nặng

  List<String> interests; // Danh sách sở thích

  UserModel({
    required this.id,
    required this.username,
    required this.email,
    required this.phone,
    required this.location,
    required this.height,
    required this.weight,
    required this.interests,
  });

  // Chuyển từ Map (Firestore) sang UserModel object
  factory UserModel.fromMap(String id, Map<String, dynamic> data) {
    return UserModel(
      id: id,
      username: data['username'] ?? 'Người dùng',
      email: data['email'] ?? '',
      phone: data['phone'] ?? '',
      location: data['location'] ?? '',
      height: (data['height'] ?? 0.0).toDouble(),
      weight: (data['weight'] ?? 0.0).toDouble(),
      interests: List<String>.from(data['interests'] ?? []),
    );
  }

  // Chuyển từ UserModel object sang Map (Firestore)
  Map<String, dynamic> toMap() {
    return {
      'username': username,
      'email': email,
      'phone': phone,
      'location': location,
      'height': height,
      'weight': weight,
      'interests': interests,
    };
  }

  // Chuyển từ UserModel object sang JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'username': username,
      'email': email,
      'phone': phone,
      'location': location,
      'height': height,
      'weight': weight,
      'interests': interests,
    };
  }
}
