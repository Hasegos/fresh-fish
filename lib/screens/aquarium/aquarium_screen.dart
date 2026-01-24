import 'dart:math';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/app_provider.dart';
import '../../models/fish_model.dart';

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
          colors: [Color(0xFFE0F2F1), Color(0xFFE3F2FD)], // Updated gradient
        ),
      ),
      child: SafeArea(
        child: Column(
          children: [
            Expanded(
              flex: 45,
              child: Stack(
                children: [
                  Consumer<AppProvider>(
                    builder: (context, provider, child) {
                      final userData = provider.userData;
                      if (userData == null) {
                        return const Center(
                          child: Text('데이터 없음', style: TextStyle(color: Colors.white)),
                        );
                      }

                      final fish = userData.fish;
                      final stage = _getGrowthStage(fish);

                      return _AquariumAnimation(stage: stage, fish: fish);
                    },
                  ),
                  Consumer<AppProvider>(
                    builder: (context, provider, child) {
                      final userData = provider.userData;
                      if (userData == null) return const SizedBox.shrink();

                      return _buildHeader(userData);
                    },
                  ),
                ],
              ),
            ),
            Expanded(
              flex: 55,
              child: Container(
                color: Colors.white, // Placeholder for Task List section
                child: const Center(
                  child: Text('Task List Placeholder'),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  GrowthStage _getGrowthStage(dynamic fish) {
    if (fish.eggHatchedAt == null) return GrowthStage.adult;

    final now = DateTime.now().millisecondsSinceEpoch;
    final elapsed = now - (fish.eggHatchedAt as int);
    final hours = elapsed / (1000 * 60 * 60);

    if (hours < 24) return GrowthStage.egg;
    if (hours < 48) return GrowthStage.juvenile;
    return GrowthStage.adult;
  }

  Widget _buildHeader(dynamic userData) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.pets, color: Colors.blueAccent, size: 32), // Fish icon
                const SizedBox(width: 8),
                Text(
                  '레벨 ${userData.fish.level}',
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            LinearProgressIndicator(
              value: userData.fish.exp / 100,
              backgroundColor: Colors.grey[300],
              valueColor: const AlwaysStoppedAnimation<Color>(Colors.blueAccent),
              minHeight: 8,
            ),
          ],
        ),
        const Spacer(),
        _buildGoldDisplay(userData.gold.toString()),
      ],
    );
  }

  Widget _buildGoldDisplay(String gold) {
    return Row(
      children: [
        const Icon(Icons.monetization_on, color: Colors.amber, size: 28),
        const SizedBox(width: 4),
        Text(
          gold,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
        ),
      ],
    );
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