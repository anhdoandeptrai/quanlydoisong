import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:path_provider/path_provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:quanlydoisong/firebase_options.dart';
import 'package:quanlydoisong/view/BudgetPage/budget_page.dart';
import 'package:quanlydoisong/view/login/login_page.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:quanlydoisong/bingdings/budget_binding.dart';
import 'package:quanlydoisong/bingdings/schedule_binding.dart';
import 'package:quanlydoisong/models/transaction_model.dart';
import 'package:quanlydoisong/view/noti/notification_helper.dart';
import 'package:quanlydoisong/view/noti/notification_local_helper.dart';
import 'package:quanlydoisong/view/schedule/schedule_list_view.dart';
import 'package:quanlydoisong/view/selection_favorite.dart';
import 'package:quanlydoisong/view/login/wellcome.dart';
import 'bingdings/selection_binding.dart';
import 'models/schedule.dart';
import 'models/dream_goal.dart'; // Import DreamGoal
import 'services/data_service.dart';
import 'view/ResetPassPage/reset_password.dart';
import 'view/login/signup_page.dart';
import 'package:quanlydoisong/controllers/schedule_controller.dart';
import 'package:quanlydoisong/controllers/dreams_controller.dart'; // Import DreamsController
import 'package:quanlydoisong/view/home_page.dart';
import 'package:quanlydoisong/view/dreamPage/dreams_page.dart'; // Import DreamsPage

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Khởi tạo Hive
  final appDocumentDir = await getApplicationDocumentsDirectory();
  await Hive.initFlutter(appDocumentDir.path);

  // Đăng ký các Adapter của Hive
  Hive.registerAdapter(TransactionModelAdapter());
  Hive.registerAdapter(DreamGoalAdapter()); // Đăng ký adapter cho DreamGoal
  Hive.registerAdapter(ScheduleAdapter()); // Đăng ký adapter cho Schedule

  final dataService = DataService();
  await dataService.initHive();

  final dreamsController = Get.put(DreamsController());
  dreamsController.dreams.addAll(dataService.loadDreams());

  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  await NotificationHelper().initialize();
  await FirebaseNotificationHelper().initialize();

  // Mở các hộp (boxes) với xử lý lỗi
  try {
    await Hive.openBox('userBox');
    await Hive.openBox('settings');
    await Hive.openBox('preferencesBox');
    await Hive.openBox<TransactionModel>('transactions');
    await Hive.openBox<DreamGoal>('dreams'); // Mở hộp dreams
    await Hive.openBox<Schedule>('schedules'); // Mở hộp schedules
  } catch (e) {
    print('Error opening Hive boxes: $e');
    // Xóa hộp bị lỗi nếu cần
    await Hive.deleteBoxFromDisk('schedules');
    await Hive.openBox<Schedule>('schedules');
  }

  // Khởi tạo định dạng ngày tháng
  await initializeDateFormatting('vi_VN', null);

  // Khởi tạo ScheduleController và DreamsController
  Get.put(ScheduleController());
  Get.put(DreamsController()); // Khởi tạo DreamsController

  // Chạy ứng dụng
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'Quản Lý Đời Sống',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const HomePage(),
      initialRoute: '/',
      getPages: [
        GetPage(
          name: '/welcome',
          page: () => const WelcomePage(),
        ),
        GetPage(
          name: '/login',
          page: () => const LoginPage(),
        ),
        GetPage(
          name: '/signup',
          page: () => const SignupPage(),
        ),
        GetPage(
            name: '/selection',
            page: () => const PreferenceSelectionPage(),
            binding: PreferenceBinding()), // Định nghĩa tuyến đường /selection

        GetPage(
          name: '/reset-password',
          page: () => const ResetPasswordPage(),
        ),
        GetPage(
          name: '/schedules',
          page: () => const ScheduleListView(),
          binding: ScheduleBinding(),
        ),

        GetPage(
          name: '/budget',
          page: () => const BudgetPage(title: 'Budget Page'),
          binding: BudgetBinding(),
        ),

        GetPage(
          name: '/dreams',
          page: () => DreamsPage(), 
        ),
      ],
      debugShowCheckedModeBanner: false,
      locale: const Locale('vi', 'VN'),
    );
  }
}
