
import 'package:flutter/material.dart';
import 'package:moodeatsai/db_services/reminder_service.dart';
import 'package:moodeatsai/provider/allergy_notify_provider.dart';
import 'package:moodeatsai/provider/pwd_toggle_provider.dart';
import 'package:provider/provider.dart';
import 'package:moodeatsai/constants/constants.dart';
import 'package:moodeatsai/screens/splash_screen.dart';
import 'package:moodeatsai/provider/bottom_navigation_provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:device_preview/device_preview.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  NotificationService().initNotification();

  tz.initializeTimeZones();
  Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
  // runApp(
  //   DevicePreview(
  //     builder: (context) => const MyApp(),
  //   ),
  // );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    const ColorScheme baseLightColorScheme = ColorScheme.light();
    final ColorScheme myColorScheme = baseLightColorScheme.copyWith(
      background: AppColors.backgroundColor,
    );
    const AppBarTheme appBarTheme = AppBarTheme(
      backgroundColor: AppColors.backgroundColor,
      elevation: 0.0,
      iconTheme: IconThemeData(
        color: AppColors.darkYellow,
      ),
      titleTextStyle: TextStyle(
        color: Colors.black,
        fontSize: 20,
      ),
      actionsIconTheme: IconThemeData(
        color: AppColors.darkYellow,
      ),
    );

    return MultiProvider(
      providers: [
        // Add your providers here
        ChangeNotifierProvider<BottomNavigationProvider>(
          create: (context) => BottomNavigationProvider(),
        ),
        ChangeNotifierProvider<PasswordIconToggleProvider>(
          create: (context) => PasswordIconToggleProvider(),
        ),
        ChangeNotifierProvider<AllergiesModel>(
          create: (context) => AllergiesModel(),
        ),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          useMaterial3: true,
          appBarTheme: appBarTheme,
          colorScheme: myColorScheme,
        ),
        home: const SplashScreen(),
      ),
    );
  }
}
