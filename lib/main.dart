// lib/main.dart
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'providers/app_provider.dart';
import 'screens/app_screen.dart';
void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    // 💡 Gradle이 파일을 못 읽을 때 사용하는 수동 초기화 방식입니다.
    // google-services.json 파일 안의 값들을 아래에 매칭시키세요.
    await Firebase.initializeApp(
      options: const FirebaseOptions(
        apiKey: "AIzaSy...",          // api_key의 current_key 값
        appId: "1:12345:android:...", // mobilesdk_app_id 값
        messagingSenderId: "12345...", // project_number 값
        projectId: "your-project-id",  // project_id 값
      ),
    );
    debugPrint('✅ Firebase 수동 초기화 성공');
  } catch (e) {
    debugPrint('⚠️ Firebase 초기화 실패: $e');
  }

  runApp(const MyTinyAquariumApp());
}

class MyTinyAquariumApp extends StatelessWidget {
  const MyTinyAquariumApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // 전역 상태 관리 도구인 Provider를 앱 최상단에 배치합니다.
    return ChangeNotifierProvider(
      create: (_) => AppProvider()..initialize(), // 앱 시작 시 데이터 로드
      child: MaterialApp(
        title: 'My Tiny Aquarium',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          useMaterial3: true,
          brightness: Brightness.dark,
          primarySwatch: Colors.blue,
        ),
        home: const AppScreen(), // 메인 화면으로 이동
      ),
    );
  }
}