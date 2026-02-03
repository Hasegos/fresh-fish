import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';

import 'theme/app_theme.dart';
import 'providers/app_provider.dart';
import 'providers/user_data_provider.dart';
import 'screens/app_screen.dart';
import 'screens/main/main_screen.dart';
import 'screens/auth/login_screen.dart';
import 'screens/auth/signup_screen.dart';


Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    await Firebase.initializeApp(
      options: const FirebaseOptions(
        apiKey: "AIzaSy...",
        appId: "1:12345:android:...",
        messagingSenderId: "12345...",
        projectId: "your-project-id",
      ),
    );
    if (kDebugMode) {
      debugPrint('✅ Firebase 초기화 성공');
    }
  } on FirebaseException catch (e) {
    if (e.code == 'duplicate-app') {
      try {
        final app = Firebase.app();
        if (kDebugMode) {
          debugPrint('✅ Firebase 이미 존재함 -> 재사용: ${app.name}');
        }
      } catch (appError) {
        if (kDebugMode) {
          debugPrint('⚠️ Firebase 앱 재사용 실패: $appError');
        }
      }
    } else {
      if (kDebugMode) {
        debugPrint('⚠️ Firebase 초기화 실패(FirebaseException): ${e.code} / ${e.message}');
      }
    }
  } catch (e) {
    if (kDebugMode) {
      debugPrint('⚠️ Firebase 초기화 실패(기타): $e');
    }
  }

  runApp(const FishQuestApp());
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
      ),
    );
  }
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