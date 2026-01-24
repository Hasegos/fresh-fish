import 'dart:math';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/app_provider.dart';
import '../../models/fish_model.dart';

/// 수족관 화면
class AquariumScreen extends StatelessWidget {
  const AquariumScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFFE0F2F1), Color(0xFFE3F2FD)],
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
                  ],
                ),
              ),
              Expanded(
                flex: 55,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Padding(
                      padding: EdgeInsets.all(16.0),
                      child: Text(
                        "My Today's Focus",
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                    ),
                    Expanded(
                      child: Consumer<AppProvider>(
                        builder: (context, provider, child) {
                          final activeToDos = provider.userData?.todos.where((todo) => todo.isActive).toList() ?? [];

                          if (activeToDos.isEmpty) {
                            return const Center(
                              child: Text(
                                'No active tasks for today.',
                                style: TextStyle(color: Colors.black54, fontSize: 16),
                              ),
                            );
                          }

                          return ListView.builder(
                            itemCount: activeToDos.length,
                            itemBuilder: (context, index) {
                              final todo = activeToDos[index];
                              return Card(
                                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                elevation: 4,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Container(
                                  padding: const EdgeInsets.all(16),
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      colors: [Color(0xFFE3F2FD), Color(0xFFBBDEFB)],
                                      begin: Alignment.topLeft,
                                      end: Alignment.bottomRight,
                                    ),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        todo.title,
                                        style: const TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.black87,
                                        ),
                                      ),
                                      const SizedBox(height: 8),
                                      Text(
                                        todo.description,
                                        style: const TextStyle(
                                          fontSize: 14,
                                          color: Colors.black54,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            },
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.check_circle),
            label: 'To-Do List',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.timer),
            label: 'Timer',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.calendar_today),
            label: 'Calendar',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.store),
            label: 'Store',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.menu),
            label: 'Menu',
          ),
        ],
        currentIndex: 0, // Default selected index
        selectedItemColor: const Color(0xFFB3E5FC), // Light pastel blue
        unselectedItemColor: Colors.grey,
        onTap: (index) {
          // Handle navigation logic here
        },
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
            color: const Color(0xFF1E2A3A).withValues(alpha: 0.5),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: const Color(0xFF4FC3F7).withValues(alpha: 0.3), width: 2),
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