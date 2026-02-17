import 'package:flutter/material.dart';
import 'aquarium_screen.dart';
import '../timer/timer_screen.dart';
import '../quests/quests_screen.dart';
import '../menu/menu_screen.dart';
import '../../widgets/bottom_navigation.dart';

/// 메인 화면 (하단 네비게이션 포함)
class MainScreen extends StatefulWidget {
  const MainScreen({Key? key}) : super(key: key);

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> with WidgetsBindingObserver {
  int _currentIndex = 0;

  late final List<Widget> _pages;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _pages = [
      AquariumScreen(onNavChanged: (index) {
        setState(() => _currentIndex = index);
      }),
      const QuestsScreen(),
      const TimerScreen(),
      const MenuScreen(),
    ];
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    // 앱이 백그라운드에서 포그라운드로 돌아왔을 때 타이머 화면 새로고침
    if (state == AppLifecycleState.resumed && _currentIndex == 2) {
      // Timer screen requires refresh after background pause
    }
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async => false,
      child: Scaffold(
        body: _pages[_currentIndex],
        bottomNavigationBar: BottomNavigation(
          currentIndex: _currentIndex,
          onTap: (index) {
            setState(() => _currentIndex = index);
          },
        ),
      ),
    );
  }
}