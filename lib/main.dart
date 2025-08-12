import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'screens/home_screen.dart';
import 'providers/job_application_provider.dart';
import 'providers/mood_provider.dart';
import 'providers/study_group_provider.dart';
import 'providers/performance_provider.dart';
import 'services/data_initializer.dart';
import 'services/smart_notification_service.dart';
import 'services/ai_career_assistant.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Start app immediately, initialize services in background
  runApp(const StudyProApp());

  // Initialize services asynchronously after app starts
  _initializeServicesInBackground();
}

void _initializeServicesInBackground() async {
  try {
    // Run initialization in background without blocking UI
    await Future.wait([
      DataInitializer.initializeSampleData(),
      SmartNotificationService.initialize(),
    ]);

    // Initialize AI Career Assistant
    AICareerAssistant.initialize();
  } catch (e) {
    debugPrint('Error initializing background services: $e');
    // Services will work with fallbacks
  }
}

class StudyProApp extends StatelessWidget {
  const StudyProApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => JobApplicationProvider()),
        ChangeNotifierProvider(create: (_) => MoodProvider()),
        ChangeNotifierProvider(create: (_) => StudyGroupProvider()),
        ChangeNotifierProvider(create: (_) => PerformanceProvider()),
      ],
      child: MaterialApp(
        title: 'StudyPro',
        theme: ThemeData(
          useMaterial3: true,
          primarySwatch: Colors.blue,
          primaryColor: const Color(0xFF6366F1),
          scaffoldBackgroundColor: const Color(0xFFF8FAFC),
          colorScheme: ColorScheme.fromSeed(
            seedColor: const Color(0xFF6366F1),
            brightness: Brightness.light,
          ).copyWith(
            primary: const Color(0xFF6366F1),
            secondary: const Color(0xFF8B5CF6),
            tertiary: const Color(0xFFEC4899),
            surface: Colors.white,
            background: const Color(0xFFF8FAFC),
          ),
          appBarTheme: const AppBarTheme(
            backgroundColor: Colors.transparent,
            foregroundColor: Color(0xFF1E293B),
            elevation: 0,
            centerTitle: true,
            titleTextStyle: TextStyle(
              color: Color(0xFF1E293B),
              fontSize: 20,
              fontWeight: FontWeight.w600,
            ),
          ),
          elevatedButtonTheme: ElevatedButtonThemeData(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF6366F1),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              elevation: 0,
              shadowColor: const Color(0xFF6366F1).withOpacity(0.3),
            ),
          ),
          cardTheme: CardTheme(
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            color: Colors.white,
            shadowColor: Colors.black.withOpacity(0.1),
          ),
          inputDecorationTheme: InputDecorationTheme(
            filled: true,
            fillColor: const Color(0xFFF1F5F9),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(
                color: Color(0xFF6366F1),
                width: 2,
              ),
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 16,
            ),
          ),
          textTheme: const TextTheme(
            headlineLarge: TextStyle(
              color: Color(0xFF1E293B),
              fontSize: 32,
              fontWeight: FontWeight.bold,
            ),
            headlineMedium: TextStyle(
              color: Color(0xFF1E293B),
              fontSize: 24,
              fontWeight: FontWeight.w600,
            ),
            titleLarge: TextStyle(
              color: Color(0xFF1E293B),
              fontSize: 20,
              fontWeight: FontWeight.w600,
            ),
            titleMedium: TextStyle(
              color: Color(0xFF475569),
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
            bodyLarge: TextStyle(
              color: Color(0xFF64748B),
              fontSize: 16,
            ),
            bodyMedium: TextStyle(
              color: Color(0xFF64748B),
              fontSize: 14,
            ),
          ),
        ),
        home: const HomeScreen(),
        debugShowCheckedModeBanner: false,
      ),
    );
  }
}
