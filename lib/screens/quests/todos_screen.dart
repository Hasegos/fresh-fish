import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/user_data_provider.dart';
import '../../widgets/bottom_navigation.dart';

/// To Do 화면
class TodosScreen extends StatelessWidget {
  const TodosScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFF0A1628),
              Color(0xFF1B263B),
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // 헤더
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  children: [
                    IconButton(
                      onPressed: () {
                        context.read<UserDataProvider>().backToMain();
                      },
                      icon: const Icon(Icons.arrow_back, color: Colors.white),
                    ),
                    const SizedBox(width: 8),
                    const Text(
                      '✅ To Do',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
              
              // 할 일 목록
              const Expanded(
                child: Center(
                  child: Text(
                    'To Do 기능 준비 중',
                    style: TextStyle(
                      fontSize: 18,
                      color: Color(0xFF778DA9),
                    ),
                  ),
                ),
              ),
              
              const SizedBox(height: 80),
            ],
          ),
        ),
      ),
      bottomNavigationBar: const BottomNavigation(),
    );
  }
}
