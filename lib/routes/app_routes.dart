import 'package:get/get.dart';
import 'package:nectar/screens/onboarding.dart';

class AppRoutes {
  static const String onboarding = '/onboarding'; 

  static List<GetPage> pages = [
    GetPage(
      name: onboarding,
      page: () => const Onboarding(),
      transition: Transition.zoom,
      transitionDuration: const Duration(milliseconds: 200),
    ),
   
    ];
}
