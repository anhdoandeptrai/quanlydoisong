import 'package:firebase_auth/firebase_auth.dart';


class Auth{
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance; // Khởi tạo FirebaseAuth
  
  User? get currentUser => _firebaseAuth.currentUser; // Lấy thông tin người dùng hiện tại

  Stream<User?> get authStateChanges => _firebaseAuth.authStateChanges(); // Lắng nghe sự thay đổi trạng thái đăng nhập 

  Future<void> signInWithEmailAndPassword(String email, String password) async {
    await _firebaseAuth.signInWithEmailAndPassword(email: email, password: password); // Đăng nhập bằng email và mật khẩu
  }

  Future<void> signOut() async {
    await _firebaseAuth.signOut(); // Đăng xuất
  }
}