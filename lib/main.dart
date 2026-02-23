import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:fresh_fish/firebase_options.dart';
import 'package:provider/provider.dart';
import 'theme/app_theme.dart';
import 'providers/app_provider.dart';
import 'providers/user_data_provider.dart';
import 'services/notification_service.dart';
import 'screens/app_screen.dart';
import 'screens/main/main_screen.dart';
import 'screens/auth/login_screen.dart';
import 'screens/auth/signup_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await _initializeServices();
  runApp(const FishQuestApp());
}

Future<void> _initializeServices() async {
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform
    ).timeout(const Duration(seconds: 8));

    if (kDebugMode) debugPrint('✅ Firebase 초기화 완료');
  } catch (e) {
    if (kDebugMode) debugPrint('❌ Firebase 초기화 실패: $e');
  }

  try {
    await NotificationService.instance
        .initialize()
        .timeout(const Duration(seconds: 3));
    if (kDebugMode) debugPrint('✅ 알림 서비스 초기화 완료');
  } catch (e) {
    if (kDebugMode) debugPrint('⚠️ NotificationService 초기화 실패/타임아웃: $e');
  }
}

class FishQuestApp extends StatelessWidget {
  const FishQuestApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => AppProvider()..initialize(),
        ),
        ChangeNotifierProvider(
          create: (_) => UserDataProvider()..initialize(),
        ),
      ],
      child: MaterialApp(
        title: 'Fresh Fish - 자기계발 습관 추적기',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        initialRoute: '/login',
        routes: {
          '/login': (_) => const LoginScreen(),
          '/signup': (_) => const SignupScreen(),
          '/home': (_) => const MainScreen(),
        },

        home: Consumer<AppProvider>(
          builder: (context, appProvider, _) {
            if (kDebugMode) {
              debugPrint('🔍 AppProvider 상태: isLoading=${appProvider.isLoading}, isOnboardingComplete=${appProvider.isOnboardingComplete}, userData=${appProvider.userData}');
            }

            if (appProvider.isLoading) {
              return _buildLoadingScreen();
            }

            if (!appProvider.isOnboardingComplete) {
              return const OnboardingFlow();
            }

            return const MainScreen();
          },
        ),
      ),
    );
  }

  Widget _buildLoadingScreen() {
    return const Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('🐠', style: TextStyle(fontSize: 80)),
            SizedBox(height: 24),
            CircularProgressIndicator(color: Color(0xFF4FC3F7)),
            SizedBox(height: 16),
            Text(
              'My Tiny Aquarium',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }
}
