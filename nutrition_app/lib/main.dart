// lib/main.dart
import 'package:flutter/material.dart';
import 'package:nutrition_app/providers/health_profile_provider.dart';
import 'package:nutrition_app/screens/auth/login_screen.dart';
import 'package:provider/provider.dart';
import 'package:nutrition_app/providers/auth_provider.dart';
import 'package:nutrition_app/screens/auth/register_screen.dart';
import 'package:nutrition_app/screens/splash_screen.dart';
import 'package:nutrition_app/screens/dashboard/dashboard_screen.dart';
import 'package:nutrition_app/utils/AppColor.dart';
import 'package:nutrition_app/services/health_profile_service.dart';
import 'package:nutrition_app/services/api_client.dart';
import 'package:nutrition_app/services/auth_service.dart';
import 'package:nutrition_app/providers/water_intake_provider.dart';
import 'package:nutrition_app/services/water_intake_service.dart';
import 'package:nutrition_app/providers/food_entry_provider.dart';
import 'package:nutrition_app/services/food_entry_service.dart';
import 'package:nutrition_app/providers/step_counter_provider.dart';
import 'package:nutrition_app/services/step_counter_service.dart';
import 'package:nutrition_app/providers/language_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize step counter service
  final stepCounterService = StepCounterService();
  try {
    await stepCounterService.initialize();
  } catch (e) {
    print('Error initializing step counter: $e');
  }

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final authService = AuthService();
    final apiClient = ApiClient();
    final stepCounterService = StepCounterService();

    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => LanguageProvider()),
        Provider<AuthService>.value(value: authService),
        ChangeNotifierProvider(
          create: (context) => HealthProfileProvider(
            HealthProfileService(apiClient),
            authService,
          ),
        ),
        ChangeNotifierProvider(
          create: (context) =>
              WaterIntakeProvider(WaterIntakeService(apiClient)),
        ),
        ChangeNotifierProvider<FoodEntryProvider>(
          create: (context) {
            final foodEntryService = FoodEntryService(apiClient);
            return FoodEntryProvider(foodEntryService);
          },
        ),
        ChangeNotifierProvider(
          create: (context) => StepCounterProvider(stepCounterService),
        ),
      ],
      child: Consumer<AuthProvider>(
        builder: (context, authProvider, _) {
          return MaterialApp(
            title: 'Nutrition Tracker',
            debugShowCheckedModeBanner: false,
            theme: ThemeData(
              colorScheme: ColorScheme.fromSeed(
                seedColor: primaryColor,
                primary: primaryColor,
                secondary: accentColor,
                surface: surfaceColor,
                background: backgroundColor,
                error: errorColor,
              ),
              useMaterial3: true,
              appBarTheme: AppBarTheme(
                centerTitle: true,
                elevation: 0,
                backgroundColor: surfaceColor,
                foregroundColor: textPrimaryColor,
              ),
              elevatedButtonTheme: ElevatedButtonThemeData(
                style: ElevatedButton.styleFrom(
                  backgroundColor: primaryColor,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
              ),
              textTheme: TextTheme(
                headlineLarge: TextStyle(
                  color: textPrimaryColor,
                  fontWeight: FontWeight.bold,
                ),
                headlineMedium: TextStyle(
                  color: textPrimaryColor,
                  fontWeight: FontWeight.bold,
                ),
                bodyLarge: TextStyle(color: textPrimaryColor),
                bodyMedium: TextStyle(color: textSecondaryColor),
              ),
            ),
            routes: {
              '/login': (context) => const LoginScreen(),
              '/register': (context) => const RegisterScreen(),
              '/dashboard': (context) => const DashboardScreen(),
            },
            home: const SplashScreen(),
          );
        },
      ),
    );
  }
}
