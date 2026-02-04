import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';
import '../../models/fish_model.dart'; // FishType 정의가 포함된 파일

class EggSelectionScreen extends StatefulWidget {
  final List<String> selectedCategories;
  final Function(FishType, String)? onComplete; // (FishType, eggColor)

  const EggSelectionScreen({
    Key? key,
    required this.selectedCategories,
    this.onComplete,
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
    // ... 나머지 데이터 유지
  };

  Future<void> _createUser() async {
    if (_selectedFish == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('물고기를 선택해주세요'),
          backgroundColor: Colors.pinkAccent,
        ),
      );
      return;
    }
    setState(() => _isCreating = true);
    try {
      // 선택된 물고기의 알 색상 가져오기
      final eggColor = _fishData[_selectedFish]!['emoji'] as String;
      widget.onComplete?.call(_selectedFish!, eggColor);
    } catch (e) {
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
            colors: [Color(0xFFE0F2F1), Color(0xFFE3F2FD)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Top-left HUD
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  children: [
                    // [수정된 부분] Icons.fish -> Icons.set_meal 로 변경
                    // Material 아이콘에는 fish가 없어서 가장 비슷한 set_meal(접시 위의 생선) 사용
                    const Icon(Icons.set_meal, color: Colors.blueAccent, size: 32),
                    
                    const SizedBox(width: 8),

                    // Level Bar
                    Expanded(
                      child: LinearProgressIndicator(
                        value: 0.5, // Example value
                        backgroundColor: Colors.white,
                        valueColor: const AlwaysStoppedAnimation<Color>(Colors.blueAccent),
                      ),
                    ),
                    const SizedBox(width: 8),

                    // Coin Text
                    const Text(
                      '100', // Example coin value
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.blueAccent,
                      ),
                    ),
                  ],
                ),
              ),

              // 상단 수조 섹션
              SizedBox(
                height: MediaQuery.of(context).size.height * 0.4,
                child: Stack(
                  children: [
                    Container(
                      width: double.infinity,
                      color: Colors.blueAccent.withOpacity(0.1),
                      child: Center(
                        child: _selectedFish != null
                            ? Text(
                                _fishData[_selectedFish]!['emoji'],
                                style: const TextStyle(fontSize: 80),
                              )
                            : const Text(
                                "물고기를 선택해 주세요",
                                style: TextStyle(
                                  color: Colors.blueGrey,
                                  fontSize: 18,
                                ),
                              ),
                      ),
                    ),
                  ],
                ),
              ),

              // 하단 리스트 섹션
              Expanded(
                child: Column(
                  children: [
                    // 헤더
                    Padding(
                      padding: const EdgeInsets.fromLTRB(20, 20, 20, 10),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            '물고기 선택',
                            style: TextStyle(
                              fontSize: 28,
                              fontWeight: FontWeight.bold,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          const SizedBox(height: 8),
                          const Text(
                            '함께 할 물고기를 선택하세요',
                            style: TextStyle(
                              fontSize: 14,
                              color: AppColors.textSecondary,
                            ),
                          ),
                          const SizedBox(height: 16),
                          ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: const LinearProgressIndicator(
                              value: 0.67,
                              minHeight: 8,
                              backgroundColor: AppColors.borderLight,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                AppColors.primaryPastel,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    // 물고기 선택 리스트
                    Expanded(
                      child: ListView.builder(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 10,
                        ),
                        itemCount: _fishData.length,
                        itemBuilder: (context, index) {
                          final fishType = _fishData.keys.toList()[index];
                          final fishInfo = _fishData[fishType]!;
                          return _buildFishCard(
                            fishType: fishType,
                            name: fishInfo['name'],
                            emoji: fishInfo['emoji'],
                            color: fishInfo['color'],
                            description: fishInfo['description'],
                            isSelected: _selectedFish == fishType,
                          );
                        },
                      ),
                    ),

                    // 하단 버튼
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: ElevatedButton(
                        onPressed: _isCreating ? null : _createUser,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primaryPastel,
                          disabledBackgroundColor: AppColors.textTertiary,
                          minimumSize: const Size(double.infinity, 56),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                          elevation: 2,
                        ),
                        child: _isCreating
                            ? const SizedBox(
                                height: 24,
                                width: 24,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                    Colors.white,
                                  ),
                                ),
                              )
                            : const Text(
                                '선택 완료',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
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
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: GestureDetector(
        onTap: () => setState(() => _selectedFish = fishType),
        child: Container(
          padding: const EdgeInsets.all(16.0),
          decoration: BoxDecoration(
            color: isSelected ? color.withOpacity(0.1) : AppColors.surface,
            border: Border.all(
              color: isSelected ? color : AppColors.borderLight,
              width: 2,
            ),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Row(
            children: [
              // 물고기 이모지
              SizedBox(
                width: 60,
                child: Center(child: Text(emoji, style: const TextStyle(fontSize: 40))),
              ),
              const SizedBox(width: 16),

              // 설명 텍스트
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(name, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: isSelected ? color : AppColors.textPrimary)),
                    const SizedBox(height: 4),
                    Text(description, style: const TextStyle(fontSize: 13, color: AppColors.textSecondary, height: 1.3)),
                  ],
                ),
              ),

              // 라디오 버튼 형태의 아이콘
              Icon(
                isSelected ? Icons.check_circle : Icons.circle_outlined,
                color: isSelected ? color : AppColors.borderMedium,
                size: 28,
              ),
            ],
          ),
        ),
      ),
    );
  }
}