import 'package:flutter/material.dart';
import 'aquarium_screen.dart';
import '../timer/timer_screen.dart';
import '../quests/quests_screen.dart';
import '../menu/menu_screen.dart';
import '../../widgets/bottom_navigation.dart';

/// 메인 화면 (하단 네비게이션 포함)
class MainScreen extends StatefulWidget {
  /// ✅ 외부 라우트에서 특정 탭으로 바로 열기 위한 초기 인덱스
  final int initialIndex;

  const MainScreen({
    Key? key,
    this.initialIndex = 0,
  }) : super(key: key);

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
      MenuScreen(
        onGoHome: () {
          if (mounted) {
            setState(() => _currentIndex = 0);
          }
        },
      ),
    ];

    // ✅ pages 길이를 넘어가는 값 방지 (안전장치)
    final maxIndex = _pages.length - 1;
    _currentIndex = widget.initialIndex.clamp(0, maxIndex);
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
