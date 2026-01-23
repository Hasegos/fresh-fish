import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';

import 'theme/app_theme.dart';
import 'providers/app_provider.dart';
import 'screens/auth/login_screen.dart';

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
    debugPrint('✅ Firebase 초기화 성공');
  } on FirebaseException catch (e) {
    if (e.code == 'duplicate-app') {
      final app = Firebase.app();
      debugPrint('✅ Firebase 이미 존재함 -> 재사용: ${app.name}');
    } else {
      debugPrint('⚠️ Firebase 초기화 실패(FirebaseException): ${e.code} / ${e.message}');
    }
  } catch (e) {
    debugPrint('⚠️ Firebase 초기화 실패(기타): $e');
  }

  runApp(const FishQuestApp());
}

class FishQuestApp extends StatelessWidget {
  const FishQuestApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => AppProvider()..initialize(),
      child: MaterialApp(
        title: 'Fresh Fish - 자기계발 습관 추적기',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        home: const LoginScreen(),
      ),
    );
  }
}
