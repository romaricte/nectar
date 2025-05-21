import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:nectar/screens/onboarding/onboarding.dart';
import 'routes/app_routes.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

void main() async {
    WidgetsFlutterBinding.ensureInitialized();
// Chargement des variables d'environnement
  await dotenv.load();
  
  // Initialisation de Supabase
  await Supabase.initialize(
    url: dotenv.env['SUPABASE_URL']!,
    anonKey: dotenv.env['SUPABASE_ANON_KEY']!,
    debug: true, // Mettez à false en production
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'Nectar',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF53B175)),
        primaryColor: const Color(0xFF53B175),
      ),
      initialRoute: AppRoutes.splash,
      getPages: AppRoutes.pages,
    );
  }
}
