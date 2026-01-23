import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:math';
import '../../providers/user_data_provider.dart';
import '../../models/user_data_model.dart';
import '../../models/fish_model.dart';
import '../../models/quest_model.dart';
import '../../theme/app_colors.dart';
import '../../widgets/bottom_navigation.dart';

/// 메인 어항 화면 - 새로운 아키텍처
class AquariumScreen extends StatefulWidget {
  const AquariumScreen({super.key});

  @override
  State<AquariumScreen> createState() => _AquariumScreenState();
}

class _AquariumScreenState extends State<AquariumScreen>
    with TickerProviderStateMixin {
  late AnimationController _positionController;
  late Offset _fishPosition;
  late Offset _targetPosition;
  String? _displayedMessage;
  bool _showMessage = false;

  @override
  void initState() {
    super.initState();
    _initializeAnimation();
  }

  void _initializeAnimation() {
    _positionController = AnimationController(
      duration: const Duration(seconds: 4),
      vsync: this,
    );

    _fishPosition = const Offset(50, 50);
    _targetPosition = _generateRandomTarget();

    _positionController.addListener(() {
      setState(() {
        _fishPosition = Offset(
          _fishPosition.dx +
              (_targetPosition.dx - _fishPosition.dx) * 0.02,
          _fishPosition.dy +
              (_targetPosition.dy - _fishPosition.dy) * 0.02,
        );
      });
    });

    _positionController.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        _targetPosition = _generateRandomTarget();
        _positionController.reset();
        _positionController.forward();
      }
    });

    _positionController.forward();
  }

  Offset _generateRandomTarget() {
    final random = Random();
    return Offset(
      random.nextDouble() * 200,
      random.nextDouble() * 150,
    );
  }

  void _onFishTapped() {
    final hour = DateTime.now().hour;
    String message;

    if (hour < 12) {
      message = "Fresh start! Let's do this!";
    } else if (hour >= 18) {
      message = "You've done well. Rest up for tomorrow.";
    } else {
      // Check progress
      // For now, using random threshold
      final isGoodProgress = Random().nextBool();
      message = isGoodProgress
          ? "You're doing amazing!"
          : "Need a little boost?";
    }

    setState(() {
      _displayedMessage = message;
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

  @override
  void dispose() {
    _positionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Consumer<UserDataProvider>(
        builder: (context, provider, child) {
          final userData = provider.userData;

          if (userData == null) {
            return Center(
              child: CircularProgressIndicator(
                color: AppColors.primaryPastel,
              ),
            );
          }

          return Stack(
            children: [
              Column(
                children: [
                  // Top 45% - Aquarium Section
                  SizedBox(
                    height: MediaQuery.of(context).size.height * 0.45,
                    child: _buildAquariumSection(context, userData),
                  ),

                  // Bottom 55% - Task List Section
                  Expanded(
                    child: _buildMissionArea(context, userData),
                  ),
                ],
              ),

              // Bottom Navigation
              Positioned(
                left: 0,
                right: 0,
                bottom: 0,
                child: BottomNavigation(
                  currentIndex: 0,
                  onTap: (index) {
                    if (index != 0) {
                      Navigator.of(context).pushNamed(_getRouteName(index));
                    }
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildAquariumSection(BuildContext context, UserData userData) {
    final fish = userData.fish;

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            const Color(0xFFE0F2F1), // Soft Mint
            const Color(0xFFE3F2FD), // Sky Blue
          ],
        ),
      ),
      child: Stack(
        children: [
          // HUD (Top-Left)
          Positioned(
            top: 16,
            left: 16,
            child: _buildHUD(context, fish, userData.gold),
          ),

          // Aquarium with animated fish
          Center(
            child: GestureDetector(
              onTap: _onFishTapped,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  // Aquarium background
                  Container(
                    width: 280,
                    height: 200,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.3),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: AppColors.primaryPastel.withOpacity(0.3),
                        width: 2,
                      ),
                    ),
                  ),

                  // Animated fish
                  AnimatedPositioned(
                    duration: const Duration(milliseconds: 100),
                    left: _fishPosition.dx,
                    top: _fishPosition.dy,
                    child: GestureDetector(
                      onTap: _onFishTapped,
                      child: Text(
                        fish.type.emoji,
                        style: const TextStyle(fontSize: 60),
                      ),
                    ),
                  ),

                  // Speech bubble
                  if (_showMessage)
                    Positioned(
                      top: 20,
                      child: _buildSpeechBubble(_displayedMessage ?? ""),
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHUD(BuildContext context, Fish fish, int gold) {
    const expToNextLevel = 100;
    final double expProgress = (fish.exp / expToNextLevel).clamp(0.0, 1.0);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Fish icon and level
        Row(
          children: [
            Text(
              fish.type.emoji,
              style: const TextStyle(fontSize: 28),
            ),
            const SizedBox(width: 8),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Lv. ${fish.level}',
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
                SizedBox(
                  width: 120,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: LinearProgressIndicator(
                      value: expProgress,
                      minHeight: 6,
                      backgroundColor: Colors.grey[300],
                      valueColor: const AlwaysStoppedAnimation<Color>(
                        AppColors.primaryPastel,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
        const SizedBox(height: 12),

        // Coin display
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          decoration: BoxDecoration(
            color: AppColors.highlightPink.withOpacity(0.15),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: AppColors.highlightPink.withOpacity(0.3),
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('💰', style: TextStyle(fontSize: 16)),
              const SizedBox(width: 4),
              Text(
                gold.toString(),
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSpeechBubble(String message) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: AppColors.primaryPastel,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Text(
        message,
        style: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: Colors.white,
        ),
        textAlign: TextAlign.center,
      ),
    );
  }

  Widget _buildMissionArea(BuildContext context, UserData userData) {
    return Container(
      color: AppColors.background,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
            child: Text(
              "My Today's Focus",
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
          ),
          Expanded(
            child: _buildActiveTodosList(context, userData),
          ),
        ],
      ),
    );
  }

  Widget _buildActiveTodosList(BuildContext context, UserData userData) {
    // Filter active todos
    final activeTodos = userData.quests
        .where((q) =>
            q.questType == QuestType.daily &&
            q.date == userData.currentDate &&
            !q.completed)
        .toList();

    if (activeTodos.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              '🎉',
              style: TextStyle(fontSize: 48),
            ),
            const SizedBox(height: 12),
            const Text(
              'All tasks completed!',
              style: TextStyle(
                fontSize: 16,
                color: AppColors.textSecondary,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      itemCount: activeTodos.length,
      itemBuilder: (context, index) {
        final todo = activeTodos[index];
        return _buildTodoCard(todo);
      },
    );
  }

  Widget _buildTodoCard(Quest quest) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppColors.borderLight,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 4,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 4,
            height: 40,
            decoration: BoxDecoration(
              color: _getDifficultyColor(quest.difficulty),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  quest.title,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(
                  _getDifficultyLabel(quest.difficulty),
                  style: TextStyle(
                    fontSize: 12,
                    color: _getDifficultyColor(quest.difficulty),
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: AppColors.accentPastel.withOpacity(0.1),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Text(
              '+10',
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: AppColors.accentPastel,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Color _getDifficultyColor(Difficulty difficulty) {
    switch (difficulty) {
      case Difficulty.easy:
        return AppColors.statusSuccess;
      case Difficulty.normal:
        return AppColors.primaryPastel;
      case Difficulty.hard:
        return AppColors.highlightPink;
    }
  }

  String _getDifficultyLabel(Difficulty difficulty) {
    switch (difficulty) {
      case Difficulty.easy:
        return '쉬움';
      case Difficulty.normal:
        return '보통';
      case Difficulty.hard:
        return '어려움';
    }
  }

  String _getRouteName(int index) {
    switch (index) {
      case 1:
        return '/todos';
      case 2:
        return '/timer';
      case 3:
        return '/calendar';
      case 4:
        return '/menu';
      default:
        return '/';
    }
  }
}
