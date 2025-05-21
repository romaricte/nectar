import 'package:get/get.dart';
import 'package:nectar/screens/auth/login_screen.dart';
import 'package:nectar/screens/auth/register_screen.dart';
import 'package:nectar/screens/home/home_screen.dart';
import 'package:nectar/screens/onboarding/onboarding.dart';
import 'package:nectar/screens/splash_screen/splash_screen.dart';

class AppRoutes {
  static const String splash = '/splash';
  static const String onboarding = '/onboarding'; 
  static const String login = '/login';
  static const String register = '/register';
  static const String home = '/home';
  static List<GetPage> pages = [
    GetPage(
      name: splash,
      page: () => const SplashScreen(),
      transition: Transition.zoom,
      transitionDuration: const Duration(milliseconds: 200),
    ),
    GetPage(
      name: onboarding,
      page: () => const Onboarding(),
      transition: Transition.zoom,
      transitionDuration: const Duration(milliseconds: 200),
    ),
    GetPage(
      name: login,
      page: () => const LoginScreen(),
      transition: Transition.zoom,
      transitionDuration: const Duration(milliseconds: 200),
    ),
    GetPage(
      name: register,
      page: () => const RegisterScreen(),
      transition: Transition.zoom,
      transitionDuration: const Duration(milliseconds: 200),
    ),
    GetPage(
      name: home,
      page: () => const HomeScreen(),
      transition: Transition.zoom,
      transitionDuration: const Duration(milliseconds: 200),
    ),
    ];
}
