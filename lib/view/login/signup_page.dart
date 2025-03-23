import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:hive/hive.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:quanlydoisong/models/users.dart';

class SignupPage extends StatefulWidget {
  const SignupPage({super.key});

  @override
  _SignupPageState createState() => _SignupPageState();
}

class _SignupPageState extends State<SignupPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _heightController = TextEditingController();
  final TextEditingController _weightController = TextEditingController();
  final TextEditingController _locationController = TextEditingController();

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  bool isSubscribed = false; // Trạng thái nhận bản tin
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
  }

  /// Hàm xử lý đăng ký
  void _signup() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    final String username = _usernameController.text.trim();
    final String email = _emailController.text.trim();
    final String password = _passwordController.text.trim();
    final double height = double.tryParse(_heightController.text.trim()) ?? 0.0;
    final double weight = double.tryParse(_weightController.text.trim()) ?? 0.0;
    final String location = _locationController.text.trim();

    try {
      UserCredential userCredential =
          await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      User? firebaseUser = userCredential.user;

      if (firebaseUser != null) {
        // Tạo đối tượng UserModel
        UserModel newUser = UserModel(
          id: firebaseUser.uid,
          username: username,
          email: email,
          phone: '',
          location: location,
          height: height,
          weight: weight,
          interests: [],
          // subscribed: isSubscribed, // Lưu trạng thái nhận bản tin
        );

        // Lưu vào Firestore
        await _firestore
            .collection('users')
            .doc(firebaseUser.uid)
            .set(newUser.toMap());

        // Lưu vào Hive
        var userBox = Hive.box('userBox');
        userBox.put('username', username);

        // Hiển thị thông báo thành công
        Get.snackbar('Thành công', 'Tài khoản của bạn đã được tạo.',
            snackPosition: SnackPosition.TOP,
            backgroundColor: Colors.green,
            colorText: Colors.white);

        // Điều hướng sang trang lựa chọn
        Get.offNamed('/selection');
      }
    } on FirebaseAuthException catch (e) {
      _showError(e.message ?? 'Đã xảy ra lỗi không xác định');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  /// Xử lý đăng nhập bằng Google
  Future<void> _signInWithGoogle() async {
    try {
      final GoogleSignIn googleSignIn = GoogleSignIn();
      final GoogleSignInAccount? googleUser = await googleSignIn.signIn();
      if (googleUser == null) return;

      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;

      final AuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      await _auth.signInWithCredential(credential);
      Get.offNamed('/selection');
    } catch (e) {
      _showError("Đăng nhập Google thất bại: $e");
    }
  }

  /// Hiển thị lỗi
  void _showError(String message) {
    Get.snackbar('Lỗi', message,
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.red,
        colorText: Colors.white);
  }

  /// Giao diện chính
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 40),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                const CircleAvatar(
                  radius: 40,
                  backgroundColor: Colors.blueAccent,
                  child: Icon(Icons.person_add, size: 50, color: Colors.white),
                ),
                const SizedBox(height: 20),
                const Text(
                  'Tạo tài khoản mới',
                  style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 20),
                buildInputField(
                    _usernameController, Icons.person, "Tên người dùng", false),
                const SizedBox(height: 15),
                buildInputField(_emailController, Icons.email, "E-mail", false,
                    validator: (value) {
                  if (value == null || !value.contains('@')) {
                    return "Email không hợp lệ";
                  }
                  return null;
                }),
                const SizedBox(height: 15),
                buildInputField(
                    _passwordController, Icons.lock, "Mật khẩu", true,
                    validator: (value) {
                  if (value == null || value.length < 6) {
                    return "Mật khẩu tối thiểu 6 ký tự";
                  }
                  return null;
                }),
                const SizedBox(height: 15),
                buildInputField(
                    _heightController, Icons.height, "Chiều Cao (m)", false),
                const SizedBox(height: 15),
                buildInputField(_weightController, Icons.fitness_center,
                    "Cân Nặng (kg)", false),
                const SizedBox(height: 15),
                buildLocationField(),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: _isLoading ? null : _signup,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    minimumSize: const Size(double.infinity, 50),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15)),
                  ),
                  child: _isLoading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text('Đăng ký',
                          style: TextStyle(color: Colors.white, fontSize: 18)),
                ),
                const SizedBox(height: 20),
                buildOutlinedButton(Icons.g_mobiledata, 'Tiếp tục với Google',
                    _signInWithGoogle),
                Row(
                  children: [
                    Checkbox(
                      value: isSubscribed,
                      onChanged: (value) =>
                          setState(() => isSubscribed = value!),
                    ),
                    const Expanded(
                      child: Text(
                        'Đăng ký nhận bản tin cập nhật và ưu đãi độc quyền.',
                        style: TextStyle(color: Colors.black54),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                RichText(
                  text: TextSpan(
                    text: 'Đã có tài khoản? ',
                    style: const TextStyle(color: Colors.black87),
                    children: [
                      TextSpan(
                        text: 'Đăng nhập',
                        style: const TextStyle(
                            color: Colors.blue, fontWeight: FontWeight.bold),
                        recognizer: TapGestureRecognizer()
                          ..onTap = () => Get.toNamed('/login'),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// Hàm tạo ô nhập liệu
  Widget buildInputField(TextEditingController controller, IconData icon,
      String hint, bool isPassword,
      {String? Function(String?)? validator}) {
    return TextFormField(
      controller: controller,
      obscureText: isPassword,
      validator: validator,
      decoration: InputDecoration(
        filled: true,
        fillColor: Colors.white,
        prefixIcon: Icon(icon),
        hintText: hint,
        border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(15),
            borderSide: BorderSide.none),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
      ),
    );
  }

  /// Hàm tạo ô nhập liệu cho địa điểm
  Widget buildLocationField() {
    return TextFormField(
      controller: _locationController,
      decoration: InputDecoration(
        filled: true,
        fillColor: Colors.white,
        prefixIcon: const Icon(Icons.location_on),
        hintText: "Nhập địa điểm",
        border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(15),
            borderSide: BorderSide.none),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
      ),
    );
  }

  /// Hàm tạo nút hành động
  Widget buildOutlinedButton(
      IconData icon, String label, VoidCallback onPressed) {
    return OutlinedButton.icon(
      onPressed: onPressed,
      icon: Icon(icon, color: Colors.blue),
      label: Text(label, style: const TextStyle(color: Colors.black)),
      style: OutlinedButton.styleFrom(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        minimumSize: const Size(double.infinity, 50),
      ),
    );
  }
}
