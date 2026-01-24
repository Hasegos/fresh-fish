import 'dart:math';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/app_provider.dart';
import '../../models/fish_model.dart';
// UserData 모델이 정의된 파일도 임포트해야 합니다.
// import '../../models/user_data.dart';

/// 수족관 화면
class AquariumScreen extends StatelessWidget {
  const AquariumScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFF1A3A52), Color(0xFF0D1B2A)],
        ),
      ),
      child: SafeArea(
        child: Consumer<AppProvider>(
          builder: (context, provider, child) {
            final userData = provider.userData;
            if (userData == null) {
              return const Center(child: Text('데이터 없음', style: TextStyle(color: Colors.white)));
            }

            final fish = userData.fish;
            // [How] fish 객체를 전달하여 현재 성장 단계를 계산합니다.
            final stage = _getGrowthStage(fish);

            return Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  _buildHeader(userData),
                  const SizedBox(height: 24),
                  Expanded(
                    child: _AquariumAnimation(stage: stage, fish: fish),
                  ),
                  const SizedBox(height: 24),
                  _buildStats(fish, userData),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  // [How] userData에 dynamic 또는 정확한 타입을 명시합니다.
  Widget _buildHeader(dynamic userData) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const Text('My Aquarium', style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.white)),
        _buildGoldDisplay(userData.gold.toString()),
      ],
    );
  }

  Widget _buildGoldDisplay(String gold) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(color: const Color(0xFF1E2A3A), borderRadius: BorderRadius.circular(20)),
      child: Row(
        children: [
          const Icon(Icons.monetization_on, color: Color(0xFFFFD700), size: 16),
          const SizedBox(width: 4),
          Text('${gold}G', style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Color(0xFFFFD700))),
        ],
      ),
    );
  }

  Widget _buildStats(dynamic fish, dynamic userData) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(color: const Color(0xFF1E2A3A), borderRadius: BorderRadius.circular(16)),
      child: Column(
        children: [
          _buildStatBar(
            label: 'HP',
            value: fish.hp as int, // [How] dynamic을 int로 명시적 형변환
            maxValue: fish.maxHp as int,
            color: _getHpColor(fish.hp as int),
          ),
          const SizedBox(height: 16),
          _buildStatBar(
            label: 'EXP',
            value: fish.exp as int,
            maxValue: 100,
            color: const Color(0xFF4FC3F7),
          ),
          const SizedBox(height: 16),
          _buildStatBar(
            label: '수질',
            value: userData.waterQuality as int,
            maxValue: 100,
            color: Colors.blue,
          ),
        ],
      ),
    );
  }

  Widget _buildStatBar({required String label, required int value, required int maxValue, required Color color}) {
    final progress = (value / maxValue).clamp(0.0, 1.0);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.white)),
            Text('$value/$maxValue', style: const TextStyle(fontSize: 14, color: Colors.white70)),
          ],
        ),
        const SizedBox(height: 8),
        LinearProgressIndicator(value: progress, backgroundColor: Colors.white10, valueColor: AlwaysStoppedAnimation<Color>(color), minHeight: 8),
      ],
    );
  }

  GrowthStage _getGrowthStage(dynamic fish) {
    if (fish.eggHatchedAt == null) return GrowthStage.adult;

    // [Why] 현재 시간과 부화 시간의 차이를 계산하여 성장 단계를 결정합니다.
    // 수식: $$ \text{hours} = \frac{\text{currentTime} - \text{hatchedTime}}{1000 \text{ms} \times 60 \text{s} \times 60 \text{m}} $$
    final now = DateTime.now().millisecondsSinceEpoch;
    final elapsed = now - (fish.eggHatchedAt as int);
    final hours = elapsed / (1000 * 60 * 60);

    if (hours < 24) return GrowthStage.egg;
    if (hours < 48) return GrowthStage.juvenile;
    return GrowthStage.adult;
  }

  Color _getHpColor(int hp) {
    if (hp > 60) return Colors.green;
    if (hp > 30) return Colors.orange;
    return Colors.red;
  }
}

class _AquariumAnimation extends StatefulWidget {
  final GrowthStage stage;
  final dynamic fish;

  const _AquariumAnimation({
    Key? key,
    required this.stage,
    required this.fish,
  }) : super(key: key);

  @override
  State<_AquariumAnimation> createState() => _AquariumAnimationState();
}

class _AquariumAnimationState extends State<_AquariumAnimation> {
  final Random _random = Random();
  double _fishX = 0.0;
  double _fishY = 0.0;

  @override
  void initState() {
    super.initState();
    _startFishAnimation();
  }

  void _startFishAnimation() {
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) {
        setState(() {
          _fishX = _random.nextDouble() * MediaQuery.of(context).size.width * 0.8;
          _fishY = _random.nextDouble() * MediaQuery.of(context).size.height * 0.4;
        });
        _startFishAnimation();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Container(
          decoration: BoxDecoration(
            color: const Color(0xFF1E2A3A).withOpacity(0.5),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: const Color(0xFF4FC3F7).withOpacity(0.3), width: 2),
          ),
        ),
        AnimatedPositioned(
          duration: const Duration(seconds: 2),
          curve: Curves.easeInOut,
          left: _fishX,
          top: _fishY,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                _getFishEmoji(widget.stage),
                style: const TextStyle(fontSize: 120),
              ),
              const SizedBox(height: 16),
              Text(
                '레벨 ${widget.fish.level}',
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  String _getFishEmoji(GrowthStage stage) {
    switch (stage) {
      case GrowthStage.egg:
        return '🥚';
      case GrowthStage.juvenile:
        return '🐟';
      case GrowthStage.adult:
        return '🐠';
    }
  }
}