import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import '../models/user_data.dart';
import 'mission_list_screen.dart';
import 'calendar_screen.dart';
import 'settings_screen.dart';

class MainAquariumScreen extends StatefulWidget {
  final UserData userData;
  final Function(UserData) onUserDataChanged;
  final VoidCallback onLogout;

  const MainAquariumScreen({
    super.key,
    required this.userData,
    required this.onUserDataChanged,
    required this.onLogout,
  });

  @override
  State<MainAquariumScreen> createState() => _MainAquariumScreenState();
}

class _MainAquariumScreenState extends State<MainAquariumScreen>
    with SingleTickerProviderStateMixin {
  double _fishX = 0.5;
  double _fishY = 0.5;
  Timer? _fishTimer;
  bool _showMessage = false;
  String _currentMessage = '';
  final Random _random = Random();

  final List<String> _messages = [
    '오늘 운동은 하셨나요?',
    '배고파요! 미션 완료해주세요!',
    '오늘도 화이팅!',
    '물 많이 마셔요~',
    '건강한 하루 되세요!',
    '같이 성장해요!',
  ];

  final List<String> _fishEmojis = ['🐠', '🐟', '🐡'];

  @override
  void initState() {
    super.initState();
    _startFishAnimation();
  }

  void _startFishAnimation() {
    _fishTimer = Timer.periodic(const Duration(seconds: 3), (timer) {
      if (mounted) {
        setState(() {
          _fishX = 0.1 + _random.nextDouble() * 0.8;
          _fishY = 0.2 + _random.nextDouble() * 0.6;
        });
      }
    });
  }

  void _handleFishTap() {
    setState(() {
      _currentMessage = _messages[_random.nextInt(_messages.length)];
      _showMessage = true;
    });
    Future.delayed(const Duration(seconds: 3), () {
      if (mounted) {
        setState(() {
          _showMessage = false;
        });
      }
    });
  }

  void _navigateToMissions() async {
    final updatedUserData = await Navigator.push<UserData>(
      context,
      MaterialPageRoute(
        builder: (context) => MissionListScreen(userData: widget.userData),
      ),
    );
    if (updatedUserData != null) {
      widget.onUserDataChanged(updatedUserData);
    }
  }

  void _navigateToCalendar() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const CalendarScreen(),
      ),
    );
  }

  void _navigateToSettings() async {
    final result = await Navigator.push<Map<String, dynamic>>(
      context,
      MaterialPageRoute(
        builder: (context) => SettingsScreen(userData: widget.userData),
      ),
    );

    if (result != null) {
      if (result['action'] == 'logout' || result['action'] == 'delete') {
        widget.onLogout();
      } else if (result['userData'] != null) {
        widget.onUserDataChanged(result['userData']);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final fishScale = 1.0 + (widget.userData.level - 1) * 0.1;

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFF60A5FA),
              Color(0xFF3B82F6),
              Color(0xFF2563EB),
            ],
          ),
        ),
        child: SafeArea(
          child: Stack(
            children: [
              // Bubbles
              ..._buildBubbles(),

              // Header
              Positioned(
                top: 16,
                left: 16,
                right: 16,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _buildHeaderButton(
                      icon: Icons.calendar_today,
                      onTap: _navigateToCalendar,
                    ),
                    _buildHeaderButton(
                      icon: Icons.settings,
                      onTap: _navigateToSettings,
                    ),
                  ],
                ),
              ),

              // Status Bar
              Positioned(
                top: 80,
                left: 24,
                right: 24,
                child: _buildStatusBar(),
              ),

              // Fish
              AnimatedPositioned(
                duration: const Duration(milliseconds: 3000),
                curve: Curves.easeInOut,
                left: MediaQuery.of(context).size.width * _fishX - 40,
                top: MediaQuery.of(context).size.height * _fishY - 40,
                child: GestureDetector(
                  onTap: _handleFishTap,
                  child: Transform.scale(
                    scale: fishScale,
                    child: Text(
                      _fishEmojis[widget.userData.selectedFish],
                      style: const TextStyle(fontSize: 80),
                    ),
                  ),
                ),
              ),

              // Speech Bubble
              if (_showMessage)
                AnimatedPositioned(
                  duration: const Duration(milliseconds: 300),
                  left: MediaQuery.of(context).size.width * _fishX - 80,
                  top: MediaQuery.of(context).size.height * _fishY - 100,
                  child: _buildSpeechBubble(),
                ),

              // Mission Button
              Positioned(
                bottom: 32,
                left: 24,
                right: 24,
                child: _buildMissionButton(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeaderButton({required IconData icon, required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.2),
          borderRadius: BorderRadius.circular(24),
        ),
        child: Icon(icon, color: Colors.white, size: 24),
      ),
    );
  }

  Widget _buildStatusBar() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.9),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '레벨 ${widget.userData.level}',
                    style: const TextStyle(
                      fontSize: 12,
                      color: Color(0xFF6B7280),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    widget.userData.nickname,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1F2937),
                    ),
                  ),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    '${widget.userData.gold} G',
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFFF59E0B),
                    ),
                  ),
                  const Text(
                    '골드',
                    style: TextStyle(
                      fontSize: 10,
                      color: Color(0xFF6B7280),
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              value: widget.userData.expPercentage,
              minHeight: 12,
              backgroundColor: const Color(0xFFE5E7EB),
              valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF3B82F6)),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'EXP ${widget.userData.exp} / ${widget.userData.expNeeded}',
            style: const TextStyle(
              fontSize: 10,
              color: Color(0xFF6B7280),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSpeechBubble() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
          ),
        ],
      ),
      child: Text(
        _currentMessage,
        style: const TextStyle(fontSize: 12),
      ),
    );
  }

  Widget _buildMissionButton() {
    return ElevatedButton(
      onPressed: _navigateToMissions,
      style: ElevatedButton.styleFrom(
        padding: const EdgeInsets.symmetric(vertical: 16),
        backgroundColor: const Color(0xFF8B5CF6),
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        elevation: 8,
      ),
      child: const Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.auto_awesome, size: 24),
          SizedBox(width: 12),
          Text(
            '오늘의 미션 하러 가기',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  List<Widget> _buildBubbles() {
    return List.generate(8, (index) {
      return _Bubble(
        left: _random.nextDouble() * 100,
        delay: _random.nextDouble() * 5,
      );
    });
  }

  @override
  void dispose() {
    _fishTimer?.cancel();
    super.dispose();
  }
}

class _Bubble extends StatefulWidget {
  final double left;
  final double delay;

  const _Bubble({required this.left, required this.delay});

  @override
  State<_Bubble> createState() => _BubbleState();
}

class _BubbleState extends State<_Bubble> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: Duration(seconds: 5 + Random().nextInt(5)),
      vsync: this,
    )..repeat();

    _animation = Tween<double>(begin: 1.0, end: 0.0).animate(_controller);
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Positioned(
          left: widget.left,
          bottom: MediaQuery.of(context).size.height * _animation.value - 20,
          child: Opacity(
            opacity: 0.3,
            child: Container(
              width: 16,
              height: 16,
              decoration: const BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
              ),
            ),
          ),
        );
      },
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}