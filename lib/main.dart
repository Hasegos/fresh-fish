import 'package:flutter/material.dart';
import '../screens/onboarding_screen.dart';
import '../screens/main_aquarium_screen.dart';
import '../services/storage_service.dart';
import '../models/user_data.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  await StorageService.init();
  runApp(const FishQuestApp());
}

class FishQuestApp extends StatelessWidget {
  const FishQuestApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Fish Quest',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
        fontFamily: 'System',
      ),
      home: const AppRouter(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class AppRouter extends StatefulWidget {
  const AppRouter({super.key});

  @override
  State<AppRouter> createState() => _AppRouterState();
}

class _AppRouterState extends State<AppRouter> {
  UserData? _userData;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    final userData = await StorageService.getUserData();
    setState(() {
      _userData = userData;
      _isLoading = false;
    });
  }

  void _handleOnboardingComplete(UserData userData) {
    setState(() {
      _userData = userData;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    if (_userData == null) {
      return OnboardingScreen(onComplete: _handleOnboardingComplete);
    }

    return MainAquariumScreen(
      userData: _userData!,
      onUserDataChanged: (userData) {
        setState(() {
          _userData = userData;
        });
      },
      onLogout: () {
        setState(() {
          _userData = null;
        });
      },
    );
  }
}
