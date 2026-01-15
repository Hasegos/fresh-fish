import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/fish_model.dart';
import '../../providers/app_provider.dart';
import '../../services/storage_service.dart';

/// 알 선택 화면
class EggSelectionScreen extends StatefulWidget {
  final List<String> selectedCategories;

  const EggSelectionScreen({
    Key? key,
    required this.selectedCategories,
  }) : super(key: key);

  @override
  State<EggSelectionScreen> createState() => _EggSelectionScreenState();
}

class _EggSelectionScreenState extends State<EggSelectionScreen> {
  FishType? _selectedFish;
  bool _isCreating = false;

  final Map<FishType, Map<String, dynamic>> _fishData = {
    FishType.goldfish: {
      'name': '금붕어',
      'emoji': '🟡',
      'color': const Color(0xFFFFD700),
      'description': '행운과 부를 가져다주는\n황금빛 물고기',
    },
    FishType.bluefish: {
      'name': '파랑이',
      'emoji': '🔵',
      'color': const Color(0xFF4169E1),
      'description': '깊은 바다의 지혜를\n품은 물고기',
    },
    FishType.redfish: {
      'name': '빨강이',
      'emoji': '🔴',
      'color': const Color(0xFFDC143C),
      'description': '열정과 용기가 넘치는\n붉은 물고기',
    },
  };

  Future<void> _createUser() async {
    if (_selectedFish == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('물고기를 선택해주세요'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() => _isCreating = true);

    try {
      final storage = StorageService();
      final userData = storage.createInitialUser(
        _selectedFish!,
        widget.selectedCategories,
      );

      await context.read<AppProvider>().saveUserData(userData);
    } catch (e) {
      if (!mounted) return;
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('오류가 발생했습니다: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _isCreating = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFF1A3A52),
              Color(0xFF0D1B2A),
            ],
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              children: [
                const SizedBox(height: 24),
                
                // 제목
                const Text(
                  '🥚',
                  style: TextStyle(fontSize: 80),
                ),
                const SizedBox(height: 24),
                const Text(
                  '물고기 알 선택',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  '키우고 싶은 물고기를 선택하세요\n72시간에 걸쳐 성장합니다',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.white70,
                    height: 1.5,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 32),
                
                // 물고기 목록
                Expanded(
                  child: ListView.builder(
                    itemCount: FishType.values.length,
                    itemBuilder: (context, index) {
                      final fishType = FishType.values[index];
                      final data = _fishData[fishType]!;
                      final isSelected = _selectedFish == fishType;
                      
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 16.0),
                        child: _buildFishCard(
                          fishType: fishType,
                          name: data['name'],
                          emoji: data['emoji'],
                          color: data['color'],
                          description: data['description'],
                          isSelected: isSelected,
                        ),
                      );
                    },
                  ),
                ),
                
                // 시작 버튼
                if (_isCreating)
                  const CircularProgressIndicator(
                    color: Color(0xFF4FC3F7),
                  )
                else
                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: ElevatedButton(
                      onPressed: _createUser,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF4FC3F7),
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      child: const Text(
                        '시작하기',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFishCard({
    required FishType fishType,
    required String name,
    required String emoji,
    required Color color,
    required String description,
    required bool isSelected,
  }) {
    return GestureDetector(
      onTap: () {
        setState(() => _selectedFish = fishType);
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: isSelected
              ? color.withOpacity(0.2)
              : const Color(0xFF1E2A3A),
          border: Border.all(
            color: isSelected ? color : Colors.transparent,
            width: 2,
          ),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          children: [
            // 이모지
            Text(
              emoji,
              style: const TextStyle(fontSize: 60),
            ),
            const SizedBox(width: 20),
            
            // 정보
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: isSelected ? color : Colors.white,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    description,
                    style: const TextStyle(
                      fontSize: 14,
                      color: Colors.white70,
                    ),
                  ),
                ],
              ),
            ),
            
            // 선택 표시
            if (isSelected)
              Icon(
                Icons.check_circle,
                color: color,
                size: 32,
              ),
          ],
        ),
      ),
    );
  }
}
