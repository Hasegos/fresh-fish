import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:math';
import '../../providers/user_data_provider.dart';
import '../../models/user_data_model.dart';
import '../../models/fish_model.dart';
import '../../models/quest_model.dart';
import '../../theme/app_colors.dart';
import '../../widgets/habit_progress_section.dart';
import '../../data/decorations.dart';

/// 메인 어항 화면 - 새로운 아키텍처
class AquariumScreen extends StatefulWidget {
  final Function(int)? onNavChanged;

  const AquariumScreen({super.key, this.onNavChanged});

  @override
  State<AquariumScreen> createState() => _AquariumScreenState();
}

class _AquariumScreenState extends State<AquariumScreen>
    with TickerProviderStateMixin {
  late AnimationController _positionController;
  late Offset _fishPosition;
  late Offset _targetPosition;
  String? _displayedMessage = null;
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
                      color: Colors.white.withValues(alpha: 0.3),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: AppColors.primaryPastel.withValues(alpha: 0.3),
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

                  // 배치된 장식들 (읽기 전용 - 드래그 불가능)
                  ...userData.decorations.map((decoration) {
                    final decoData = availableDecorations.firstWhere(
                      (d) => d.id == decoration.decorationId,
                      orElse: () => availableDecorations.first,
                    );
                    return Positioned(
                      left: decoration.x,
                      top: decoration.y,
                      child: Tooltip(
                        message: '장식 관리에서 이동/삭제 가능',
                        child: Text(
                          decoData.icon,
                          style: const TextStyle(fontSize: 30),
                        ),
                      ),
                    );
                  }).toList(),

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
            color: AppColors.highlightPink.withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: AppColors.highlightPink.withValues(alpha: 0.3),
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
            color: Colors.black.withValues(alpha: 0.1),
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
    final todayQuests = userData.quests
        .where((quest) => quest.date == userData.currentDate)
        .toList();

    return Container(
      color: AppColors.background,
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
        child: HabitProgressSection(
          todayQuests: todayQuests,
          todos: userData.todos,
          onQuestToggle: (questId) =>
              context.read<UserDataProvider>().completeQuestById(questId),
        ),
      ),
    );
  }
}
