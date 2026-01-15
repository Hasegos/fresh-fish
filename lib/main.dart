import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'providers/app_provider.dart';
import 'screens/app_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Firebase 초기화 (옵션)
  try {
    await Firebase.initializeApp();
    debugPrint('✅ Firebase 초기화 성공');
  } catch (e) {
    debugPrint('⚠️ Firebase 초기화 실패 (로컬 모드로 작동): $e');
  }

  runApp(const MyTinyAquariumApp());
}

class MyTinyAquariumApp extends StatelessWidget {
  const MyTinyAquariumApp({Key? key}) : super(key: key);

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
          colorScheme: ColorScheme.fromSeed(
            seedColor: const Color(0xFF4FC3F7),
            brightness: Brightness.dark,
          ),
          scaffoldBackgroundColor: const Color(0xFF0D1B2A),
        ),
        home: const AppScreen(),
      ),
    );
  }
}
