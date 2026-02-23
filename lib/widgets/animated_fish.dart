import 'dart:math';
import 'package:flutter/material.dart';
import '../models/models.dart';
import '../utils/growth_utils.dart';
import '../utils/level_utils.dart';
import 'pixel_fish.dart';

/// 애니메이션이 있는 물고기 위젯
class AnimatedFish extends StatefulWidget {
  final FishType fishType;
  final int level;
  final double scale;
  final int waterQuality; // 0-100
  final int? eggHatchedAt;
  final VoidCallback? onTap;

  const AnimatedFish({
    Key? key,
    required this.fishType,
    required this.level,
    this.scale = 1.0,
    this.waterQuality = 50,
    this.eggHatchedAt,
    this.onTap,
  }) : super(key: key);

  @override
  State<AnimatedFish> createState() => _AnimatedFishState();
}

class _AnimatedFishState extends State<AnimatedFish>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  Offset _position = const Offset(0.5, 0.5); // 0-1 범위의 정규화된 위치
  bool _isFacingRight = true;
  String? _message;
  GrowthStage _growthStage = GrowthStage.adult;

  @override
  void initState() {
    super.initState();
    _growthStage = GrowthUtils.getGrowthStage(
      Fish(
        id: '',
        type: widget.fishType,
        level: widget.level,
        exp: 0,
        hp: 100,
        maxHp: 100,
        eggHatchedAt: widget.eggHatchedAt,
      ),
    );

    _controller = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    )..repeat();

    // 랜덤 수영 움직임
    _startSwimming();

    // 성장 단계 업데이트 (1분마다)
    _updateGrowthStage();
  }

  void _startSwimming() {
    Future.delayed(const Duration(seconds: 3), () {
      if (mounted) {
        setState(() {
          final random = Random();
          _position = Offset(
            random.nextDouble() * 0.6 + 0.2, // 20-80%
            random.nextDouble() * 0.4 + 0.3, // 30-70%
          );
          // 방향 전환
          if (_position.dx > 0.5) {
            _isFacingRight = true;
          } else {
            _isFacingRight = false;
          }
        });
        _startSwimming();
      }
    });
  }

  void _updateGrowthStage() {
    Future.delayed(const Duration(minutes: 1), () {
      if (mounted) {
        setState(() {
          _growthStage = GrowthUtils.getGrowthStage(
            Fish(
              id: '',
              type: widget.fishType,
              level: widget.level,
              exp: 0,
              hp: 100,
              maxHp: 100,
              eggHatchedAt: widget.eggHatchedAt,
            ),
          );
        });
        _updateGrowthStage();
      }
    });
  }

  void _handleFishTap() {
    final remainingTime = widget.eggHatchedAt != null
        ? GrowthUtils.getRemainingGrowthTime(
            Fish(
              id: '',
              type: widget.fishType,
              level: widget.level,
              exp: 0,
              hp: 100,
              maxHp: 100,
              eggHatchedAt: widget.eggHatchedAt,
            ),
          )
        : 0;

    if (remainingTime > 0) {
      // 아직 성장 중
      setState(() {
        _message =
            '아직 성장 중이에요! ${GrowthUtils.formatRemainingTime(remainingTime)} 남았어요 🥚';
      });
    } else {
      // 완전히 성장함 - 수질 메시지 표시
      final messages = _getFishMessages(widget.waterQuality);
      final random = Random();
      setState(() {
        _message = messages[random.nextInt(messages.length)];
      });
    }

    // 3초 후 메시지 숨기기
    Future.delayed(const Duration(seconds: 3), () {
      if (mounted) {
        setState(() {
          _message = null;
        });
      }
    });

    widget.onTap?.call();
  }

  List<String> _getFishMessages(int waterQuality) {
    if (waterQuality >= 75) {
      return [
        '오늘도 최고예요! 🌟',
        '수조가 너무 깨끗해서 행복해요! ✨',
        '당신과 함께라서 정말 좋아요! 💙',
        '완벽한 환경이에요! 🎉',
        '계속 이렇게만 해주세요! 😊',
      ];
    } else if (waterQuality >= 50) {
      return [
        '오늘 운동은 하셨나요? 🏃',
        '수조가 괜찮아요 ✨',
        '퀘스트를 완료하면 저도 배부를 거예요 🍽️',
        '함께 성장해요! 💪',
        '오늘도 화이팅! 🎉',
      ];
    } else if (waterQuality >= 25) {
      return [
        '조금 기운이 없어요... 😔',
        '물이 조금 탁해요 💧',
        '퀘스트를 완료해주시면 좋겠어요 🙏',
        '힘을 내볼게요... 💪',
        '같이 노력해봐요 🌱',
      ];
    } else {
      return [
        '많이 힘들어요... 😢',
        '수조가 너무 더러워요 💔',
        '도와주세요... 🆘',
        '퀘스트를 완료해주세요 🙏',
        '포기하지 말아요! 💪',
      ];
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final evolutionInfo = getEvolutionInfo(widget.level);
    final baseFishSize = 64.0;
    final fishSize = baseFishSize * widget.scale;
    final screenSize = MediaQuery.of(context).size;

    return Stack(
      children: [
        // 물고기
        Positioned(
          left: _position.dx * screenSize.width,
          top: _position.dy * screenSize.height,
          child: GestureDetector(
            onTap: _handleFishTap,
            child: AnimatedBuilder(
              animation: _controller,
              builder: (context, child) {
                return Transform.translate(
                  offset: Offset(0, sin(_controller.value * 2 * pi) * 5),
                  child: Transform.scale(
                    scale: _isFacingRight ? 1.0 : -1.0,
                    alignment: Alignment.center,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // 진화 단계 배지
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [
                                Color(0xFF9C27B0),
                                Color(0xFFE91E63),
                              ],
                            ),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: Colors.white,
                              width: 2,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.3),
                                blurRadius: 4,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Text(
                            'Lv.${widget.level} ${evolutionInfo.emoji}',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        const SizedBox(height: 4),
                        // 픽셀 아트 물고기
                        PixelFish(
                          fishType: widget.fishType,
                          growthStage: _growthStage,
                          size: fishSize,
                          level: widget.level,
                        ),
                        const SizedBox(height: 4),
                        // 진화 단계 이름
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFF00BCD4).withOpacity(0.9),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            evolutionInfo.displayName,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ),

        // 말풍선
        if (_message != null)
          Positioned(
            left: _position.dx * screenSize.width,
            top: (_position.dy - 0.15) * screenSize.height,
            child: Transform.translate(
              offset: const Offset(-100, 0),
              child: Container(
                constraints: const BoxConstraints(maxWidth: 200),
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.95),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: const Color(0xFF4FC3F7),
                    width: 2,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.2),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Text(
                  _message!,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: Color(0xFF2E3440),
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
          ),
      ],
    );
  }
}
