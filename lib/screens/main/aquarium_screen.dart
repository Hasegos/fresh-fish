import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:math';
import '../../providers/user_data_provider.dart';
import '../../models/user_data_model.dart';
import '../../models/fish_model.dart';
import '../../models/quest_model.dart';
import '../../theme/app_colors.dart';

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

            ],
          );
        },
      ),
    );
  }

  Widget _buildAquariumSection(BuildContext context, UserData userData) {
    final fish = userData.fish;
    final placedDecorations = userData.decorations;
    final decorationMap = <String, dynamic>{
      'seaweed1': {'icon': '🌿', 'name': '갈조류'},
      'seaweed2': {'icon': '🪴', 'name': '초록 해초'},
      'kelp': {'icon': '🌱', 'name': '다시마'},
      'kelp_forest': {'icon': '🌲', 'name': '다시마 숲'},
      'small_rock': {'icon': '🪨', 'name': '작은 돌'},
      'big_rock': {'icon': '🗿', 'name': '큰 바위'},
      'coral_pink': {'icon': '🪸', 'name': '핑크 산호'},
      'coral_red': {'icon': '🦞', 'name': '빨간 산호'},
      'shell': {'icon': '🐚', 'name': '조개껍데기'},
      'starfish': {'icon': '⭐', 'name': '불가사리'},
      'starfish_big': {'icon': '🌟', 'name': '큰 불가사리'},
      'treasure': {'icon': '💎', 'name': '보물상자'},
      'anchor': {'icon': '⚓', 'name': '앵커'},
      'castle': {'icon': '🏰', 'name': '해저 성'},
    };

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

          // Aquarium with animated fish and decorations
          Center(
            child: GestureDetector(
              onTap: _onFishTapped,
              child: _AquariumWidget(
                width: 280,
                height: 200,
                fish: fish,
                fishPosition: _fishPosition,
                placedDecorations: placedDecorations,
                decorationMap: decorationMap,
                onFishTap: _onFishTapped,
                showMessage: _showMessage,
                message: _displayedMessage ?? "",
                onDecorationPositionChanged: (placedDecoration, newX, newY) {
                  final provider = context.read<UserDataProvider>();
                  provider.updateUserData((data) {
                    final updatedDecorations = data.decorations.map((d) {
                      if (d.decorationId == placedDecoration.decorationId) {
                        return d.copyWith(x: newX, y: newY);
                      }
                      return d;
                    }).toList();
                    return data.copyWith(decorations: updatedDecorations);
                  });
                },
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
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      itemCount: activeTodos.length,
      itemBuilder: (context, index) {
        final todo = activeTodos[index];
        return _buildTodoCard(todo);
      },
    );
  }

  Widget _buildTodoCard(Quest quest) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppColors.borderLight,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 4,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 4,
            height: 36,
            decoration: BoxDecoration(
              color: _getDifficultyColor(quest.difficulty),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(width: 10),
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
              color: AppColors.accentPastel.withValues(alpha: 0.1),
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
}

// ============ 수족관 위젯 (장식 드래그 포함) ============
class _AquariumWidget extends StatefulWidget {
  final double width;
  final double height;
  final Fish fish;
  final Offset fishPosition;
  final List<PlacedDecoration> placedDecorations;
  final Map<String, dynamic> decorationMap;
  final VoidCallback onFishTap;
  final bool showMessage;
  final String message;
  final Function(PlacedDecoration, double, double) onDecorationPositionChanged;

  const _AquariumWidget({
    required this.width,
    required this.height,
    required this.fish,
    required this.fishPosition,
    required this.placedDecorations,
    required this.decorationMap,
    required this.onFishTap,
    required this.showMessage,
    required this.message,
    required this.onDecorationPositionChanged,
  });

  @override
  State<_AquariumWidget> createState() => _AquariumWidgetState();
}

class _AquariumWidgetState extends State<_AquariumWidget> {
  late Map<String, Offset> decorationOffsets;

  @override
  void initState() {
    super.initState();
    _initializeOffsets();
  }

  void _initializeOffsets() {
    decorationOffsets = {};
    for (final placed in widget.placedDecorations) {
      decorationOffsets[placed.decorationId] = 
          Offset(placed.x * widget.width, placed.y * widget.height);
    }
  }

  @override
  void didUpdateWidget(_AquariumWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.placedDecorations.length != widget.placedDecorations.length) {
      _initializeOffsets();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: [
        // 수족관 배경
        Container(
          width: widget.width,
          height: widget.height,
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.3),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: AppColors.primaryPastel.withValues(alpha: 0.3),
              width: 2,
            ),
          ),
        ),

        // 드래그 가능한 장식들
        ...widget.placedDecorations.map((placed) {
          final icon = widget.decorationMap[placed.decorationId]?['icon'] ?? '🎁';
          final offset = decorationOffsets[placed.decorationId] ?? 
              Offset(placed.x * widget.width, placed.y * widget.height);

          return Positioned(
            left: offset.dx,
            top: offset.dy,
            child: GestureDetector(
              onPanUpdate: (details) {
                // 현재 저장된 offset 값에서 새 위치 계산
                final currentOffset = decorationOffsets[placed.decorationId] ?? offset;
                final newOffset = currentOffset + details.delta;
                final clampedX = newOffset.dx.clamp(0.0, widget.width);
                final clampedY = newOffset.dy.clamp(0.0, widget.height);
                
                // 실시간으로 부드럽게 업데이트
                setState(() {
                  decorationOffsets[placed.decorationId] = Offset(clampedX, clampedY);
                });
              },
              onPanEnd: (details) {
                // 드래그 종료 후 데이터 저장
                final finalOffset = decorationOffsets[placed.decorationId]!;
                widget.onDecorationPositionChanged(
                  placed,
                  finalOffset.dx / widget.width,
                  finalOffset.dy / widget.height,
                );
              },
              child: Transform.translate(
                offset: Offset(-12, -12), // 중심 정렬
                child: MouseRegion(
                  cursor: SystemMouseCursors.grab,
                  child: Text(
                    icon,
                    style: const TextStyle(fontSize: 24),
                  ),
                ),
              ),
            ),
          );
        }).toList(),

        // 물고기
        Positioned(
          left: widget.fishPosition.dx,
          top: widget.fishPosition.dy,
          child: GestureDetector(
            onTap: widget.onFishTap,
            child: Text(
              widget.fish.type.emoji,
              style: const TextStyle(fontSize: 60),
            ),
          ),
        ),

        // 메시지 버블
        if (widget.showMessage)
          Positioned(
            top: 20,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.1),
                    blurRadius: 8,
                  ),
                ],
              ),
              child: Text(
                widget.message,
                style: const TextStyle(
                  fontSize: 12,
                  color: AppColors.textPrimary,
                ),
              ),
            ),
          ),
      ],
    );
  }
}
