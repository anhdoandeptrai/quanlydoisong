import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:path_provider/path_provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:quanlydoisong/bingdings/attendance_binding.dart';
// import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:quanlydoisong/firebase_options.dart';
import 'package:quanlydoisong/view/BudgetPage/budget_page.dart';
import 'package:quanlydoisong/view/attendance/attendance_page.dart';
import 'package:quanlydoisong/view/home_view.dart';
import 'package:quanlydoisong/view/login/login_page.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:quanlydoisong/bingdings/budget_binding.dart';
import 'package:quanlydoisong/bingdings/expense_binding.dart';
import 'package:quanlydoisong/bingdings/schedule_binding.dart';
import 'package:quanlydoisong/models/transaction_model.dart';
import 'package:quanlydoisong/view/expense/expense_list_view.dart';
import 'package:quanlydoisong/view/schedule/schedule_list_view.dart';
import 'package:quanlydoisong/view/selection_favorite.dart';
import 'package:quanlydoisong/wellcome.dart';
import 'bingdings/selection_binding.dart';
import 'models/schedule.dart';
import 'models/expense.dart';
import 'view/ResetPassPage/reset_password.dart';
import 'view/login/signup_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // await Firebase.initializeApp();
  // final fcmToken = await FirebaseMessaging.instance.getToken();
  // print('FCM Token: $fcmToken');
 
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  // Khởi tạo Hive
  final appDocumentDir = await getApplicationDocumentsDirectory();
  await Hive.initFlutter(appDocumentDir.path);

  // Đăng ký các Adapter của Hive
  Hive.registerAdapter(ScheduleAdapter());
  Hive.registerAdapter(ExpenseAdapter());
  Hive.registerAdapter(TransactionModelAdapter());

  // Mở các hộp (boxes)
  await Hive.openBox('userBox');
  await Hive.openBox('settings');
  await Hive.openBox('preferencesBox');
  await Hive.openBox<Schedule>('schedules');
  await Hive.openBox<Expense>('expenses');
  await Hive.openBox<TransactionModel>('transactions');

  // Khởi tạo định dạng ngày tháng
  await initializeDateFormatting('vi_VN', null);

  // Chạy ứng dụng
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'Quản Lý Đời Sống',
      initialRoute: '/',
      getPages: [
        GetPage(
          name: '/',
          page: () => const WelcomePage(),
        ),
        GetPage(
          name: '/login',
          page: () => LoginPage(),
        ),
        GetPage(
          name: '/signup',
          page: () => SignupPage(),
        ),
        GetPage(
            name: '/selection',
            page: () => PreferenceSelectionPage(),
            binding: PreferenceBinding()), // Định nghĩa tuyến đường /selection
        GetPage(
          name: '/home',
          page: () => HomeView(),
        ),
        GetPage(
          name: '/reset-password',
          page: () => ResetPasswordPage(),
        ),
        GetPage(
          name: '/schedules',
          page: () => ScheduleListView(),
          binding: ScheduleBinding(),
        ),
        GetPage(
          name: '/expenses',
          page: () => ExpenseListView(),
          binding: ExpenseBinding(),
        ),
        GetPage(
          name: '/budget',
          page: () => BudgetPage(title: 'Budget Page'),
          binding: BudgetBinding(),
        ),
        GetPage(
          name: '/attendance',
          page: () => AttendancePage(),
        ),
        GetPage(
            name: '/attendance',
            page: () => AttendancePage(),
            binding: AttendanceBinding()),
      ],
      debugShowCheckedModeBanner: false,
      locale: const Locale('vi', 'VN'),
    );
  }
}
