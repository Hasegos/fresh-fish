// lib/main.dart
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';

import 'providers/app_provider.dart';

// ✅ 로그인 화면으로 시작하고 싶으면 이 import 필요
import 'screens/auth/login_screen.dart';

// 만약 파일 경로/이름이 다르면 위 import만 네 프로젝트에 맞게 수정!
// 예) import 'screens/auth/login_screen.dart';

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
    // ✅ Hot restart에서 네이티브는 이미 DEFAULT가 살아있을 수 있음
    if (e.code == 'duplicate-app') {
      final app = Firebase.app(); // 이미 존재하는 DEFAULT 가져오기
      debugPrint('✅ Firebase 이미 존재함 -> 재사용: ${app.name}');
    } else {
      debugPrint('⚠️ Firebase 초기화 실패(FirebaseException): ${e.code} / ${e.message}');
    }
  } catch (e) {
    debugPrint('⚠️ Firebase 초기화 실패(기타): $e');
  }

  runApp(const MyTinyAquariumApp());
}

class MyTinyAquariumApp extends StatelessWidget {
  const MyTinyAquariumApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => AppProvider()..initialize(),
      child: MaterialApp(
        title: 'My Tiny Aquarium',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          useMaterial3: true,
          brightness: Brightness.dark,
          primarySwatch: Colors.blue,
        ),

        // ✅ 무조건 로그인 화면부터 시작 (처음부터 테스트용)
        home: const LoginScreen(),
      ),
    );
  }
}
