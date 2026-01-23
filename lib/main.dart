import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';

import 'theme/app_theme.dart';
import 'providers/app_provider.dart';
import 'providers/user_data_provider.dart';
import 'screens/app_screen.dart';
import 'screens/main/main_screen.dart';

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
        home: Consumer<AppProvider>(
          builder: (context, appProvider, _) {
            debugPrint('🔍 AppProvider 상태: isLoading=${appProvider.isLoading}, isOnboardingComplete=${appProvider.isOnboardingComplete}, userData=${appProvider.userData}');
            
            // 로딩 중
            if (appProvider.isLoading) {
              debugPrint('⏳ 로딩 화면 표시');
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

            // 온보딩 미완료
            if (!appProvider.isOnboardingComplete) {
              debugPrint('🔄 OnboardingFlow로 진입');
              return const OnboardingFlow();
            }

            // 온보딩 완료 -> 메인 화면
            debugPrint('✅ MainScreen으로 진입');
            return const MainScreen();
          },
        ),
      ),
    );
  }
}
