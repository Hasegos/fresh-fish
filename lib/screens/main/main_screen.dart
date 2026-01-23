import 'package:flutter/material.dart';
import 'aquarium_screen.dart';
import '../timer/timer_screen.dart';
import '../quests/quests_screen.dart';
import '../calendar/calendar_screen.dart';
import '../settings/settings_screen.dart';

/// 메인 화면 (하단 네비게이션 포함)
class MainScreen extends StatefulWidget {
  const MainScreen({Key? key}) : super(key: key);

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 0;

  late final List<Widget> _pages;

  @override
  void initState() {
    super.initState();
    _pages = [
      AquariumScreen(onNavChanged: (index) {
        setState(() => _currentIndex = index);
      }),
      const TimerScreen(),
      const QuestsScreen(),
      const CalendarScreen(),
      const SettingsScreen(),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async => false,
      child: Scaffold(
        body: _pages[_currentIndex],
      ),
    );
  }
}