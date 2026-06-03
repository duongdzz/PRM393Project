import 'package:get/get.dart';
import '../features/splash/splash_screen.dart';
import '../features/auth/login_screen.dart';
import '../features/home/home_screen.dart';

abstract class AppRoutes {
  static const splash    = '/';
  static const login     = '/login';
  static const home      = '/home';
  static const profile   = '/profile';
  static const schedule  = '/schedule';
  static const report    = '/report';
}

class AppPages {
  static final pages = [
    GetPage(name: AppRoutes.splash, page: () => const SplashScreen()),
    GetPage(
      name: AppRoutes.login,
      page: () => const LoginScreen(),
      transition: Transition.fadeIn,
      transitionDuration: const Duration(milliseconds: 400),
    ),
    GetPage(
      name: AppRoutes.home,
      page: () => const HomeScreen(),
      transition: Transition.fadeIn,
      transitionDuration: const Duration(milliseconds: 400),
    ),
    // Mở ra khi code xong:
    // GetPage(name: AppRoutes.profile,  page: () => const ProfileScreen()),
    // GetPage(name: AppRoutes.schedule, page: () => const ScheduleScreen()),
    // GetPage(name: AppRoutes.report,   page: () => const ReportScreen()),
  ];
}