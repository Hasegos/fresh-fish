import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../theme/app_colors.dart';
import '../../models/fish_model.dart';
import '../../providers/app_provider.dart';

/// 알 선택 화면
/// 유저가 처음 앱을 시작할 때 키울 물고기를 고르는 화면입니다.
class EggSelectionScreen extends StatefulWidget {
  final List<String> selectedCategories;
  final Function(FishType)? onComplete;

  const EggSelectionScreen({
    Key? key,
    required this.selectedCategories,
    this.onComplete,
  }) : super(key: key);

  @override
  State<EggSelectionScreen> createState() => _EggSelectionScreenState();
}

class _EggSelectionScreenState extends State<EggSelectionScreen> {
  FishType? _selectedFish; // 선택된 물고기 타입
  bool _isCreating = false; // 생성 중 로딩 상태

  // 각 물고기 타입별 상세 데이터 정의
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
    FishType.tropical: {
      'name': '열대어',
      'emoji': '🐠',
      'color': const Color(0xFFFF6B9D),
      'description': '화려한 색상의\n열대 물고기',
    },
    FishType.clownfish: {
      'name': '니모',
      'emoji': '🐡',
      'color': const Color(0xFFFF8C00),
      'description': '귀엽고 사교적인\n니모 친구',
    },
    FishType.dolphin: {
      'name': '돌고래',
      'emoji': '🐬',
      'color': const Color(0xFF00CED1),
      'description': '영리하고 빠른\n바다의 천재',
    },
  };

  /// [핵심 로직] 사용자 생성 및 다음 단계 진행
  Future<void> _createUser() async {
    if (_selectedFish == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('물고기를 선택해주세요'),
          backgroundColor: AppColors.highlightPink,
        ),
      );
      return;
    }

    setState(() => _isCreating = true);

    try {
      // 선택된 물고기 정보를 onComplete 콜백으로 전달
      // OnboardingFlow가 이를 받아 UserData를 생성함
      widget.onComplete?.call(_selectedFish!);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('오류 발생: $e')),
        );
        setState(() => _isCreating = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            // Top 45% - Aquarium Section (Stack)
            SizedBox(
              height: MediaQuery.of(context).size.height * 0.45,
              child: Stack(
                children: [
                  // Aquarium background/content here
                  Container(
                    color: Colors.blueAccent.withOpacity(0.2),
                  ),
                ],
              ),
            ),

            // Bottom 55% - Task List Section
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    // 헤더 (진행도 표시)
                    Padding(
                      padding: const EdgeInsets.all(16.0),
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
                          // 진행도 표시
                          ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: LinearProgressIndicator(
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
                    ListView.builder(
                      shrinkWrap: true,
                      physics: NeverScrollableScrollPhysics(),
                      padding: const EdgeInsets.all(16),
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

                    // 버튼
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
                        ),
                        child: _isCreating
                            ? const SizedBox(
                                height: 24,
                                width: 24,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor:
                                      AlwaysStoppedAnimation<Color>(Colors.white),
                                ),
                              )
                            : const Text(
                                '선택 완료',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.white,
                                ),
                              ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
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
          decoration: BoxDecoration(
            color: isSelected ? color.withOpacity(0.12) : AppColors.surface,
            border: Border.all(
              color: isSelected ? color : AppColors.borderLight,
              width: 2,
            ),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Row(
            children: [
              // 물고기 이모지
              Text(
                emoji,
                style: const TextStyle(fontSize: 60),
              ),
              const SizedBox(width: 20),

              // 물고기 설명 텍스트
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name,
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: isSelected ? color : AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      description,
                      style: const TextStyle(
                        fontSize: 14,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),

              // 선택 표시
              Padding(
                padding: const EdgeInsets.only(right: 16.0),
                child: isSelected
                    ? Icon(
                        Icons.check_circle,
                        color: color,
                        size: 32,
                      )
                    : Icon(
                        Icons.circle_outlined,
                        color: AppColors.borderMedium,
                        size: 32,
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
